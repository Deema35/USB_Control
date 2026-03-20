module M_USB
#(
	SKIP_POWER_RISE = 1'b0,
	DEVICE_ADDR = 'h0C,
	FAIL_MAX = 'd5,
	FULLSPEED_WAITE = 16'd12_000 // 1 ms on 12 mHz => 12000 thics,
)

(
	input wire Low_clk,
	input wire Hi_clk,
	input wire ResetOut,
	
	
	output reg clk_out,
	output wire GetDataValid,
	output wire GetName,
	output wire KeyBoardData_En,
		
	output wire [15:0] GetAddr,
	output wire [7:0] GetData,
	
	output wire Fail,
	output wire Disconnect,
	
	inout tri Dp,
	inout tri Dm,
	
	output wire [7:0] MAX_Packet_Size,
	
	
	output wire Flag,
	output wire [3:0] Analiz_Num
);

assign Flag = Disconnect;
wire rst = ResetOut || Disconnect;


wire FullSpeedConnect;

wire clk = (FullSpeedConnect) ? Hi_clk :  Low_clk;

wire EndOfPacket = (!Dp && !Dm);

wire J_State = (FullSpeedConnect) ? Dp && !Dm :  Dm && !Dp;
wire K_State = (FullSpeedConnect) ? Dm && !Dp : Dp && !Dm;

wire Not_J_State = (FullSpeedConnect) ? (!Dp || Dm) : (Dp || !Dm);

assign clk_out = clk;

wire USBReset;
assign Dp = (USBReset) ? 1'b0 : 1'bz;
assign Dm = (USBReset) ? 1'b0 : 1'bz;

wire [15:0] DataAddrBaceGet = (Tranzaction_En) ? DataAddrBaceGet_Tranz : DataAddrBaceGet_Main;

wire [6:0] Addr = (Init_En) ? Addr_Init : Addr_Main;
wire [3:0] EndPoint = (Init_En) ? EndPoint_Init : EndPoint_Main;

wire [7:0] PacketType = (Tranzaction_En) ? PacketType_Tranz : PacketType_Main;

wire DataTransferDirection;
wire [1:0] PipeType;
wire [4:0] Recipient;
wire [7:0] Request;
wire [15:0] RequestValue;
wire [15:0] RequestIndex;
wire [15:0] RequestLength;

wire [7:0] DataPacketType;

wire SendPacket_En;
wire SendPacketComplite;
wire SendPacketFail;

wire GetPacketComplite;
wire GetPacketNAK;
wire GetPacketFail;

wire SOF_En;
wire Eof1;

M_DATA 
#(
	.FULLSPEED_WAITE(FULLSPEED_WAITE)
)
DATA
(
	.clk(clk),
	.rst(rst),
	
	.FullSpeedConnect(FullSpeedConnect),
	
	.DataAddrBaceGet(DataAddrBaceGet),
	
	.GetData(GetData),
	.GetAddr(GetAddr),
	.GetDataValid(GetDataValid),
	
	.Addr(Addr),
	.EndPoint(EndPoint),
	
	.PacketType(PacketType),
	
	.DataTransferDirection(DataTransferDirection),
	.PipeType(PipeType),
	.Recipient(Recipient),
	.Request(Request),
	.RequestValue(RequestValue),
	.RequestIndex(RequestIndex),
	.RequestLength(RequestLength),
	
	.DataPacketType(DataPacketType),
	.SendPacketLength(PacketLength_Tranz),
	
	.SendPacket_En(SendPacket_En),
	.SendPacketComplite(SendPacketComplite),
	.SendPacketFail(SendPacketFail),
	
	.GetPacket_En(GetPacket_En_Tranz | GetPacket_En_Main),
	.GetPacketComplite(GetPacketComplite),
	.GetPacketNAK(GetPacketNAK),
	.GetPacketFail(GetPacketFail),
	
	.SOF_En(SOF_En),
	.Eof1(Eof1),
	
	.EndOfPacket(EndOfPacket),
	.K_State(K_State),
	.J_State(J_State),
	.Not_J_State(Not_J_State),
		
	.Dp(Dp),
	.Dm(Dm),
	
	.Analiz_Num(Analiz_Num)
);



wire Tranzaction_En;
wire TranzactionComplite;
wire TranzactionFail;

