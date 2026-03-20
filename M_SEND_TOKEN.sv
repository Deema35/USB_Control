module M_SEND_TOKEN

(
	input wire clk,
	input wire rst,
	
	
	input wire SendToken_En,
	
	output reg CRC5_En = 1'b0,
	
	input wire TransferReady,
	output reg [7:0] State_main = 8'd0,
	
	input wire [7:0] TransferLenght,
	
	output reg SendTokenFail = 1'b0,
	output reg SendTokenComlite = 1'b0

);


reg [7:0] PacketCount = 'd0;


localparam 	S_IDLE = 8'd0,
				S_START_OF_PACKET_K = 8'd1,
				S_START_OF_PACKET_J = 8'd2,
				S_START_OF_PACKET_K_END = 8'd3,
				S_SEND_TOKEN = 8'd4,
				
				S_END_OF_PACKET_SE0 = 8'd13,
				S_END_OF_PACKET_J = 8'd14,
				S_END = 8'd15;


always @(posedge clk) 
begin 

	if (rst)
	begin
		
		State_main <= S_IDLE;
		
	end
	else
	begin
	
		case (State_main)
		S_IDLE:
		begin
		
			if (SendToken_En)
			begin
				State_main <= S_START_OF_PACKET_K;
				CRC5_En <= 1'b1;
				PacketCount <= 'd0;
			end
		end
		
		S_START_OF_PACKET_K: State_main <= S_START_OF_PACKET_J;
	
		S_START_OF_PACKET_J:
		begin
			if (PacketCount == 2) 
			begin
				PacketCount <= 'd0;
				State_main <= S_START_OF_PACKET_K_END;
			end
			else
			begin
				PacketCount = PacketCount + 1'b1;
				State_main <= S_START_OF_PACKET_K;
			end
		end
		S_START_OF_PACKET_K_END:
		begin
			
			if (PacketCount == 1)
			begin
				PacketCount <= 'd0;
				
				State_main <= S_SEND_TOKEN;
			end
			else PacketCount <= PacketCount + 1'b1;
		end
		
		S_SEND_TOKEN:
		begin
			if (TransferReady) State_main <= S_END_OF_PACKET_SE0;
			
			
		end
		
		
		S_END_OF_PACKET_SE0:
		begin
			if (PacketCount == 'd1)
			begin
				State_main <= S_END_OF_PACKET_J;
				PacketCount <= 'd0;
			end
			else PacketCount <= PacketCount + 1'b1;
		
		end
		
		S_END_OF_PACKET_J:
		begin
			if (PacketCount == 'd2)
			begin
				State_main <= S_END;
				PacketCount <= 'd0;
			end
			else PacketCount <= PacketCount + 1'b1;
		
		end
		
		S_END:
		begin
			if (SendToken_En)
			begin
				SendTokenComlite = 1'b1;
				CRC5_En <= 1'b0;
			end
			else
			begin
				SendTokenComlite = 1'b0;
				State_main <= S_IDLE;
			end
			
		end
		
		default:
		begin
			if (SendToken_En)
			begin
				SendTokenFail = 1'b1;
				CRC5_En <= 1'b0;
			end
			else
			begin
				SendTokenFail = 1'b0;
				State_main <= S_IDLE;
			end
			
		end
		
		endcase
	end
end





endmodule 