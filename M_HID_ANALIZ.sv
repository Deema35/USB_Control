module M_HID_ANALIZ
(
	input wire clk,
	input wire rst,
	
	input wire Analiz_En,
	output wire Analiz_Comlite,
	output wire Analiz_Fail,
	
	input wire DataValid,
	input wire [7:0]Data,
	
	input wire [7:0] EndPointPacket_size,
	
	output reg [7:0] CollectionNum = 'd0,
	
	output reg FT_we = 1'b0,
	output reg [15:0] FT_ReadAddr = 'd0,
	input wire [7:0] FT_ReadData,
	output reg [15:0] FT_WriteAddr = 'd0,
	output reg [7:0] FT_WriteData = 'd0,
	
	output reg FV_we = 1'b0,
	output reg [15:0] FV_ReadAddr = 'd0,
	input wire [7:0] FV_ReadData,
	output reg [15:0] FV_WriteAddr = 'd0,
	output reg [7:0] FV_WriteData = 'd0,
	
		
	output reg CPS_we = 1'b0,
	output reg [15:0] CPS_WriteAddr = 'd0,
	output reg [7:0] CPS_WriteData = 'd0,
	
	output reg CPC_we = 1'b0,
	output reg [15:0] CPC_WriteAddr = 'd0,
	output reg [7:0] CPC_WriteData = 'd0
	
);

assign Analiz_Comlite = (AnalizState == S_END);
assign Analiz_Fail = (AnalizState == S_FAIL);

reg [7:0] CollectionSizeByte = 'd0;

reg [7:0] CollectionSize = 'd0;
reg [7:0] CollectionPacketCountLocal = 'd1;


reg [7:0] FieldNumber = 'd0;


reg [7:0] ReportSize = 'd0;
reg [7:0] ReportCount = 'd0;

localparam  KEYBOARD_DEVICE = 8'h06,
				MEDIA_KEYBOARD_DEVICE = 8'h09,
				MOUCE_DEVICE = 8'h02;

localparam  HID_REPORT_SIZE = 8'h75,
				HID_REPORT_COUNT = 8'h95,
				HID_OUTPUT_FIELD = 8'h91,
				HID_INPUT_FIELD = 8'h81,
				HID_COLLECTION_ID = 8'h85,
				HID_END_COLLECTION = 8'hC0;
				
reg [7:0] AnalizState = 0;

localparam 	S_IDLE = 8'd0,
				S_SET_DEFAULT_VAL = 8'd1,
				S_GET_DATA = 8'd2,
				S_GET_SIZE_REPORT = 8'd3,
				S_GET_COUNT_REPORT = 8'd4,
				S_GET_COLLECTION_ID = 8'd5,
				S_END_COLLECTION = 8'd6,
				S_GET_OUTPUT_FIELD = 8'd7,
				S_GET_INPUT_FIELD = 8'd9,
				S_CALK_COLLECTION = 8'd10,
				S_BYTE_CONVERT = 8'd11,
				S_CALK_SIZE = 8'd12,
				
				S_FAIL = 8'd254,
				S_END = 8'd255;

