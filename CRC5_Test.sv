module CRC5_Test;

reg clk = 1'b0;

always #1 clk = ~clk;

reg CRC_En = 'd0;
wire CRC_Valid;
reg [6:0] Addr = 'd0;
reg [3:0] EndPoint = 'd0;
wire [4:0] CRC;

M_CRC5 CRC5
(
	.clk(clk),
	.CRC_En(CRC_En),
	
	.Addr(Addr),
	.EndPoint(EndPoint),
	
	.CRC(CRC),
	.CRC_Valid(CRC_Valid)
);

reg [7:0] State ='d0;

localparam 	S_START_TEST = 8'd0,
				S_TEST_01_START = 'd1,
				S_TEST_01_CHECK = 'd2,
				S_TEST_02_START = 'd3,
				S_TEST_02_CHECK = 'd4,
				S_TEST_03_START = 'd5,
				S_TEST_03_CHECK = 'd6,
				S_TEST_04_START = 'd7,
				S_TEST_04_CHECK = 'd8,
				
				S_COMPLITE = 8'd253,
				S_FAIL = 8'd254,
				S_END = 8'd255;
				

always @(posedge clk)
begin

	
	case(State)
	S_START_TEST:
	begin
		$write("%c[1;34m",27);
		$display("");
		$display("*********** Test CRC5 start. ***********");
		$write("%c[0m",27);
		State <= S_TEST_01_START;
	end
	
	S_TEST_01_START:
	begin
		Addr <= 'h18;
		EndPoint <= 'h01;
		CRC_En <= 1'b1;
		State <= S_TEST_01_CHECK;
	end
	
	S_TEST_01_CHECK:
	begin
		if (CRC_Valid)
		begin	
			CRC_En <= 1'b0;
			if (CRC == 5'b00110) State <= S_TEST_02_START;
			else State <= S_FAIL;
		end
	end
	
	S_TEST_02_START:
	begin
		Addr <= 'h15;
		EndPoint <= 'h0e;
		CRC_En <= 1'b1;
		State <= S_TEST_02_CHECK;
	end
	
	S_TEST_02_CHECK:
	begin
		if (CRC_Valid)
		begin	
			CRC_En <= 1'b0;
			if (CRC == 5'b11101) State <= S_TEST_03_START;
			else State <= S_FAIL;
		end
	end
	
	S_TEST_03_START:
	begin
		Addr <= 'h3a;
		EndPoint <= 'h0a;
		CRC_En <= 1'b1;
		State <= S_TEST_03_CHECK;
	end
	
	S_TEST_03_CHECK:
	begin
		if (CRC_Valid)
		begin	
			CRC_En <= 1'b0;
			if (CRC == 5'b00111) State <= S_TEST_04_START;
			else State <= S_FAIL;
		end
	end
	
	S_TEST_04_START:
	begin
		Addr <= 'h70;
		EndPoint <= 'h04;
		CRC_En <= 1'b1;
		State <= S_TEST_04_CHECK;
	end
	
	S_TEST_04_CHECK:
	begin
		if (CRC_Valid)
		begin	
			CRC_En <= 1'b0;
			if (CRC == 5'b01110) State <= S_COMPLITE;
			else State <= S_FAIL;
		end
	end
	
	S_COMPLITE:
	begin
		$write("%c[1;32m",27);
		$display("CRC5 test Complite, time =", $stime);
		$display("%c[0m",27);
		
		State <= S_END;
	end
	
	S_FAIL: 
	begin
		$write("%c[1;31m",27);
		$display("CRC5 test Fail, time =", $stime);
		$display("%c[0m",27);
		State <= S_END;
	end
	
	endcase
end

initial  #500 $finish;

initial
begin
  $dumpfile("out.vcd");
  $dumpvars(0,CRC5);
end

//initial $monitor($stime,,, clk,, State,, CRC_Valid,, CRC_En);

endmodule 