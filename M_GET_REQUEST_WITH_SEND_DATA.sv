module M_GET_REQUEST_WITH_SEND_DATA
#(
	SEND_ERROR_BLOCK = 1'b0
)
(
	input wire clk,
	input wire rst,
	
	input wire SendDescriptor_En,
	output reg SendDescriptorFail = 1'b0,
	output reg SendDescriptorComplite = 1'b0,
	
	output reg GetData_En = 1'b0,
	input wire GetDataComlite,
	input wire GetDataFail,
	output reg [15:0] GetPacketLength = 'd0,
	
	input wire GetDataValid,
	input wire [7:0] GetData,
	input wire [15:0] GetAddr,
	
	
	output reg SendHandshake_En = 1'b0,
	input wire SendHandshakeComlite,
	
	output reg SendNAK_En = 1'b0,
	input wire SendNAKComlite,
	
	output reg SendData_En = 1'b0,
	input wire SendDataComlite,
	output reg [15:0] SendPacketLength = 'd0,
	
	output reg [7:0] DataPacketType = 8'b11000011,
	input wire [7:0] PacketTypeGet,
	input wire PacketTypeValid,
	output reg [15:0] DataAddrBace = 'd0,
	
	input wire [15:0] DescriptorID,

	
	input wire [6:0] DeviceAddr,
	
	input wire [7:0] MAX_Packet_Size
);

reg [7:0] DeskriptorLen;

reg [15:0] Token = 'd0;
reg [63:0] CommandPipe = 'd0;

reg [7:0] TranzactionDataCount = 'd0;
reg [7:0] LastDataPacket = 'd0;


reg [7:0] NAKCount = 'd0;
		 

reg [7:0] USB_SendDescriptor_State = 'd0;
reg [7:0] USB_SendDescriptor_State_Return = 'd0;

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



localparam  S_IDLE = 8'd0,
				S_IDLE_GET_DEVICE_DESCRIPTOR = 8'd1,
				S_GET_TOKEN_GET_DEVICE_DESCRIPTOR = 8'd2,
				S_DELAY_03 = 8'd3,
				S_IDLE_COMMAND_PIPE_GET_DEVICE_DESCRIPTOR = 8'd4,
				S_GET_COMMAND_PIPE_GET_DEVICE_DESCRIPTOR = 8'd5,
				S_SEND_ACK_GET_DEVICE_DESCRIPTOR = 8'd6,
				S_CALCULATE_DEVICE_DESCRIPTOR = 8'd7,
				S_GET_TOKEN_DATA_DEVICE_DESCRIPTOR = 8'd8,
				S_SEND_NAK = 8'd9,
				S_SEND_ERROR_ID = 8'd10,
				S_SEND_DATA_DEVICE_DESCRIPTOR = 8'd11,
				S_GET_ACK_DEVICE_DESCRIPTOR = 8'd12,
				S_DELAY_05 = 8'd13,
				S_DELAY_06 = 8'd14,
				S_GET_TOKEN_STATUS_DEVICE_DESCRIPTOR = 8'd15,
				S_DELAY_04 = 8'd16,
				S_GET_STATUS_DEVICE_DESCRIPTOR = 8'd17,
				S_SEND_STATUS_ACK_DEVICE_DESCRIPTOR = 8'd18,
				S_GET_SOF = 8'd19,
				S_GET_SOF_02 = 8'd20,
				
				S_FAIL = 8'd254,
				S_END = 8'd255;