wire TranzactionIgnorDataLength;
wire [15:0] PacketLength_Tranz;

wire [7:0] PacketType_Tranz;
wire GetPacket_En_Tranz;
wire [15:0] DataAddrBaceGet_Tranz;

M_TRANZACTION TRANZACTION
(
	.clk(clk),
	.rst(rst),
	
	
	.Tranzaction_En(Tranzaction_En),
	.TranzactionComplite(TranzactionComplite),
	.TranzactionFail(TranzactionFail),
	
	.PacketType(PacketType_Tranz),

	
	.DataAddrBace(DataAddrBaceGet_Tranz),
	.PacketLength(PacketLength_Tranz),

	
	.SendPacket_En(SendPacket_En),
	.SendPacketComplite(SendPacketComplite),
	.SendPacketFail(SendPacketFail),
	
	.GetPacket_En(GetPacket_En_Tranz),
	.GetPacketComplite(GetPacketComplite),
	.GetPacketNAK(GetPacketNAK),
	.GetPacketFail(GetPacketFail),
	
	.DataPacketType(DataPacketType),
	.DataLength(RequestLength),
	.DataTransferDirection(DataTransferDirection),
	
	.IgnorDataLength(TranzactionIgnorDataLength),
	
	.MAX_Packet_Size(MAX_Packet_Size)
);




wire Analiz_En;
wire Analiz_Comlite;
wire Analiz_Fail;


wire Init_En;
wire InitComplite;
wire InitFail;

wire [6:0] Addr_Init;
wire [3:0] EndPoint_Init;
wire [7:0] EndPointPacket_size;

wire [32:0] SetAddressRec;

M_USB_INIT 
#(
	.SKIP_POWER_RISE(SKIP_POWER_RISE),
	.DEVICE_ADDR(DEVICE_ADDR)
)
USB_INIT
(
	.clk(clk),
	.rst(rst),
	
	.SetAddressRec(SetAddressRec),
	
	.Init_En(Init_En),
	.InitComplite(InitComplite),
	.InitFail(InitFail),
	
	.Tranzaction_En(Tranzaction_En),
	.TranzactionComplite(TranzactionComplite),
	.TranzactionFail(TranzactionFail),
	.TranzactionIgnorDataLength(TranzactionIgnorDataLength),
	
	.Addr(Addr_Init),
	.EndPoint(EndPoint_Init),
	
	.DataTransferDirection(DataTransferDirection),
	.PipeType(PipeType),
	.Recipient(Recipient),
	.Request(Request),
	.RequestValue(RequestValue),
	.RequestIndex(RequestIndex),
	.RequestLength(RequestLength),
	
	.GetName(GetName),
	.GetData(GetData),
	.GetAddr(GetAddr),
	.GetDataValid(GetDataValid),
	
	.Analiz_En(Analiz_En),
	.Analiz_Comlite(Analiz_Comlite),
	.Analiz_Fail(Analiz_Fail),
	
	.MAX_Packet_Size(MAX_Packet_Size),
	.EndPointPacket_size(EndPointPacket_size)
	
	
);

wire [15:0] GetCollectionNumber;
wire [7:0] CollectionNum;
wire [7:0] CollectionPacketSize;
wire [7:0] CollectionPacketCount;



wire FT_we;
wire [15:0] FT_ReadAddr;
wire [7:0] FT_ReadData;
wire [15:0] FT_WriteAddr;
wire [7:0] FT_WriteData;

M_MEMORY_BUF 
#(
	.SIZE('d15)
)
FIELD_TYPE_BUF
(
	.clk(clk),
	.we(FT_we),
	
	
	.ReadAddr(FT_ReadAddr),
	.ReadData(FT_ReadData),
	
	.WriteAddr(FT_WriteAddr),
	.WriteData(FT_WriteData)
);

wire FV_we;
wire [15:0] FV_ReadAddr;
wire [7:0] FV_ReadData;
wire [15:0] FV_WriteAddr;
wire [7:0] FV_WriteData;

M_MEMORY_BUF 
#(
	.SIZE('d15)
)
FIELD_VALUE_BUF
(
	.clk(clk),
	.we(FV_we),
	
	
	.ReadAddr(FV_ReadAddr),
	.ReadData(FV_ReadData),
	
	.WriteAddr(FV_WriteAddr),
	.WriteData(FV_WriteData)
);



