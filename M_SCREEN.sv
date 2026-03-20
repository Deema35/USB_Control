module M_SCREEN
#(
	SCREEN_BUFFER_SIZE = 'd6000
)
(
	input wire clk,
	input wire rst,
	
	output wire Screen_we,
	output wire [15:0] Screen_addr_write,
	output wire [7:0] ScreenData_write,
	
	input wire USB_we,
	input wire [15:0] USB_WriteAddr,
	input wire [7:0] USB_WriteData,
	
	input wire GetName,
	input wire KeyBoardData_En,
	
	input wire Clean_En,
	
	input wire USB_Fail
);

assign Screen_we = (Clean_En) ? 1'b1 : Screen_we_text;
assign Screen_addr_write = (Clean_En) ? Screen_addr_write_clean : Screen_addr_write_text;
assign ScreenData_write = (GetName) ? UniData : (KeyBoardData_En) ? HidData : (Clean_En) ? 'd0 : FailData;

wire [7:0] ScreenText;
wire [7:0] UniAddr;
wire [7:0] UniData;

M_UNICODE_TABLE  Unicode
(
	.UniAddr(UniAddr),
	.UniData(UniData)
);

wire [7:0] HidAddr;
wire [7:0] HidData;

M_HID_CODE_TABLE  Hid_code
(
	.HidAddr(HidAddr),
	.HidData(HidData)
);

wire [7:0] FailAddr;
wire [7:0] FailData;

M_INICIALIZATION_FAIL  INICIALIZATION_FAIL
(
	.FailAddr(FailAddr),
	.FailData(FailData)
);


wire Screen_we_clean;
wire [15:0] Screen_addr_write_clean;

M_SCREEN_CLANER
#(
	.SCREEN_BUFFER_SIZE(SCREEN_BUFFER_SIZE)
)
SCREEN_CLANER
(
	.clk(clk),
	.Clean_En(Clean_En),
	
	.Screen_addr_write(Screen_addr_write_clean)
);





wire Screen_we_text;
wire [15:0] Screen_addr_write_text;

M_TEXT_CONTROLLER TEXT_CONTROLLER
(
	.clk(clk),
	.rst(rst),
	
	.USB_we(USB_we),
	.USB_WriteAddr(USB_WriteAddr),
	.USB_WriteData(USB_WriteData),
	.GetName(GetName),
	.KeyBoardData_En(KeyBoardData_En),
	
	.USB_Fail(USB_Fail),
	
	.Screen_we(Screen_we_text),
	.Screen_addr_write(Screen_addr_write_text),
	
	.UniAddr(UniAddr),
	.HidAddr(HidAddr),
	.FailAddr(FailAddr)
	
);

endmodule 