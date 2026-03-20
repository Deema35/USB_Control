module M_CRC5
(
	input wire clk,
	input wire CRC_En,
	
	input wire [6:0]Addr,
	input wire [3:0]EndPoint,
	
	output reg [4:0] CRC = 'd0,
	output reg CRC_Valid = 1'b0
);

reg [7:0] CRC_Count = 'd0;
reg CRC_Flag = 'd0;

reg [7:0] State_CRC5 = S_IDLE;

reg [11:0] InPut = 'd0;


localparam 	S_IDLE = 8'd0,
				S_FLAG_CALK = 8'd1,
				S_CRC_CALK = 8'd2,
				S_CRC_XOR = 8'd3,
				
				S_CRC_COMPLITE = 8'd254,
				S_END = 8'd255;


always @(posedge clk) 
begin 

	case (State_CRC5)
	S_IDLE:
	begin
		if (CRC_En)
		begin
			CRC <= 5'b11111;
			CRC_Count <= 'd0;
			InPut <= {EndPoint, Addr};
			State_CRC5 <= S_FLAG_CALK;
		end
	end
	
	S_FLAG_CALK:
	begin
		
		CRC_Flag <= InPut[0] ^ CRC[0];
		InPut <= InPut >> 1'b1;
		CRC <= CRC >> 1'b1;
		State_CRC5 <= S_CRC_CALK;
		
	end
	
	S_CRC_CALK:
	begin
		if (CRC_Flag) CRC <= CRC ^ 5'b10100;
		
		if (CRC_Count == 10)
		begin
			CRC_Count <= 'd0;
			State_CRC5 <= S_CRC_XOR;
		end
		else
		begin
			CRC_Count <= CRC_Count + 1'b1;
			State_CRC5 <= S_FLAG_CALK;
		end
	end
	
	S_CRC_XOR:
	begin
		CRC <= CRC ^ 5'b11111;
		State_CRC5 <= S_CRC_COMPLITE;
	end
	
	S_CRC_COMPLITE:
	begin
		if (CRC_En) CRC_Valid <= 1'b1;
		else 
		begin
			CRC_Valid <= 1'b0;
			State_CRC5 <= S_IDLE;
		end
	end
	endcase
	
end

endmodule 