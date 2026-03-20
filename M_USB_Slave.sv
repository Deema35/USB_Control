module M_USB_Slave
#(
	FULL_SPEED = 1'b0,
	SEND_ERROR_BLOCK = 1'b0
)
(
	input wire Low_clk,
	input wire Hi_clk,
	input wire rst,
	
	input wire [7:0] MAX_Packet_Size,
	
	output wire [15:0] SendDataAddr,
	input wire [7:0] SendData,
	output reg [15:0] DescriptorID = 'd0,
	
	output reg SlaveFaill = 1'b0,
	
	input wire Disconnect,
	
	inout tri Dp_Sl,
	inout tri Dm_Sl
);

localparam 	P_OUT = 8'b11100001,
				P_IN = 8'b01101001,
				P_SOF_START_OF_FRAME = 8'b10100101,
				P_SETUP = 8'b00101101,
				P_DATA0 = 8'b11000011,
				P_DATA1 = 8'b01001011,
				P_ACK = 8'b11010010,
				P_NAK = 8'b01011010,
				P_STALL = 8'b00011110;

localparam  REQ_GET_STATUS = 8'd0,
				REQ_CLEAR_FEATURE = 8'd1,
				REQ_SET_FEATURE = 8'd3,
				REQ_SET_ADDRESS = 8'd5,
				REQ_GET_DESCRIPTOR = 8'd6,
				REQ_SET_DESCRIPTOR = 8'd7,
				REQ_GET_CONFIGURATION = 8'd8,
				REQ_SET_CONFIGURATION = 8'd9,
				REQ_GET_INTERFACE = 8'd10,
				REQ_SET_INTERFACE = 8'd11,
				REQ_SYNCH_FRAME = 8'd12;	


reg ChangeAddrWait = 'd0;
reg CommandPipeWait = 1'b0;
reg LasPackedEven = 1'b0;
reg GetData_En_main = 1'b0;
reg SendData_En_main = 1'b0;
reg [15:0] SendPacketLength_main = 'd0;
reg [15:0] DataAddrBace_main = 'd0;
reg [7:0] DataPacketLen = 'd0;


assign (pull1, pull0) Dp_Sl = (Disconnect) ? 1'b0 : (FULL_SPEED) ? 1'b1  : 1'b0;
assign (pull1, pull0) Dm_Sl = (Disconnect) ? 1'b0 : (!FULL_SPEED) ? 1'b1  : 1'b0;

wire CRC16_En = (SendData_En) ? CRC16_En_SendData :
					 (GetData_En) ? CRC16_En_GetData : 1'b0;
					
wire Get_CRC16_Data =   (SendData_En) ? Get_CRC16_Data_SendData : 
								(GetData_En) ? Get_CRC16_Data_GetData : 1'b0;
								
wire [7:0] CRC16_Data = (SendData_En) ? CRC16_Data_SendData : 
								(GetData_En) ?CRC16_Data_GetData : 'd0;
								


wire [15:0] CRC16_Res;
wire CRC16_Valid;

M_CRC16_USB CRC16
(
	.clk(clk),
	.rst(rst),
	
	.Enable(CRC16_En),
	.GetData(Get_CRC16_Data),
	.Data(CRC16_Data),
	.Valid(CRC16_Valid),
	
	.CRC(CRC16_Res)

);

wire GetData_En = (SetAddress_En) ? GetData_En_SetAddress :
						(SendDescriptor_En) ? GetData_En_SendDescriptor :
						(GetRequest_En) ? GetData_En_SetConfig : GetData_En_main;
						
						
wire [7:0] PacketTypeGet;
wire [7:0] GetData;
wire [15:0] CRC16_Get;

wire [15:0] GetAddr;
reg [15:0] GetDataLength = 'd0;
wire GetDataValid;
wire PacketTypeValid;
wire GetDataComlite;
wire GetDataFail;


wire ResiveComplite;
reg [15:0] GetPacketLength_Slave = 'd0;
wire [15:0] GetPacketLength =   (SetAddress_En) ? 'd8 :
											(SendDescriptor_En) ? GetPacketLength_SendDescriptor :
											(GetRequest_En) ? GetPacketLength_GetRequest : GetPacketLength_Slave;
											
