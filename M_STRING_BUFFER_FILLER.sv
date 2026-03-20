module M_STRING_BUFFER_FILLER
#(
	parameter FONT_HEIGHT = 16'd10,
	parameter FONT_WITH = 16'd8,
	parameter SIGNSTRING_LENGTH = 16'd100,
	parameter FONT_COLOR = 12'b000011111111,
	parameter BACKGROUND_COLOR = 12'b000000000000
)
(
	input wire clk,
	input wire rst,
	
	output reg [15:0] Screen_addr_read = 'd0,
	input wire [7:0] Screen_data_read,
	
	input wire Hblank,
	input wire Vblank,
	
	input wire [10:0] V_count,
	
	output reg StringRAM_we = 1'b0,
	output reg [15:0]StringRAM_write_addr = 'd0,
	output reg [15:0] StringRAM_data = 'd0,
	
	output reg [7:0] FontAddr,
	output reg [7:0] FontOffset,
	input wire [7:0] Font_data
);

reg [15:0]Pix_H_Counter = 'd0;

reg [15:0] SymbolString = 'd0;
reg [15:0] SymbolNum = 'd0;

reg [7:0] Font_Pix_Count = 'd0;

reg [3:0] m_State = 'd0;

parameter   S_BEGIN = 4'd0,
				S_GET_FONT = 4'd1,
				S_SET_SCREEN_RAM_ADDRESS  = 4'd2,
				S_FILLSTRING = 4'd4,
				S_PIX_COUNT_INCREAS = 4'd5;
				
				
				
always @(posedge clk)
begin
	if (rst)
	begin
		m_State <= 4'd0;
	end
	
	else 
	begin
	
	case(m_State)
		S_BEGIN:
		begin
			if (Hblank && !Vblank)
			begin
				FontAddr <= 'd0;
				StringRAM_we <= 1'b0;
				SymbolString <= V_count / FONT_HEIGHT;
				SymbolNum <= 16'd0;
				
				Pix_H_Counter <= 'd0;
				FontOffset <= V_count % FONT_HEIGHT;
				
				m_State <= S_SET_SCREEN_RAM_ADDRESS;
			end
			
		end
		
		S_SET_SCREEN_RAM_ADDRESS:
		begin
			Screen_addr_read <= SymbolNum + (SymbolString * SIGNSTRING_LENGTH);
			m_State <= S_GET_FONT;
		end
		
		S_GET_FONT:
		begin
			FontAddr <= Screen_data_read;
			Font_Pix_Count <= 'd0;
			m_State <= S_FILLSTRING;
		end
		
		S_FILLSTRING:
		begin
			
			
			StringRAM_data <= (Font_data[Font_Pix_Count]) ? FONT_COLOR : BACKGROUND_COLOR;
			StringRAM_write_addr <= Pix_H_Counter + Font_Pix_Count;

			
			if (Font_Pix_Count != FONT_WITH - 1'b1) 
			begin
				Font_Pix_Count <= Font_Pix_Count + 1'b1;
				StringRAM_we <= 1'b1;
			end
			
			else 
			begin
				if (SymbolNum == SIGNSTRING_LENGTH)
				begin
					StringRAM_we <= 1'b0;
					m_State <= S_BEGIN;
					
				end
				else
				begin
					m_State <= S_SET_SCREEN_RAM_ADDRESS;
					Pix_H_Counter <= Pix_H_Counter + FONT_WITH;
					SymbolNum <= SymbolNum + 1'b1;
				end
			
			end
			
		end
		
		
		
		
	endcase
		
	end
	
end

endmodule 