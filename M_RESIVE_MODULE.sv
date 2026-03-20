module M_RESIVE_MODULE
(
	input wire clk,
	input wire rst,
	
	input wire GetData_En,
	output wire GetDataComlite,
	output wire GetDataFail,

	output wire [7:0] PacketTypeGet,
	output wire [7:0] GetData,
	output wire [15:0] GetAddr,
	output wire GetDataValid,
	
	input wire [15:0] DataAddrBaceGet,
	
	output wire CRC16_En,
	output wire CRC16_GetData,
	output wire [7:0] CRC16_Data,
	input wire [15:0] CRC16_Res,
	input wire CRC16_Valid,
	
	input wire EndOfPacket,
	input wire K_State,
	input wire J_State,
	
	output wire [3:0] Analiz_Num
);



wire [15:0] CRC16_Get;
wire [15:0]GetAddr_count;
wire GetDataValid_Buf;
wire [15:0] GetAddr_count_Buf;
wire [15:0] DataAddrBaceGet_Buf;
wire [7:0] GetData_Buf;
wire PacketTypeValid;

wire Resiver_En;

assign GetAddr = GetAddr_count + DataAddrBaceGet_Buf;

M_GET_DATA GET_DATA
(
	.clk(clk),
	.rst(rst),
	
	.GetData_En(GetData_En),
	
	.GetDataComlite(GetDataComlite),
	.GetDataFaill(GetDataFail),
	
	.Addr_count(GetAddr_count_Buf),
	
	.PacketTypeGet(PacketTypeGet),
	.Data(GetData_Buf),
	.DataValid(GetDataValid_Buf),
	.PacketTypeValid(PacketTypeValid),
	
	
	.CRC16_Res(CRC16_Res),
	.CRC16_Get(CRC16_Get),
	
	
	.EndOfPacket(EndOfPacket),
	.K_State(K_State),
	.J_State(J_State),
	
	.CRC16_En(CRC16_En),
	.CRC16_Valid(CRC16_Valid),
	
	.Analiz_Num(Analiz_Num)
	
);



M_MEMORY_BUF_CRC16
#(
	.SIZE('d66)
)
 MEMORY_BUF
(
	.clk(clk),
	.we(GetDataValid_Buf),
	
	
	.ReadAddr(GetAddr_count),
	.ReadData(GetData),
	
	.WriteAddr(GetAddr_count_Buf),
	.WriteData(GetData_Buf),
	
	
	.CRC16_GetData(CRC16_GetData),
	.CRC16_Data(CRC16_Data),
	.CRC16_Get(CRC16_Get)
	
);

M_BUF_RETRONSLATOR BUF_RETRONSLATOR
(
	.clk(clk),
	.rst(rst),
	
	.DataAddrBaceGet_Buf(DataAddrBaceGet_Buf),
	.DataAddrBaceGet(DataAddrBaceGet),
	
	.DataValid(GetDataValid),
	
	.GetDataComlite(GetDataComlite),
	.Addr_count_Buf(GetAddr_count_Buf),
	
	.Addr_count(GetAddr_count)
	
);



endmodule