wire CRC16_En_GetData;
wire Get_CRC16_Data_GetData;
wire [7:0] CRC16_Data_GetData;
wire  FakeOne;

wire Resiver_En;

wire EndOfPacket = (!Dp_Sl && !Dm_Sl);

wire J_State = (FULL_SPEED) ? (Dp_Sl && !Dm_Sl) : (!Dp_Sl && Dm_Sl);
wire K_State = (FULL_SPEED) ? (!Dp_Sl && Dm_Sl) : (Dp_Sl && !Dm_Sl);

M_GET_DATA
#(
	.DISABLE_WAITE_COUNT(1'b1)
)
 GET_DATA
(
	.clk(clk),
	.rst(rst),
	
	.GetData_En(GetData_En),
	
	.GetDataComlite(GetDataComlite),
	.GetDataFaill(GetDataFail),
	
	.Addr_count(GetAddr),
	
	.PacketTypeGet(PacketTypeGet),
	.Data(GetData),
	.DataValid(GetDataValid),
	.PacketTypeValid(PacketTypeValid),
	
	
	.CRC16_Res(CRC16_Res),
	.CRC16_Get(CRC16_Get),
	
	
	.EndOfPacket(EndOfPacket),
	.K_State(K_State),
	.J_State(J_State),
	
	.CRC16_En(CRC16_En_GetData),
	.CRC16_Valid(CRC16_Valid)
	
	
);



reg [15:0] Mem_ReadAddr = 'd0;
wire [7:0] Mem_ReadData;

M_MEMORY_BUF_CRC16
#(
	.SIZE('d66)
)
 MEMORY_BUF
(
	.clk(clk),
	.we(GetDataValid),
	
	
	.ReadAddr(Mem_ReadAddr),
	.ReadData(Mem_ReadData),
	
	.WriteAddr(GetAddr),
	.WriteData(GetData),
	
	
	.CRC16_GetData(Get_CRC16_Data_GetData),
	.CRC16_Data(CRC16_Data_GetData),
	.CRC16_Get(CRC16_Get)
	
);


wire SendHandshake_En = (SetAddress_En) ? SendHandshake_En_SetAddress :
								(SendDescriptor_En) ? SendHandshake_En_SendDescriptor : 
								(GetRequest_En) ? SendHandshake_En_SetConfig : 1'b0;
wire SendHandshakeComlite;

wire TransferReady;
wire [63:0] DataBuf_Handshake = {56'd0, 8'b11010010};
wire [7:0] TransferState_Handshake;
wire [7:0] TransferLenght_Handshake = 'd7;

M_SEND_TOKEN SEND_HANDSHAKE
(
	.clk(clk),
	.rst(rst),
	
	.SendToken_En(SendHandshake_En),
	
	.TransferReady(TransferReady),
	.State_main(TransferState_Handshake),
	
	.TransferLenght(TransferLenght_Handshake),

	.SendTokenComlite(SendHandshakeComlite)
);

wire SendNAK_En;
wire SendNAKComlite;

wire [63:0] DataBuf_NAK = {56'd0, 8'b01011010};
wire [7:0] TransferState_NAK;
wire [7:0] TransferLenght_NAK = 'd7;


M_SEND_TOKEN SEND_NAK

(
	.clk(clk),
	.rst(rst),
	
	.SendToken_En(SendNAK_En),
	
	.TransferReady(TransferReady),
	.State_main(TransferState_NAK),
	
	.TransferLenght(TransferLenght_NAK),

	.SendTokenComlite(SendNAKComlite)
);

reg [7:0] DataPacketType_main = 'd0;


wire SendData_En =   (SetAddress_En) ? SendData_En_SetAddress :
							(SendDescriptor_En) ? SendData_En_SendDescriptor :
							(GetRequest_En) ? SendData_En_SetConfig : SendData_En_main;
							
wire [15:0] SendPacketLength =   (SetAddress_En) ? SendPacketLength_SetAddress :
											(SendDescriptor_En) ? SendPacketLength_SendDescriptor :
											(GetRequest_En) ? SendPacketLength_SetConfig : SendPacketLength_main;
							
