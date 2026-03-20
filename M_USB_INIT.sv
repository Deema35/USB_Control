module M_USB_INIT
#(
	SKIP_POWER_RISE = 1'b0,
	DEVICE_ADDR = 7'h01,
	SET_ADDRES_REC = 'd20_000
)
(
	input wire clk,
	input wire rst,
	
	input wire [32:0] SetAddressRec,
	
	input wire Init_En,
	output reg InitComplite = 1'b0,
	output reg InitFail = 1'b0,
	
	output reg Tranzaction_En = 1'b0,
	input wire TranzactionComplite,
	input wire TranzactionFail,
	output reg TranzactionIgnorDataLength = 1'b0,
	
	output reg [6:0] Addr = 'd0,
	output reg [3:0] EndPoint = 'd0,
	
	output reg DataTransferDirection = 1'b0,
	output reg [1:0] PipeType = 'd0,
	output reg [4:0] Recipient = 'd0,
	output reg [7:0] Request = 'd0,
	output reg [15:0] RequestValue = 'd0,
	output reg [15:0] RequestIndex = 'd0,
	output reg [15:0] RequestLength = 'd0,
	
	output reg GetName = 1'b0,
	input wire [7:0] GetData,
	input wire [15:0] GetAddr,
	input wire GetDataValid,
	
	
	output reg Analiz_En = 1'b0,
	input wire Analiz_Comlite,
	input wire Analiz_Fail,
	
	output reg CanResiveLED_State = 1'b0,
	output reg [7:0] MAX_Packet_Size = 8'd0,
	output reg [7:0] EndPointPacket_size = 8'd0,
	output reg [7:0] ProtokolType = 8'd0
);



reg [7:0] DeviceNameString = 'd0;
reg [7:0] DeviceManfactureString = 'd0;
reg [7:0] ConfiguratinNumber = 'd0;
reg [7:0] StringSize = 'd0;
reg [7:0] HID_Len = 'd0;

localparam  DTD_HOST_TO_DEVICE = 1'b0,
				DTD_DEVICE_TO_HOST = 1'b1;
				
localparam  HID_PROTOCOL_NON = 8'd0,
				HID_PROTOCOL_KEYBOARD = 8'd1,
				HID_PROTOCOL_MOUSE = 8'd2;



localparam  PT_STANDART = 2'd0,
				PT_CLASS = 2'd1,
				PT_VENDOR = 2'd2;
				


localparam  RP_DEVICE = 5'd0,
				RP_INTERFACE = 5'd1,
				RP_ENDPOINT = 5'd2,
				RP_OTHER = 5'd3;
				


localparam  REQ_GET_STATUS = 8'd0,
				REQ_CLEAR_FEATURE = 8'd1,
				REQ_SET_FEATURE = 8'd3,
				REQ_SET_ADDRESS = 8'd5,
				REQ_GET_DESCRIPTOR = 8'd6,
				REQ_SET_DESCRIPTOR = 8'd7,
				REQ_GET_CONFIGURATION = 8'd8,
				REQ_SET_CONFIGURATION = 8'd9,
				REQ_GET_INTERFACE = 8'd10,
				REQ_SET_INTERFACE = 8'd11,
				REQ_SYNCH_FRAME = 8'd12;


reg [18:0] WaiteCount = 'd0; // 2 ms on 12 mHz => 24000 thics


reg [7:0] DataBuffer [120:0];

reg [7:0] State_Init = 8'd0;




