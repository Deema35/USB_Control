module M_SEND_END_OF_PACKED


(
	input wire clk,
	input wire rst,
	input wire EndOfPacked_En,
	
	
	output reg [7:0] State_EndOfPacked = 8'd0,
	
	output reg EndOfPackedComlite = 1'b0,
	output reg EndOfPackedFail = 1'b0

);





reg [7:0] PacketCount = 'd0;


localparam 	S_IDLE = 8'd0,

				
				S_END_OF_PACKET_SE0 = 8'd13,
				S_END_OF_PACKET_J = 8'd14,
				S_END = 8'd15;


always @(posedge clk) 
begin 

	if (rst)
	begin
		
		State_EndOfPacked <= S_IDLE;
		
	end
	else
	begin
	
		case (State_EndOfPacked)
		S_IDLE:
		begin
		
			if (EndOfPacked_En)
			begin
				State_EndOfPacked <= S_END_OF_PACKET_SE0;
				PacketCount <= 'd0;
			end
		end
		

		
		
		S_END_OF_PACKET_SE0:
		begin
			if (PacketCount == 'd1)
			begin
				State_EndOfPacked <= S_END_OF_PACKET_J;
				PacketCount <= 'd0;
			end
			else PacketCount <= PacketCount + 1'b1;
		
		end
		
		S_END_OF_PACKET_J:
		begin
			if (PacketCount == 'd2)
			begin
				State_EndOfPacked <= S_END;
				PacketCount <= 'd0;
			end
			else PacketCount <= PacketCount + 1'b1;
		
		end
		
		S_END:
		begin
			if (EndOfPacked_En)
			begin
				EndOfPackedComlite = 1'b1;
			end
			else
			begin
				EndOfPackedComlite = 1'b0;
				State_EndOfPacked <= S_IDLE;
			end
			
		end
		
		default:
		begin
			if (EndOfPacked_En)
			begin
				EndOfPackedFail = 1'b1;
			end
			else
			begin
				EndOfPackedFail = 1'b0;
				State_EndOfPacked <= S_IDLE;
			end
			
		end
		
		endcase
	end
end





endmodule 