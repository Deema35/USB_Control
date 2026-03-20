module M_GET_REQUEST_WITH_GET_DATA
(
	input wire clk,
	input wire rst,
	
	input wire GetRequest_En,
	output reg GetRequestFail = 1'b0,
	output reg GetRequestComplite = 1'b0,
	
	output reg GetData_En = 1'b0,
	input wire GetDataComlite,
	
	input wire GetDataValid,
	input wire [7:0] GetData,
	input wire [15:0] GetAddr,
	
	output reg SendHandshake_En = 1'b0,
	input wire SendHandshakeComlite,
	
	output reg SendData_En = 1'b0,
	input wire SendDataComlite,
	output reg [15:0] SendPacketLength = 'd0,
	output reg [7:0] PacketType = 'd0,
	input wire [7:0] PacketTypeGet,
	
	output reg [15:0] DataAddrBace = 'd0,
	
	input wire [6:0] DeviceAddr
);
reg [7:0] DataBuffer [40:0];

reg [15:0] DataLen = 'd0;
reg [7:0] TranzactionDataCount = 'd0;
reg [7:0] LastDataPacket = 'd0;

reg [15:0] Token = 'd0;
reg [63:0] CommandPipe = 'd0;


localparam  S_GET_TOKEN = 8'd1,
				S_GET_COMMAND_PIPE = 8'd2,
				S_GET_STATUS = 8'd3;


									

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
										

reg [7:0] USB_Set_Device_Config = 'd0;

localparam 	S_IDLE = 8'd0,
				S_IDLE_SET_DEVICE_CONFIG = 8'd1,
				S_GET_TOKEN_SET_DEVICE_CONFIG = 8'd2,
				S_DELAY_01 = 8'd3,
				S_IDLE_COMMAND_PIPE_SET_DEVICE_CONFIG = 8'd4,
				S_GET_COMMAND_PIPE_SET_DEVICE_CONFIG = 8'd5,
				S_SEND_ACK_SET_DEVICE_CONFIG = 8'd6,
				S_CALCULATE_LEN = 8'd7,
				S_GET_TOKEN_GET_DATA = 8'd8,
				S_DELAY_02 = 8'd9,
				S_GET_DATA = 8'd10,
				S_DELAY_03 = 8'd11,
				S_SEND_DATA_ACK = 8'd12,
				S_GET_TOKEN_SEND_STATUS = 8'd13,
				S_SEND_STATUS = 8'd14,
				S_GET_STATUS_ACK = 8'd15,
				
				S_FAIL = 8'd254,
				S_END = 8'd255;