localparam 	S_IDLE = 8'd0,
			
				S_SET_ADDR = 8'd1,
				S_RECOVERY = 8'd2,
				S_GET_PACKET_SIZE = 8'd3,
				S_DELAY_01 = 8'd4,
				S_GET_DEVICE_DESCRIPTOR = 8'd6,
				S_DELAY_02 = 8'd7,
				S_GET_DEVICE_NAME_01 = 8'd8,
				S_DELAY_03 = 8'd9,
				S_GET_DEVICE_NAME_02 = 8'd10,
				S_DELAY_04 = 8'd11,
				S_GET_DEVICE_MANUFACTURE_01 = 8'd12,
				S_DELAY_05 = 8'd13,
				S_GET_DEVICE_MANUFACTURE_02 = 8'd14,
				S_DELAY_06 = 8'd15,
				S_GET_DEVICE_CONFIGURATION_01 = 8'd16,
				S_DELAY_07 = 8'd17,
				S_GET_DEVICE_CONFIGURATION_02 = 8'd18,
				S_DELAY_08 = 8'd19,
				S_SET_CONFIGURATION = 8'd20,
				S_DELAY_09 = 8'd21,
				S_GET_DEVICE_HID = 8'd22,
				S_DELAY_10 = 8'd23,
				S_SET_IDLE_HID = 8'd24,
				S_DELAY_11 = 8'd25,
				S_SET_PROTOCOL_HID = 8'd26,
				S_DELAY_12 = 8'd27,
				S_SET_REPORT_HID= 8'd28,
				S_DELAY_13 = 8'd29,

				S_FAIL = 8'd254,
				S_COMPLITE = 8'd255;


