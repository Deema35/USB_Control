module M_SCREEN_CLANER
#(
	SCREEN_BUFFER_SIZE = 'd6000
)
(
	input wire clk,
	input wire Clean_En,
	
	output reg [15:0] Screen_addr_write = 'd0
);


reg [7:0]m_Clean_State = 'd0;

parameter	S_IDLE = 8'd0,
				S_CLEAN = 8'd1,
				
				S_END = 8'd255;
				
				

always @(posedge clk)
begin
	
	case (m_Clean_State)
	S_IDLE:
	begin
		if (Clean_En)
		begin
			m_Clean_State <= S_CLEAN;
		end
		
		Screen_addr_write <= 'd0;
	end
	
	S_CLEAN:
	begin
		if (Screen_addr_write == SCREEN_BUFFER_SIZE - 1'b1)
		begin
			m_Clean_State <= S_END;
			Screen_addr_write <= 'd0;
		end
		else if (!Clean_En)
		begin
			m_Clean_State <= S_IDLE;
		end
		else
			Screen_addr_write <= Screen_addr_write + 1'b1;
	end
	
	S_END:
	begin
		if (!Clean_En)
			m_Clean_State <= S_IDLE;
		
	end
	endcase
end
endmodule 