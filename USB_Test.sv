module USB_Test
#(
	FULL_SPEED = 1'b1,
	SEND_ERROR_BLOCK = 1'b1
);

wire Usb_Dp;
wire Usb_Dm;

reg rst = 1'b0;
reg Low_clk = 1'b0;
reg Hi_clk = 1'b0;

wire Fail;

always #1 Low_clk = ~Low_clk;
always #1 Hi_clk = ~Hi_clk;

wire clk = (FULL_SPEED) ? Hi_clk :  Low_clk;

wire [7:0] MAX_Packet_Size;

wire USB_clk;
wire USB_we;
reg [15:0]USB_ReadAddr = 'd0;
wire [7:0] USB_ReadData;

wire [15:0] USB_WriteAddr;
wire [7:0] USB_WriteData;
wire GetName;
wire KeyBoardData_En;

M_USB
#(
	.SKIP_POWER_RISE(1'b1)
	//.FULLSPEED_WAITE(16'd1_000)
)

 USB
(
	.Low_clk(Low_clk),
	.Hi_clk(Hi_clk),
	.ResetOut(rst),
	
	.Fail(Fail),
	
	.clk_out(USB_clk), 
	.GetDataValid(USB_we),
	.GetName(GetName),
	.KeyBoardData_En(KeyBoardData_En),
	
	.GetAddr(USB_WriteAddr),
	.GetData(USB_WriteData),
	
	.Dp(Usb_Dp),
	.Dm(Usb_Dm),
	
	.MAX_Packet_Size(MAX_Packet_Size)
);

M_MEMORY_BUF MEMORY_BUF
(
	.clk(USB_clk),
	.we(USB_we),
	
	
	.ReadAddr(USB_ReadAddr),
	.ReadData(USB_ReadData),
	
	.WriteAddr(USB_WriteAddr),
	.WriteData(USB_WriteData)
);

wire [15:0] Screen_addr_read;
wire [7:0] Screen_data_read;

wire Screen_we;
wire [15:0] Screen_addr_write;
wire [7:0] ScreenData_write;

M_MEMORY_BUF 
#(
	.SIZE('d6000)
)
ScreenRam
(
	.clk(clk),
	.we(Screen_we),
	
	.ReadAddr(Screen_addr_read),
	.ReadData(Screen_data_read),
	
	.WriteAddr(Screen_addr_write),
	.WriteData(ScreenData_write)
);

M_SCREEN SCREEN
(
	.clk(USB_clk),
	.rst(rst),
	
	.Screen_we(Screen_we),
	.Screen_addr_write(Screen_addr_write),
	.ScreenData_write(ScreenData_write),
	
	.USB_we(USB_we),
	.USB_WriteAddr(USB_WriteAddr),
	.USB_WriteData(USB_WriteData),
	
	.GetName(GetName),
	.KeyBoardData_En(KeyBoardData_En),
	
	.Clean_En(rst),
	
	.USB_Fail(Fail)
);


wire [7:0] SendData;

reg StringComp = 1'b0;
wire [15:0] SendDataAddr = (StringComp) ? SendDataAddr_Test : SendDataAddr_Slave;
wire [15:0] SendDataAddr_Slave;
reg [15:0] SendDataAddr_Test = 'd0;

wire [15:0] DescriptorID = (StringComp) ? DescriptorID_Test : DescriptorID_Slave;
wire [15:0] DescriptorID_Slave;
reg [15:0] DescriptorID_Test = 'd0;
reg Disconnect = 1'b0;

wire SlaveFaill;

M_USB_Slave
#(
	.FULL_SPEED(FULL_SPEED),
	.SEND_ERROR_BLOCK(SEND_ERROR_BLOCK)
)
 USB_Slave
(
	.Low_clk(Low_clk),
	.Hi_clk(Hi_clk),
	.rst(rst),
	
	.MAX_Packet_Size(MAX_Packet_Size),
	
	.SendDataAddr(SendDataAddr_Slave),
	.SendData(SendData),
	.DescriptorID(DescriptorID_Slave),
	
	.SlaveFaill(SlaveFaill),
	.Disconnect(Disconnect),
	
	.Dp_Sl(Usb_Dp),
	.Dm_Sl(Usb_Dm)
);