wire [7:0] DataPacketType = (SetAddress_En) ? 8'b01001011 :
						(SendDescriptor_En) ? DataPacketType_SendDescriptor :
						(GetRequest_En) ?  8'b01001011 : DataPacketType_main;
							
wire SendDataComlite;





wire [15:0] DataAddrBace = (SendDescriptor_En) ? DataAddrBace_SendDescriptor : DataAddrBace_main;

wire SendReady;

wire [31:0] DataBuf_Data;
wire [7:0] TransferState_Data;
wire [7:0] TransferLenght_Data;

wire CRC16_En_SendData;
wire Get_CRC16_Data_SendData;
wire [7:0] CRC16_Data_SendData = SendData;
wire TransferReadyMinusOne;

M_SEND_DATA SEND_DATA
(
	.clk(clk),
	.rst(rst),
	
	.SendData_En(SendData_En),
	
	.DataPacketType(DataPacketType),

	.DataAddr(SendDataAddr),		
	.Data(SendData),
	.SendReady(SendReady),
	
	.PacketLength(SendPacketLength),
	.DataAddrBace(DataAddrBace),
	
	.TransferReady(TransferReady),
	.TransferReadyMinusOne( TransferReadyMinusOne),
	.DataBuf(DataBuf_Data),
	.TransferLenght(TransferLenght_Data),
	.State_DataSend(TransferState_Data),
	
	.SendDataComlite(SendDataComlite),
	
	.CRC16_En(CRC16_En_SendData),
	.CRC16_Get_Data(Get_CRC16_Data_SendData),
	.CRC16_Valid(CRC16_Valid),
	.CRC16_Res(CRC16_Res)
	
);

wire [31:0] DataBuf =   (SendHandshake_En) ? DataBuf_Handshake : 
								(SendData_En) ? DataBuf_Data :
								(SendNAK_En) ? DataBuf_NAK : 'd0;
								
wire [7:0] TransferState = (SendHandshake_En) ? TransferState_Handshake : 
									(SendData_En) ? TransferState_Data :
									(SendNAK_En) ? TransferState_NAK : 'd0;
									
wire [7:0] TransferLenght =   (SendHandshake_En) ? TransferLenght_Handshake : 
										(SendData_En) ? TransferLenght_Data : 
										(SendNAK_En) ? TransferLenght_NAK : 'd0;

M_DATA_TRANSFER DATA_TRANSFER
(
	.clk(clk),
	.DataBuf(DataBuf),
	.TransferState(TransferState),
	.TransferLenght(TransferLenght),
	.FullSpeedConnect(FULL_SPEED),
	
	.TransferReady(TransferReady),
	.TransferReadyMinusOne(TransferReadyMinusOne),
	
	.Dp(Dp_Sl),
	.Dm(Dm_Sl)
);

reg SetAddress_En = 1'b0;
wire SetAddressFail;
wire SetAddressComplite;

wire [6:0] DeviceAddr;
wire SendHandshake_En_SetAddress;
wire SendData_En_SetAddress;
wire [15:0] SendPacketLength_SetAddress;
wire GetData_En_SetAddress;

M_SET_ADDRESS SET_ADDRESS
(
	.clk(clk),
	.rst(rst),
	
	.SetAddress_En(SetAddress_En),
	.SetAddressFail(SetAddressFail),
	.SetAddressComplite(SetAddressComplite),
	
	.GetData_En(GetData_En_SetAddress),
	.GetDataComlite(GetDataComlite),
	.GetDataFail(GetDataFail),
	
	.GetDataValid(GetDataValid),
	.PacketTypeValid(PacketTypeValid),
	.GetData(GetData),
	.GetAddr(GetAddr),
	
	.SendHandshake_En(SendHandshake_En_SetAddress),
	.SendHandshakeComlite(SendHandshakeComlite),
	
	.SendData_En(SendData_En_SetAddress),
	.SendDataComlite(SendDataComlite),
	.SendPacketLength(SendPacketLength_SetAddress),
	.PacketTypeGet(PacketTypeGet),
	
	.DeviceAddr(DeviceAddr)
);

reg SendDescriptor_En = 1'b0;
wire SendDescriptorFail;
wire SendDescriptorComplite;