always @(posedge clk) 
begin 

	if (rst)
	begin
		
		AnalizState <= S_IDLE;
		
		CollectionNum <= 'd0;
		CollectionSizeByte <= 'd0;
		CollectionSize <= 'd0;
		CollectionPacketCountLocal <= 'd1;
		FieldNumber <= 'd0;
		ReportSize <= 'd0;
		ReportCount <= 'd0;
		
		FV_WriteAddr <= 'd0;
		FT_WriteAddr <= 'd0;
		FV_ReadAddr <= 'd0;
		FT_ReadAddr <= 'd0;
		
		CPC_we <= 1'b0;
		CPS_we <= 1'b0;
		CPS_WriteAddr <= 'd0;
		CPC_WriteAddr <= 'd0;
		
		
	end
	else
	begin
	
		case (AnalizState)
		S_IDLE:
		begin
		
			if (Analiz_En)
			begin
				AnalizState <= S_SET_DEFAULT_VAL;
				
				CollectionNum <= 'd0;
				CollectionSizeByte <= 'd0;
				CollectionSize <= 'd0;
				CollectionPacketCountLocal <= 'd1;
				FieldNumber <= 'd0;
				ReportSize <= 'd0;
				ReportCount <= 'd0;
				
				CPC_we <= 1'b1;
				CPC_WriteData <= 'd1;
				
				FV_WriteAddr <= 'd0;
				FT_WriteAddr <= 'd0;
				FV_ReadAddr <= 'd0;
				FT_ReadAddr <= 'd0;
				
				
				CPS_WriteAddr <= 'd0;
				CPC_WriteAddr <= 'd0;
			end
		end
		
		S_SET_DEFAULT_VAL:
		begin
			if (CPC_WriteAddr == 'd6) 
			begin
				AnalizState <= S_GET_DATA;
				
				CPC_we <= 1'b0;
				CPC_WriteAddr <= 'd0;
			end
			else
			begin
				CPC_WriteAddr <= CPC_WriteAddr + 1'b1;
				CPC_WriteData <= 'd1;
			end
		end
		
		S_GET_DATA:
		begin
			if (!Analiz_En) 
			begin
				AnalizState <= S_CALK_COLLECTION;
				CollectionSize <= 'd0;
				
			end
			else if (DataValid)
			begin
				case(Data)
				
				HID_REPORT_SIZE: AnalizState <= S_GET_SIZE_REPORT;
				HID_REPORT_COUNT: AnalizState <= S_GET_COUNT_REPORT;
				HID_OUTPUT_FIELD: AnalizState <= S_GET_OUTPUT_FIELD;
				HID_INPUT_FIELD: AnalizState <= S_GET_INPUT_FIELD;
				HID_COLLECTION_ID: AnalizState <= S_GET_COLLECTION_ID;
				HID_END_COLLECTION: AnalizState <= S_END_COLLECTION;
				endcase;
			end
			
			FT_we <= 1'b0;
			FV_we <= 1'b0;
		end
		
		S_GET_SIZE_REPORT:
		begin
			if (DataValid && Data != HID_REPORT_SIZE)
			begin
				ReportSize <= Data;
				AnalizState <= S_GET_DATA;
			end
		end
		
		S_GET_COUNT_REPORT:
		begin
			if (DataValid && Data != HID_REPORT_COUNT)
			begin
				ReportCount <= Data;
				AnalizState <= S_GET_DATA;
			end
		end
		
		S_GET_OUTPUT_FIELD:
		begin
			if (Data != HID_OUTPUT_FIELD)
			begin
				FT_WriteData <= HID_OUTPUT_FIELD;
				
				FT_we <= 1'b1;	
				FT_we <= 1'b1;
				
				FT_WriteAddr <= FieldNumber;
				FV_WriteAddr <= FieldNumber;
				
				FV_WriteData <= ReportSize * ReportCount;
				FieldNumber <= FieldNumber + 1'b1;
				AnalizState <= S_GET_DATA;
			end
		end
		
		S_GET_INPUT_FIELD:
		begin
			if (Data != HID_INPUT_FIELD)
			begin
				FT_WriteData <= HID_INPUT_FIELD;
				
					
				FT_we <= 1'b1;
				FV_we <= 1'b1;
				
				FT_WriteAddr <= FieldNumber;
				FV_WriteAddr <= FieldNumber;
				
				FV_WriteData <= ReportSize * ReportCount;
				FieldNumber <= FieldNumber + 1'b1;
				AnalizState <= S_GET_DATA;
			end
		end
		
		
		S_GET_COLLECTION_ID:
		begin
			if (DataValid && Data != HID_COLLECTION_ID)
			begin
				FV_we <= 1'b1;
				FV_WriteAddr <= FieldNumber;
				FV_WriteData <= Data;
				
				FT_we <= 1'b1;
				FT_WriteAddr <= FieldNumber;
				FT_WriteData <= HID_COLLECTION_ID;
				
				FieldNumber <= FieldNumber + 1'b1;
				AnalizState <= S_GET_DATA;
			end
		end
		
		S_END_COLLECTION:
		begin
			if (Data != HID_END_COLLECTION)
			begin
				FV_we <= 1'b1;
				FV_WriteAddr <= FieldNumber;
				FV_WriteData <= 'd0;
				
				FT_we <= 1'b1;
				FT_WriteAddr <= FieldNumber;
				FT_WriteData <= HID_END_COLLECTION;
				
				FieldNumber <= FieldNumber + 1'b1;
				
				AnalizState <= S_GET_DATA;
			end
		end
		
		S_CALK_COLLECTION:
		begin 
			CPS_we <= 1'b0;
			CPC_we <= 1'b0;
			if (FieldNumber == FT_ReadAddr)
				AnalizState <= S_END;
				
			else 
			begin
				FT_ReadAddr <= FT_ReadAddr + 1'b1;
				FV_ReadAddr <= FV_ReadAddr + 1'b1;
				
				case (FT_ReadData)
				
				HID_END_COLLECTION:
				begin
					
					CollectionSizeByte <= 'd1;
					AnalizState <= S_BYTE_CONVERT;
					
				end
				
					
				HID_COLLECTION_ID:
				begin
					CollectionSize <= CollectionSize + 8'd8;
					
				end
				
				
				HID_INPUT_FIELD:
				begin
					CollectionSize <= CollectionSize + FV_ReadData;
				end
				
				endcase
			end
			
		end
		
		S_BYTE_CONVERT:
		begin
			if (CollectionSize > 'd8)
			begin
				CollectionSize <= CollectionSize - 8'd8;
				CollectionSizeByte <= CollectionSizeByte + 8'd1;
			end
			else
				AnalizState <= S_CALK_SIZE;
			
		end
		
		S_CALK_SIZE:
		begin
			CPS_we <= 1'b1;
			CPC_we <= 1'b1;
			
			CPS_WriteAddr <= CollectionNum;
			CPC_WriteAddr <= CollectionNum;
			
			
			if (CollectionSizeByte > EndPointPacket_size)
			begin
				CollectionPacketCountLocal <= CollectionPacketCountLocal + 1'b1;
				CPC_WriteData <= CollectionPacketCountLocal + 1'b1;
				CPS_WriteData <= EndPointPacket_size;
				CollectionSizeByte <= CollectionSizeByte - EndPointPacket_size;
			end
			else
			begin
				CPC_WriteData <= CollectionPacketCountLocal;
				if (CollectionSizeByte != 0) 
				begin
					CPS_WriteData <= CollectionSizeByte;
					$display("HID_Analiz--> Add collection PacketSize = %d, PacketNum = %d, ID = %d", CollectionSizeByte,
					CollectionPacketCountLocal, CollectionNum + 'd1);
				end
					
				else
					$display("HID_Analiz--> Add collection PacketSize = %d, PacketNum = %d, ID = %d", 'd0,
					CollectionPacketCountLocal, CollectionNum + 'd1);
				
				CollectionPacketCountLocal <= 'd1;
				CollectionSize <= 'd0;
				CollectionNum <= CollectionNum + 1'b1;
				AnalizState <= S_CALK_COLLECTION;
			end
			
		end
		
		S_FAIL:
		begin
			if (!Analiz_En) 
				AnalizState <= S_IDLE;
		end
		
		S_END:
		begin
			if (!Analiz_En) 
				AnalizState <= S_IDLE;
		end
		
		default:
		begin
			AnalizState <= S_FAIL;
		end
		
		endcase
	end
end


endmodule 