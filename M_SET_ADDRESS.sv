module M_SET_ADDRESS
(
	input wire clk,
	input wire rst,
	
	input wire SetAddress_En,
	output reg SetAddressFail = 1'b0,
	output reg SetAddressComplite = 1'b0,
	
	output reg GetData_En = 1'b0,
	input wire GetDataComlite,
	input wire GetDataFail,
	
	input wire GetDataValid,
	input wire PacketTypeValid,
	input wire [7:0] GetData,
	input wire [15:0] GetAddr,
	
	output reg SendHandshake_En = 1'b0,
	input wire SendHandshakeComlite,
	
	output reg SendData_En = 1'b0,
	input wire SendDataComlite,
	output reg [15:0] SendPacketLength = 'd0,
	input wire [7:0] PacketTypeGet,
	
	
	output reg [6:0] DeviceAddr = 'd0
);


reg [15:0] Token = 'd0;
reg [63:0] CommandPipe = 'd0;

reg [6:0] DeviceAddr_Temp = 'd0;

reg [7:0] SOF_Return = 'd0;

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
										

reg [7:0] USB_Set_Address_State = 'd0;

localparam 	S_IDLE = 8'd0,
				S_IDLE_SET_ADDR = 8'd1,
				S_GET_TOKEN_SET_ADDR = 8'd2,
				S_DELAY_01 = 8'd3,
				S_IDLE_COMMAND_PIPE_SET_ADDR = 8'd4,
				S_GET_COMMAND_PIPE_SET_ADDR = 8'd5,
				S_SEND_ACK_SET_ADDR = 8'd6,
				S_GET_TOKEN_STATUS_SET_ADDR = 8'd7,
				S_SEND_STATUS_SET_ADDR = 8'd8,
				S_GET_STATUS_ACK_SET_ADDR = 8'd9,
				S_GET_SOF = 8'd10,
				
				S_FAIL = 8'd254,
				S_END = 8'd255;


