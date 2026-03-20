module M_MEMORY_BUF
#(
	SIZE = 'd10
)
(
	input wire clk,
	input wire we,
	
	input wire [15:0] ReadAddr,
	output wire [7:0] ReadData,
	
	input wire [15:0] WriteAddr,
	input wire [7:0] WriteData
	
);


	
reg [7:0] MEMBuf [SIZE - 1:0];	

assign ReadData = MEMBuf[ReadAddr];
				

always @ (posedge clk)
begin
	if (we)
	begin
		MEMBuf[WriteAddr]<= WriteData;
	end
end
		

endmodule 