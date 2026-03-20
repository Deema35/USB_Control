module M_HID_CODE_TABLE 
(   
	input wire [7:0] HidAddr,
	output wire [7:0] HidData

);
 
assign HidData = mem[HidAddr];



 
reg [7:0] mem[44:0];

initial 
begin
	mem[0] = 8'd0;
	mem[1] = 8'd0;
	mem[2] = 8'd0;
	mem[3] = 8'd0;
	mem[4] = 8'd11;// A
	mem[5] = 8'd12;// B
	mem[6] = 8'd13;// C
	mem[7] = 8'd14;// D
	mem[8] = 8'd15;// E
	mem[9] = 8'd16;// F
	mem[10] = 8'd17;// G
	mem[11] = 8'd18;// H
	mem[12] = 8'd19;// I
	mem[13] = 8'd20;// J
	mem[14] = 8'd21;// K
	mem[15] = 8'd22;// L
	mem[16] = 8'd23;// M
	mem[17] = 8'd24;// N
	mem[18] = 8'd25;// O
	mem[19] = 8'd26;// P
	mem[20] = 8'd27;// Q
	mem[21] = 8'd28;// R
	mem[22] = 8'd29;// S
	mem[23] = 8'd30;// T
	mem[24] = 8'd31;// U
	mem[25] = 8'd32;// V
	mem[26] = 8'd33;// W
	mem[27] = 8'd34;// X
	mem[28] = 8'd35;// Y
	mem[29] = 8'd36;// Z
	mem[30] = 8'd1;// 0
	mem[31] = 8'd2;// 1
	mem[32] = 8'd3;// 2
	mem[33] = 8'd4;// 3
	mem[34] = 8'd5;// 4
	mem[35] = 8'd6;// 5
	mem[36] = 8'd7;// 6
	mem[37] = 8'd8;// 7
	mem[38] = 8'd9;// 8
	mem[39] = 8'd10;// 9
	mem[40] = 8'd0; //Enter;
	mem[41] = 8'd0; //Esc;
	mem[42] = 8'd0; //Del;
	mem[43] = 8'd0; //Tab;
	mem[44] = 8'd0; //Space;

end
  

endmodule 