always @(posedge clk) 
begin 

	if (rst)
	begin
		USB_Set_Device_Config <= S_IDLE;
		
	end
	else
	begin
		case (USB_Set_Device_Config)
		S_IDLE:
		begin
			if (GetRequest_En) USB_Set_Device_Config <= S_IDLE_SET_DEVICE_CONFIG;
		end
		S_IDLE_SET_DEVICE_CONFIG:
		begin
			if (PacketTypeGet != 'd0)
			begin
				if (PacketTypeGet == P_SETUP) USB_Set_Device_Config <= S_GET_TOKEN_SET_DEVICE_CONFIG;
				else
				begin
					$display("USB_Slave_SetConfig--> Wrong token type, you need send SETUP token for change address");
					USB_Set_Device_Config <= S_FAIL;
				end
			end
			else GetData_En <= 1'b1;
			
		end
		
		
		S_GET_TOKEN_SET_DEVICE_CONFIG:
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				if (Token[6:0] == DeviceAddr)
				begin
					$display("USB_Slave_SetConfig--> Get token Addres = %h, End point = %h, Setup", Token[6:0], Token[10:7]);
					USB_Set_Device_Config <= S_DELAY_01;
				end
				else
				begin
					$display("USB_Slave_SetConfig--> Wrong device addr. Need %h, Get %h", DeviceAddr, Token[6:0]);
					USB_Set_Device_Config <= S_FAIL;
				end
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
		
		
		S_DELAY_01: if (PacketTypeGet == 'd0) USB_Set_Device_Config <= S_IDLE_COMMAND_PIPE_SET_DEVICE_CONFIG;
		
		
		S_IDLE_COMMAND_PIPE_SET_DEVICE_CONFIG:
		begin
			if (PacketTypeGet != 'd0)
			begin
				if (PacketTypeGet == P_DATA0) USB_Set_Device_Config <= S_GET_COMMAND_PIPE_SET_DEVICE_CONFIG;
				else
				begin
					$display("USB_Slave_SetConfig--> Wrong packet type, you need send DATA0 packed for change address");
					USB_Set_Device_Config <= S_FAIL;
				end
			end
			else GetData_En <= 1'b1;
			
		end
		
		S_GET_COMMAND_PIPE_SET_DEVICE_CONFIG:
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				if (CommandPipe[15:8] == REQ_SET_CONFIGURATION )
				begin
					$display("USB_Slave_USB_Slave_SetConfig--> Get command pipe. DataTransferDirection = %b, PipeType = %h Recipient = %h Request = %h Value = %h Index = %h, Length = %h", 
					CommandPipe[7], CommandPipe[6:5], CommandPipe[4:0], CommandPipe[15:8], CommandPipe[31:16], CommandPipe[47:32], CommandPipe[63:48]);
					
					DataLen <= CommandPipe[63:48];
					USB_Set_Device_Config <= S_SEND_ACK_SET_DEVICE_CONFIG;
				end
				else
				begin
					$display("USB_Slave_SetAddr--> Wrong request, you need send REQ_SET_CONFIGURATION (h09) get %d", CommandPipe[15:8]);
					USB_Set_Device_Config <= S_FAIL;
				end
				
				
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
			else GetData_En <= 1'b1;
			
		end
		
		S_SEND_ACK_SET_DEVICE_CONFIG:
		begin
			if (SendHandshakeComlite)
			begin
				SendHandshake_En <= 1'b0;
				TranzactionDataCount <= DataLen / 'd8;
				LastDataPacket <= DataLen % 'd8;
				
				
				DataAddrBace <= 'd0;
				
				USB_Set_Device_Config <= S_CALCULATE_LEN;
			end
			else
			begin
				SendHandshake_En <= 1'b1;
			end
		end
		
		S_CALCULATE_LEN:
		begin
			
			
			if (LastDataPacket != 'd0) TranzactionDataCount <= TranzactionDataCount + 'd1;
			USB_Set_Device_Config <= S_GET_TOKEN_GET_DATA;
					
		end
		
		S_GET_TOKEN_GET_DATA: 
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				if (GetDataComlite & Token[6:0] == DeviceAddr) 
				begin
					$display("USB_Slave_SetConfig--> Get token Addres = %h, End point = %h", Token[6:0], Token[10:7]);
					USB_Set_Device_Config <= S_DELAY_02;
				end
				
				else
				begin
					$display("USB_Slave_SetConfig--> Wrong device addr. Need %h, Get %h", DeviceAddr, Token[6:0]);
					USB_Set_Device_Config <= S_FAIL;
				end
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
		
		S_DELAY_02: if (GetDataComlite == 'd0) USB_Set_Device_Config <= S_GET_DATA;
		
		S_GET_DATA:
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				USB_Set_Device_Config <= S_DELAY_03;
			end
			else if (GetDataValid) DataBuffer[GetAddr] <= GetData;
			else
			begin
				GetData_En <= 1'b1;
				
			end
		end
		
		S_DELAY_03: if (GetDataComlite == 'd0) USB_Set_Device_Config <= S_SEND_DATA_ACK;
		
		S_SEND_DATA_ACK:
		begin
			if (SendHandshakeComlite)
			begin
				SendHandshake_En <= 1'b0;
				
				if (TranzactionDataCount != 'd1) 
				begin
					TranzactionDataCount <= TranzactionDataCount - 'd1;
					
					
					
					DataAddrBace <= DataAddrBace + 'd8;
					USB_Set_Device_Config <= S_GET_TOKEN_GET_DATA;
				end
				else
				begin
					
					LastDataPacket <= 'd0;
					DataAddrBace <= 'd0;
					TranzactionDataCount <= 'd0;
					PacketType <= 'd0;
					
					USB_Set_Device_Config <= S_GET_TOKEN_SEND_STATUS;
				end
				
				
				
			end
			else
			begin
				SendHandshake_En <= 1'b1;
			end
		end
		
		S_GET_TOKEN_SEND_STATUS:
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				if (GetDataComlite & Token[6:0] == DeviceAddr) 
				begin
					$display("USB_Slave_SetConfig--> Get token Addres = %h, End point = %h, Return status", Token[6:0], Token[10:7]);
					USB_Set_Device_Config <= S_SEND_STATUS;
				end
				
				else
				begin
					$display("USB_Slave_SetConfig--> Wrong device addr. Need %h, Get %h", DeviceAddr, Token[6:0]);
					USB_Set_Device_Config <= S_FAIL;
				end
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
		
		S_SEND_STATUS:
		begin
			if (SendDataComlite)
			begin
				SendData_En <= 1'b0;
				USB_Set_Device_Config <= S_GET_STATUS_ACK;
			end
			else
			begin
				SendData_En <= 1'b1;
				SendPacketLength <= 'h0;
				PacketType <= P_DATA1;
			end
		end
		
		S_GET_STATUS_ACK:
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				if (PacketTypeGet == P_ACK)
				begin
					USB_Set_Device_Config <= S_END;
				end
				else 
				begin
					$display("USB_Slave_SetConfig--> Wrong token type, you need send ACK token, get %b", PacketTypeGet);
					USB_Set_Device_Config <= S_FAIL;
				end
			end
			
			else GetData_En <= 1'b1;
		end
		
		S_FAIL:
		begin
			if (GetRequest_En) GetRequestFail <= 1'b1;
			else
			begin
				GetRequestFail <= 1'b0;
				USB_Set_Device_Config <= S_IDLE;
			end
		end
		
		
		
		S_END:
		begin
			if (GetRequest_En) GetRequestComplite <= 1'b1;
			else
			begin
				$write("%c[1;34m",27);
				$display("USB_Slave_SetConfig--> Set device Configuration size = %d, type = %d, %h%h %h%h %h%h %h%h %h%h %h%h %h%h %h%h", DataLen, DataBuffer[1],DataBuffer[2],DataBuffer[3],DataBuffer[4],
				DataBuffer[5],DataBuffer[6],DataBuffer[7],DataBuffer[8],DataBuffer[9],DataBuffer[10],DataBuffer[11], DataBuffer[12],DataBuffer[13], DataBuffer[14],DataBuffer[15], 
				DataBuffer[16],DataBuffer[17]);
				$write("%c[0m",27);
				
				GetRequestComplite <= 1'b0;
				USB_Set_Device_Config <= S_IDLE;
			end
		end
		
		
		endcase
	end
end

endmodule
