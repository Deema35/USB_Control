module M_UNICODE_TABLE 
(   
	input wire [7:0] UniAddr,
	output wire [7:0] UniData

);
 
assign UniData = mem[UniAddr];



 
reg [7:0] mem[122:0];

initial 
begin
	mem[0] = 8'd0;
	mem[1] = 8'd0;
	mem[2] = 8'd0;
	mem[3] = 8'd0;
	mem[4] = 8'd0;
	mem[5] = 8'd0;
	mem[6] = 8'd0;
	mem[7] = 8'd0;
	mem[8] = 8'd0;
	mem[9] = 8'd0;
	mem[10] = 8'd0;
	mem[11] = 8'd0;
	mem[12] = 8'd0;
	mem[13] = 8'd0;
	mem[14] = 8'd0;
	mem[15] = 8'd0;
	mem[16] = 8'd0;
	mem[17] = 8'd0;
	mem[18] = 8'd0;
	mem[19] = 8'd0;
	mem[20] = 8'd0;
	mem[21] = 8'd0;
	mem[22] = 8'd0;
	mem[23] = 8'd0;
	mem[24] = 8'd0;
	mem[25] = 8'd0;
	mem[26] = 8'd0;
	mem[27] = 8'd0;
	mem[28] = 8'd0;
	mem[29] = 8'd0;
	mem[30] = 8'd0;
	mem[31] = 8'd0;
	mem[32] = 8'd0;
	mem[33] = 8'd0;
	mem[34] = 8'd0;
	mem[35] = 8'd0;
	mem[36] = 8'd0;
	mem[37] = 8'd0;
	mem[38] = 8'd0;
	mem[39] = 8'd0;
	mem[40] = 8'd0;
	mem[41] = 8'd0;
	mem[42] = 8'd0;
	mem[43] = 8'd0;
	mem[44] = 8'd0;
	mem[45] = 8'd0;
	mem[46] = 8'd0;
	mem[47] = 8'd0;
	mem[48] = 8'd1;// 0
	mem[49] = 8'd2;// 1
	mem[50] = 8'd3;// 2
	mem[51] = 8'd4;// 3
	mem[52] = 8'd5;// 4
	mem[53] = 8'd6;// 5
	mem[54] = 8'd7;// 6
	mem[55] = 8'd8;// 7
	mem[56] = 8'd9;// 8
	mem[57] = 8'd10;// 9
	mem[58] = 8'd0;
	mem[59] = 8'd0;
	mem[60] = 8'd0;
	mem[61] = 8'd0;
	mem[62] = 8'd0;
	mem[63] = 8'd0;
	mem[64] = 8'd0;
	mem[65] = 8'd11;// A
	mem[66] = 8'd12;// B
	mem[67] = 8'd13;// C
	mem[68] = 8'd14;// D
	mem[69] = 8'd15;// E
	mem[70] = 8'd16;// F
	mem[71] = 8'd17;// G
	mem[72] = 8'd18;// H
	mem[73] = 8'd19;// I
	mem[74] = 8'd20;// J
	mem[75] = 8'd21;// K
	mem[76] = 8'd22;// L
	mem[77] = 8'd23;// M
	mem[78] = 8'd24;// N
	mem[79] = 8'd25;// O
	mem[80] = 8'd26;// P
	mem[81] = 8'd27;// Q
	mem[82] = 8'd28;// R
	mem[83] = 8'd29;// S
	mem[84] = 8'd30;// T
	mem[85] = 8'd31;// U
	mem[86] = 8'd32;// V
	mem[87] = 8'd33;// W
	mem[88] = 8'd34;// X
	mem[89] = 8'd35;// Y
	mem[90] = 8'd36;// Z
	mem[91] = 8'd0;
	mem[92] = 8'd0;
	mem[93] = 8'd0;
	mem[94] = 8'd0;
	mem[95] = 8'd0;
	mem[96] = 8'd0;
	mem[97] = 8'd11;// a
	mem[98] = 8'd12;// b
	mem[99] = 8'd13;// c
	mem[100] = 8'd14;// d
	mem[101] = 8'd15;// e
	mem[102] = 8'd16;// f
	mem[103] = 8'd17;// g
	mem[104] = 8'd18;// h
	mem[105] = 8'd19;// i
	mem[106] = 8'd20;// j
	mem[107] = 8'd21;// k
	mem[108] = 8'd22;// l
	mem[109] = 8'd23;// m
	mem[110] = 8'd24;// n
	mem[111] = 8'd25;// o
	mem[112] = 8'd26;// p
	mem[113] = 8'd27;// q
	mem[114] = 8'd28;// r
	mem[115] = 8'd29;// s
	mem[116] = 8'd30;// t
	mem[117] = 8'd31;// u
	mem[118] = 8'd32;// v
	mem[119] = 8'd33;// w
	mem[120] = 8'd34;// x
	mem[121] = 8'd35;// y
	mem[122] = 8'd36;// z

end
  

endmodule 
