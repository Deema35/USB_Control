module M_TRANSMITE_MODULE
#(
	HANDSHAKE_LEN = 'd7,
	TOKEN_LEN = 'd23,
	SOF_LEN = 'd23
)
(
	input wire clk,
	input wire rst,
	
	input wire FullSpeedConnect,
	
	input wire [6:0] Addr,
	input wire [3:0] EndPoint,
	
	input wire SendToken_En,
	output wire SendTokenComlite,
	output wire SendTokenFail,

	input wire [7:0] PacketType,
	
	input wire EndOfPacked_En,
	output wire EndOfPackedComlite,
	output wire EndOfPackedFail,
	
	input wire SendSOF_En,
	input wire [10:0] FrameNumber,

	
	input wire SendControlPipe_En,
	input wire DataTransferDirection,
	input wire [1:0] PipeType,
	input wire [4:0] Recipient,
	input wire [7:0] Request,
	input wire [15:0] RequestValue,
	input wire [15:0] RequestIndex,
	input wire [15:0] RequestLength,
	
	input wire SendHandshake_En,
	
	input wire SendData_En,
	output wire SendDataComlite,
	output wire SendDataFail,

	input wire [7:0] DataPacketType,

	output wire [15:0] SendDataAddr,
	output wire SendReady,
	input wire [7:0] SendData,
	input wire [15:0] SendPacketLength,
	input wire [15:0] DataAddrBace,
	
	output wire CRC16_En,
	output wire CRC16_Get_Data,
	output wire [7:0] CRC16_Data,
	input wire CRC16_Valid,
	input wire [15:0] CRC16_Res,

	
	output wire Dp,
	output wire Dm
);





wire TransferReady;
wire TransferReadyMinusOne;
wire [7:0] TransferState_Token;
wire CRC5_En_Token;
wire CRC5_En;

M_SEND_TOKEN SEND_TOKEN
(
	.clk(clk),
	.rst(rst),
	
	.SendToken_En(SendToken_En | SendSOF_En | SendHandshake_En),
	
	.CRC5_En(CRC5_En),
	
	.TransferReady(TransferReady),
	.State_main(TransferState_Token),
	
	.TransferLenght(TransferLenght),
	
	.SendTokenComlite(SendTokenComlite),
	.SendTokenFail(SendTokenFail)
);


wire [4:0] CRC5_Res;

wire [6:0] CRC5_Addr = (SendToken_En) ? Addr : (SendSOF_En) ? FrameNumber[6:0] : 'd0;
wire [3:0] CRC5_EndPoint = (SendToken_En) ? EndPoint : (SendSOF_En) ? FrameNumber[10:7] : 'd0;


M_CRC5 CRC5
(
	.clk(clk),
	.CRC_En(CRC5_En),
	
	.Addr(CRC5_Addr),
	.EndPoint(CRC5_EndPoint),
	
	.CRC(CRC5_Res)
);


wire [7:0] TransferState_EndOfPacked;

M_SEND_END_OF_PACKED SEND_END_OF_PACKED

(
	.clk(clk),
	.rst(rst),
	.EndOfPacked_En(EndOfPacked_En),
	
	.State_EndOfPacked(TransferState_EndOfPacked),
	
	.EndOfPackedComlite(EndOfPackedComlite),
	.EndOfPackedFail(EndOfPackedFail)

);





reg [7:0] ControlPipe [7:0];
assign ControlPipe[0] = {DataTransferDirection, PipeType, Recipient};
assign ControlPipe[1] = Request;
assign {ControlPipe[3], ControlPipe[2]} = RequestValue;
assign {ControlPipe[5], ControlPipe[4]} = RequestIndex;
assign {ControlPipe[7], ControlPipe[6]} = RequestLength;


wire [15:0] SendDataAddr_controlpipe;

wire [7:0] DataPacketType_Send = (SendData_En) ? DataPacketType : 8'b11000011;

wire [7:0] Data = (SendData_En) ? SendData : ControlPipe[SendDataAddr];
assign CRC16_Data = Data;

wire [15:0] PacketLength = (SendData_En) ? SendPacketLength : 16'd8;
wire [15:0]DataAddrBace_Send = (SendData_En) ? DataAddrBace : 16'd0;

wire [31:0] DataBuf_SendData;
wire [7:0] TransferState_SendData;
wire [7:0] TransferLenght_SendData;



M_SEND_DATA SEND_DATA
(
	.clk(clk),
	.rst(rst),
	
	
	.SendData_En(SendData_En | SendControlPipe_En),
	
	.DataPacketType(DataPacketType_Send),

	.DataAddr(SendDataAddr),	
	.Data(Data),
	.SendReady(SendReady),
	
	.PacketLength(PacketLength),
	.DataAddrBace(DataAddrBace_Send),
	
	.TransferReady(TransferReady),
	.TransferReadyMinusOne( TransferReadyMinusOne),
	.DataBuf(DataBuf_SendData),
	.TransferLenght(TransferLenght_SendData),
	.State_DataSend(TransferState_SendData),
	
	.SendDataComlite(SendDataComlite),
	.SendDataFail(SendDataFail),
	
	
	.CRC16_En(CRC16_En),
	.CRC16_Get_Data(CRC16_Get_Data),
	.CRC16_Valid(CRC16_Valid),
	.CRC16_Res(CRC16_Res)
	
);



wire [31:0] DataBuf =   (SendToken_En) ? {8'd0, CRC5_Res, EndPoint, Addr, PacketType} :
								(SendControlPipe_En) ? DataBuf_SendData : 
								(SendHandshake_En) ? {24'd0, 8'b11010010} :
								(SendData_En) ? DataBuf_SendData :
								(SendSOF_En) ? {8'd0, CRC5_Res, FrameNumber, 8'b10100101} : 'd0;
								
wire [7:0] TransferState = (SendToken_En) ? TransferState_Token :
									(SendControlPipe_En) ? TransferState_SendData :
									(SendHandshake_En) ? TransferState_Token :
									(SendData_En) ? TransferState_SendData :
									(SendSOF_En) ? TransferState_Token :
									(EndOfPacked_En) ? TransferState_EndOfPacked : 8'd0;
									
									
wire [7:0] TransferLenght = (SendToken_En) ? TOKEN_LEN :
									 (SendControlPipe_En) ? TransferLenght_SendData :
									 (SendHandshake_En) ? HANDSHAKE_LEN :
									 (SendData_En) ? TransferLenght_SendData :
									 (SendSOF_En) ? SOF_LEN : 8'd0;

M_DATA_TRANSFER DATA_TRANSFER
(
	.clk(clk),
	.DataBuf(DataBuf),
	.TransferState(TransferState),
	.TransferLenght(TransferLenght),
	.FullSpeedConnect(FullSpeedConnect),
	
	.TransferReady(TransferReady),
	.TransferReadyMinusOne(TransferReadyMinusOne),
	
	.Dp(Dp),
	.Dm(Dm)
);

endmodule 