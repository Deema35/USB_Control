module M_SOF_SENDER
#(
	FULLSPEED_WAITE = 16'd12_000, // 1 ms on 12 mHz => 12000 thics,
	FULLSPEED_EOF_1 = 'd560,
	FULLSPEED_EOF_2 = 'd64,
	LOWSPEED_WAITE = 16'd1_500, // 1 ms on 1.5 mHz => 1500 thics
	LOWSPEED_EOF_1 = 'd32,
	LOWSPEED_EOF_2 = 'd10
)
(
	input wire clk,
	input wire rst,
	
	input wire SOF_En,
	
	input wire FullSpeed,
	
	output reg SendSOF_En = 'd0,
	output reg [10:0] FrameNumber = 'd0,
	input wire SendSOFComlite,
	input wire SendSOFFail,
	
	output reg EndOfPacked_En = 'd0,
	input wire EndOfPackedComlite,
	input wire EndOfPackedFail,
	
	output reg Eof1 = 1'b0,
	output reg Eof2 = 1'b0
);


reg [15:0] WaiteCount = 'd0;

reg [10:0] CurrentFrame = 'd0;

				
reg [7:0] SOFState = 'd0;

localparam 	S_IDLE = 8'd0,
				S_WAITE = 8'd1,
				S_SEND_SOF = 8'd2,
				S_SEND_END_OF_PACKED = 8'd3;
				
				
always @(posedge clk) 
begin 

	if (rst)
	begin
		SOFState <= S_IDLE;
		Eof2 <= 1'b0;
		Eof1 <= 1'b0;
		WaiteCount <= 'd0;
		CurrentFrame <= 'd0;
		SendSOF_En <= 'd0;
		EndOfPacked_En <= 'd0;
	end
	else
	begin
		case (SOFState)
		
		S_IDLE:
		begin
			if (SOF_En)
				SOFState <= S_WAITE;
		
		end
		S_WAITE:
		begin
			if (WaiteCount == 'd0)
			begin
				if (FullSpeed)
					SOFState <= S_SEND_SOF;
				else
					SOFState <= S_SEND_END_OF_PACKED;
				
				Eof2 <= 1'b1;
				Eof1 <= 1'b1;
			end
			else if ((FullSpeed && (WaiteCount == FULLSPEED_EOF_1)) ||(!FullSpeed && (WaiteCount == LOWSPEED_EOF_1)))
			begin
				Eof1 <= 1'b1;
				WaiteCount <= WaiteCount - 1'b1;
			end
			else if ((FullSpeed && (WaiteCount == FULLSPEED_EOF_2)) || (!FullSpeed && (WaiteCount == LOWSPEED_EOF_2)))
			begin
				Eof2 <= 1'b1;
				WaiteCount <= WaiteCount - 1'b1;
			end
			
			else WaiteCount <= WaiteCount - 1'b1;
		end
		
		S_SEND_SOF:
		begin
			if (SendSOFComlite || SendSOFFail)
			begin
				SOFState <= S_WAITE;
				SendSOF_En <= 1'b0;
				
				CurrentFrame <= CurrentFrame + 1'b1;
				WaiteCount <= FULLSPEED_WAITE;
				Eof2 <= 1'b0;
				Eof1 <= 1'b0;
			end
			
			else
			begin
				SendSOF_En <= 1'b1;
				FrameNumber <= CurrentFrame;
			end
		end
		S_SEND_END_OF_PACKED:
		begin
			if (EndOfPackedComlite || EndOfPackedFail)
			begin
				SOFState <= S_WAITE;
				EndOfPacked_En <= 1'b0;
				
				WaiteCount <= LOWSPEED_WAITE;
				Eof2 <= 1'b0;
				Eof1 <= 1'b0;
			end
			
			else
				EndOfPacked_En <= 1'b1;
		end
		
		endcase
	end
end

endmodule 