module M_GET_PACKET
#(
	FAIL_MAX = 'd5
)

(
	input wire clk,
	input wire rst,
	
		
	input wire Eof1,
	input wire Eof2,
	
	input wire GetPacket_En,
	output reg GetPacketComplite = 1'b0,
	output reg GetPacketNAK = 1'b0,
	output reg GetPacketFail = 1'b0,
	
	input wire [7:0] PacketTypeGet,
	
	output reg SendToken_En = 1'b0,
	input wire SendTokenComlite,
	input wire SendTokenFail,
	
	
	output reg SendHandshake_En = 1'b0,
	input wire SendHandshakeComlite,
	input wire SendHandshakeFail,
	
	output reg GetData_En = 1'b0,
	input wire GetDataComlite,
	input wire GetDataFail,
	
	output reg EndOfPacked_En = 1'b0,
	input wire EndOfPackedComlite,
	input wire EndOfPackedFail,
	
	input wire Not_J_State,
	input wire EndOfPacket
	
);

reg [7:0] GetFailCounter = 8'd0;
reg [4:0] WaiteCount = 5'd0;
reg [4:0] ResetCount = 5'd0;

localparam 	P_OUT = 8'b11100001,
				P_IN = 8'b01101001,
				P_SOF_START_OF_FRAME = 8'b10100101,
				P_SETUP = 8'b00101101,
				P_DATA0 = 8'b11000011,
				P_DATA1 = 8'b01001011,
				P_ACK = 8'b11010010,
				P_NAK = 8'b01011010,
				P_STALL = 8'b00011110;
				
				
reg [7:0]State_GetPacked  = 8'd0;
reg [7:0]State_GetPacked_Return  = 8'd0;

localparam 	S_IDLE = 8'd0,
				S_TOKEN = 8'd1,
				S_GET_DATA_FROM_DEVICE = 8'd2,
				S_SEND_ACK = 8'd3,
				S_END_OF_PACKED = 8'd4,
				S_ERROR = 8'd5,
				
				S_NAK  = 'd253,
				S_FAIL  = 'd254,
				S_COMPLITE = 'd255;


always @(posedge clk) 
begin 

	if (rst)
	begin
		
		State_GetPacked <= S_IDLE;
		GetPacketComplite <= 1'b0;
		GetPacketNAK <= 1'b0;
		GetPacketFail <= 1'b0;
		
		SendToken_En <= 1'b0;
		SendHandshake_En <= 1'b0;
		GetData_En <= 1'b0;
		EndOfPacked_En <= 1'b0;
	end
	else
	begin

		case (State_GetPacked)
		
		S_IDLE:
		begin
			if (GetPacket_En && !Eof1)
			begin
			
				State_GetPacked <= S_TOKEN;
				GetFailCounter <= 'd0;
			end
		end
		
		S_TOKEN:
		begin
			
			if (SendTokenComlite)
			begin
				SendToken_En <= 1'b0;
				State_GetPacked <= S_GET_DATA_FROM_DEVICE;
			end
			else if (SendTokenFail)
			begin
				SendHandshake_En <= 1'b0;
				State_GetPacked <= S_END_OF_PACKED;
			end
			else
			begin
				if (!Eof1) 
					SendToken_En <= 1'b1;
			end
			
		end
		
		S_GET_DATA_FROM_DEVICE:
		begin
			if (GetDataComlite)
			begin
				case (PacketTypeGet)
				P_NAK:
				begin
					State_GetPacked <= S_NAK;
					
				end
				
				P_DATA0,
				P_DATA1:
				begin
					State_GetPacked <= S_SEND_ACK;
					
				end
				
				P_STALL:
				begin
					State_GetPacked <= S_FAIL;
					
				end
				
				default:
				begin
					
					if (GetFailCounter == FAIL_MAX) 
						State_GetPacked_Return <= S_FAIL;
					
					else
					begin
						GetFailCounter <= GetFailCounter + 1'b1;
						State_GetPacked_Return <= S_TOKEN;
					end
					
					State_GetPacked <= S_ERROR;
					
				end
				endcase
				
				
				GetData_En <= 1'b0;
				
			end
			else if (GetDataFail)
			begin
				
				if (GetFailCounter == FAIL_MAX) 
						State_GetPacked_Return <= S_FAIL;
					
				else
				begin
					GetFailCounter <= GetFailCounter + 1'b1;
					State_GetPacked_Return <= S_TOKEN;
				end
				
				State_GetPacked <= S_ERROR;
				
				GetData_En <= 1'b0;
			end
			
			else
			begin
				
				GetData_En <= 1'b1;
				
			end
		end
		
		S_SEND_ACK:
		begin
			if (SendHandshakeComlite)
			begin
				SendHandshake_En <= 1'b0;
				
			
				State_GetPacked <= S_COMPLITE;
			end
			else if (SendHandshakeFail)
			begin
				SendHandshake_En <= 1'b0;
				State_GetPacked <= S_END_OF_PACKED;
			end
			else
			begin
				if (!Eof2) 
					SendHandshake_En <= 1'b1;
				
			end
			
			
		end
		
		S_END_OF_PACKED:
		begin
			if (EndOfPackedComlite)
			begin
				EndOfPacked_En <= 1'b0;
				State_GetPacked <= S_ERROR;
			end
			else if (EndOfPackedFail)
			begin
				EndOfPacked_En <= 1'b0;
				State_GetPacked <= S_FAIL;
				
			end
			else EndOfPacked_En <= 1'b1;
			
		end
		
		
		
		S_ERROR:
		begin
			if (&WaiteCount) 
			begin
				WaiteCount <= 'd0;
				State_GetPacked <= State_GetPacked_Return;
			end
//			else if (&ResetCount) 
//			begin
//				ResetCount <= 'd0;
//				State_GetPacked <= S_FAIL;
//			end
//			else if (EndOfPacket)
//			begin
//				ResetCount <= ResetCount + 1'b1;
//			end
			
			else if (Not_J_State)
					WaiteCount <= 'd0;
			else 
				WaiteCount <= WaiteCount + 1'b1;
			
		end
		
		
		S_NAK:
		begin
			if (GetPacket_En) GetPacketNAK <= 1'b1;
			else
			begin
				GetPacketNAK <= 1'b0;
				State_GetPacked <= S_IDLE;
			end
		end
		
		S_COMPLITE:
		begin
			if (GetPacket_En) GetPacketComplite <= 1'b1;
			else
			begin
				GetPacketComplite <= 1'b0;
				State_GetPacked <= S_IDLE;
			end
			
		end
		
		default:
		begin
			if (GetPacket_En) GetPacketFail <= 1'b1;
			else
			begin
				GetPacketFail <= 1'b0;
				State_GetPacked <= S_IDLE;
			end
			
		end
		endcase
	end
end

endmodule 