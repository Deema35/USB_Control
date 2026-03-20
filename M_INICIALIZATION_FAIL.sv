module M_INICIALIZATION_FAIL
(   
	input wire [7:0] FailAddr,
	output wire [7:0] FailData

);
 
assign FailData = mem[FailAddr];



 
reg [7:0] mem[18:0];

initial 
begin
	mem[0] = 8'd19;  //I
	mem[1] = 8'd24;  //N
	mem[2] = 8'd19;  //I
	mem[3] = 8'd13;  //C
	mem[4] = 8'd19;  //I
	mem[5] = 8'd11;  //A
	mem[6] = 8'd22;  //L
	mem[7] = 8'd19;  //I
	mem[8] = 8'd36; // Z
	mem[9] = 8'd11;  //A
	mem[10] = 8'd30;// T
	mem[11] = 8'd19; //I
	mem[12] = 8'd25;// O
	mem[13] = 8'd24;// N
	mem[14] = 8'd00;
	mem[15] = 8'd16;// F
	mem[16] = 8'd11; //A
	mem[17] = 8'd19; //I
	mem[18] = 8'd22; //L
	

end
  

endmodule 