wire [7:0] USB_Data_Resive_State_SendDescriptor;
wire SendHandshake_En_SendDescriptor;
wire SendData_En_SendDescriptor;
wire [15:0] SendPacketLength_SendDescriptor;
wire [7:0] DataPacketType_SendDescriptor;
wire GetData_En_SendDescriptor;

wire [15:0] GetPacketLength_SendDescriptor;
wire [15:0] DataAddrBace_SendDescriptor;

M_GET_REQUEST_WITH_SEND_DATA
#(
	.SEND_ERROR_BLOCK(SEND_ERROR_BLOCK)
) 
GET_REQUEST_WITH_SEND_DATA
(
	.clk(clk),
	.rst(rst),
	
	
	.SendDescriptor_En(SendDescriptor_En),
	.SendDescriptorFail(SendDescriptorFail),
	.SendDescriptorComplite(SendDescriptorComplite),
	
	.GetData_En(GetData_En_SendDescriptor),
	.GetDataComlite(GetDataComlite),
	.GetDataFail(GetDataFail),
	.GetPacketLength(GetPacketLength_SendDescriptor),
	
	.GetDataValid(GetDataValid),
	.GetData(GetData),
	.GetAddr(GetAddr),
	
	.SendHandshake_En(SendHandshake_En_SendDescriptor),
	.SendHandshakeComlite(SendHandshakeComlite),
	
	.SendNAK_En(SendNAK_En),
	.SendNAKComlite(SendNAKComlite),
	
	.SendData_En(SendData_En_SendDescriptor),
	.SendDataComlite(SendDataComlite),
	.SendPacketLength(SendPacketLength_SendDescriptor),
	.DataPacketType(DataPacketType_SendDescriptor),
	.PacketTypeGet(PacketTypeGet),
	.PacketTypeValid(PacketTypeValid),
	.DataAddrBace(DataAddrBace_SendDescriptor),
	
	
	.DescriptorID(DescriptorID),
	
	.DeviceAddr(DeviceAddr),
	
	.MAX_Packet_Size(MAX_Packet_Size)
);





reg GetRequest_En = 1'b0;
wire GetRequestFail;
wire GetRequestComplite;

wire SendHandshake_En_SetConfig;
wire SendData_En_SetConfig;
wire [15:0] SendPacketLength_SetConfig;
wire GetData_En_SetConfig;

reg [7:0] Request = 'd0;

wire [15:0] GetPacketLength_GetRequest;

M_GET_REQUEST GET_REQUEST
(
	.clk(clk),
	.rst(rst),
	
	.GetRequest_En(GetRequest_En),
	.GetRequestFail(GetRequestFail),
	.GetRequestComplite(GetRequestComplite),
	
	.GetData_En(GetData_En_SetConfig),
	.GetDataComlite(GetDataComlite),
	.GetPacketLength_GetRequest(GetPacketLength_GetRequest),
	
	.GetDataValid(GetDataValid),
	.GetData(GetData),
	.GetAddr(GetAddr),
	
	.SendHandshake_En(SendHandshake_En_SetConfig),
	.SendHandshakeComlite(SendHandshakeComlite),
	
	.SendData_En(SendData_En_SetConfig),
	.SendDataComlite(SendDataComlite),
	.SendPacketLength(SendPacketLength_SetConfig),
	.PacketTypeGet(PacketTypeGet),
	.PacketTypeValid(PacketTypeValid),
	
	.Request(Request),
	
	
	.DeviceAddr(DeviceAddr)
);

reg [15:0] Token = 'd0;


wire clk = (FULL_SPEED) ? Hi_clk :  Low_clk;


reg [7:0] USB_Slave_State = 'd0;
reg [7:0] USB_Slave_State_Return = 'd0;

