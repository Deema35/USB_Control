module M_TEXT_CONTROLLER
(
	input wire clk,
	input wire rst,
	
	input wire USB_we,
	input wire [15:0] USB_WriteAddr,
	input wire [7:0] USB_WriteData,
	input wire GetName,
	input wire KeyBoardData_En,
	
	input wire USB_Fail,
	
	output reg Screen_we = 'b0,
	output wire [15:0] Screen_addr_write,
	
	output reg [7:0] UniAddr = 'd0,
	output reg [7:0] HidAddr = 'd0,
	
	output reg [7:0] FailAddr = 'd0
	
);


reg [7:0] String_Num = 'd0; //0..60

reg [15:0] Letter_Num = 'd0; //0..100
reg [15:0] BaceLetter_Num = 'd0;
reg NewString = 1'b1;

assign Screen_addr_write = String_Num * 16'd100 + BaceLetter_Num + Letter_Num;

reg [7:0]m_Text_State = 'd0;
parameter	S_IDLE = 8'd0,
				S_GET_DEVICE_NAME = 8'd1,
				S_GET_DATA = 8'd2,
				S_USB_FAIL = 8'd3,
				
				S_END = 8'd255;
				
				

always @(posedge clk)
begin
	if (rst)
	begin
		m_Text_State <= 'd0;
		String_Num <= 'd0;
		Letter_Num <= 'd0;
		Screen_we <= 1'b0;
		UniAddr <= 'd0;
		HidAddr <= 'd0;
		FailAddr <= 'd0;
		BaceLetter_Num <= 'd0;
		NewString <= 1'b1;
	end
	else
	begin
		case (m_Text_State) 
		S_IDLE:
		begin
			if (GetName) 
			begin
				
				if (USB_WriteData)
				begin
					
					Screen_we <= 1'b1;
					
					UniAddr <= USB_WriteData;
					
				end
				
				m_Text_State <= S_GET_DEVICE_NAME;
			end
				
			else if (KeyBoardData_En)
			begin
				if (USB_we && USB_WriteData)
				begin
					if (NewString)
						NewString <= 1'b0;
					else
						Letter_Num <= Letter_Num + 1'b1;
						
					Screen_we <= 1'b1;
					HidAddr <= USB_WriteData;
				end
				m_Text_State <= S_GET_DATA;
			end
				
			else if (USB_Fail)
			begin
				Screen_we <= 1'b1;
				m_Text_State <= S_USB_FAIL;
			end
		end
		S_GET_DEVICE_NAME:
		begin
			if (!GetName)
			begin
				String_Num <= String_Num + 1'b1;
				NewString <= 1'b1;
				Letter_Num <= 'd0;
				Screen_we <= 1'b0;
				
				m_Text_State <= S_IDLE;
				
			end
			else if (!USB_we) 
			begin
				Screen_we <= 1'b0;
			end
			else
			begin
				if (|USB_WriteData)
				begin
					
					Screen_we <= 1'b1;
					
					Letter_Num <= Letter_Num + 1'b1;
						
					UniAddr <= USB_WriteData;
					
				end
			end
		end
		S_GET_DATA:
		begin
			if (!KeyBoardData_En)
			begin
				Screen_we <= 1'b0;
				BaceLetter_Num <= BaceLetter_Num + Letter_Num;
				Letter_Num  <= 'd0;
				m_Text_State <= S_IDLE;
				
			end
			else if (!USB_we) 
			begin
				Screen_we <= 1'b0;
			end
			else
			begin
				if (USB_we && USB_WriteData)
				begin
					Screen_we <= 1'b1;
					if (NewString)
						NewString <= 1'b0;
					else
						Letter_Num <= Letter_Num + 1'b1;
						
					HidAddr <= USB_WriteData;
					
				end
			end
		end
		
		S_USB_FAIL:
		begin
			if (FailAddr != 'd19)
			begin
				Screen_we <= 1'b1;
				FailAddr <= FailAddr + 1'b1;
				Letter_Num <= Letter_Num + 1'b1;
			end
			else
			begin
				Screen_we <= 1'b0;
				m_Text_State <= S_IDLE;
			end
		end
		
		
		endcase 
	end
end

endmodule





