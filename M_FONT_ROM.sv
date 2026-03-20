module M_FONT_ROM 
(   
	input wire [7:0] FontAddr,
	input wire [7:0] FontOffset,
	output wire [7:0] Font_data

);
 
assign Font_data = Font_mem[(FontAddr * 'd10) + FontOffset];



 
reg [7:0] Font_mem[369:0];

initial 
begin

	Font_mem[0] = 8'b00000000; // N = 0 L = Space
	Font_mem[1] = 8'b00000000;
	Font_mem[2] = 8'b00000000;
	Font_mem[3] = 8'b00000000;
	Font_mem[4] = 8'b00000000;
	Font_mem[5] = 8'b00000000;
	Font_mem[6] = 8'b00000000;
	Font_mem[7] = 8'b00000000;
	Font_mem[8] = 8'b00000000;
	Font_mem[9] = 8'b00000000;

	Font_mem[10] = 8'b00000000; // N = 1 L = 0
	Font_mem[11] = 8'b00111100;
	Font_mem[12] = 8'b01100110;
	Font_mem[13] = 8'b01000010;
	Font_mem[14] = 8'b01000010;
	Font_mem[15] = 8'b01000010;
	Font_mem[16] = 8'b01000010;
	Font_mem[17] = 8'b01100110;
	Font_mem[18] = 8'b00111100;
	Font_mem[19] = 8'b00000000;

	Font_mem[20] = 8'b00000000; // N = 2 L = 1
	Font_mem[21] = 8'b00110000;
	Font_mem[22] = 8'b00111000;
	Font_mem[23] = 8'b00101100;
	Font_mem[24] = 8'b00100000;
	Font_mem[25] = 8'b00100000;
	Font_mem[26] = 8'b00100000;
	Font_mem[27] = 8'b00100000;
	Font_mem[28] = 8'b00100000;
	Font_mem[29] = 8'b00000000;

	Font_mem[30] = 8'b00000000; // N = 3 L = 2
	Font_mem[31] = 8'b00111100;
	Font_mem[32] = 8'b01100110;
	Font_mem[33] = 8'b01000010;
	Font_mem[34] = 8'b01100000;
	Font_mem[35] = 8'b00110000;
	Font_mem[36] = 8'b00011000;
	Font_mem[37] = 8'b00001100;
	Font_mem[38] = 8'b01111110;
	Font_mem[39] = 8'b00000000;

	Font_mem[40] = 8'b00000000; // N = 4 L = 3
	Font_mem[41] = 8'b00011100;
	Font_mem[42] = 8'b00100010;
	Font_mem[43] = 8'b01100000;
	Font_mem[44] = 8'b00110000;
	Font_mem[45] = 8'b00011000;
	Font_mem[46] = 8'b00110000;
	Font_mem[47] = 8'b01100010;
	Font_mem[48] = 8'b00111110;
	Font_mem[49] = 8'b00000000;

	Font_mem[50] = 8'b00000000; // N = 5 L = 4
	Font_mem[51] = 8'b00110000;
	Font_mem[52] = 8'b00111000;
	Font_mem[53] = 8'b00101100;
	Font_mem[54] = 8'b00100100;
	Font_mem[55] = 8'b00100110;
	Font_mem[56] = 8'b00100010;
	Font_mem[57] = 8'b01111110;
	Font_mem[58] = 8'b00100000;
	Font_mem[59] = 8'b00000000;

	Font_mem[60] = 8'b00000000; // N = 6 L = 5
	Font_mem[61] = 8'b01111100;
	Font_mem[62] = 8'b00000100;
	Font_mem[63] = 8'b00000100;
	Font_mem[64] = 8'b00111100;
	Font_mem[65] = 8'b01100000;
	Font_mem[66] = 8'b01000000;
	Font_mem[67] = 8'b01000100;
	Font_mem[68] = 8'b01111100;
	Font_mem[69] = 8'b00000000;

	Font_mem[70] = 8'b00000000; // N = 7 L = 6
	Font_mem[71] = 8'b00111100;
	Font_mem[72] = 8'b01100110;
	Font_mem[73] = 8'b00000010;
	Font_mem[74] = 8'b00111110;
	Font_mem[75] = 8'b01100110;
	Font_mem[76] = 8'b01000010;
	Font_mem[77] = 8'b01000010;
	Font_mem[78] = 8'b01111110;
	Font_mem[79] = 8'b00000000;

	Font_mem[80] = 8'b00000000; // N = 8 L = 7
	Font_mem[81] = 8'b01111110;
	Font_mem[82] = 8'b01100000;
	Font_mem[83] = 8'b00100000;
	Font_mem[84] = 8'b00110000;
	Font_mem[85] = 8'b00011000;
	Font_mem[86] = 8'b00001000;
	Font_mem[87] = 8'b00001100;
	Font_mem[88] = 8'b00001100;
	Font_mem[89] = 8'b00000000;

	Font_mem[90] = 8'b00000000; // N = 9 L = 8
	Font_mem[91] = 8'b00111100;
	Font_mem[92] = 8'b01100110;
	Font_mem[93] = 8'b01000010;
	Font_mem[94] = 8'b01100110;
	Font_mem[95] = 8'b00111100;
	Font_mem[96] = 8'b01100110;
	Font_mem[97] = 8'b01000010;
	Font_mem[98] = 8'b01111110;
	Font_mem[99] = 8'b00000000;

	Font_mem[100] = 8'b00000000; // N = 10 L = 9
	Font_mem[101] = 8'b00111100;
	Font_mem[102] = 8'b01100110;
	Font_mem[103] = 8'b01000010;
	Font_mem[104] = 8'b01100010;
	Font_mem[105] = 8'b01011100;
	Font_mem[106] = 8'b01000000;
	Font_mem[107] = 8'b01000010;
	Font_mem[108] = 8'b01111110;
	Font_mem[109] = 8'b00000000;

	Font_mem[110] = 8'b00000000; // N = 11 L = A
	Font_mem[111] = 8'b00011000;
	Font_mem[112] = 8'b00111100;
	Font_mem[113] = 8'b00100100;
	Font_mem[114] = 8'b00100100;
	Font_mem[115] = 8'b01100110;
	Font_mem[116] = 8'b01111110;
	Font_mem[117] = 8'b01000010;
	Font_mem[118] = 8'b01000010;
	Font_mem[119] = 8'b00000000;

	Font_mem[120] = 8'b00000000; // N = 12 L = B
	Font_mem[121] = 8'b00011110;
	Font_mem[122] = 8'b01100010;
	Font_mem[123] = 8'b01000010;
	Font_mem[124] = 8'b00100010;
	Font_mem[125] = 8'b00111110;
	Font_mem[126] = 8'b01000010;
	Font_mem[127] = 8'b01100010;
	Font_mem[128] = 8'b00111110;
	Font_mem[129] = 8'b00000000;

	Font_mem[130] = 8'b00000000; // N = 13 L = C
	Font_mem[131] = 8'b00111100;
	Font_mem[132] = 8'b01100110;
	Font_mem[133] = 8'b01000010;
	Font_mem[134] = 8'b00000010;
	Font_mem[135] = 8'b00000010;
	Font_mem[136] = 8'b01000010;
	Font_mem[137] = 8'b01100110;
	Font_mem[138] = 8'b00111100;
	Font_mem[139] = 8'b00000000;

	Font_mem[140] = 8'b00000000; // N = 14 L = D
	Font_mem[141] = 8'b00111110;
	Font_mem[142] = 8'b01100010;
	Font_mem[143] = 8'b01000010;
	Font_mem[144] = 8'b01000010;
	Font_mem[145] = 8'b01000010;
	Font_mem[146] = 8'b01000010;
	Font_mem[147] = 8'b01100010;
	Font_mem[148] = 8'b00111110;
	Font_mem[149] = 8'b00000000;

	Font_mem[150] = 8'b00000000; // N = 15 L = E
	Font_mem[151] = 8'b01111110;
	Font_mem[152] = 8'b00000010;
	Font_mem[153] = 8'b00000010;
	Font_mem[154] = 8'b00000010;
	Font_mem[155] = 8'b00111110;
	Font_mem[156] = 8'b00000010;
	Font_mem[157] = 8'b00000010;
	Font_mem[158] = 8'b01111110;
	Font_mem[159] = 8'b00000000;

	Font_mem[160] = 8'b00000000; // N = 16 L = F
	Font_mem[161] = 8'b01111110;
	Font_mem[162] = 8'b00000010;
	Font_mem[163] = 8'b00000010;
	Font_mem[164] = 8'b00000010;
	Font_mem[165] = 8'b00011110;
	Font_mem[166] = 8'b00000010;
	Font_mem[167] = 8'b00000010;
	Font_mem[168] = 8'b00000010;
	Font_mem[169] = 8'b00000000;

	Font_mem[170] = 8'b00000000; // N = 17 L = G
	Font_mem[171] = 8'b01111100;
	Font_mem[172] = 8'b01000110;
	Font_mem[173] = 8'b00000010;
	Font_mem[174] = 8'b00000010;
	Font_mem[175] = 8'b01100010;
	Font_mem[176] = 8'b01000010;
	Font_mem[177] = 8'b01100110;
	Font_mem[178] = 8'b00111100;
	Font_mem[179] = 8'b00000000;

	Font_mem[180] = 8'b00000000; // N = 18 L = H
	Font_mem[181] = 8'b01000010;
	Font_mem[182] = 8'b01000010;
	Font_mem[183] = 8'b01000010;
	Font_mem[184] = 8'b01111110;
	Font_mem[185] = 8'b01111110;
	Font_mem[186] = 8'b01000010;
	Font_mem[187] = 8'b01000010;
	Font_mem[188] = 8'b01000010;
	Font_mem[189] = 8'b00000000;

	Font_mem[190] = 8'b00000000; // N = 19 L = I
	Font_mem[191] = 8'b00111100;
	Font_mem[192] = 8'b00011000;
	Font_mem[193] = 8'b00011000;
	Font_mem[194] = 8'b00011000;
	Font_mem[195] = 8'b00011000;
	Font_mem[196] = 8'b00011000;
	Font_mem[197] = 8'b00011000;
	Font_mem[198] = 8'b00111100;
	Font_mem[199] = 8'b00000000;

	Font_mem[200] = 8'b00000000; // N = 20 L = J
	Font_mem[201] = 8'b00111000;
	Font_mem[202] = 8'b00010000;
	Font_mem[203] = 8'b00010000;
	Font_mem[204] = 8'b00010000;
	Font_mem[205] = 8'b00010000;
	Font_mem[206] = 8'b00010010;
	Font_mem[207] = 8'b00010110;
	Font_mem[208] = 8'b00011100;
	Font_mem[209] = 8'b00000000;

	Font_mem[210] = 8'b00000000; // N = 21 L = K
	Font_mem[211] = 8'b01000010;
	Font_mem[212] = 8'b01100010;
	Font_mem[213] = 8'b00100010;
	Font_mem[214] = 8'b00110010;
	Font_mem[215] = 8'b00011110;
	Font_mem[216] = 8'b00110010;
	Font_mem[217] = 8'b01100010;
	Font_mem[218] = 8'b01000010;
	Font_mem[219] = 8'b00000000;

	Font_mem[220] = 8'b00000000; // N = 22 L = L
	Font_mem[221] = 8'b00000110;
	Font_mem[222] = 8'b00000110;
	Font_mem[223] = 8'b00000110;
	Font_mem[224] = 8'b00000110;
	Font_mem[225] = 8'b00000110;
	Font_mem[226] = 8'b00000110;
	Font_mem[227] = 8'b01111110;
	Font_mem[228] = 8'b01111110;
	Font_mem[229] = 8'b00000000;

	Font_mem[230] = 8'b00000000; // N = 23 L = M
	Font_mem[231] = 8'b00100100;
	Font_mem[232] = 8'b01100110;
	Font_mem[233] = 8'b01111110;
	Font_mem[234] = 8'b01011010;
	Font_mem[235] = 8'b01011010;
	Font_mem[236] = 8'b01000010;
	Font_mem[237] = 8'b01000010;
	Font_mem[238] = 8'b01000010;
	Font_mem[239] = 8'b00000000;

	Font_mem[240] = 8'b00000000; // N = 24 L = N
	Font_mem[241] = 8'b01000110;
	Font_mem[242] = 8'b01001110;
	Font_mem[243] = 8'b01001010;
	Font_mem[244] = 8'b01011010;
	Font_mem[245] = 8'b01011010;
	Font_mem[246] = 8'b01010010;
	Font_mem[247] = 8'b01110010;
	Font_mem[248] = 8'b01100010;
	Font_mem[249] = 8'b00000000;

	Font_mem[250] = 8'b00000000; // N = 25 L = O
	Font_mem[251] = 8'b00111100;
	Font_mem[252] = 8'b01100110;
	Font_mem[253] = 8'b01000010;
	Font_mem[254] = 8'b01000010;
	Font_mem[255] = 8'b01000010;
	Font_mem[256] = 8'b01000010;
	Font_mem[257] = 8'b01100110;
	Font_mem[258] = 8'b00111100;
	Font_mem[259] = 8'b00000000;

	Font_mem[260] = 8'b00000000; // N = 26 L = P
	Font_mem[261] = 8'b00111110;
	Font_mem[262] = 8'b01100010;
	Font_mem[263] = 8'b01000010;
	Font_mem[264] = 8'b01100010;
	Font_mem[265] = 8'b00111110;
	Font_mem[266] = 8'b00000010;
	Font_mem[267] = 8'b00000010;
	Font_mem[268] = 8'b00000010;
	Font_mem[269] = 8'b00000000;

	Font_mem[270] = 8'b00000000; // N = 27 L = Q
	Font_mem[271] = 8'b00111100;
	Font_mem[272] = 8'b01100110;
	Font_mem[273] = 8'b01000010;
	Font_mem[274] = 8'b01000010;
	Font_mem[275] = 8'b01010010;
	Font_mem[276] = 8'b01110010;
	Font_mem[277] = 8'b00100110;
	Font_mem[278] = 8'b01011100;
	Font_mem[279] = 8'b00000000;

	Font_mem[280] = 8'b00000000; // N = 28 L = R
	Font_mem[281] = 8'b00111110;
	Font_mem[282] = 8'b01100010;
	Font_mem[283] = 8'b01000010;
	Font_mem[284] = 8'b01100010;
	Font_mem[285] = 8'b00111110;
	Font_mem[286] = 8'b00011010;
	Font_mem[287] = 8'b00110010;
	Font_mem[288] = 8'b01100010;
	Font_mem[289] = 8'b00000000;

	Font_mem[290] = 8'b00000000; // N = 29 L = S
	Font_mem[291] = 8'b00111100;
	Font_mem[292] = 8'b01100110;
	Font_mem[293] = 8'b01000010;
	Font_mem[294] = 8'b00001100;
	Font_mem[295] = 8'b00110000;
	Font_mem[296] = 8'b01000010;
	Font_mem[297] = 8'b01100110;
	Font_mem[298] = 8'b00111100;
	Font_mem[299] = 8'b00000000;

	Font_mem[300] = 8'b00000000; // N = 30 L = T
	Font_mem[301] = 8'b01111110;
	Font_mem[302] = 8'b01111110;
	Font_mem[303] = 8'b00011000;
	Font_mem[304] = 8'b00011000;
	Font_mem[305] = 8'b00011000;
	Font_mem[306] = 8'b00011000;
	Font_mem[307] = 8'b00011000;
	Font_mem[308] = 8'b00011000;
	Font_mem[309] = 8'b00000000;

	Font_mem[310] = 8'b00000000; // N = 31 L = U
	Font_mem[311] = 8'b01000010;
	Font_mem[312] = 8'b01000010;
	Font_mem[313] = 8'b01000010;
	Font_mem[314] = 8'b01000010;
	Font_mem[315] = 8'b01000010;
	Font_mem[316] = 8'b01000010;
	Font_mem[317] = 8'b01100110;
	Font_mem[318] = 8'b00111100;
	Font_mem[319] = 8'b00000000;

	Font_mem[320] = 8'b00000000; // N = 32 L = V
	Font_mem[321] = 8'b01000010;
	Font_mem[322] = 8'b01000010;
	Font_mem[323] = 8'b00100110;
	Font_mem[324] = 8'b00100100;
	Font_mem[325] = 8'b00100100;
	Font_mem[326] = 8'b00100100;
	Font_mem[327] = 8'b00011000;
	Font_mem[328] = 8'b00011000;
	Font_mem[329] = 8'b00000000;

	Font_mem[330] = 8'b00000000; // N = 33 L = W
	Font_mem[331] = 8'b01000010;
	Font_mem[332] = 8'b01000010;
	Font_mem[333] = 8'b01000010;
	Font_mem[334] = 8'b01011010;
	Font_mem[335] = 8'b01011010;
	Font_mem[336] = 8'b01111110;
	Font_mem[337] = 8'b00100100;
	Font_mem[338] = 8'b00100100;
	Font_mem[339] = 8'b00000000;

	Font_mem[340] = 8'b00000000; // N = 34 L = X
	Font_mem[341] = 8'b01000010;
	Font_mem[342] = 8'b00100100;
	Font_mem[343] = 8'b00111100;
	Font_mem[344] = 8'b00011000;
	Font_mem[345] = 8'b00011000;
	Font_mem[346] = 8'b00111100;
	Font_mem[347] = 8'b00100100;
	Font_mem[348] = 8'b01000010;
	Font_mem[349] = 8'b00000000;

	Font_mem[350] = 8'b00000000; // N = 35 L = Y
	Font_mem[351] = 8'b01000010;
	Font_mem[352] = 8'b01100110;
	Font_mem[353] = 8'b00100100;
	Font_mem[354] = 8'b00111100;
	Font_mem[355] = 8'b00011000;
	Font_mem[356] = 8'b00011000;
	Font_mem[357] = 8'b00011000;
	Font_mem[358] = 8'b00011000;
	Font_mem[359] = 8'b00000000;

	Font_mem[360] = 8'b00000000; // N = 36 L = Z
	Font_mem[361] = 8'b01111110;
	Font_mem[362] = 8'b01100000;
	Font_mem[363] = 8'b00100000;
	Font_mem[364] = 8'b00111000;
	Font_mem[365] = 8'b00011100;
	Font_mem[366] = 8'b00000100;
	Font_mem[367] = 8'b00000110;
	Font_mem[368] = 8'b01111110;
	Font_mem[369] = 8'b00000000;




end
  

endmodule 
