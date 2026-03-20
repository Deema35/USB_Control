module M_GET_DATA
#(
	BYTE_SIZE = 'd7,
	DISABLE_WAITE_COUNT = 1'b0
)
(
	input wire clk,
	input wire rst,
	
	input wire GetData_En,
	
	

	output wire GetDataComlite,
	output wire GetDataFaill,
	
	output reg [15:0]Addr_count = 'd0,
	
	output reg [7:0] PacketTypeGet = 'd0,
	output reg [7:0] Data = 'd0,
	output reg DataValid = 1'b0,
	output reg PacketTypeValid = 1'b0,
	input wire [15:0] CRC16_Get,
	input wire [15:0] CRC16_Res,
	
	
	output wire CRC16_En,
	input wire CRC16_Valid,
	
	
	input wire EndOfPacket,
	input wire K_State,
	input wire J_State,
	
	
	output wire [3:0] Analiz_Num
	
);

assign Analiz_Num[3:0] = GetDataState[3:0];

assign GetDataComlite = (GetDataState == S_END);
assign GetDataFaill = (GetDataState == S_FAIL);

assign CRC16_En = (GetDataState == S_GET_DATA || GetDataState == S_CHECK_CRC);

assign Resiver_En = (GetDataState == S_GET_DATA);

reg StartCount = 1'b0;

reg [3:0] WaiteCounter = 'd0;


reg [7:0] OneCount = 'd0;
reg  Current_J = 'd0;
reg [7:0] PacketCount = 'd0;
reg FistAddr = 1'b0;


localparam 	P_OUT = 8'b11100001,
				P_IN = 8'b01101001,
				P_START_OF_FRAME = 8'b10100101,
				P_SETUP = 8'b00101101,
				P_DATA0 = 8'b11000011,
				P_DATA1 = 8'b01001011,
				P_ACK = 8'b11010010,
				P_NAK = 8'b01011010,
				P_STALL = 8'b00011110;

reg [7:0] GetDataState = S_IDLE;

localparam 	S_IDLE =  8'd0,
				S_START_OF_PACKET = 8'd1,
				S_GET_DATA = 8'd2,
				S_CHECK_CRC = 8'd3,
				
				S_FAIL = 8'd254,
				S_END = 8'd255;


always @(negedge clk) 
begin 

	if (rst)
	begin
		GetDataState <= S_IDLE;
		
		
	end
	else
	begin
		case (GetDataState)
		
		S_IDLE:
		begin
			if (GetData_En)
			begin
				GetDataState <= S_START_OF_PACKET;
				StartCount <= 1'b0;
				WaiteCounter <= 'd0;
				
				PacketTypeValid <= 'd0;
				Data <= 'd0;
				DataValid <= 1'b0;
				PacketCount <= 'd0;
				OneCount <= 'd0;
				FistAddr <= 1'b0;
			end
		end
				
		
		S_START_OF_PACKET:  // Waite 2 k in a row
		begin
		
			if (K_State)
			begin
				if (StartCount)
				begin
					GetDataState <= S_GET_DATA;
				end
				WaiteCounter <= 'd0;
				StartCount <= 1'b1;
			end
			
			else
			begin
				if (&WaiteCounter && !DISABLE_WAITE_COUNT)
				begin
					$display("Get_DATA--> Time out is over");
					GetDataState <= S_FAIL;
					
				end
				
				StartCount <= 1'b0;
				WaiteCounter <= WaiteCounter + 1'b1;
			end
		

		end
		
		
		
		S_GET_DATA:
		begin
			if (K_State)
				WaiteCounter <= 'd0;
			else
			begin
				if (&WaiteCounter && !DISABLE_WAITE_COUNT)
				begin
					GetDataState <= S_FAIL;
				end
				WaiteCounter <= WaiteCounter + 1'b1;
			end
			
			if (EndOfPacket)
			begin
				PacketCount <= 'd0;
				OneCount <= 'd0;
				GetDataState <= S_CHECK_CRC;
			end
			
			
			else if (OneCount == 'd6)
				OneCount <= 'd0;
				
				
			else
			begin
				if (PacketCount == BYTE_SIZE)
				begin
					
					if (!PacketTypeValid)
					begin
						PacketTypeValid <= 1'b1;
						Addr_count <= 'd0;
						FistAddr <= 1'b0;
						PacketTypeGet <= {Current_J == J_State, Data[6:0]};
					end
						
					else
					begin
						DataValid <= 1'b1;
						if (FistAddr) Addr_count <= Addr_count + 1'b1;
						else FistAddr <= 1'b1;
					end
					
					PacketCount <= 'd0;
				end
				
				else 
				begin
					
					PacketCount <= PacketCount + 1'b1;
					
					DataValid <= 1'b0;
				end
				
				Data[PacketCount] <= Current_J == J_State;
				
				if (Current_J == J_State)
					OneCount <= OneCount + 1'b1;
				else 
					OneCount <= 'd0;
			end
			
			
			
			Current_J <= J_State;

			
		end
		
		
		
		S_CHECK_CRC:
		begin
			if (CRC16_Valid)
			begin
				case(PacketTypeGet)
				P_OUT,
				P_IN,
				P_START_OF_FRAME,
				P_SETUP,
				P_DATA0,
				P_DATA1,
				P_ACK,
				P_NAK,
				P_STALL:
				begin
					if(CRC16_Get == CRC16_Res) 
						GetDataState <= S_END;
					
					else 
					begin
						$display("Get_DATA--> Wrong CRC");
						GetDataState <= S_FAIL;
					end
				end
				default:
				begin
					GetDataState <= S_FAIL;
				end
				endcase
				
			end
		end
		
		S_FAIL,
		S_END:
		begin
			if (!GetData_En) 
			begin
				
				GetDataState <= S_IDLE;
			end
			
			DataValid <= 1'b0;
			PacketTypeValid <= 1'b0;
		end
		
		default:
			GetDataState <= S_FAIL;
		
		
		
		endcase
	end
end




endmodule 
