module CRC16_Test;

reg [7:0] Write_Data [8:0];

initial
begin
	Write_Data[0] = 8'h31; //1,2,3,4,5,6,7,8,9 In ANSI code CRC16-USB = 0xB4C8
	Write_Data[1] = 8'h32;
	Write_Data[2] = 8'h33;
	Write_Data[3] = 8'h34;
	Write_Data[4] = 8'h35;
	Write_Data[5] = 8'h36;
	Write_Data[6] = 8'h37;
	Write_Data[7] = 8'h38;
	Write_Data[8] = 8'h39;
end


reg clk = 1'b0;

always #1 clk = ~clk;

reg CRC_En = 'd0;
wire [15:0]CRC;

reg GetData = 'd0;
reg [7:0]StringLen = 'd0;

M_CRC16_USB CRC16
(
	.clk(clk),
	.Enable(CRC_En),
	.GetData(GetData),
	.Data(Write_Data[BuyteCount]),
	.CRC(CRC)
);

reg [7:0] Data_Count = 'd0;
reg [15:0] BuyteCount = 'd0;

reg [7:0] State ='d0;

localparam 	S_START_TEST = 8'd0,
				S_DATA_IDLE = 'd1,
				S_CRC_CALK = 'd3,
				S_DATA_CHECK = 'd4,
				
				S_CRC_PASS = 'd253,
				S_CRC_FAIL = 'd254,
				S_END = 'd255;
				

always @(posedge clk)
begin
	
	case(State)
	S_START_TEST:
	begin
		$write("%c[1;34m",27);
		$display("");
		$display("*********** CRC16-USB test start. ***********");
		$write("%c[0m",27);
		State <= S_DATA_IDLE;
	end
	
	S_DATA_IDLE:
	begin
		CRC_En <= 1'b1;
		StringLen <= 'd9;
		GetData <= 1'b1;
		State <= S_CRC_CALK;
	end
	
	S_CRC_CALK:
	begin
		GetData <= 1'b0;
		
		if (Data_Count == 'd7)
		begin
			Data_Count <= 'd0;
			BuyteCount <= BuyteCount + 1'b1;
			if (BuyteCount == StringLen - 1) State <= S_DATA_CHECK;
			else GetData <= 1'b1;
			
		end
		else Data_Count <= Data_Count + 1'b1;
		
	end
	
	S_DATA_CHECK:
	begin
		
		CRC_En <= 1'b0;
		if (CRC == 16'hb4c8) State <= S_CRC_PASS;
		else State <= S_CRC_FAIL;
		
		
	end
	
	S_CRC_PASS:
	begin
		$write("%c[1;32m",27);
		$display("CRC Check passed. CRC16 = %h time =%d", CRC,$stime);
		$display("%c[0m",27);
		State <= S_END;
	end
	
	S_CRC_FAIL:
	begin
		$write("%c[1;31m",27);
		$display("CRC Check fail. CRC16 = %h time =%d", CRC, $stime);
		$display("%c[0m",27);
		State <= S_END;
	end
	
	endcase
	
	
end

initial  #1000 $finish;

initial
begin
  $dumpfile("out.vcd");
  $dumpvars(0,CRC16_Test);
  $dumpvars(0,CRC16);
end

//initial $monitor($stime,,, clk,, State,, CRC_Valid,, CRC_En);

endmodule 