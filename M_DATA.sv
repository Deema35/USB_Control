module M_DATA
#(
	FAIL_MAX = 'd5,
	FULLSPEED_WAITE = 16'd12_000 // 1 ms on 12 mHz => 12000 thics,
	
)
(
	input wire clk,
	input wire rst,
	
	input wire FullSpeedConnect,
	
	input wire [15:0] DataAddrBaceGet,
	
	output wire [7:0] GetData,
	output wire [15:0] GetAddr,
	output wire GetDataValid,
	
	input wire [6:0] Addr,
	input wire [3:0] EndPoint,
	
	input wire [7:0] PacketType,
	
	input wire DataTransferDirection,
	input wire [1:0] PipeType,
	input wire [4:0] Recipient,
	input wire [7:0] Request,
	input wire [15:0] RequestValue,
	input wire [15:0] RequestIndex,
	input wire [15:0] RequestLength,
	
	input wire [7:0] DataPacketType,
	input wire [15:0] SendPacketLength,
	
	input wire SendPacket_En,
	output wire SendPacketComplite,
	output wire SendPacketFail,
	
	input wire GetPacket_En,
	output wire GetPacketComplite,
	output wire GetPacketNAK,
	output wire GetPacketFail,
	
	input wire SOF_En,
	output wire Eof1,
	
	
	input wire EndOfPacket,
	input wire K_State,
	input wire J_State,
	input wire Not_J_State,
	
	output wire Dp,
	output wire Dm,
	
	output wire [3:0] Analiz_Num
);

wire [7:0] CRC16_Data = (CRC16_En_Resive) ? CRC16_Data_Resive : CRC16_Data_Transmite;
wire [15:0] CRC16_Res;

wire CRC16_En_Resive;
wire Get_CRC16_Data_Resive;
wire [7:0] CRC16_Data_Resive;

wire CRC16_En_Transmite;
wire Get_CRC16_Data_Transmite;
wire [7:0] CRC16_Data_Transmite;

wire CRC16_Valid;

M_CRC16_USB CRC16
(
	.clk(clk),
	.rst(rst),
	
	.Enable(CRC16_En_Resive | CRC16_En_Transmite),
	.GetData(Get_CRC16_Data_Resive | Get_CRC16_Data_Transmite),
	.Data(CRC16_Data),
	.Valid(CRC16_Valid),
	
	.CRC(CRC16_Res)
);


						
wire GetDataComlite;
wire GetDataFail;
wire [7:0] PacketTypeGet;

M_RESIVE_MODULE RESIVE_MODULE
(
	.clk(clk),
	.rst(rst),
	
	.GetData_En(GetData_En_Send | GetData_En_Get),
	.GetDataComlite(GetDataComlite),
	.GetDataFail(GetDataFail),
	
	.PacketTypeGet(PacketTypeGet),
	.GetData(GetData),
	.GetAddr(GetAddr),
	.GetDataValid(GetDataValid),
	
	.DataAddrBaceGet(DataAddrBaceGet),
	
	.CRC16_En(CRC16_En_Resive),
	.CRC16_GetData(Get_CRC16_Data_Resive),
	.CRC16_Data(CRC16_Data_Resive),
	.CRC16_Res(CRC16_Res),
	.CRC16_Valid (CRC16_Valid),
	
	.EndOfPacket(EndOfPacket),
	.K_State(K_State),
	.J_State(J_State),
	
	.Analiz_Num(Analiz_Num)
);


wire SendTokenComlite;
wire SendTokenFail;
	
wire EndOfPackedComlite;
wire EndOfPackedFail;

wire SendSOF_En;
wire [10:0] FrameNumber;

wire SendControlPipe_En;

wire SendHandshake_En;

wire SendData_En;		
wire SendDataComlite;
wire SendDataFail;

reg [7:0] SendData = 'd0;
reg [15:0] DataAddrBace = 'd0;


