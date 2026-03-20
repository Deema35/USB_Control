module M_SEND_DATA
(
	input wire clk,
	input wire rst,
	
	
	input wire SendData_En,
	
	input wire [7:0] DataPacketType,

	output wire [15:0]	DataAddr,		
	input wire [7:0] Data,
	output reg SendReady = 1'b0,
	
	input wire [15:0] PacketLength,
	input wire [15:0]	DataAddrBace,
	
	input wire TransferReady,
	input wire TransferReadyMinusOne,
	
	output reg [31:0] DataBuf,
	output reg [7:0] TransferLenght = 'd0,
	output reg [7:0] State_DataSend = 8'd0,
	
	output reg SendDataComlite = 1'b0,
	output reg SendDataFail = 1'b0,
	
	
	output reg CRC16_En = 1'b0,
	output reg CRC16_Get_Data = 1'b0,
	input wire CRC16_Valid,
	input wire [15:0] CRC16_Res
	
);


reg [15:0]Byte_count = 'd0;

assign DataAddr = Byte_count + DataAddrBace;


reg [7:0] PacketCount = 'd0;



localparam 	S_IDLE = 8'd0,
				S_START_OF_PACKET_K = 8'd1,
				S_START_OF_PACKET_J = 8'd2,
				S_START_OF_PACKET_K_END = 8'd3,
				S_SEND_PACKET_TYPE = 8'd4,
				S_SEND_DATA = 8'd5,
				S_SEND_CRC = 8'd6,
				
				S_END_OF_PACKET_SE0 = 8'd13,
				S_END_OF_PACKET_J = 8'd14,
				S_END = 8'd15;



always @(posedge clk) 
begin 

	if (rst)
	begin
		
		State_DataSend <= S_IDLE;
		
	end
	else
	begin
	
		case (State_DataSend)
		S_IDLE:
		begin
		
			if (SendData_En)
			begin
				State_DataSend <= S_START_OF_PACKET_K;
				CRC16_En <= 1'b1;
				PacketCount <= 'd0;
			end
		end
		
		S_START_OF_PACKET_K: State_DataSend <= S_START_OF_PACKET_J;
		
		S_START_OF_PACKET_J:
		begin
			if (PacketCount == 2) 
			begin
				PacketCount <= 'd0;
				State_DataSend <= S_START_OF_PACKET_K_END;
			end
			else
			begin
				PacketCount = PacketCount + 1'b1;
				State_DataSend <= S_START_OF_PACKET_K;
			end
		end
		S_START_OF_PACKET_K_END:
		begin
			if (PacketCount == 1)
			begin
				PacketCount <= 'd0;
				
				TransferLenght <= 'd7;
				DataBuf[7:0] <= DataPacketType;
				
				State_DataSend <= S_SEND_PACKET_TYPE;
			end
			else PacketCount <= PacketCount + 1'b1;
		end
		
		S_SEND_PACKET_TYPE:
		begin
			SendReady <= 1'b1;
			Byte_count <= 'd0;
			if (TransferReady)
			begin
				CRC16_Get_Data <= 1'b1;
				
				
				TransferLenght <= 'd7;
				
				DataBuf[7:0] <= Data;
				
				
				State_DataSend <= S_SEND_DATA;
			end
			
		end
		
		S_SEND_DATA:
		begin
			if (PacketLength == Byte_count)
			begin
				
				
				if (PacketLength == 'd0) DataBuf <= 'd0;
			
				else DataBuf <= CRC16_Res;
				
				TransferLenght <= 'd15;
				State_DataSend <= S_SEND_CRC;
				
			end
		
			else if (TransferReady)
			begin
				DataBuf[7:0] <= Data;
				CRC16_Get_Data <= 1'b1;
			end
			else if (TransferReadyMinusOne)
			begin
				
					Byte_count <= Byte_count + 1'b1;
				
			end
			
			else
				CRC16_Get_Data <= 1'b0;
			
			
			
			
			
		end
		
		S_SEND_CRC:
		begin
			
				
			if (TransferReady) 
			begin
				
				Byte_count <= 'd0;
				State_DataSend <= S_END_OF_PACKET_SE0;
				
				PacketCount <= 'd0;
			end
			
			CRC16_Get_Data <= 1'b0;
		end
		
		
		S_END_OF_PACKET_SE0:
		begin
			SendReady <= 1'b0;
			if (PacketCount == 'd0)
			begin
				State_DataSend <= S_END_OF_PACKET_J;
				PacketCount <= 'd0;
			end
			else PacketCount <= PacketCount + 1'b1;
			
		end
		
		S_END_OF_PACKET_J:
		begin
			if (PacketCount == 'd2)
			begin
				State_DataSend <= S_END;
				PacketCount <= 'd0;
			end
			else PacketCount <= PacketCount + 1'b1;
			
		end
		
		S_END:
		begin
			if (SendData_En)
			begin
				SendDataComlite = 1'b1;
				CRC16_En <= 1'b0;
			end
			else
			begin
				SendDataComlite = 1'b0;
				State_DataSend <= S_IDLE;
			end
			
		end
		
		default:
		begin
			if (SendData_En)
			begin
				SendDataFail = 1'b1;
				CRC16_En <= 1'b0;
			end
			else
			begin
				SendDataFail = 1'b0;
				State_DataSend <= S_IDLE;
			end
			
		end
		
		endcase
	end
end



endmodule 