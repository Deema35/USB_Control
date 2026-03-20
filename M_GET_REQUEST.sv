module M_GET_REQUEST
(
	input wire clk,
	input wire rst,
	
	input wire GetRequest_En,
	output reg GetRequestFail = 1'b0,
	output reg GetRequestComplite = 1'b0,
	
	output reg GetData_En = 1'b0,
	input wire GetDataComlite,
	output reg [15:0] GetPacketLength_GetRequest = 'd0,
	
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
	input wire PacketTypeValid,
	
	input wire [7:0] Request,
	
	
	input wire [6:0] DeviceAddr
);


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

			
										

reg [7:0] USB_Set_Device_Config = 'd0;
reg [7:0] USB_Set_Device_Config_Return = 'd0;

localparam 	S_IDLE = 8'd0,
				S_IDLE_SET_DEVICE_CONFIG = 8'd1,
				S_GET_TOKEN_SET_DEVICE_CONFIG = 8'd2,
				S_DELAY_01 = 8'd3,
				S_IDLE_COMMAND_PIPE_SET_DEVICE_CONFIG = 8'd4,
				S_GET_COMMAND_PIPE_SET_DEVICE_CONFIG = 8'd5,
				S_SEND_ACK_SET_DEVICE_CONFIG = 8'd6,
				
				
				S_GET_TOKEN_SEND_STATUS = 8'd7,
				S_SEND_STATUS = 8'd8,
				S_GET_STATUS_ACK = 8'd9,
				S_GET_SOF = 8'd10,
				S_GET_SOF_02 = 8'd11,
				
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
			if (PacketTypeValid)
			begin
				if (PacketTypeGet == P_SETUP) USB_Set_Device_Config <= S_GET_TOKEN_SET_DEVICE_CONFIG;
				else
				begin
					$display("USB_Slave_GetRequest--> Wrong token type, you need send SETUP token for change address");
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
					$display("USB_Slave_GetRequest--> Get token Addres = %h, End point = %h, Setup", Token[6:0], Token[10:7]);
					USB_Set_Device_Config <= S_DELAY_01;
				end
				else
				begin
					$display("USB_Slave_GetRequest--> Wrong device addr. Need %h, Get %h", DeviceAddr, Token[6:0]);
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
			else
			begin
				GetPacketLength_GetRequest <= 'd8;
				GetData_En <= 1'b1;
			end
		end
		
		
		S_DELAY_01: if (!GetDataComlite) USB_Set_Device_Config <= S_IDLE_COMMAND_PIPE_SET_DEVICE_CONFIG;
		
		
		S_IDLE_COMMAND_PIPE_SET_DEVICE_CONFIG:
		begin
			if (PacketTypeValid)
			begin
				if (PacketTypeGet == P_DATA0) 
					USB_Set_Device_Config <= S_GET_COMMAND_PIPE_SET_DEVICE_CONFIG;
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_Set_Device_Config_Return <= S_GET_TOKEN_SET_DEVICE_CONFIG;
					USB_Set_Device_Config <= S_GET_SOF;
				end
				else
				begin
					$display("USB_Slave_GetRequest--> Wrong packet type, you need send DATA0 packed for change address");
					USB_Set_Device_Config <= S_FAIL;
				end
			end
			else
			begin
				GetPacketLength_GetRequest <= 'd8;
				GetData_En <= 1'b1;
			end
			
		end
		
		S_GET_COMMAND_PIPE_SET_DEVICE_CONFIG:
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				if (CommandPipe[15:8] == Request)
				begin
					$display("USB_Slave_GetRequest--> Get command pipe. DataTransferDirection = %b, PipeType = %h Recipient = %h Request = %h Value = %h Index = %h, Length = %h", 
					CommandPipe[7], CommandPipe[6:5], CommandPipe[4:0], CommandPipe[15:8], CommandPipe[31:16], CommandPipe[47:32], CommandPipe[63:48]);
					
					USB_Set_Device_Config <= S_SEND_ACK_SET_DEVICE_CONFIG;
				end
				else
				begin
					$display("USB_Slave_GetRequest--> Wrong request, you need send (%h) get %h", Request, CommandPipe[15:8]);
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
			else
			begin
				GetPacketLength_GetRequest <= 'd8;
				GetData_En <= 1'b1;
			end
			
		end
		
		S_SEND_ACK_SET_DEVICE_CONFIG:
		begin
			if (SendHandshakeComlite)
			begin
				SendHandshake_En <= 1'b0;

				
				USB_Set_Device_Config <= S_GET_TOKEN_SEND_STATUS;
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
				if (PacketTypeGet == P_IN)
				begin
					if (Token[6:0] == DeviceAddr) 
					begin
						$display("USB_Slave_GetRequest--> Get token Addres = %h, End point = %h, Return status", Token[6:0], Token[10:7]);
						USB_Set_Device_Config <= S_SEND_STATUS;
					end
					
					else
					begin
						$display("USB_Slave_GetRequest--> Wrong device addr. Need %h, Get %h", DeviceAddr, Token[6:0]);
						USB_Set_Device_Config <= S_FAIL;
					end
				end
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_Set_Device_Config_Return <= S_GET_TOKEN_SEND_STATUS;
					USB_Set_Device_Config <= S_GET_SOF;
				end
				else
				begin
					$display("USB_Slave_GetRequest--> Wrong token type.");
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
					$display("USB_Slave_GetRequest--> Wrong token type, you need send ACK token, get %b", PacketTypeGet);
					USB_Set_Device_Config <= S_FAIL;
				end
			end
			
			else GetData_En <= 1'b1;
		end
		
		S_GET_SOF:
		begin
			if (GetDataComlite)
			begin
				USB_Set_Device_Config <= S_GET_SOF_02;
				GetData_En <= 1'b0;
			end
		end
		
		S_GET_SOF_02:
		begin
			if (!GetDataComlite)
			begin
				USB_Set_Device_Config <= USB_Set_Device_Config_Return;
			end
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
				
				
				GetRequestComplite <= 1'b0;
				USB_Set_Device_Config <= S_IDLE;
			end
		end
		
		
		endcase
	end
end

endmodule