localparam 	S_IDLE = 8'd0,
				S_SET_ADDRESS = 8'd1,
				S_SEND_DEVICE_DESCRIPTOR_01 = 8'd2,
				S_DELAY_00 = 8'd3,
				S_SEND_DEVICE_DESCRIPTOR_02 = 8'd4,
				S_DELAY_01 = 8'd5,
				S_SEND_DEVICE_NAME_01 = 8'd6,
				S_DELAY_02 = 8'd7,
				S_SEND_DEVICE_NAME_02 = 8'd8,
				S_DELAY_03 = 8'd9,
				S_GET_DEVICE_MANUFACTURE_01 = 8'd10,
				S_DELAY_04 = 8'd11,
				S_GET_DEVICE_MANUFACTURE_02 = 8'd12,
				S_DELAY_05 = 8'd13,
				S_GET_DEVICE_CONFIGURATION_01 = 8'd14,
				S_DELAY_06 = 8'd15,
				S_GET_DEVICE_CONFIGURATION_02 = 8'd16,
				S_SET_DEVICE_CONFIG = 8'd17,
				S_GET_DEVICE_HID = 8'd18,
				S_SET_IDLE_HID = 8'd19,
				S_DELAY_07 = 8'd20,
				S_SET_PROTOCOL_HID = 8'd21,
				S_DELAY_08 = 8'd22,
				S_SET_REPORT_HID = 8'd23,
				S_TOKEN_WAITE_01 = 8'd24,
				S_SEND_DATA_01 = 8'd25,
				S_GET_ACK_01 = 8'd26,
				S_DELAY_09 = 8'd27,
				S_TOKEN_WAITE_02 = 8'd28,
				S_SEND_DATA_02 = 8'd29,
				S_GET_ACK_02 = 8'd30,
				S_DELAY_10 = 8'd31,
				S_TOKEN_WAITE_03 = 8'd32,
				S_SEND_DATA_03 = 8'd33,
				S_GET_ACK_03 = 8'd34,
				S_GET_SOF = 8'd35,
				S_GET_SOF_02 = 8'd36,
				
				
				S_FAIL = 8'd254,
				S_END = 8'd255;


