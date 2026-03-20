module M_DATA_TRANSFER
(
	input wire clk,
	input wire [31:0] DataBuf,
	input wire [7:0] TransferState,
	input wire [7:0] TransferLenght,
	input wire FullSpeedConnect,
	
	output wire TransferReady,
	output wire TransferReadyMinusOne,
	
	inout tri Dp,
	inout tri Dm
);


assign TransferReady = (TransferCount == TransferLenght);
assign TransferReadyMinusOne = (TransferCount == TransferLenght - 'd1);

reg Dp_W = 1'b0;
reg Dm_W = 1'b0;

assign Dp = (TransferState == S_IDLE | TransferState == S_END) ? 1'bz : Dp_W;
assign Dm = (TransferState == S_IDLE | TransferState == S_END) ? 1'bz : Dm_W;

reg [7:0] TransferCount = 'd0;
reg [7:0] OneCount = 'd0;

localparam 	S_IDLE = 8'd0,
				S_START_OF_PACKET_K = 8'd1,
				S_START_OF_PACKET_J = 8'd2,
				S_START_OF_PACKET_K_END = 8'd3,
				S_SEND_DATA_1 = 8'd4,
				S_SEND_DATA_2 = 8'd5,
				S_SEND_DATA_3 = 8'd6,
				S_SEND_DATA_4 = 8'd7,
				S_SEND_DATA_5 = 8'd8,
				S_SEND_DATA_6 = 8'd9,
				S_SEND_DATA_7 = 8'd10,
				S_SEND_DATA_8 = 8'd11,
				S_SEND_DATA_9 = 8'd12,
				
				S_END_OF_PACKET_SE0 = 8'd13,
				S_END_OF_PACKET_J = 8'd14,
				S_END = 8'd15;


always @(posedge clk) //Data transfer function
begin 
	case (TransferState)
	S_IDLE:
	begin

		Dp_W <= Dp;
		Dm_W <= Dm;
		
		OneCount <= 'd0;
		TransferCount <= 'd0;

	end
	S_START_OF_PACKET_K:
	begin
		if (FullSpeedConnect)
		begin
			Dp_W <= 1'b0;
			Dm_W <= 1'b1;
		end
		else
		begin
			Dp_W <= 1'b1;
			Dm_W <= 1'b0;
		end
		
	end
	
	S_START_OF_PACKET_J:
	begin
		if (FullSpeedConnect)
		begin
			Dp_W <= 1'b1;
			Dm_W <= 1'b0;
		end
		else
		begin
			Dp_W <= 1'b0;
			Dm_W <= 1'b1;
		end
	end
	S_START_OF_PACKET_K_END:
	begin
		if (FullSpeedConnect)
		begin
			Dp_W <= 1'b0;
			Dm_W <= 1'b1;
		end
		else
		begin
			Dp_W <= 1'b1;
			Dm_W <= 1'b0;
		end
		
	end
	
	S_SEND_DATA_1,
	S_SEND_DATA_2,
	S_SEND_DATA_3,
	S_SEND_DATA_4,
	S_SEND_DATA_5,
	S_SEND_DATA_6,
	S_SEND_DATA_7,
	S_SEND_DATA_8,
	S_SEND_DATA_9:
	begin
		if(!DataBuf[TransferCount] | OneCount == 'd6)
		begin
			Dp_W <= ~Dp_W;
			Dm_W <= ~Dm_W;
			OneCount <= 'd0;
		end
		else OneCount <= OneCount + 1'b1;
		
		if (TransferCount == TransferLenght) TransferCount <= 'd0;
		
		else if (OneCount != 'd6) TransferCount <= TransferCount + 1'b1;
		
	end
	
	
	S_END_OF_PACKET_SE0:
	begin
		Dp_W <= 1'b0;
		Dm_W <= 1'b0;
		
	end
	
	S_END_OF_PACKET_J:
	begin
		if (FullSpeedConnect)
		begin
			Dp_W <= 1'b1;
			Dm_W <= 1'b0;
		end
		else
		begin
			Dp_W <= 1'b0;
			Dm_W <= 1'b1;
		end
	end
	endcase
end

endmodule 