wire CPS_we;
wire [15:0] CPS_WriteAddr;
wire [7:0] CPS_WriteData;

M_MEMORY_BUF 
#(
	.SIZE('d5)
)
COLLECT_PACKET_SIZE_BUF
(
	.clk(clk),
	.we(CPS_we),
	
	
	.ReadAddr(GetCollectionNumber),
	.ReadData(CollectionPacketSize),
	
	.WriteAddr(CPS_WriteAddr),
	.WriteData(CPS_WriteData)
);

wire CPC_we;
wire [15:0] CPC_WriteAddr;
wire [7:0] CPC_WriteData;

M_MEMORY_BUF 
#(
	.SIZE('d5)
)
COLLECT_PACKET_COUNT_BUF
(
	.clk(clk),
	.we(CPC_we),
	
	
	.ReadAddr(GetCollectionNumber),
	.ReadData(CollectionPacketCount),
	
	.WriteAddr(CPC_WriteAddr),
	.WriteData(CPC_WriteData)
);


M_HID_ANALIZ HID_ANALIZ
(
	.clk(clk),
	.rst(rst),
	
	.Analiz_En(Analiz_En),
	.Analiz_Comlite(Analiz_Comlite),
	.Analiz_Fail(Analiz_Fail),
	
	.DataValid(GetDataValid),
	.Data(GetData),
	
	.CollectionNum(CollectionNum),
	
	.EndPointPacket_size(EndPointPacket_size),
	
	.FT_we(FT_we),
	.FT_ReadAddr(FT_ReadAddr),
	.FT_ReadData(FT_ReadData),
	.FT_WriteAddr(FT_WriteAddr),
	.FT_WriteData(FT_WriteData),
	
	.FV_we(FV_we),
	.FV_ReadAddr(FV_ReadAddr),
	.FV_ReadData(FV_ReadData),
	.FV_WriteAddr(FV_WriteAddr),
	.FV_WriteData(FV_WriteData),
	
	.CPS_we(CPS_we),
	.CPS_WriteAddr(CPS_WriteAddr),
	.CPS_WriteData(CPS_WriteData),
	
	.CPC_we(CPC_we),
	.CPC_WriteAddr(CPC_WriteAddr),
	.CPC_WriteData(CPC_WriteData)
);




wire [7:0] PacketType_Main;
wire GetPacket_En_Main;

wire [6:0] Addr_Main;
wire [3:0] EndPoint_Main;
wire [15:0] DataAddrBaceGet_Main;



M_MAIN_AUTOMAT
#(
	.SKIP_POWER_RISE(SKIP_POWER_RISE),
	.DEVICE_ADDR(DEVICE_ADDR)
)
MAIN_AUTOMAT
(
	.clk(clk),
	.rst(ResetOut),
	
	.KeyBoardData_En(KeyBoardData_En),
	
	.FullSpeedConnect(FullSpeedConnect),
	.USBReset(USBReset),
	
	.Fail(Fail),
	
	.Eof1(Eof1),
	.SOF_En(SOF_En),
	
	.Init_En(Init_En),
	.InitComplite(InitComplite),
	.InitFail(InitFail),
	
	.GetPacket_En(GetPacket_En_Main),
	.GetPacketComplite(GetPacketComplite),
	.GetPacketNAK(GetPacketNAK),
	.GetPacketFail(GetPacketFail),
	.PacketType(PacketType_Main),
	
	.Addr(Addr_Main),
	.EndPoint(EndPoint_Main),
	
	
	
	.AddrBace(DataAddrBaceGet_Main),
	.GetData(GetData),
	.GetDataAddr(GetAddr),
	.DataValid(GetDataValid),
	
	.GetCollectionNumber(GetCollectionNumber),
	.CollectionNum(CollectionNum),
	.CollectionPacketSize(CollectionPacketSize),
	.CollectionPacketCount(CollectionPacketCount),
	
	.EndOfPacket(EndOfPacket),
	.Disconnect(Disconnect),
	
	.SetAddressRec(SetAddressRec),
	
	.Dp(Dp),
	.Dm(Dm)
);





endmodule 