always @(posedge clk) 
begin 

	if (rst)
	begin
		USB_Slave_State <= S_IDLE;
		
	end
	else
	begin
		case (USB_Slave_State)
		S_IDLE:
		begin
			USB_Slave_State <= S_SET_ADDRESS;
			
		end
		
		S_SET_ADDRESS:
		begin
			if (SetAddressComplite)
			begin
				SetAddress_En <= 1'b0;
				USB_Slave_State <= S_SEND_DEVICE_DESCRIPTOR_01;
			end
			else if (SetAddressFail)
			begin
				SetAddress_En <= 1'b0;
				USB_Slave_State <= S_FAIL;
			end
			else  SetAddress_En <= 1'b1;
		end
		
		S_SEND_DEVICE_DESCRIPTOR_01:
		begin
			if (SendDescriptorComplite)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_DELAY_00;
			end
			else if (SendDescriptorFail)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_FAIL;
			end
			else 
			begin
				DescriptorID <= 'h01_00; //01 - Device descriptor number 00.
				SendDescriptor_En <= 1'b1;
			end
				
		end
		
		S_DELAY_00: if (!SendDescriptorComplite) USB_Slave_State <= S_SEND_DEVICE_DESCRIPTOR_02;
		
		S_SEND_DEVICE_DESCRIPTOR_02:
		begin
			if (SendDescriptorComplite)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_DELAY_01;
			end
			else if (SendDescriptorFail)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_FAIL;
			end
			else 
			begin
				DescriptorID <= 'h01_00; //01 - Device descriptor number 00.
				SendDescriptor_En <= 1'b1;
			end
				
		end
		
		S_DELAY_01: if (!SendDescriptorComplite) USB_Slave_State <= S_SEND_DEVICE_NAME_01;
		
		S_SEND_DEVICE_NAME_01:
		begin
			if (SendDescriptorComplite)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_DELAY_02;
			end
			else if (SendDescriptorFail)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_FAIL;
			end
			else
			begin
				DescriptorID <= 'h03_02; //03 - String number 02.
				SendDescriptor_En <= 1'b1;
			end
				
		end
		
		S_DELAY_02: if (!SendDescriptorComplite) USB_Slave_State <= S_SEND_DEVICE_NAME_02;
		
		S_SEND_DEVICE_NAME_02:
		begin
			if (SendDescriptorComplite)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_DELAY_03;
			end
			else if (SendDescriptorFail)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_FAIL;
			end
			else
			begin
				DescriptorID <= 'h03_02; //03 - String number 02.
				SendDescriptor_En <= 1'b1;
			end
				
		end
		
		S_DELAY_03: if (!SendDescriptorComplite) USB_Slave_State <= S_GET_DEVICE_MANUFACTURE_01;
		
		S_GET_DEVICE_MANUFACTURE_01:
		begin
			if (SendDescriptorComplite)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_DELAY_04;
			end
			else if (SendDescriptorFail)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_FAIL;
			end
			else
			begin
				DescriptorID <= 'h03_01; //03 - String number 02.
				SendDescriptor_En <= 1'b1;
			end
		end
		
		S_DELAY_04: if (!SendDescriptorComplite) USB_Slave_State <= S_GET_DEVICE_MANUFACTURE_02;
		
		S_GET_DEVICE_MANUFACTURE_02:
		begin
			if (SendDescriptorComplite)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_DELAY_05;
			end
			else if (SendDescriptorFail)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_FAIL;
			end
			else
			begin
				DescriptorID <= 'h03_01; //03 - String number 02.
				SendDescriptor_En <= 1'b1;
			end
		end
		
		S_DELAY_05: if (!SendDescriptorComplite) USB_Slave_State <= S_GET_DEVICE_CONFIGURATION_01;
		
		S_GET_DEVICE_CONFIGURATION_01:
		begin
			if (SendDescriptorComplite)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_DELAY_06;
			end
			else if (SendDescriptorFail)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_FAIL;
			end
			else
			begin
				DescriptorID <= 'h02_00; //02 - Config number 00.
				SendDescriptor_En <= 1'b1;
				
				
			end
		end
		
		S_DELAY_06: if (!SendDescriptorComplite) USB_Slave_State <= S_GET_DEVICE_CONFIGURATION_02;
		
		S_GET_DEVICE_CONFIGURATION_02:
		begin
			if (SendDescriptorComplite)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_SET_DEVICE_CONFIG;
			end
			else if (SendDescriptorFail)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_FAIL;
			end
			else
			begin
				DescriptorID <= 'h02_00; //02 - String number 02.
				SendDescriptor_En <= 1'b1;
				
				if (SendDataAddr == 'd31) 
					DataPacketLen <= SendData;
			end
		end
		
		S_SET_DEVICE_CONFIG:
		begin
			if (GetRequestComplite)
			begin
				GetRequest_En <= 1'b0;
				USB_Slave_State <= S_GET_DEVICE_HID;
				Request <= 'd0;
			end
			else if (GetRequestFail)
			begin
				GetRequest_En <= 1'b0;
				USB_Slave_State <= S_FAIL;
				Request <= 'd0;
			end
			else
			begin
				Request <= REQ_SET_CONFIGURATION;
				GetRequest_En <= 1'b1;
			end
		end
		
		S_GET_DEVICE_HID:
		begin
			if (SendDescriptorComplite)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_SET_IDLE_HID;
			end
			else if (SendDescriptorFail)
			begin
				SendDescriptor_En <= 1'b0;
				USB_Slave_State <= S_FAIL;
			end
			else
			begin
				DescriptorID <= 'h22_00; //22 - Report registr 00.
				SendDescriptor_En <= 1'b1;
			end
		end
		
		
		S_SET_IDLE_HID:
		begin
			if (GetRequestComplite)
			begin
				GetRequest_En <= 1'b0;
				USB_Slave_State <= S_DELAY_07;
				Request <= 'd0;
			end
			else if (GetRequestFail)
			begin
				GetRequest_En <= 1'b0;
				USB_Slave_State <= S_FAIL;
				Request <= 'd0;
			end
			else
			begin
				Request <= 'h0A; //SET_IDLE to HIDclass
				GetRequest_En <= 1'b1;
			end
		end
		
		S_DELAY_07: if (!GetRequestComplite) USB_Slave_State <= S_SET_PROTOCOL_HID;
		
		S_SET_PROTOCOL_HID:
		begin
			if (GetRequestComplite)
			begin
				GetRequest_En <= 1'b0;
				USB_Slave_State <= S_DELAY_08;
				Request <= 'd0;
			end
			else if (GetRequestFail)
			begin
				GetRequest_En <= 1'b0;
				USB_Slave_State <= S_FAIL;
				Request <= 'd0;
			end
			else
			begin
				Request <= 'h0B; //SET_IDLE to HIDclass
				GetRequest_En <= 1'b1;
			end
		end
		
		S_DELAY_08: if (!GetRequestComplite) USB_Slave_State <= S_TOKEN_WAITE_01;
		
		S_SET_REPORT_HID:
		begin
			if (GetRequestComplite)
			begin
				GetRequest_En <= 1'b0;
				USB_Slave_State <= S_TOKEN_WAITE_01;
				Request <= 'd0;
			end
			else if (GetRequestFail)
			begin
				GetRequest_En <= 1'b0;
				USB_Slave_State <= S_FAIL;
				Request <= 'd0;
			end
			else
			begin
				Request <= 'h09; //SET_IDLE to HIDclass
				GetRequest_En <= 1'b1;
			end
		end
		
		S_TOKEN_WAITE_01:
		begin
			if (GetDataComlite)
			begin
				GetData_En_main <= 1'b0;
				
				if (PacketTypeGet == P_IN && Token[6:0] == DeviceAddr && Token[10:7] == 'h01) 
					USB_Slave_State <= S_SEND_DATA_01;
				
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_Slave_State <= S_GET_SOF;
					USB_Slave_State_Return <= S_TOKEN_WAITE_01;
				end
				
				else
				begin
					$display("USB_Slave--> Need token IN Get = %b Addres get = %h, End point get = %h, Setup", PacketTypeGet, Token[6:0], Token[10:7]);
					USB_Slave_State <= S_FAIL;
				end
			end
			
			else if (GetDataValid)
			begin
				case (GetAddr)
				'd0: Token[7:0] <= GetData;
				'd1: Token[15:8] <= GetData;
				endcase
			end
			
			else 
			begin
				GetPacketLength_Slave <= 'd8;
				GetData_En_main <= 1'b1;
			end
			
			
		end
		
		S_SEND_DATA_01:
		begin
			
			if (SendDataComlite)
			begin
				SendData_En_main <= 1'b0;
				USB_Slave_State <= S_GET_ACK_01;
			end
			
			else
			begin
				SendData_En_main <= 1'b1;
				DataPacketType_main <= 8'b11000011;
				DataAddrBace_main <= 'd0;
				DescriptorID <= 'h00_01;
				SendPacketLength_main <= DataPacketLen;
			end
		
		end
		
		
		
		
		S_GET_ACK_01:
		begin
			if (GetDataComlite)
			begin
				GetData_En_main <= 1'b0;
				if (PacketTypeGet == P_ACK)
				begin
					USB_Slave_State <= S_DELAY_10;
				end
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_Slave_State <= S_GET_SOF;
					USB_Slave_State_Return <= S_GET_ACK_01;
				end
				else 
				begin
					$display("USB_Slave--> Wrong token type, you need send ACK token ");
					USB_Slave_State <= S_FAIL;
				end
			end
			
			else
			begin
				GetData_En_main <= 1'b1;
				GetPacketLength_Slave <= 'd8;
			end
			
		end
		
		S_DELAY_09:
			if (!GetDataComlite) USB_Slave_State <= S_TOKEN_WAITE_02;
		
		S_TOKEN_WAITE_02:
		begin
			if (GetDataComlite)
			begin
				GetData_En_main <= 1'b0;
				
				if (PacketTypeGet == P_IN && Token[6:0] == DeviceAddr && Token[10:7] == 'h01) 
					USB_Slave_State <= S_SEND_DATA_02;
				
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_Slave_State <= S_GET_SOF;
					USB_Slave_State_Return <= S_TOKEN_WAITE_02;
				end
				
				else
				begin
					$display("USB_Slave--> Need token IN Get = %b Addres get = %h, End point get = %h, Setup", PacketTypeGet, Token[6:0], Token[10:7]);
					USB_Slave_State <= S_FAIL;
				end
			end
			
			else if (GetDataValid)
			begin
				case (GetAddr)
				'd0: Token[7:0] <= GetData;
				'd1: Token[15:8] <= GetData;
				endcase
			end
			
			else 
			begin
				GetData_En_main <= 1'b1;
				GetPacketLength_Slave <= 'd8;
			end
			
			
		end
		
		S_SEND_DATA_02:
		begin
			
			if (SendDataComlite)
			begin
				SendData_En_main <= 1'b0;
				USB_Slave_State <= S_GET_ACK_02;
			end
			
			else
			begin
				SendData_En_main <= 1'b1;
				DataPacketType_main <= 8'b01001011;
				DataAddrBace_main <= 'd4;
				DescriptorID <= 'h00_01;
				SendPacketLength_main <= DataPacketLen;
			end
		
		end
		
		S_GET_ACK_02:
		begin
			if (GetDataComlite)
			begin
				GetData_En_main <= 1'b0;
				if (PacketTypeGet == P_ACK)
				begin
					USB_Slave_State <= S_DELAY_10;
				end
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_Slave_State <= S_GET_SOF;
					USB_Slave_State_Return <= S_GET_ACK_02;
				end
				else 
				begin
					$display("USB_Slave--> Wrong token type, you need send ACK token ");
					USB_Slave_State <= S_FAIL;
				end
			end
			
			else
			begin
				GetData_En_main <= 1'b1;
				GetPacketLength_Slave <= 'd8;
			end
			
		end
		
		S_DELAY_10:
			if (!GetDataComlite) USB_Slave_State <= S_TOKEN_WAITE_03;
		
		S_TOKEN_WAITE_03:
		begin
			if (GetDataComlite)
			begin
				GetData_En_main <= 1'b0;
				
				if (PacketTypeGet == P_IN && Token[6:0] == DeviceAddr && Token[10:7] == 'h01) 
					USB_Slave_State <= S_SEND_DATA_03;
				
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_Slave_State <= S_GET_SOF;
					USB_Slave_State_Return <= S_TOKEN_WAITE_03;
				end
				
				else
				begin
					$display("USB_Slave--> Need token IN Get = %b Addres get = %h, End point get = %h, Setup", PacketTypeGet, Token[6:0], Token[10:7]);
					USB_Slave_State <= S_FAIL;
				end
			end
			
			else if (GetDataValid)
			begin
				case (GetAddr)
				'd0: Token[7:0] <= GetData;
				'd1: Token[15:8] <= GetData;
				endcase
			end
			
			else 
			begin
				GetData_En_main <= 1'b1;
				GetPacketLength_Slave <= 'd8;
			end
			
			
		end
		
		S_SEND_DATA_03:
		begin
			
			if (SendDataComlite)
			begin
				SendData_En_main <= 1'b0;
				USB_Slave_State <= S_GET_ACK_03;
			end
			
			else
			begin
				SendData_En_main <= 1'b1;
				DataPacketType_main <= 8'b01001011;
				DataAddrBace_main <= 'd0;
				DescriptorID <= 'h00_02;
				SendPacketLength_main <= 'd2;
			end
		
		end
		
		S_GET_ACK_03:
		begin
			if (GetDataComlite)
			begin
				GetData_En_main <= 1'b0;
				if (PacketTypeGet == P_ACK)
				begin
					USB_Slave_State <= S_END;
				end
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_Slave_State <= S_GET_SOF;
					USB_Slave_State_Return <= S_GET_ACK_02;
				end
				else 
				begin
					$display("USB_Slave--> Wrong token type, you need send ACK token ");
					USB_Slave_State <= S_FAIL;
				end
			end
			
			else
			begin
				GetData_En_main <= 1'b1;
				GetPacketLength_Slave <= 'd8;
			end
			
		end
		
		
		S_GET_SOF:
		begin
			if (GetDataComlite)
			begin
				USB_Slave_State <= S_GET_SOF_02;
				GetData_En_main <= 1'b0;
			end
		end
		
		S_GET_SOF_02:
		begin
			if (!GetDataComlite)
			begin
				USB_Slave_State <= USB_Slave_State_Return;
			end
		end
		
		S_END:
		begin
			if (rst)
				USB_Slave_State <= S_IDLE;
		end
		
		
		default:
		begin
			SlaveFaill <= 1'b1;
		end
		
		
		endcase
	end
end

endmodule 