always @(posedge clk) 
begin 
	if (rst)
	begin
		
		State_Init <= S_IDLE;
		
		InitComplite <= 1'b0;
		InitFail <= 1'b0;
		Analiz_En <= 1'b0;
		GetName <= 1'b0;
		Tranzaction_En <= 1'b0;
		TranzactionIgnorDataLength <= 1'b0;
		
	end
	else
	begin
	
		case (State_Init)
		
		S_IDLE:
		begin
			if (Init_En)
			begin
				State_Init <= S_SET_ADDR;
			end
			MAX_Packet_Size <= 'd8;
		end
		
	
		
		S_SET_ADDR:
		begin
			if (TranzactionComplite)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_RECOVERY;
			end
			else if (TranzactionFail)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_FAIL;
			end
			else
			begin
				Addr <= 'h00;
				EndPoint <= 'h00;
				
				DataTransferDirection <= DTD_HOST_TO_DEVICE;
				PipeType <= PT_STANDART; 
				Recipient <= RP_DEVICE;
				Request <= REQ_SET_ADDRESS; 
				RequestValue <= DEVICE_ADDR; 
				RequestIndex <= 'h0;
				RequestLength <= 'h0;
				
				Tranzaction_En <= 1'b1;
			end
			
		end
		
		S_RECOVERY:
		begin
			if (WaiteCount == SetAddressRec | SKIP_POWER_RISE) State_Init <= S_GET_PACKET_SIZE;
			else WaiteCount <= WaiteCount + 1'b1;
			
			
		end
		
		S_GET_PACKET_SIZE:
		begin
			if (TranzactionComplite)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_DELAY_01;
				
			end
			else if (TranzactionFail)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_FAIL;
			end
			else
			begin
				Addr <= DEVICE_ADDR;
				EndPoint <= 'h00;
				
				DataTransferDirection <= DTD_DEVICE_TO_HOST;
				PipeType <= PT_STANDART; 
				Recipient <= RP_DEVICE;
				Request <= REQ_GET_DESCRIPTOR;
				RequestValue <= 'h01_00; //01 - Device descriptor number 00.
				RequestIndex <= 'h0;
				RequestLength <= 'h8;
				
				Tranzaction_En <= 1'b1;
				
				if (GetDataValid)
				begin
					case (GetAddr)
					'd7: MAX_Packet_Size  <= GetData;
					endcase
				end
				
			end
		end
		
		S_DELAY_01:
		begin
			if (!TranzactionComplite && !GetDataValid)
			begin
				State_Init <= S_GET_DEVICE_DESCRIPTOR;
			end
			
			if (GetDataValid)
			begin
				case (GetAddr)
				'd7: MAX_Packet_Size  <= GetData;
				endcase
			end
		end
		
		S_GET_DEVICE_DESCRIPTOR:
		begin
			if (TranzactionComplite)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_DELAY_02;
				
			end
			else if (TranzactionFail)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_FAIL;
			end
			else
			begin
				Addr <= DEVICE_ADDR;
				EndPoint <= 'h00;
				
				DataTransferDirection <= DTD_DEVICE_TO_HOST;
				PipeType <= PT_STANDART; 
				Recipient <= RP_DEVICE;
				Request <= REQ_GET_DESCRIPTOR;
				RequestValue <= 'h01_00; //01 - Device descriptor number 00.
				RequestIndex <= 'h0;
				RequestLength <= 'h12;
				
				Tranzaction_En <= 1'b1;
				
				if (GetDataValid)
				begin
					DataBuffer[GetAddr] <= GetData;
					case (GetAddr)
					'd14: DeviceManfactureString <= GetData;
					'd15: DeviceNameString <= GetData;
					endcase
				end
				
				

			end
		end
		
		S_DELAY_02: 
		begin
			
			if (!TranzactionComplite && !GetDataValid)
			begin
				$write("%c[1;34m",27);
				$display("USB--> Get device Descriptor size = %d, type = %d, %h%h %h%h %h%h %h%h %h%h %h%h %h%h %h%h", RequestLength, DataBuffer[1],DataBuffer[2],DataBuffer[3],DataBuffer[4],
				DataBuffer[5],DataBuffer[6],DataBuffer[7],DataBuffer[8],DataBuffer[9],DataBuffer[10],DataBuffer[11], DataBuffer[12],DataBuffer[13], DataBuffer[14],DataBuffer[15], 
				DataBuffer[16],DataBuffer[17]);
				$write("%c[0m",27);
				State_Init <= S_GET_DEVICE_NAME_01;
			end
			
			if (GetDataValid)
			begin
				DataBuffer[GetAddr] <= GetData;
				case (GetAddr)
				'd14: DeviceManfactureString <= GetData;
				'd15: DeviceNameString <= GetData;
				endcase
			end
		end
		
		S_GET_DEVICE_NAME_01:
		begin
			if (TranzactionComplite)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_DELAY_03;
				
				
			end
			else if (TranzactionFail)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_DELAY_04; // If we cann't get device neme we skeep it
			end
			else
			begin
				Addr <= DEVICE_ADDR;
				EndPoint <= 'h00;
				
				DataTransferDirection <= DTD_DEVICE_TO_HOST;
				PipeType <= PT_STANDART; 
				Recipient <= RP_DEVICE;
				Request <= REQ_GET_DESCRIPTOR;
				
				RequestValue[15:8] <= 'h03; //03 - String 
				RequestValue[7:0] <= DeviceNameString; //number of string
				
				RequestIndex <= 'h04_09;  //Eanglish language
				RequestLength <= 'h02;
				
				Tranzaction_En <= 1'b1;
				
				if (GetDataValid)
				begin
					DataBuffer[GetAddr] <= GetData;
					if (GetAddr == 'd0) StringSize <= GetData;
				end
				

			end
		end
		
		S_DELAY_03: 
		begin
			
			if (!TranzactionComplite && !GetDataValid)
			begin
				$write("%c[1;34m",27);
				$display("USB--> Get device Name size = %d, type = %d, %h%h %h%h %h%h %h%h %h%h %h%h %h%h %h%h", RequestLength, DataBuffer[1],DataBuffer[2],DataBuffer[3],DataBuffer[4],
				DataBuffer[5],DataBuffer[6],DataBuffer[7],DataBuffer[8],DataBuffer[9],DataBuffer[10],DataBuffer[11], DataBuffer[12],DataBuffer[13], DataBuffer[14],DataBuffer[15], 
				DataBuffer[16],DataBuffer[17]);
				$write("%c[0m",27);
				State_Init <= S_GET_DEVICE_NAME_02;
			end
		end
		
		S_GET_DEVICE_NAME_02:
		begin
			if (TranzactionComplite && !GetDataValid)
			begin
				Tranzaction_En <= 1'b0;
				GetName <= 1'b0;
				State_Init <= S_DELAY_04;
			end
			else if (TranzactionFail)
			begin
				Tranzaction_En <= 1'b0;
				GetName <= 1'b0;
				State_Init <= S_DELAY_04;
			end
			else
			begin
				Addr <= DEVICE_ADDR;
				EndPoint <= 'h00;
				
				DataTransferDirection <= DTD_DEVICE_TO_HOST;
				PipeType <= PT_STANDART; 
				Recipient <= RP_DEVICE;
				Request <= REQ_GET_DESCRIPTOR;
				
				RequestValue[15:8] <= 'h03; //03 - String 
				RequestValue[7:0] <= DeviceNameString; //number of string
				
				RequestIndex <= 'h04_09;  //Eanglish language
				RequestLength <= StringSize;
				
				Tranzaction_En <= 1'b1;
				
				if (GetDataValid)
				begin
					DataBuffer[GetAddr] <= GetData;
					if ( GetAddr > 'd0) GetName <= 1'b1;
				end
				

			end
		end
		
		S_DELAY_04: 
		begin
			
			if (!TranzactionComplite && !GetDataValid)
			begin
				$write("%c[1;34m",27);
				$display("USB--> Get device Name size = %d, type = %d, %h%h %h%h %h%h %h%h %h%h %h%h %h%h %h%h", RequestLength, DataBuffer[1],DataBuffer[2],DataBuffer[3],DataBuffer[4],
				DataBuffer[5],DataBuffer[6],DataBuffer[7],DataBuffer[8],DataBuffer[9],DataBuffer[10],DataBuffer[11], DataBuffer[12],DataBuffer[13], DataBuffer[14],DataBuffer[15], 
				DataBuffer[16],DataBuffer[17]);
				$write("%c[0m",27);
				State_Init <= S_GET_DEVICE_MANUFACTURE_01;
			end
			
			if (GetDataValid) DataBuffer[GetAddr] <= GetData;
		end
		
		S_GET_DEVICE_MANUFACTURE_01:
		begin
			if (TranzactionComplite && !GetDataValid)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_DELAY_05;
				
				
			end
			else if (TranzactionFail)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_DELAY_06;
			end
			else
			begin
				Addr <= DEVICE_ADDR;
				EndPoint <= 'h00;
				
				DataTransferDirection <= DTD_DEVICE_TO_HOST;
				PipeType <= PT_STANDART; 
				Recipient <= RP_DEVICE;
				Request <= REQ_GET_DESCRIPTOR;
				
				RequestValue[15:8] <= 'h03; //03 - String 
				RequestValue[7:0] <= DeviceManfactureString; //number of string
				
				
				RequestIndex <= 'h04_09;  //Eanglish language
				RequestLength <= 'h02;
				
				Tranzaction_En <= 1'b1;
				
				if (GetDataValid)
				begin
					DataBuffer[GetAddr] <= GetData;
					if (GetAddr == 'd0) StringSize <= GetData;
				end
				

			end
		end
		
		S_DELAY_05: 
		begin
			
			if (!TranzactionComplite)
			begin
				$write("%c[1;34m",27);
				$display("USB--> Get device Manufactor size = %d, type = %d, %h%h %h%h %h%h %h%h %h%h %h%h %h%h %h%h", RequestLength, DataBuffer[1],DataBuffer[2],DataBuffer[3],DataBuffer[4],
				DataBuffer[5],DataBuffer[6],DataBuffer[7],DataBuffer[8],DataBuffer[9],DataBuffer[10],DataBuffer[11], DataBuffer[12],DataBuffer[13], DataBuffer[14],DataBuffer[15], 
				DataBuffer[16],DataBuffer[17]);
				$write("%c[0m",27);
				
				State_Init <= S_GET_DEVICE_MANUFACTURE_02;
			end
		end
		
		S_GET_DEVICE_MANUFACTURE_02:
		begin
			if (TranzactionComplite)
			begin
				Tranzaction_En <= 1'b0;
				GetName <= 1'b0;
				State_Init <= S_DELAY_06;
			end
			else if (TranzactionFail)
			begin
				Tranzaction_En <= 1'b0;
				GetName <= 1'b0;
				State_Init <= S_DELAY_06;
			end
			else
			begin
				Addr <= DEVICE_ADDR;
				EndPoint <= 'h00;
				
				DataTransferDirection <= DTD_DEVICE_TO_HOST;
				PipeType <= PT_STANDART; 
				Recipient <= RP_DEVICE;
				Request <= REQ_GET_DESCRIPTOR;
				
				RequestValue[15:8] <= 'h03; //03 - String 
				RequestValue[7:0] <= DeviceManfactureString; //number of string
				
				
				RequestIndex <= 'h04_09;  //Eanglish language
				RequestLength <= StringSize;
				
				Tranzaction_En <= 1'b1;
				
				if (GetDataValid)
				begin
					DataBuffer[GetAddr] <= GetData;
					if (GetAddr > 'd0) GetName <= 1'b1;
				end
				

			end
		end
		
		S_DELAY_06: 
		begin
			
			if (!TranzactionComplite && !GetDataValid)
			begin
				$write("%c[1;34m",27);
				$display("USB--> Get device Manufactor size = %d, type = %d, %h%h %h%h %h%h %h%h %h%h %h%h %h%h %h%h", RequestLength, DataBuffer[1],DataBuffer[2],DataBuffer[3],DataBuffer[4],
				DataBuffer[5],DataBuffer[6],DataBuffer[7],DataBuffer[8],DataBuffer[9],DataBuffer[10],DataBuffer[11], DataBuffer[12],DataBuffer[13], DataBuffer[14],DataBuffer[15], 
				DataBuffer[16],DataBuffer[17]);
				$write("%c[0m",27);
				
				State_Init <= S_GET_DEVICE_CONFIGURATION_01;
			end
			
			if (GetDataValid) DataBuffer[GetAddr] <= GetData;
		end
		
		S_GET_DEVICE_CONFIGURATION_01:
		begin
			if (TranzactionComplite)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_DELAY_07;
				
			end
			else if (TranzactionFail)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_FAIL;
			end
			else
			begin
				Addr <= DEVICE_ADDR;
				EndPoint <= 'h00;
				
				DataTransferDirection <= DTD_DEVICE_TO_HOST;
				PipeType <= PT_STANDART; 
				Recipient <= RP_DEVICE;
				Request <= REQ_GET_DESCRIPTOR;
				
				RequestValue[15:8] <= 'h02; //02 - Configuration 
				RequestValue[7:0] <= 'h00; //number of Configuration 
				
				RequestIndex <= 'h00_00;
				RequestLength <= 'h09;
				
				Tranzaction_En <= 1'b1;
				
				if (GetDataValid)
				begin
					DataBuffer[GetAddr] <= GetData;
					if (GetAddr == 'd2) StringSize <= GetData;
				end
				

			end
			
		end
		
		S_DELAY_07: 
		begin
			
			if (!TranzactionComplite)
			begin
				$write("%c[1;34m",27);
				$display("USB--> Get device Configuration size = %d, type = %d, %h%h %h%h %h%h %h%h %h%h %h%h %h%h %h%h", RequestLength, DataBuffer[1],DataBuffer[2],DataBuffer[3],DataBuffer[4],
				DataBuffer[5],DataBuffer[6],DataBuffer[7],DataBuffer[8],DataBuffer[9],DataBuffer[10],DataBuffer[11], DataBuffer[12],DataBuffer[13], DataBuffer[14],DataBuffer[15], 
				DataBuffer[16],DataBuffer[17]);
				$write("%c[0m",27);
				
				
				State_Init <= S_GET_DEVICE_CONFIGURATION_02;
			end
		end
		
		S_GET_DEVICE_CONFIGURATION_02:
		begin
			if (TranzactionComplite)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_DELAY_08;
				
			end
			else if (TranzactionFail)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_FAIL;
				
			end
			else
			begin
				Addr <= DEVICE_ADDR;
				EndPoint <= 'h00;
				
				DataTransferDirection <= DTD_DEVICE_TO_HOST;
				PipeType <= PT_STANDART; 
				Recipient <= RP_DEVICE;
				Request <= REQ_GET_DESCRIPTOR;
				
				RequestValue[15:8] <= 'h02; //02 - Configuration 
				RequestValue[7:0] <= 'h00; //number of Configuration 
				
				RequestIndex <= 'h00_00;  
				RequestLength <= StringSize;
				
				Tranzaction_En <= 1'b1;
				
				if (GetDataValid)
				begin
					DataBuffer[GetAddr] <= GetData;
					
					case (GetAddr)
					'd5: ConfiguratinNumber  <= GetData;
					'd25: HID_Len  <= GetData;
					'd16: ProtokolType <= GetData;
					'd31: EndPointPacket_size  <= GetData;
					endcase
				end
				

			end
			
		end
		
		S_DELAY_08: 
		begin
			
			if (!TranzactionComplite && !GetDataValid)
			begin
				$write("%c[1;34m",27);
				$display("USB--> Get device Configuration size = %d, type = %d, %h%h %h%h %h%h %h%h %h%h %h%h %h%h %h%h", RequestLength, DataBuffer[1],DataBuffer[2],DataBuffer[3],DataBuffer[4],
				DataBuffer[5],DataBuffer[6],DataBuffer[7],DataBuffer[8],DataBuffer[9],DataBuffer[10],DataBuffer[11], DataBuffer[12],DataBuffer[13], DataBuffer[14],DataBuffer[15], 
				DataBuffer[16],DataBuffer[17]);
				$write("%c[0m",27);
				
				if (ProtokolType != HID_PROTOCOL_KEYBOARD) State_Init <= S_FAIL; //If this is not keyboard stop init.
				
				else State_Init <= S_SET_CONFIGURATION;
			end
			
			
			if (GetDataValid)
			begin
				DataBuffer[GetAddr] <= GetData;
				
				case (GetAddr)
				'd5: ConfiguratinNumber  <= GetData;
				'd25: HID_Len  <= GetData;
				'd16: ProtokolType <= GetData;
				'd31: EndPointPacket_size  <= GetData;
				endcase
			end
		end
		
		S_SET_CONFIGURATION:
		begin
		if (TranzactionComplite)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_DELAY_09;
			end
			else if (TranzactionFail)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_FAIL;
			end
			else
			begin
				Addr <= DEVICE_ADDR;
				EndPoint <= 'h00;
				
				DataTransferDirection <= DTD_HOST_TO_DEVICE;
				PipeType <= PT_STANDART; 
				Recipient <= RP_DEVICE;
				Request <= REQ_SET_CONFIGURATION; 
				RequestValue <= ConfiguratinNumber; 
				RequestIndex <= 'h0;
				RequestLength <= 'd0;
				Tranzaction_En <= 1'b1;
			end
		end
		
		S_DELAY_09: 
		begin
			
			if (!TranzactionComplite)
			begin
				$write("%c[1;34m",27);
				$display("USB--> Set device Configuration Number = %d", ConfiguratinNumber);
				$write("%c[0m",27);
				
				State_Init <= S_GET_DEVICE_HID;
			end
		end
		
		
		S_GET_DEVICE_HID:
		begin
			if (TranzactionComplite)
			begin
				Tranzaction_En <= 1'b0;
				
				State_Init <= S_DELAY_10;
				
			end
			else if (TranzactionFail)
			begin
				Tranzaction_En <= 1'b0;
				Analiz_En <= 1'b0;
				State_Init <= S_FAIL;
			end
			else
			begin
				Addr <= DEVICE_ADDR;
				EndPoint <= 'h00;
				
				DataTransferDirection <= DTD_DEVICE_TO_HOST;
				PipeType <= PT_STANDART; 
				Recipient <= RP_INTERFACE;
				Request <= REQ_GET_DESCRIPTOR;
				
				RequestValue[15:8] <= 'h22; //22 - Report descriptor
				RequestValue[7:0] <= 'h00; //number of Report descriptor
				
				RequestIndex <= 'h00_00;
				RequestLength <= HID_Len;
				
				Tranzaction_En <= 1'b1;
				Analiz_En <= 1'b1;
				
				if (GetDataValid) DataBuffer[GetAddr] <= GetData;
				

			end
			
		end
		
		S_DELAY_10: 
		begin
			
			if (!TranzactionComplite && !GetDataValid)
			begin
				$write("%c[1;34m",27);
				$display("USB--> Get HID Interface size = %d,  %h%h %h%h %h%h %h%h %h%h %h%h %h%h %h%h %h%h", RequestLength, DataBuffer[0], DataBuffer[1],DataBuffer[2],DataBuffer[3],DataBuffer[4],
				DataBuffer[5],DataBuffer[6],DataBuffer[7],DataBuffer[8],DataBuffer[9],DataBuffer[10],DataBuffer[11], DataBuffer[12],DataBuffer[13], DataBuffer[14],DataBuffer[15], 
				DataBuffer[16],DataBuffer[17]);
				$write("%c[0m",27);
				
				Analiz_En <= 1'b0;
				State_Init <= S_SET_IDLE_HID;
			end
			
			if (GetDataValid) DataBuffer[GetAddr] <= GetData;
		end
		
		S_SET_IDLE_HID:
		begin
			if (TranzactionComplite)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_DELAY_11;
				
			end
			else if (TranzactionFail)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_FAIL;
			end
			else
			begin
				Addr <= DEVICE_ADDR;
				EndPoint <= 'h00;
				
				DataTransferDirection <= DTD_HOST_TO_DEVICE;
				PipeType <= PT_CLASS; 
				Recipient <= RP_INTERFACE;
				Request <= 'h0A; //SET_IDLE to HIDclass
				RequestValue[15:8] <= 'h06; //24 ms Poling interval
				RequestValue[7:0] <= 'h00; 
				RequestIndex <= 'h00_00; //Interface 0
				RequestLength <= 'h00_00;
				
				Tranzaction_En <= 1'b1;
				
				if (GetDataValid) DataBuffer[GetAddr] <= GetData;
				

			end
			
		end
		
		S_DELAY_11: 
		begin
			
			if (!TranzactionComplite)
			begin
				$write("%c[1;34m",27);
				$display("USB--> Set HID Poling interval 24 ms");
				$write("%c[0m",27);
				
				
				State_Init <= S_SET_PROTOCOL_HID;
			end
		end
		
		S_SET_PROTOCOL_HID:
		begin
			if (TranzactionComplite)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_DELAY_12;
				
			end
			else if (TranzactionFail)
			begin
				Tranzaction_En <= 1'b0;
				State_Init <= S_FAIL;
			end
			else
			begin
				Addr <= DEVICE_ADDR;
				EndPoint <= 'h00;
				
				DataTransferDirection <= DTD_HOST_TO_DEVICE;
				PipeType <= PT_CLASS; 
				Recipient <= RP_INTERFACE;
				Request <= 'h0B; //SET_PROTOCOL to HIDclass
				RequestValue <= 'h00_01; //Report protocol
				RequestIndex <= 'h00_00; //Interface 0
				RequestLength <= 'h00_00;
				
				Tranzaction_En <= 1'b1;
				
				if (GetDataValid) DataBuffer[GetAddr] <= GetData;
				

			end
		end
		
		S_DELAY_12: 
		begin
			
			if (!TranzactionComplite)
			begin
				$write("%c[1;34m",27);
				$display("USB--> Set HID Protocol");
				$write("%c[0m",27);
				
				
				State_Init <= S_COMPLITE;
			end
		end
		
		
		S_SET_REPORT_HID:
		begin
			if (TranzactionComplite)
			begin
				Tranzaction_En <= 1'b0;
				TranzactionIgnorDataLength <= 1'b0;
				CanResiveLED_State <= 1'b1;
				State_Init <= S_DELAY_13;
				
			end
			else if (TranzactionFail)
			begin
				Tranzaction_En <= 1'b0;
				TranzactionIgnorDataLength <= 1'b0;
				CanResiveLED_State <= 1'b0;
				State_Init <= S_COMPLITE; //If keyboard cann't resive data from host we skeep.
			end
			else
			begin
				Addr <= DEVICE_ADDR;
				EndPoint <= 'h00;
				
				DataTransferDirection <= DTD_HOST_TO_DEVICE;
				PipeType <= PT_CLASS; 
				Recipient <= RP_INTERFACE;
				Request <= 'h09; //SET_REPORT to HIDclass
				RequestValue <= 'h02_00; //Output report 0
				RequestIndex <= 'h00_00; //Interface 0
				RequestLength <= 'h00_01;
				
				TranzactionIgnorDataLength <= 1'b1; // Tranzaction module must ignor RequestLength field, because HID class not send data.
				Tranzaction_En <= 1'b1;
				
				if (GetDataValid) DataBuffer[GetAddr] <= GetData;
				

			end
		end
		
		S_DELAY_13: 
		begin
			
			if (!TranzactionComplite)
			begin
				$write("%c[1;34m",27);
				$display("USB--> Set HID Report");
				$write("%c[0m",27);
				
				
				State_Init <= S_COMPLITE;
			end
		end
		
		
		S_FAIL:
		begin
			if (Init_En) InitFail <= 1'b1;
			else
			begin
				InitFail <= 1'b0;
				State_Init <= S_IDLE;
			end
		end
		
		S_COMPLITE:
		begin
			if (Init_En) InitComplite <= 1'b1;
			else
			begin
				InitComplite <= 1'b0;
				State_Init <= S_IDLE;
			end
		end
		
		
		endcase
	end
end

endmodule 