M_DEVICE_DESCRIPTOR DEVICE_DESCRIPTOR
(
	.Addr(SendDataAddr),
	.Data(SendData),
	.DescriptorID(DescriptorID)
);

reg [7:0] DisconnectTimer = 'd0;

reg [7:0] State ='d0;

localparam 	S_START_TEST = 8'd0,
				S_IDLE = 8'd1,
				
				S_GET_DATA_01 = 8'd2,
				S_COMPER_STRING_01 = 8'd3,
				S_IDLE_02 = 8'd4,
				S_GET_DATA_02 = 8'd5,
				S_COMPER_STRING_02 = 8'd6,
				S_DISCONNECT = 8'd7,
				S_CONNECT = 8'd8,

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
		$display("*********** USB test start. ***********");
		$write("%c[0m",27);
		State <= S_IDLE;
	end
	
	S_IDLE:
	begin
		if (KeyBoardData_En) 
			State <= S_GET_DATA_01;
		else if (Fail || SlaveFaill)
			State <= S_FAIL;
			
	end
	
	
	
	S_GET_DATA_01:
	begin
		if (!KeyBoardData_En) 
		begin
			State <= S_COMPER_STRING_01;
			USB_ReadAddr <= 'd0;
			SendDataAddr_Test <= 'd0;
			StringComp <= 1'b1;
			DescriptorID_Test <= 'h00_01;
		end
	end
	
	S_COMPER_STRING_01:
	begin
		if (SendData != USB_ReadData)
			State <= S_FAIL;
			
		else if (USB_ReadAddr == 'd7)
			State <= S_IDLE_02;
			
		USB_ReadAddr <= USB_ReadAddr + 1'b1;
		SendDataAddr_Test <= USB_ReadAddr + 1'b1;
		
	end
	
	S_IDLE_02:
	begin
		if (USB_WriteAddr == 'd1) 
			State <= S_GET_DATA_02;
		else if (Fail || SlaveFaill)
			State <= S_FAIL;
			
		StringComp <= 1'b0;
	end
	
	S_GET_DATA_02:
	begin
		if (!KeyBoardData_En) 
		begin
			State <= S_COMPER_STRING_02;
			USB_ReadAddr <= 'd0;
			SendDataAddr_Test <= 'd0;
			StringComp <= 1'b1;
			DescriptorID_Test <= 'h00_02;
		end
	end
	
	S_COMPER_STRING_02:
	begin
		if (SendData != USB_ReadData)
			State <= S_FAIL;
			
		else if (USB_ReadAddr == 'd1)
			State <= S_DISCONNECT;
			
		USB_ReadAddr <= USB_ReadAddr + 1'b1;
		SendDataAddr_Test <= USB_ReadAddr + 1'b1;
		
	end
	
	S_DISCONNECT:
	begin
		if (&DisconnectTimer)
		begin
			
			DisconnectTimer <= 'd0;
			Disconnect <= 1'b0;
			State <= S_CONNECT;
		end
		else
			DisconnectTimer <= DisconnectTimer + 1'b1;
			Disconnect <= 1'b1;
		
	end
	
	S_CONNECT:
	begin
		if (&DisconnectTimer)
		begin
			
			DisconnectTimer <= 'd0;
			
			State <= S_COMPLITE;
		end
		else
			DisconnectTimer <= DisconnectTimer + 1'b1;
			Disconnect <= 1'b0;
		
	end
	
	
	S_COMPLITE:
	begin
		$write("%c[1;32m",27);
		$display("USB test Complite, time =", $stime);
		$display("%c[0m",27);
		
		State <= S_END;
	end
	
	S_FAIL: 
	begin
		$write("%c[1;31m",27);
		$display("USB test Fail, time =", $stime);
		$display("%c[0m",27);
		State <= S_END;
	end
	
	S_END:
		rst <= 1'b1;
	
	endcase
end

initial  #60000 $finish;

initial
begin
  $dumpfile("out.vcd");
  $dumpvars(0,USB_Test);
end

//initial $monitor($stime,,, State,, StringComp);

endmodule 