always @(posedge clk) 
begin 
	if (rst)
	begin
		USB_SendDescriptor_State <= S_IDLE;
		
	end
	else
	begin
		case (USB_SendDescriptor_State)
		S_IDLE:
		begin
			
			if (SendDescriptor_En)
			begin
				if (!PacketTypeValid)
				begin
					GetData_En <= 1'b1;
					USB_SendDescriptor_State <= S_IDLE_GET_DEVICE_DESCRIPTOR;
				end
			end
		end


		S_IDLE_GET_DEVICE_DESCRIPTOR:
		begin
			if (PacketTypeValid)
			begin
				if (PacketTypeGet == P_SETUP) USB_SendDescriptor_State <= S_GET_TOKEN_GET_DEVICE_DESCRIPTOR;
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_SendDescriptor_State_Return <= S_IDLE_GET_DEVICE_DESCRIPTOR;
					USB_SendDescriptor_State <= S_GET_SOF;
				end
				
				else
				begin
					$display("USB_Slave_SendDescriptor--> Wrong token type, you need send setup token for get device descriptor");
					USB_SendDescriptor_State <= S_FAIL;
				end
			end
			else GetData_En <= 1'b1;
			
			
		end
		
		S_GET_TOKEN_GET_DEVICE_DESCRIPTOR:
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				if (Token[6:0] == DeviceAddr)
				begin
					$display("USB_Slave_SendDescriptor--> Get token Addres = %h, End point = %h, Setup",  Token[6:0], Token[10:7]);
					USB_SendDescriptor_State <= S_DELAY_03;
				end
				else
				begin
					$display("USB_Slave_SendDescriptor--> Wrong device addr. Need %h, Get %h", DeviceAddr, Token[6:0]);
					USB_SendDescriptor_State <= S_FAIL;
				end
			end
			
			else if (GetDataFail)
			begin
				$display("USB_Slave_SendDescriptor--> Data get fail");
				GetData_En <= 1'b0;
				USB_SendDescriptor_State <= S_FAIL;
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
				GetPacketLength <= 'd8;
				GetData_En <= 1'b1;
			end
		end
		
		
		S_DELAY_03: if (!PacketTypeValid) USB_SendDescriptor_State <= S_IDLE_COMMAND_PIPE_GET_DEVICE_DESCRIPTOR;
		
		S_IDLE_COMMAND_PIPE_GET_DEVICE_DESCRIPTOR:
		begin
			if (PacketTypeValid)
			begin
				if (PacketTypeGet == P_DATA0) USB_SendDescriptor_State <= S_GET_COMMAND_PIPE_GET_DEVICE_DESCRIPTOR;
				
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_SendDescriptor_State_Return <= S_GET_TOKEN_GET_DEVICE_DESCRIPTOR;
					USB_SendDescriptor_State <= S_GET_SOF;
				end
				
				else
				begin
					$display("USB_Slave_SendDescriptor--> Wrong packet type, you need send data0 packed for change address");
					USB_SendDescriptor_State <= S_FAIL;
				end
				
			end
			else
			begin
				GetPacketLength <= 'd8;
				GetData_En <= 1'b1;
			end
			
			
		end
		
		S_GET_COMMAND_PIPE_GET_DEVICE_DESCRIPTOR:
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				
				if (CommandPipe[15:8] == REQ_GET_DESCRIPTOR & CommandPipe[31:16] == DescriptorID)
				begin
					$display("USB_Slave_SendDescriptor--> Get command pipe. DataTransferDirection = %b, PipeType = %h Recipient = %h Request = %h Value = %h Index = %h, Length = %h", 
					CommandPipe[7], CommandPipe[6:5], CommandPipe[4:0], CommandPipe[15:8], CommandPipe[31:16], CommandPipe[47:32], CommandPipe[63:48]);
					DeskriptorLen <= CommandPipe[63:48];
					
					USB_SendDescriptor_State <= S_SEND_ACK_GET_DEVICE_DESCRIPTOR;
				end
				else
				begin
					$display("USB_Slave_SendDescriptor--> Wrong request, you need send REQ_GET_DESCRIPTOR (h06) have %h, and value %h have %h", DescriptorID, CommandPipe[15:8], CommandPipe[31:16]);
					USB_SendDescriptor_State <= S_FAIL;
				end
				
				
			end
			
			else if (GetDataFail)
			begin
				$display("USB_Slave_SendDescriptor--> Data get fail");
				GetData_En <= 1'b0;
				USB_SendDescriptor_State <= S_FAIL;
			end
			
				
			else if (GetDataValid)
			begin
				case (GetAddr)
				'd0: CommandPipe[7:0] <= GetData;
				'd1: CommandPipe[15:8] <= GetData;
				'd2: CommandPipe[23:16] <= GetData;
				'd3: CommandPipe[31:24] <= GetData;
				'd4: CommandPipe[39:32] <= GetData;
				'd5: CommandPipe[47:40] <= GetData;
				'd6: CommandPipe[55:48] <= GetData;
				'd7: CommandPipe[63:56] <= GetData;
				endcase
			end
			else
			begin
				GetPacketLength <= 'd8;
				GetData_En <= 1'b1;
			end
			
		end
		
		S_SEND_ACK_GET_DEVICE_DESCRIPTOR:
		begin
			if (SendHandshakeComlite)
			begin
				SendHandshake_En <= 1'b0;
				
				DataAddrBace <= 'd0;
				TranzactionDataCount <= DeskriptorLen / MAX_Packet_Size;
				LastDataPacket <= DeskriptorLen % MAX_Packet_Size;
				USB_SendDescriptor_State <= S_CALCULATE_DEVICE_DESCRIPTOR;
			end
			else SendHandshake_En <= 1'b1;
			
	
		end
		
		S_CALCULATE_DEVICE_DESCRIPTOR:
		begin
			
			
			if (DeskriptorLen % MAX_Packet_Size != 'd0) 
				TranzactionDataCount <= TranzactionDataCount + 'd1;
				
			if (DeskriptorLen > (MAX_Packet_Size - 'd1))
				SendPacketLength <= MAX_Packet_Size;
			else SendPacketLength <= DeskriptorLen;
				
			USB_SendDescriptor_State <= S_GET_TOKEN_DATA_DEVICE_DESCRIPTOR;
			
			
		end
		
		S_GET_TOKEN_DATA_DEVICE_DESCRIPTOR:
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				
				if (PacketTypeGet == P_IN)
				begin
					if ( Token[6:0] == DeviceAddr)
					begin
					
						if (NAKCount == 'd2)
						begin
						
							USB_SendDescriptor_State <= S_SEND_DATA_DEVICE_DESCRIPTOR;
							NAKCount <= 'd0;
							
							if (DataPacketType == 8'b01001011)
							begin
								DataPacketType <= 8'b11000011;
								$display("USB_Slave_SendDescriptor--> Get token Addres = %h, End point = %h, send DATA0", Token[6:0], Token[10:7]);
							end
							else 
							begin
								DataPacketType <= 8'b01001011;
								$display("USB_Slave_SendDescriptor--> Get token Addres = %h, End point = %h, send DATA1", Token[6:0], Token[10:7]);
							end
						end
						else if (NAKCount == 'd1 && SEND_ERROR_BLOCK)
						begin
							DataPacketType <= 8'b10000011;
							NAKCount <= NAKCount + 1'b1;
							USB_SendDescriptor_State <= S_SEND_ERROR_ID;
						end
						else
						begin
							NAKCount <= NAKCount + 1'b1;
							USB_SendDescriptor_State <= S_SEND_NAK;
						end
					end
				end
				
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_SendDescriptor_State_Return <= S_GET_TOKEN_DATA_DEVICE_DESCRIPTOR;
					USB_SendDescriptor_State <= S_GET_SOF_02;
				end
				
				else
				begin
					$display("USB_Slave_SendDescriptor--> Wrong token type. Get %b", PacketTypeGet);
					USB_SendDescriptor_State <= S_FAIL;
				end
			end
			
			else if (GetDataFail)
			begin
				$display("USB_Slave_SendDescriptor--> Data get fail");
				GetData_En <= 1'b0;
				USB_SendDescriptor_State <= S_FAIL;
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
				GetPacketLength <= 'd0;
				GetData_En <= 1'b1;
			end
		end
		
		S_SEND_NAK:
		begin
			if (SendNAKComlite)
			begin
				SendNAK_En <= 1'b0;
				USB_SendDescriptor_State <= S_GET_TOKEN_DATA_DEVICE_DESCRIPTOR;
			end
			else SendNAK_En <= 1'b1;
			
		end
		
		S_SEND_ERROR_ID:
		begin
			if (SendDataComlite)
			begin
				SendData_En <= 1'b0;
				USB_SendDescriptor_State <= S_GET_TOKEN_DATA_DEVICE_DESCRIPTOR;
			end
			
			else
			begin
				SendData_En <= 1'b1;
				
			end
		end
		
		
		S_SEND_DATA_DEVICE_DESCRIPTOR:
		begin
			
			if (SendDataComlite)
			begin
				SendData_En <= 1'b0;
				USB_SendDescriptor_State <= S_GET_ACK_DEVICE_DESCRIPTOR;
			end
			
			else
			begin
				SendData_En <= 1'b1;
				
			end
		
		end
		
		S_GET_ACK_DEVICE_DESCRIPTOR:
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				if (PacketTypeGet == P_ACK)
				begin
					if (TranzactionDataCount != 'd1) 
					begin
						TranzactionDataCount <= TranzactionDataCount - 'd1;
						
						if (TranzactionDataCount == 'd2)
						begin
							if (LastDataPacket != 'd0)SendPacketLength <= LastDataPacket;
						end
						
						DataAddrBace <= DataAddrBace + MAX_Packet_Size;
						USB_SendDescriptor_State <= S_DELAY_05;
					end
					else
					begin
						SendPacketLength <= 'd0;
						LastDataPacket <= 'd0;
						DataAddrBace <= 'd0;
						TranzactionDataCount <= 'd0;
						
						
						USB_SendDescriptor_State <= S_DELAY_06;
					end
				end
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_SendDescriptor_State_Return <= S_GET_ACK_DEVICE_DESCRIPTOR;
					USB_SendDescriptor_State <= S_GET_SOF_02;
				end
				else 
				begin
					$display("USB_Slave_SendDescriptor--> Wrong token type, you need send ACK token ");
					USB_SendDescriptor_State <= S_FAIL;
				end
			end
			
			else if (GetDataFail)
			begin
				$display("USB_Slave_SendDescriptor--> Data get fail");
				GetData_En <= 1'b0;
				USB_SendDescriptor_State <= S_FAIL;
			end
			
			else
			begin
				GetPacketLength <= 'd0;
				GetData_En <= 1'b1;
			end
			
			
		end
		
		S_DELAY_05:  if (!PacketTypeValid) USB_SendDescriptor_State <= S_GET_TOKEN_DATA_DEVICE_DESCRIPTOR;
		
		S_DELAY_06:  if (!PacketTypeValid) USB_SendDescriptor_State <= S_GET_TOKEN_STATUS_DEVICE_DESCRIPTOR;
		
		S_GET_TOKEN_STATUS_DEVICE_DESCRIPTOR:
		begin
			if (GetDataComlite)
			begin
				
				if (PacketTypeGet == P_OUT)
				begin
					if ( Token[6:0] == DeviceAddr) 
					begin
						$display("USB_Slave_SendDescriptor--> Get token Addres = %h, End point = %h, Return status", Token[6:0], Token[10:7]);
						USB_SendDescriptor_State <= S_DELAY_04;
					end
					else
					begin
						$display("USB_Slave_SendDescriptor--> Wrong device addr. Need %h, Get %h", DeviceAddr, Token[6:0]);
						USB_SendDescriptor_State <= S_FAIL;
					end
				end
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_SendDescriptor_State_Return <= S_GET_TOKEN_STATUS_DEVICE_DESCRIPTOR;
					USB_SendDescriptor_State <= S_GET_SOF;
				end
				else
				begin
					$display("USB_Slave_SendDescriptor--> Wrong packrt type. , Get %b", PacketTypeGet);
					USB_SendDescriptor_State <= S_FAIL;
				end
				
				GetData_En <= 1'b0;
			end
			
			else if (GetDataFail)
			begin
				$display("USB_Slave_SendDescriptor--> Data get fail");
				GetData_En <= 1'b0;
				USB_SendDescriptor_State <= S_FAIL;
			end
			
			else if (GetDataValid)
			begin
				case (GetAddr)
				'd0: Token[7:0] <= GetData;
				'd1: Token[15:8] <= GetData;
				endcase
			end
			else GetData_En <= 1'b1;
		end
		
		S_DELAY_04:  if (!PacketTypeValid) USB_SendDescriptor_State <= S_GET_STATUS_DEVICE_DESCRIPTOR;
		
		S_GET_STATUS_DEVICE_DESCRIPTOR:
		begin
			if (GetDataComlite)
			begin
				if (PacketTypeGet != P_DATA1)
				
				begin
					$display("USB_Slave_SendDescriptor--> Wrong packed type, you need send P_DATA1 packed, get %b", PacketTypeGet);
					USB_SendDescriptor_State <= S_FAIL;
				end
				else USB_SendDescriptor_State <= S_SEND_STATUS_ACK_DEVICE_DESCRIPTOR;
				
			end
			
			else if (PacketTypeGet == P_SOF_START_OF_FRAME)
			begin
				USB_SendDescriptor_State_Return <= S_GET_TOKEN_STATUS_DEVICE_DESCRIPTOR;
				USB_SendDescriptor_State <= S_GET_SOF;
			end
			
			else if (GetDataFail)
			begin
				$display("USB_Slave_SendDescriptor--> Data get fail");
				GetData_En <= 1'b0;
				USB_SendDescriptor_State <= S_FAIL;
			end
			
			else
			begin
				GetData_En <= 1'b1;
			end
			
			 
			
		end
		
		S_SEND_STATUS_ACK_DEVICE_DESCRIPTOR: 
		begin
			if (SendHandshakeComlite) 
			begin
				USB_SendDescriptor_State <= S_END;
				SendHandshake_En <= 1'b0;
				$display("USB_Slave_SendDescriptor--> Device descriptor has been sended");
			end
			else
			begin
				SendHandshake_En <= 1'b1;
			end
	
			
		end
		
		S_GET_SOF:
		begin
			if (GetDataComlite)
			begin
				USB_SendDescriptor_State <= S_GET_SOF_02;
				GetData_En <= 1'b0;
			end
			else if (GetDataFail)
			begin
				$display("USB_Slave_SendDescriptor--> Data get fail");
				GetData_En <= 1'b0;
				USB_SendDescriptor_State <= S_FAIL;
			end
		end
		
		S_GET_SOF_02:
		begin
			if (!GetDataComlite)
			begin
				USB_SendDescriptor_State <= USB_SendDescriptor_State_Return;
			end
		end
		
		S_FAIL:
		begin
			if (SendDescriptor_En) SendDescriptorFail <= 1'b1;
			else
			begin
				DeskriptorLen <= 'd0;
				SendDescriptorFail <= 1'b0;
				USB_SendDescriptor_State <= S_IDLE;
			end
		end
		
		S_END:
		begin
			if (SendDescriptor_En) SendDescriptorComplite <= 1'b1;
			else
			begin
				DeskriptorLen <= 'd0;
				SendDescriptorComplite <= 1'b0;
				USB_SendDescriptor_State <= S_IDLE;
			end
		end
		endcase
	end
end



endmodule 