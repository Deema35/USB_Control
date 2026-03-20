module M_MEMORY_BUF_CRC16
#(
	SIZE = 'd10
)
(
	input wire clk,
	input wire we,
	

	
	input wire [15:0] ReadAddr,
	output wire [7:0] ReadData,
	
	input wire [15:0] WriteAddr,
	input wire [7:0] WriteData,
	
	
	output wire CRC16_GetData,
	output wire [7:0] CRC16_Data,
	output wire [15:0] CRC16_Get
	
	
);


	
reg [7:0] MEMBuf [SIZE - 1:0];	
assign CRC16_GetData = (WriteAddr > 'd1) ? we : 1'b0;
assign ReadData = MEMBuf[ReadAddr];
assign CRC16_Data = MEMBuf[WriteAddr - 'd2];
assign CRC16_Get =  (WriteAddr > 16'd1 ) ? {MEMBuf[WriteAddr], MEMBuf[WriteAddr - 'd1]} : 16'd0;

always @ (posedge clk)
begin
	if (we)
	begin
		
		MEMBuf[WriteAddr]<= WriteData;
	end
end
		

endmodule 