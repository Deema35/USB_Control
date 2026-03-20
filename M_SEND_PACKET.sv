module M_SEND_PACKET
#(
	FAIL_MAX = 'd5
)
(
	input wire clk,
	input wire rst,
	
		
	input wire Eof1,
	
	input wire SendPacket_En,
	output reg SendPacketComplite = 1'b0,
	output reg SendPacketFail = 1'b0,
	
	input wire [7:0] PacketTypeSend,
	input wire [7:0] PacketTypeGet,
	
	output reg SendToken_En = 1'b0,
	input wire SendTokenComlite,
	input wire SendTokenFail,
	
	output reg SendControlPipe_En = 1'b0,
	input wire SendControlPipeComlite,
	input wire SendControlPipeFail,
	
	output reg SendData_En = 1'b0,
	input wire SendDataComlite,
	input wire SendDataFail,
	
	output reg GetData_En = 1'b0,
	input wire GetDataComlite,
	input wire GetDataFail,
	
	output reg EndOfPacked_En = 1'b0,
	input wire EndOfPackedComlite,
	input wire EndOfPackedFail,
	
	input wire Not_J_State
);

reg [7:0] SendFailCounter = 8'd0;
reg [7:0] State_SendPackedReturn  = 8'd0;
reg [2:0] WaiteCount = 3'd0;

localparam 	P_OUT = 8'b11100001,
				P_IN = 8'b01101001,
				P_SOF_START_OF_FRAME = 8'b10100101,
				P_SETUP = 8'b00101101,
				P_DATA0 = 8'b11000011,
				P_DATA1 = 8'b01001011,
				P_ACK = 8'b11010010,
				P_NAK = 8'b01011010,
				P_STALL = 8'b00011110;
				
				
reg [7:0]State_SendPacked  = 8'd0;
				
localparam 	S_IDLE = 8'd0,
				S_TOKEN = 8'd1,
				S_TOKEN_WAITE = 8'd2,
				S_SETUP_SEND = 8'd3,
				S_SEND_DATA_TO_DEVICE = 8'd4,
				S_GET_ACK = 8'd5,
				S_END_OF_PACKED = 8'd6,
				S_ERROR = 8'd7,
				
				
				S_FAIL  = 'd245,
				S_COMPLITE = 'd255;


always @(posedge clk) 
begin 

if (rst)
begin
	
	
	State_SendPacked <= S_IDLE;
	SendPacketComplite <= 1'b0;
	SendPacketFail <= 1'b0;
	
	SendControlPipe_En <= 1'b0;
	SendData_En <= 1'b0;
	GetData_En <= 1'b0;
	EndOfPacked_En <= 1'b0;
end
else
begin

	case (State_SendPacked)
		
		S_IDLE:
		begin
			if (SendPacket_En && !Eof1)
			begin
				SendFailCounter <= 'd0;
			
				State_SendPacked <= S_TOKEN;
			end
		end
		
		
		S_TOKEN:
		begin
			if (SendTokenComlite )
			begin
				if (Eof1)
					State_SendPacked <= S_TOKEN_WAITE;
					
				else
				begin
				
					case (PacketTypeSend)
					
					P_SETUP: State_SendPacked <= S_SETUP_SEND;
					
					P_OUT: State_SendPacked <= S_SEND_DATA_TO_DEVICE;
					
					default: State_SendPacked <= S_FAIL;
					
					endcase
				end
				
				SendToken_En <= 1'b0;
			end
			else if (SendTokenFail)
			begin
				SendToken_En <= 1'b0;
				State_SendPackedReturn <= S_TOKEN;
				State_SendPacked <= S_END_OF_PACKED;
			end
			else
			begin
				if (!Eof1)
					SendToken_En <= 1'b1;
			end
			
			
			
		end
		
		S_TOKEN_WAITE:
			if (!SendTokenComlite) 
				State_SendPacked <= S_TOKEN;
		
		
		
		S_SETUP_SEND:
		begin
			if (SendControlPipeComlite)
			begin
				SendControlPipe_En <= 1'b0;
				State_SendPacked <= S_GET_ACK;
			end
			else if (SendControlPipeFail)
			begin
				SendControlPipe_En <= 1'b0;
				State_SendPackedReturn <= S_TOKEN;
				State_SendPacked <= S_END_OF_PACKED;
			end
			else
			begin
				if  (!Eof1)
				begin
					SendControlPipe_En <= 1'b1;
				end
			end
			
		end
		
		S_SEND_DATA_TO_DEVICE:
		begin
			
			if (SendDataComlite)
			begin
				State_SendPacked <= S_GET_ACK;
				SendData_En <= 1'b0;
			end
			
			else if (SendDataFail)
			begin
				SendData_En <= 1'b0;
				State_SendPackedReturn <= S_TOKEN;
				State_SendPacked <= S_END_OF_PACKED;
			end
			
			else
			begin
				if  (!Eof1)
				begin
					SendData_En <= 1'b1;
				end
			end
		end
		
		S_GET_ACK:
		begin
			
			if (GetDataComlite)
			begin 
				if (PacketTypeGet == P_ACK) State_SendPacked <= S_COMPLITE;
				
				
				else if (PacketTypeGet == P_NAK) State_SendPacked <= S_TOKEN;
				
				else if (PacketTypeGet == P_STALL) State_SendPacked <= S_FAIL;
				
				else
				begin
					
					if (SendFailCounter == FAIL_MAX) State_SendPacked <= S_FAIL;
					else
					begin
						SendFailCounter <= SendFailCounter + 1'b1;
						
						State_SendPacked <= S_ERROR;
						
						State_SendPackedReturn <= S_TOKEN;
					end
				end
				
				GetData_En <= 1'b0;
				
			end
			else if (GetDataFail)
			begin
			
				if (SendFailCounter == FAIL_MAX) State_SendPacked <= S_FAIL;
				else
				begin
					SendFailCounter <= SendFailCounter + 1'b1;
					
					State_SendPacked <= S_ERROR;
					
					State_SendPackedReturn <= S_TOKEN;
					
					
				end
				
				GetData_En <= 1'b0;
			end
			
			else GetData_En <= 1'b1;
		end
		
		
		
		S_END_OF_PACKED:
		begin
			if (EndOfPackedComlite)
			begin
				EndOfPacked_En <= 1'b0;
				State_SendPacked <= S_ERROR;
			end
			else if (EndOfPackedFail)
			begin
				EndOfPacked_En <= 1'b0;
				State_SendPacked <= S_FAIL;
				
			end
			else EndOfPacked_En <= 1'b1;
			
		end
		
		S_ERROR:
		begin
			if (&WaiteCount) 
			begin
				WaiteCount <= 'd0;
				
				State_SendPacked <= State_SendPackedReturn;
			end
			else 
			begin
				if (Not_J_State) WaiteCount <= 'd0;
				else WaiteCount <= WaiteCount + 1'b1;
			end
			
		end
		
		S_COMPLITE:
		begin
			if (SendPacket_En) SendPacketComplite <= 1'b1;
			else
			begin
				SendPacketComplite <= 1'b0;
				State_SendPacked <= S_IDLE;
			end
			
		end
			
		default:
		begin
			if (SendPacket_En) SendPacketFail <= 1'b1;
			else
			begin
				SendPacketFail <= 1'b0;
				State_SendPacked <= S_IDLE;
			end
			
		end
		
	endcase
	end
end


endmodule 