M_TRANSMITE_MODULE TRANSMITE_MODULE
(
	.clk(clk),
	.rst(rst),
	
	.Addr(Addr),
	.EndPoint(EndPoint),
	
	.FullSpeedConnect(FullSpeedConnect),
	
	.SendToken_En(SendToken_En_Send | SendToken_En_Get),
	.SendTokenComlite(SendTokenComlite),
	.SendTokenFail(SendTokenFail),
	
	.PacketType(PacketType),
	
	.EndOfPacked_En(EndOfPacked_En_Send | EndOfPacked_En_Get | EndOfPacked_En_SOF),
	.EndOfPackedComlite(EndOfPackedComlite),
	.EndOfPackedFail(EndOfPackedFail),
	
	.SendSOF_En(SendSOF_En),
	.FrameNumber(FrameNumber),
	
	.SendControlPipe_En(SendControlPipe_En),
	.DataTransferDirection(DataTransferDirection),
	.PipeType(PipeType),
	.Recipient(Recipient),
	.Request(Request),
	.RequestValue(RequestValue),
	.RequestIndex(RequestIndex),
	.RequestLength(RequestLength),
	
	.SendHandshake_En(SendHandshake_En),
	
	.SendData_En(SendData_En),		
	.SendDataComlite(SendDataComlite),
	.SendDataFail(SendDataFail),

	.DataPacketType(DataPacketType),
	.SendData(SendData),
	.SendPacketLength(SendPacketLength),
	.DataAddrBace(DataAddrBace),
	
	.CRC16_En(CRC16_En_Transmite),
	.CRC16_Get_Data(Get_CRC16_Data_Transmite),
	.CRC16_Data(CRC16_Data_Transmite),
	.CRC16_Valid(CRC16_Valid),
	.CRC16_Res(CRC16_Res),
	
	.Dp(Dp),
	.Dm(Dm)
	
);

wire GetData_En_Send;
wire SendToken_En_Send;
wire EndOfPacked_En_Send;


M_SEND_PACKET
#(
	.FAIL_MAX(FAIL_MAX)
)
 SEND_PACKET
(
	.clk(clk),
	.rst(rst),
	
	.Eof1(Eof1),
	
	.SendPacket_En(SendPacket_En),
	.SendPacketComplite(SendPacketComplite),
	.SendPacketFail(SendPacketFail),
	
	.PacketTypeSend(PacketType),
	.PacketTypeGet(PacketTypeGet),
	
	.SendToken_En(SendToken_En_Send),
	.SendTokenComlite(SendTokenComlite),
	.SendTokenFail(SendTokenFail),
	
	.SendControlPipe_En(SendControlPipe_En),
	.SendControlPipeComlite(SendDataComlite),
	.SendControlPipeFail(SendDataFail),
	
	.SendData_En(SendData_En),
	.SendDataComlite(SendDataComlite),
	.SendDataFail(SendDataFail),
	
	.GetData_En(GetData_En_Send),
	.GetDataComlite(GetDataComlite),
	.GetDataFail(GetDataFail),
	
	
	.EndOfPacked_En(EndOfPacked_En_Send),
	.EndOfPackedComlite(EndOfPackedComlite),
	.EndOfPackedFail(EndOfPackedFail),
	
	.Not_J_State(Not_J_State)
);

wire GetData_En_Get;
wire SendToken_En_Get;
wire EndOfPacked_En_Get;

M_GET_PACKET
#(
	.FAIL_MAX(FAIL_MAX)
)
 GET_PACKET
(
	.clk(clk),
	.rst(rst),
	
	.Eof1(Eof1),
	.Eof2(Eof2),
	
	.GetPacket_En(GetPacket_En),
	.GetPacketComplite(GetPacketComplite),
	.GetPacketNAK(GetPacketNAK),
	.GetPacketFail(GetPacketFail),
	
	.PacketTypeGet(PacketTypeGet),
	
	.SendToken_En(SendToken_En_Get),
	.SendTokenComlite(SendTokenComlite),
	.SendTokenFail(SendTokenFail),
	
	
	.SendHandshake_En(SendHandshake_En),
	.SendHandshakeComlite(SendTokenComlite),
	.SendHandshakeFail(SendTokenFail),
	
	.GetData_En(GetData_En_Get),
	.GetDataComlite(GetDataComlite),
	.GetDataFail(GetDataFail),
	
	.EndOfPacked_En(EndOfPacked_En_Get),
	.EndOfPackedComlite(EndOfPackedComlite),
	.EndOfPackedFail(EndOfPackedFail),
	
	.Not_J_State(Not_J_State),
	.EndOfPacket(EndOfPacket)
	
);

wire Eof2;
wire EndOfPacked_En_SOF;

M_SOF_SENDER
#(
	.FULLSPEED_WAITE(FULLSPEED_WAITE)
)
 SOF_SENDER
(
	.clk(clk),
	.rst(rst),
	
	.SOF_En(SOF_En),
	
	.FullSpeed(FullSpeedConnect),
	
	.SendSOF_En(SendSOF_En),
	.FrameNumber(FrameNumber),
	.SendSOFComlite(SendTokenComlite),
	.SendSOFFail(SendTokenFail),
	
	.EndOfPacked_En(EndOfPacked_En_SOF),
	.EndOfPackedComlite(EndOfPackedComlite),
	.EndOfPackedFail(EndOfPackedFail),
	
	.Eof1(Eof1),
	.Eof2(Eof2)
);

endmodule 