module USB_Controller
#(
	parameter FONT_COLOR = 12'b000011111111,
	parameter BACKGROUND_COLOR = 12'b000000000000,
	parameter SCREEN_BUFFER_SIZE = 'd6000
)
(
	input wire clk_50,
	input reg RESET_N,
	input reg KEY_N,
	output wire LEDR,
	
	
	//Video interfase
	output wire Hsync,
	output wire Vsync,
	output wire [3:0]  Red,
	output wire [3:0]  Green,
	output wire [3:0]  Blue,
	

	
	//USB interface
	inout tri Usb_Dp,
	inout tri Usb_Dm,
	
	output wire Analiz_Dp,
	output wire Analiz_Dm,
	output wire [3:0]Analiz_Num
);

assign LEDR = (!Flag);
wire Flag;

assign Analiz_Dp = Usb_Dp;
assign Analiz_Dm = Usb_Dm;

wire clk_1k5;
wire clk_12;

pll USB_pll
(
	.inclk0(clk_50),
	.c0(clk_1k5),
	.c1(clk_12)
);

wire clk_120;
wire clk_40;

VPLL Video_pll
(
	.inclk0(clk_50),
	.c0(clk_120),
	.c1(clk_40)
);


//Video


wire [15:0]Pix_color;
wire [10:0] H_count;
wire [10:0] V_count;
wire Hblank;

M_VIDEO_ADAPTER Video
(
	.clk(clk_40),
	.rst(!RESET_N),
	.Pix_color(Pix_color),
	
	.Hsync(Hsync),
	.Vsync(Vsync),
	
	.Red(Red),
	.Green(Green),
	.Blue(Blue),
	
	.Hblank(Hblank),
	.Vblank(Vblank),
	
	.H_count(H_count),
	.V_count(V_count)
	
	
);



wire StringRAM_we;
wire [15:0]StringRAM_write_addr;
wire [15:0] StringRAM_data;

M_MEMORY_BUF 
#(
	.SIZE('d800)
)
StringRAM
(
	.clk(clk_120),
	.we(StringRAM_we),
	
	.ReadAddr(H_count),
	.ReadData(Pix_color),
	
	.WriteAddr(StringRAM_write_addr),
	.WriteData(StringRAM_data)
	
);

wire [7:0] FontAddr;
wire [7:0] FontOffset;
wire [7:0] Font_data;

M_FONT_ROM  FontRom
(
	.FontAddr(FontAddr),
	.FontOffset(FontOffset),
	.Font_data(Font_data)
);

wire [15:0] Screen_addr_read;
wire [7:0] Screen_data_read;

M_STRING_BUFFER_FILLER
#(
	.FONT_COLOR(FONT_COLOR),
	.BACKGROUND_COLOR(BACKGROUND_COLOR)
)
 BUFFER_FILLER
(
	.clk(clk_120),
	.rst(!RESET_N),
	
	.Screen_addr_read(Screen_addr_read),
	.Screen_data_read(Screen_data_read),
	
	.Hblank(Hblank),
	.Vblank(Vblank),
	.V_count(V_count),
	
	.StringRAM_we(StringRAM_we),
	.StringRAM_write_addr(StringRAM_write_addr),
	.StringRAM_data(StringRAM_data),
	
	.FontAddr(FontAddr),
	.FontOffset(FontOffset),
	.Font_data(Font_data)
);

wire Screen_we;
wire [15:0] Screen_addr_write;
wire [7:0] ScreenData_write;

M_MEMORY_BUF 
#(
	.SIZE(SCREEN_BUFFER_SIZE)
)
ScreenRam
(
	.clk(USB_clk),
	.we(Screen_we),
	
	.ReadAddr(Screen_addr_read),
	.ReadData(Screen_data_read),
	
	.WriteAddr(Screen_addr_write),
	.WriteData(ScreenData_write)
);


M_SCREEN
#(
	.SCREEN_BUFFER_SIZE(SCREEN_BUFFER_SIZE)
)
 SCREEN
(
	.clk(USB_clk),
	.rst(!RESET_N || Disconnect),
	
	.Screen_we(Screen_we),
	.Screen_addr_write(Screen_addr_write),
	.ScreenData_write(ScreenData_write),
	
	
	.USB_we(USB_we),
	.USB_WriteAddr(USB_WriteAddr),
	.USB_WriteData(USB_WriteData),
	
	.GetName(GetName),
	.KeyBoardData_En(KeyBoardData_En),
	
	.Clean_En(!RESET_N || Disconnect),
	
	.USB_Fail(USB_Fail)
);


//USB

wire USB_clk;
wire USB_we;
wire GetName;
wire KeyBoardData_En;
wire [15:0]USB_ReadAddr;
wire [7:0] USB_ReadData;
	
wire [15:0] USB_WriteAddr;
wire [7:0] USB_WriteData;
wire USB_Fail;
wire Disconnect;

M_USB USB
(
	.Low_clk(clk_1k5),
	.Hi_clk(clk_12),
	.ResetOut(!RESET_N),
	
	.clk_out(USB_clk),
	.GetDataValid(USB_we),
	.GetName(GetName),
	.KeyBoardData_En(KeyBoardData_En),
	
	.GetAddr(USB_WriteAddr),
	.GetData(USB_WriteData),
	
	.Fail(USB_Fail),
	.Disconnect(Disconnect),
	
	
	.Dp(Usb_Dp),
	.Dm(Usb_Dm),
	
	
	.Flag(Flag),
	
	.Analiz_Num(Analiz_Num)
);

endmodule 