always @(posedge clk) 
begin 

	if (rst)
	begin
		USB_Set_Address_State <= S_IDLE;
		DeviceAddr <= 'd0;
		
	end
	else
	begin
		case (USB_Set_Address_State)
		S_IDLE:
		begin
			if (SetAddress_En) USB_Set_Address_State <= S_IDLE_SET_ADDR;
		end
		S_IDLE_SET_ADDR:
		begin
			if (PacketTypeValid)
			begin
				if (PacketTypeGet == P_SETUP) USB_Set_Address_State <= S_GET_TOKEN_SET_ADDR;
				
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_Set_Address_State <= S_GET_SOF;
					SOF_Return <= S_IDLE_SET_ADDR;
				end
				
				else
				begin
					$display("USB_Slave_SetAddr--> Wrong token type, you need send SETUP token for change address");
					USB_Set_Address_State <= S_FAIL;
				end
			end
			else GetData_En <= 1'b1;
			
		end
		
		
		S_GET_TOKEN_SET_ADDR:
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				if (Token[6:0] == DeviceAddr)
				begin
					$display("USB_Slave_SetAddr--> Get token Addres = %h, End point = %h, Setup", Token[6:0], Token[10:7]);
					USB_Set_Address_State <= S_DELAY_01;
				end
				else
				begin
					$display("USB_Slave_SetAddr--> Wrong device addr. Need %h, Get %h", DeviceAddr, Token[6:0]);
					USB_Set_Address_State <= S_FAIL;
				end
			end
			else if (GetDataFail)
			begin
				$display("USB_Slave_SetAddr--> Get data fail");
				USB_Set_Address_State <= S_FAIL;
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
		
		
		S_DELAY_01: if (!PacketTypeValid) USB_Set_Address_State <= S_IDLE_COMMAND_PIPE_SET_ADDR;
		
		
		S_IDLE_COMMAND_PIPE_SET_ADDR:
		begin
			if (PacketTypeValid)
			begin
				if (PacketTypeGet == P_DATA0) USB_Set_Address_State <= S_GET_COMMAND_PIPE_SET_ADDR;
				
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_Set_Address_State <= S_GET_SOF;
					SOF_Return <= S_IDLE_COMMAND_PIPE_SET_ADDR;
				end
				else
				begin
					$display("USB_Slave_SetAddr--> Wrong packet type, you need send DATA0 packed for change address");
					USB_Set_Address_State <= S_FAIL;
				end
			end
			else GetData_En <= 1'b1;
			
		end
		
		S_GET_COMMAND_PIPE_SET_ADDR:
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				if (CommandPipe[15:8] == REQ_SET_ADDRESS & CommandPipe[31:16] != 'd0)
				begin
					$display("USB_Slave_SetAddr--> Get command pipe. DataTransferDirection = %b, PipeType = %h Recipient = %h Request = %h Value = %h Index = %h, Length = %h", 
					CommandPipe[7], CommandPipe[6:5], CommandPipe[4:0], CommandPipe[15:8], CommandPipe[31:16], CommandPipe[47:32], CommandPipe[63:48]);
					
					DeviceAddr_Temp <= CommandPipe[31:16];
					USB_Set_Address_State <= S_SEND_ACK_SET_ADDR;
				end
				else
				begin
					$display("USB_Slave_SetAddr--> Wrong request, you need send REQ_SET_ADDRESS (h05) get %d and new addres not h00 get %h", CommandPipe[15:8], CommandPipe[31:16]);
					USB_Set_Address_State <= S_FAIL;
				end
				
				
			end
			else if (GetDataFail)
			begin
				$display("USB_Slave_SetAddr--> Set address fail");
					USB_Set_Address_State <= S_FAIL;
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
		
		S_SEND_ACK_SET_ADDR:
		begin
			if (SendHandshakeComlite)
			begin
				SendHandshake_En <= 1'b0;
				USB_Set_Address_State <= S_GET_TOKEN_STATUS_SET_ADDR;
			end
			else
			begin
				SendHandshake_En <= 1'b1;
			end
		end
		
		S_GET_TOKEN_STATUS_SET_ADDR: 
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				if (GetDataComlite & Token[6:0] == DeviceAddr) 
				begin
					$display("USB_Slave_SetAddr--> Get token Addres = %h, End point = %h, Return status", Token[6:0], Token[10:7]);
					USB_Set_Address_State <= S_SEND_STATUS_SET_ADDR;
				end
				
				else
				begin
					$display("USB_Slave_SetAddr--> Wrong device addr. Need %h, Get %h", DeviceAddr, Token[6:0]);
					USB_Set_Address_State <= S_FAIL;
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
		
	
		
		
		S_SEND_STATUS_SET_ADDR:
		begin
			if (SendDataComlite)
			begin
				SendData_En <= 1'b0;
				DeviceAddr <= DeviceAddr_Temp;
				$write("%c[1;34m",27);
				$display("USB_Slave_SetAddr--> Set new address complite. New address = %h", DeviceAddr_Temp);
				$write("%c[0m",27);
				USB_Set_Address_State <= S_GET_STATUS_ACK_SET_ADDR;
			end
			else
			begin
				SendData_En <= 1'b1;
				SendPacketLength <= 'h0;
			end
		end
		
		S_GET_STATUS_ACK_SET_ADDR:
		begin
			if (GetDataComlite)
			begin
				GetData_En <= 1'b0;
				if (PacketTypeGet == P_ACK)
				begin
					USB_Set_Address_State <= S_END;
				end
				else if (PacketTypeGet == P_SOF_START_OF_FRAME)
				begin
					USB_Set_Address_State <= S_GET_SOF;
					SOF_Return <= S_GET_STATUS_ACK_SET_ADDR;
				end
				else 
				begin
					$display("USB_Slave_SetAddr--> Wrong token type, you need send ACK token ");
					USB_Set_Address_State <= S_FAIL;
				end
			end
			
			else GetData_En <= 1'b1;
		end
		
		S_GET_SOF:
		begin
			if (GetDataComlite || GetDataFail)
			begin
				USB_Set_Address_State <= SOF_Return;
				GetData_En <= 1'b0;
			end
				
			else GetData_En <= 1'b1;
		end
		
		S_FAIL:
		begin
			if (SetAddress_En) SetAddressFail <= 1'b1;
			else
			begin
				SetAddressFail <= 1'b0;
				USB_Set_Address_State <= S_IDLE;
			end
		end
		
		S_END:
		begin
			if (SetAddress_En) SetAddressComplite <= 1'b1;
			else
			begin
				SetAddressComplite <= 1'b0;
				USB_Set_Address_State <= S_IDLE;
			end
		end
		
		
		endcase
	end
end

endmodule
