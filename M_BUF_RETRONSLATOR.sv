module M_BUF_RETRONSLATOR
(
	input wire clk,
	input wire rst,
	
	output reg [15:0] DataAddrBaceGet_Buf = 'd0,
	input wire [15:0] DataAddrBaceGet,
	
	output wire DataValid,
	
	input wire GetDataComlite,
	input wire [15:0] Addr_count_Buf,
	
	output reg [15:0] Addr_count = 'd0
	
);

assign DataValid = (RetronslatorState == S_RETRANSLATE);

reg [7:0] RetronslatorState ='d0;
reg [15:0] Buf_len = 'd0;

localparam 	S_IDLE = 8'd0,
				S_RETRANSLATE = 'd1,
				S_END = 'd2;


always @(posedge clk) 
begin 

	if (rst)
	begin
		RetronslatorState <= S_IDLE;
		DataAddrBaceGet_Buf <= 'd0;
		Addr_count <= 'd0;
	end
	else
	begin
		case (RetronslatorState)
		
		S_IDLE:
		begin
			if (GetDataComlite && Addr_count_Buf != 'd0)
			begin
				if (Addr_count_Buf > 'd1)
				begin
					Buf_len <= Addr_count_Buf - 16'd2;
					DataAddrBaceGet_Buf <= DataAddrBaceGet;
					RetronslatorState <= S_RETRANSLATE;
				end
			end
			else
			begin
				DataAddrBaceGet_Buf <= 'd0;
				Buf_len <= 'd0;
			end
			
			Addr_count <= 'd0;
		end
		
		S_RETRANSLATE:
		begin
			if (Addr_count == Buf_len)
				RetronslatorState <= S_IDLE;
			else	
				Addr_count <= Addr_count + 1'b1;
			
			
			
		end
		
		endcase
	end
end


endmodule 