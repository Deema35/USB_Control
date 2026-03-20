module M_DEVICE_DESCRIPTOR
#(
	MAX_PACKET_SIZE = 'h08,
	HID_INTERFACE_SIZE = 'h44, 
	HID_DATA_SIZE = 'h08
)
(
	input wire [15:0] Addr,
	output wire [7:0]Data,
	input wire [15:0] DescriptorID
);

assign Data = (DescriptorID == 'h01_00) ? DeviceDescriptor[Addr] :
					(DescriptorID == 'h03_02) ? DeviceName[Addr] :
					(DescriptorID == 'h03_01) ? DeviceManufacture[Addr] :
					(DescriptorID == 'h02_00) ? DeviceConfig[Addr] :
					(DescriptorID == 'h22_00) ? DeviceHIDErgodox[Addr] :
					(DescriptorID == 'h00_01) ? KeyBoardResponce[Addr] :
					(DescriptorID == 'h00_02) ? KeyBoardResponce_02[Addr] :'d0;

reg [7:0] DeviceDescriptor [17:0];
//initial 
//begin
//	DeviceDescriptor[0] = 'h12; //Lenght of descriptor h12
//	DeviceDescriptor[1] = 'h01; //01 - device descriptor
//	DeviceDescriptor[2] = 'h10;
//	DeviceDescriptor[3] = 'h01; //h0110 - USB version 1.1
//	DeviceDescriptor[4] = 'h00; //Device class h00
//	DeviceDescriptor[5] = 'h00; //Device subclass h00
//	DeviceDescriptor[6] = 'h00; //Protocl h00
//	DeviceDescriptor[7] = 'h08; //Max packet size
//	DeviceDescriptor[8] = 'h3C; 
//	DeviceDescriptor[9] = 'h41; //Vendor h413C
//	DeviceDescriptor[10] = 'h03;
//	DeviceDescriptor[11] = 'h20; //Product h2003
//	DeviceDescriptor[12] = 'h06;
//	DeviceDescriptor[13] = 'h03; // Device relice 3.06
//	DeviceDescriptor[14] = 'h01; //Manufacture description in string 01
//	DeviceDescriptor[15] = 'h02; //Product description in string 02
//	DeviceDescriptor[16] = 'h00; //Product serial number in string 00
//	DeviceDescriptor[17] = 'h01; //1 - possible configuration
//end

initial 
begin
	DeviceDescriptor[0] = 'h12; //Lenght of descriptor h12
	DeviceDescriptor[1] = 'h01; //01 - device descriptor
	DeviceDescriptor[2] = 'h00;
	DeviceDescriptor[3] = 'h02; //h0110 - USB version 1.1
	DeviceDescriptor[4] = 'h00; //Device class h00
	DeviceDescriptor[5] = 'h00; //Device subclass h00
	DeviceDescriptor[6] = 'h00; //Protocl h00
	DeviceDescriptor[7] = MAX_PACKET_SIZE; //Max packet size
	DeviceDescriptor[8] = 'h83; 
	DeviceDescriptor[9] = 'h04; //Vendor h413C
	DeviceDescriptor[10] = 'h2B;
	DeviceDescriptor[11] = 'h57; //Product h2003
	DeviceDescriptor[12] = 'h00;
	DeviceDescriptor[13] = 'h02; // Device relice 3.06
	DeviceDescriptor[14] = 'h01; //Manufacture description in string 01
	DeviceDescriptor[15] = 'h02; //Product description in string 02
	DeviceDescriptor[16] = 'h03; //Product serial number in string 00
	DeviceDescriptor[17] = 'h01; //1 - possible configuration
end

reg [7:0] DeviceName [25:0];
initial 
begin
	DeviceName[0] = 'h1A; //Lenght of descriptor h1A
	DeviceName[1] = 'h03; //03 - String descriptor
	DeviceName[2] = 'h55;
	DeviceName[3] = 'h00; 
	DeviceName[4] = 'h53; 
	DeviceName[5] = 'h00; 
	DeviceName[6] = 'h42; 
	DeviceName[7] = 'h00; 
	DeviceName[8] = 'h20; 
	DeviceName[9] = 'h00; 
	DeviceName[10] = 'h4b;
	DeviceName[11] = 'h00; 
	DeviceName[12] = 'h65;
	DeviceName[13] = 'h00; 
	DeviceName[14] = 'h79;
	DeviceName[15] = 'h00; 
	DeviceName[16] = 'h62; 
	DeviceName[17] = 'h00; 
	DeviceName[18] = 'h6f; 
	DeviceName[19] = 'h00; 
	DeviceName[20] = 'h61; 
	DeviceName[21] = 'h00; 
	DeviceName[22] = 'h72; 
	DeviceName[23] = 'h00; 
	DeviceName[24] = 'h64;
	DeviceName[25] = 'h00; //USB Keyboard
	
	
end

reg [7:0] DeviceManufacture [17:0];
initial 
begin
	DeviceManufacture[0] = 'h12; //Lenght of descriptor h1A
	DeviceManufacture[1] = 'h03; //03 - String descriptor
	DeviceManufacture[2] = 'h44;
	DeviceManufacture[3] = 'h00; 
	DeviceManufacture[4] = 'h65; 
	DeviceManufacture[5] = 'h00; 
	DeviceManufacture[6] = 'h65; 
	DeviceManufacture[7] = 'h00; 
	DeviceManufacture[8] = 'h6d; 
	DeviceManufacture[9] = 'h00; 
	DeviceManufacture[10] = 'h61;
	DeviceManufacture[11] = 'h00; 
	DeviceManufacture[12] = 'h33;
	DeviceManufacture[13] = 'h00; 
	DeviceManufacture[14] = 'h35;
	DeviceManufacture[15] = 'h00; 
	DeviceManufacture[16] = 'h62;
	DeviceManufacture[17] = 'h00;//Deema35
	
end

reg [7:0] DeviceConfig [33:0];
initial 
begin
	DeviceConfig[0] = 'h09; //Lenght is 9
	DeviceConfig[1] = 'h02; //Configuration descriptor
	DeviceConfig[2] = 'h22; //Total lenght of all config 
	DeviceConfig[3] = 'h00; 
	DeviceConfig[4] = 'h01; //1 interface supported by this config
	DeviceConfig[5] = 'h01; // This is config #1
	DeviceConfig[6] = 'h00; //Configuration is described in string 0
	DeviceConfig[7] = 'hE0; //Device supports remote wakeup
	DeviceConfig[8] = 'h32; //Maximum power consumption 70ma
	
	DeviceConfig[9] = 'h09; //Lenght is 9
	DeviceConfig[10] = 'h04; //Interface descriptor
	DeviceConfig[11] = 'h00; //Interface number 0
	DeviceConfig[12] = 'h00; //Interface alternate setting 0
	DeviceConfig[13] = 'h01; //Interface uses 1 endpoint
	DeviceConfig[14] = 'h03; //HID class
	DeviceConfig[15] = 'h01; //Boot subclass
	DeviceConfig[16] = 'h01; //Keyboard protocol
	DeviceConfig[17] = 'h00; //Interface is described in string 0
	
	DeviceConfig[18] = 'h09; //Lenght is 9
	DeviceConfig[19] = 'h21; //HID descriptor
	DeviceConfig[20] = 'h11; //HID class spec version 1.10
	DeviceConfig[21] = 'h01; 
	DeviceConfig[22] = 'h00; // Country code 0
	DeviceConfig[23] = 'h01; // 1 HID class descriptor
	DeviceConfig[24] = 'h22; //class descriptor type is report
	DeviceConfig[25] =  HID_INTERFACE_SIZE; //descriptor lenght 0x41
	DeviceConfig[26] = 'h00; 
	
	DeviceConfig[27] = 'h07; //Lenght is 7
	DeviceConfig[28] = 'h05; //Endpoint descriptor
	DeviceConfig[29] = 'h81;  //Endpoint Addr (10000001) fist 3 bit number Endpoint #1, bit 7 - direction IN
	DeviceConfig[30] = 'h03; // Type 0..1 (11) - interrupt, 2..3 (00) - no synchronization, 4..5 (00) Data endpoint
	DeviceConfig[31] = HID_DATA_SIZE; //Maximum packet size is 4
	DeviceConfig[32] = 'h00;
	DeviceConfig[33] = 'h18; //Polling interval is 18ms
	
end

/* This Intrface for this structure

struct keyboardReportDes
{
 	uint8_t MODIFIER;
	uint8_t RESERVED;
	uint8_t KEYCODE1;
	uint8_t KEYCODE2;
	uint8_t KEYCODE3;
	uint8_t KEYCODE4;
	uint8_t KEYCODE5;
	uint8_t KEYCODE6;
};


*/

reg [7:0] DeviceHIDKeyboard [64:0];
initial 
begin
	DeviceHIDKeyboard[0] = 'h05; 
	DeviceHIDKeyboard[1] = 'h01; //Usage page 1 (Generic desktop)
	
	DeviceHIDKeyboard[2] = 'h09; 
	DeviceHIDKeyboard[3] = 'h06; //Usage (Keyboard) 
	
	DeviceHIDKeyboard[4] = 'hA1; 
	DeviceHIDKeyboard[5] = 'h01; //Collection(Application)
	
	
	//Fist byte MODIFIER
	DeviceHIDKeyboard[6] = 'h05; 
	DeviceHIDKeyboard[7] = 'h07; //Usage page 7 (Keyboard/KeyPad)
	
	DeviceHIDKeyboard[8] = 'h19; 
	DeviceHIDKeyboard[9] = 'hE0; //Local usage minimum E0
	
	DeviceHIDKeyboard[10] = 'h29; 
	DeviceHIDKeyboard[11] = 'hE7; //Local usage maximum E7
	
	DeviceHIDKeyboard[12] = 'h15; 
	DeviceHIDKeyboard[13] = 'h00; //Logical minimum: 0
	
	DeviceHIDKeyboard[14] = 'h25; 
	DeviceHIDKeyboard[15] = 'h01; //Logical maximum: 1
	
	DeviceHIDKeyboard[16] = 'h75; 
	DeviceHIDKeyboard[17] = 'h01; //Report size 1 bit
	
	DeviceHIDKeyboard[18] = 'h95; 
	DeviceHIDKeyboard[19] = 'h08; //Report count: 8 reports
	
	DeviceHIDKeyboard[20] = 'h81; 
	DeviceHIDKeyboard[21] = 'h02; //Input (variable)
	
	
	//Second byte RESERVED
	DeviceHIDKeyboard[22] = 'h95; 
	DeviceHIDKeyboard[23] = 'h01; //Report count: 1 reports
	
	DeviceHIDKeyboard[24] = 'h75; 
	DeviceHIDKeyboard[25] = 'h08; //Report size 8 bit
	
	DeviceHIDKeyboard[26] = 'h81; 
	DeviceHIDKeyboard[27] = 'h01; //Input (constant)
	
	
	//Led states 3 bit
	DeviceHIDKeyboard[28] = 'h95; 
	DeviceHIDKeyboard[29] = 'h03; //Report count: 3 reports
	
	DeviceHIDKeyboard[30] = 'h75; 
	DeviceHIDKeyboard[31] = 'h01; //Report size 1 bit
	
	DeviceHIDKeyboard[32] = 'h05; 
	DeviceHIDKeyboard[33] = 'h08; //Usage page 8
	
	DeviceHIDKeyboard[34] = 'h19; 
	DeviceHIDKeyboard[35] = 'h01; //Local usage minimum 1
	
	DeviceHIDKeyboard[36] = 'h29; 
	DeviceHIDKeyboard[37] = 'h03; //Local usage maximum 3
	
	DeviceHIDKeyboard[38] = 'h91;  
	DeviceHIDKeyboard[39] = 'h02; //Output (variable)
	
	
	//Padding 5 bit for 8
	DeviceHIDKeyboard[40] = 'h95; 
	DeviceHIDKeyboard[41] = 'h01; //Report count: 1 reports
	
	DeviceHIDKeyboard[42] = 'h75;  
	DeviceHIDKeyboard[43] = 'h05; //Report size 5 bit
	
	DeviceHIDKeyboard[44] = 'h91; 
	DeviceHIDKeyboard[45] = 'h01; //Output (Constant)
	
	
	//Six key codes bytes
	DeviceHIDKeyboard[46] = 'h95; 
	DeviceHIDKeyboard[47] = 'h06; //Report count: 6 reports
	
	DeviceHIDKeyboard[48] = 'h75;  
	DeviceHIDKeyboard[49] = 'h08; //Report size 8 bit
	
	DeviceHIDKeyboard[50] = 'h15; 
	DeviceHIDKeyboard[51] = 'h00; //Logical minimum: 0
	
	DeviceHIDKeyboard[52] = 'h26; 
	DeviceHIDKeyboard[53] = 'hFF; 
	DeviceHIDKeyboard[54] = 'h00; //Logical maximum: 00FF
	
	DeviceHIDKeyboard[55] = 'h05; 
	DeviceHIDKeyboard[56] = 'h07; //Usage page 7 (Keyboard/Keypad)
	
	DeviceHIDKeyboard[57] = 'h19; 
	DeviceHIDKeyboard[58] = 'h00; //Local usage minimum: 00
	
	DeviceHIDKeyboard[59] = 'h2A;  
	DeviceHIDKeyboard[60] = 'hFF; 
	DeviceHIDKeyboard[61] = 'h00; //Local usage maximum: 00FF
	
	DeviceHIDKeyboard[62] = 'h81;
	DeviceHIDKeyboard[63] = 'h00; //Input (array)
	
	DeviceHIDKeyboard[64] = 'hC0; //End collection
	
end


/* This Intrface for this structure

struct keyboardReportDes
{
	uint8_t ID;
 	uint8_t MODIFIER;
	uint8_t RESERVED;
	uint8_t KEYCODE1;
	uint8_t KEYCODE2;
	uint8_t KEYCODE3;
	uint8_t KEYCODE4;
	uint8_t KEYCODE5;
};

struct keyboardMediaDes
{
	uint8_t ID;
 	uint8_t MEDIA;
};

*/
reg [7:0] DeviceHIDMediaKeyboard [103:0];
initial 
begin

	DeviceHIDMediaKeyboard[0] = 'h05; 
	DeviceHIDMediaKeyboard[1] = 'h01; //Usage page 1 (Generic desktop)
	
	DeviceHIDMediaKeyboard[2] = 'h09; 
	DeviceHIDMediaKeyboard[3] = 'h06; //Usage (Keyboard) 
	
	DeviceHIDMediaKeyboard[4] = 'hA1; 
	DeviceHIDMediaKeyboard[5] = 'h01; //Collection(Application)
	
	// Report ID1 
	DeviceHIDMediaKeyboard[6] = 'h85; 
	DeviceHIDMediaKeyboard[7] = 'h01;  
	
	
	//Fist byte MODIFIER
	DeviceHIDMediaKeyboard[8] = 'h05; 
	DeviceHIDMediaKeyboard[9] = 'h07; //Usage page 7 (Keyboard/KeyPad)
	
	DeviceHIDMediaKeyboard[10] = 'h19; 
	DeviceHIDMediaKeyboard[11] = 'hE0; //Local usage minimum E0
	
	DeviceHIDMediaKeyboard[12] = 'h29; 
	DeviceHIDMediaKeyboard[13] = 'hE7; //Local usage maximum E7
	
	DeviceHIDMediaKeyboard[14] = 'h15; 
	DeviceHIDMediaKeyboard[15] = 'h00; //Logical minimum: 0
	
	DeviceHIDMediaKeyboard[16] = 'h25; 
	DeviceHIDMediaKeyboard[17] = 'h01; //Logical maximum: 1
	
	DeviceHIDMediaKeyboard[18] = 'h75; 
	DeviceHIDMediaKeyboard[19] = 'h01; //Report size 1 bit
	
	DeviceHIDMediaKeyboard[20] = 'h95; 
	DeviceHIDMediaKeyboard[21] = 'h08; //Report count: 8 reports
	
	DeviceHIDMediaKeyboard[22] = 'h81; 
	DeviceHIDMediaKeyboard[23] = 'h02; //Input (variable)
	
	
	//Second byte RESERVED
	DeviceHIDMediaKeyboard[24] = 'h95; 
	DeviceHIDMediaKeyboard[25] = 'h01; //Report count: 1 reports
	
	DeviceHIDMediaKeyboard[26] = 'h75; 
	DeviceHIDMediaKeyboard[27] = 'h08; //Report size 8 bit
	
	DeviceHIDMediaKeyboard[28] = 'h81; 
	DeviceHIDMediaKeyboard[29] = 'h01; //Input (constant)
	
	
	//Led states 5 bit
	DeviceHIDMediaKeyboard[30] = 'h95; 
	DeviceHIDMediaKeyboard[31] = 'h05; //Report count: 5 reports
	
	DeviceHIDMediaKeyboard[32] = 'h75; 
	DeviceHIDMediaKeyboard[33] = 'h01; //Report size 1 bit
	
	DeviceHIDMediaKeyboard[34] = 'h05; 
	DeviceHIDMediaKeyboard[35] = 'h08; //Usage page 8
	
	DeviceHIDMediaKeyboard[36] = 'h19; 
	DeviceHIDMediaKeyboard[37] = 'h01; //Local usage minimum 1
	
	DeviceHIDMediaKeyboard[38] = 'h29; 
	DeviceHIDMediaKeyboard[39] = 'h05; //Local usage maximum 5
	
	DeviceHIDMediaKeyboard[40] = 'h91;  
	DeviceHIDMediaKeyboard[41] = 'h02; //Output (variable)
	
	
	//Padding 3 bit for 8
	DeviceHIDMediaKeyboard[42] = 'h95; 
	DeviceHIDMediaKeyboard[43] = 'h01; //Report count: 1 reports
	
	DeviceHIDMediaKeyboard[44] = 'h75;  
	DeviceHIDMediaKeyboard[45] = 'h03; //Report size 3 bit
	
	DeviceHIDMediaKeyboard[46] = 'h91; 
	DeviceHIDMediaKeyboard[47] = 'h01; //Output (Constant)
	
	
	
	//Five key codes bytes
	DeviceHIDMediaKeyboard[48] = 'h95; 
	DeviceHIDMediaKeyboard[49] = 'h05; //Report count: 5 reports
	
	DeviceHIDMediaKeyboard[50] = 'h75;  
	DeviceHIDMediaKeyboard[51] = 'h08; //Report size 8 bit
	
	DeviceHIDMediaKeyboard[52] = 'h15; 
	DeviceHIDMediaKeyboard[53] = 'h00; //Logical minimum: 0
	
	DeviceHIDMediaKeyboard[54] = 'h25; 
	DeviceHIDMediaKeyboard[55] = 'h65; //Logical maximum: 0065

	DeviceHIDMediaKeyboard[56] = 'h05; 
	DeviceHIDMediaKeyboard[57] = 'h07; //Usage page 7 (Keyboard/Keypad)
	
	DeviceHIDMediaKeyboard[58] = 'h19; 
	DeviceHIDMediaKeyboard[59] = 'h00; //Local usage minimum: 00
	
	DeviceHIDMediaKeyboard[60] = 'h29;  
	DeviceHIDMediaKeyboard[61] = 'h65; //Local usage maximum: 65
	
	DeviceHIDMediaKeyboard[62] = 'h81;
	DeviceHIDMediaKeyboard[63] = 'h00; //Input (array)
	
	DeviceHIDMediaKeyboard[64] = 'hC0; //End collection
	
	
	//MEDIA KEYBOARD
	DeviceHIDMediaKeyboard[65] = 'h05; 
	DeviceHIDMediaKeyboard[66] = 'h0C; //Usage Page C (Consumer Devices)
	
	DeviceHIDMediaKeyboard[67] = 'h09; 
	DeviceHIDMediaKeyboard[68] = 'h01; // Usage (Consumer Control)
	
	DeviceHIDMediaKeyboard[69] = 'hA1; 
	DeviceHIDMediaKeyboard[70] = 'h01; //Collection(Application)
	
	// Report ID2  
	DeviceHIDMediaKeyboard[71] = 'h85; 
	DeviceHIDMediaKeyboard[72] = 'h02; 
	
	//8-bit media
	DeviceHIDMediaKeyboard[73] = 'h05; 
	DeviceHIDMediaKeyboard[74] = 'h0c; //Usage Page (Consumer Devices)
	
	DeviceHIDMediaKeyboard[75] = 'h15; 
	DeviceHIDMediaKeyboard[76] = 'h00; //Local minimum: 00
	
	DeviceHIDMediaKeyboard[77] = 'h25;  
	DeviceHIDMediaKeyboard[78] = 'h01; //Local usage maximum: 01
	
	DeviceHIDMediaKeyboard[79] = 'h75;
	DeviceHIDMediaKeyboard[80] = 'h01; //Report size 1 bit
	
	DeviceHIDMediaKeyboard[81] = 'h95; 
	DeviceHIDMediaKeyboard[82] = 'h07; //Report count: 7 reports
	
	DeviceHIDMediaKeyboard[83] = 'h09; 
	DeviceHIDMediaKeyboard[84] = 'hB5; //Usage (Scan Next Track)
	
	DeviceHIDMediaKeyboard[85] = 'h09; 
	DeviceHIDMediaKeyboard[86] = 'hB6; //Usage (Scan Previous Track) 
	
	DeviceHIDMediaKeyboard[87] = 'h09; 
	DeviceHIDMediaKeyboard[88] = 'hB7; //Usage (Stop)  
	
	DeviceHIDMediaKeyboard[89] = 'h09; 
	DeviceHIDMediaKeyboard[90] = 'hCD; //Usage (Play / Pause) 
	
	DeviceHIDMediaKeyboard[91] = 'h09; 
	DeviceHIDMediaKeyboard[92] = 'hE2; //Usage (Mute)   
	
	DeviceHIDMediaKeyboard[93] = 'h09; 
	DeviceHIDMediaKeyboard[94] = 'hE9; //Usage (Volume Up)  
	
	DeviceHIDMediaKeyboard[95] = 'h09; 
	DeviceHIDMediaKeyboard[96] = 'hEA; //Usage (Volume Down) 

	DeviceHIDMediaKeyboard[97] = 'h81;
	DeviceHIDMediaKeyboard[98] = 'h02; //Input (Variable)
	
	DeviceHIDMediaKeyboard[99] = 'h95;
	DeviceHIDMediaKeyboard[100] = 'h01; //Report count: 1 reports
	
	DeviceHIDMediaKeyboard[101] = 'h81;
	DeviceHIDMediaKeyboard[102] = 'h01; //Input (Constant)
	
	DeviceHIDMediaKeyboard[103] = 'hC0; //End collection
	
end      

reg [7:0] DeviceHIDErgodox [67:0];
initial 
begin
	DeviceHIDErgodox[0] = 'h05; 
	DeviceHIDErgodox[1] = 'h01; //Usage page 1 (Generic desktop)
	
	DeviceHIDErgodox[2] = 'h09; 
	DeviceHIDErgodox[3] = 'h06; //Usage (Keyboard) 
	
	DeviceHIDErgodox[4] = 'hA1; 
	DeviceHIDErgodox[5] = 'h01; //Collection(Application)
	
	
	//Fist byte MODIFIER
	DeviceHIDErgodox[6] = 'h05; 
	DeviceHIDErgodox[7] = 'h07; //Usage page 7 (Keyboard/KeyPad)
	
	DeviceHIDErgodox[8] = 'h19; 
	DeviceHIDErgodox[9] = 'hE0; //Local usage minimum E0
	
	DeviceHIDErgodox[10] = 'h29; 
	DeviceHIDErgodox[11] = 'hE7; //Local usage maximum E7
	
	DeviceHIDErgodox[12] = 'h15; 
	DeviceHIDErgodox[13] = 'h00; //Logical minimum: 0
	
	DeviceHIDErgodox[14] = 'h25; 
	DeviceHIDErgodox[15] = 'h01; //Logical maximum: 1
	
	
	DeviceHIDErgodox[16] = 'h75; 
	DeviceHIDErgodox[17] = 'h01; //Report size 1 bit
	
	DeviceHIDErgodox[18] = 'h95; 
	DeviceHIDErgodox[19] = 'h08; //Report count: 8 reports
	
	DeviceHIDErgodox[20] = 'h81; 
	DeviceHIDErgodox[21] = 'h02; //Input (variable)
	
	
	//Second byte RESERVED
	DeviceHIDErgodox[22] = 'h95; 
	DeviceHIDErgodox[23] = 'h01; //Report count: 1 reports
	
	DeviceHIDErgodox[24] = 'h75; 
	DeviceHIDErgodox[25] = 'h08; //Report size 8 bit
	
	DeviceHIDErgodox[26] = 'h81; 
	DeviceHIDErgodox[27] = 'h01; //Input (constant)
	
	//___________________
	
	//Led states 3 bit
	
	DeviceHIDErgodox[28] = 'h05; 
	DeviceHIDErgodox[29] = 'h07; //Usage page 8
	
	DeviceHIDErgodox[30] = 'h19; 
	DeviceHIDErgodox[31] = 'h00; //Local usage minimum 1
	
	
	DeviceHIDErgodox[32] = 'h29;	
	DeviceHIDErgodox[33] = 'hFF; //Local usage maximum FF
	
	DeviceHIDErgodox[34] = 'h15; 
	DeviceHIDErgodox[35] = 'h00; //Logical minimum: 0
	
	DeviceHIDErgodox[36] = 'h26; 
	DeviceHIDErgodox[37] = 'hFF; 
	DeviceHIDErgodox[38] = 'h00; //Logical maximum: 00FF
	
	DeviceHIDErgodox[39] = 'h95; 
	DeviceHIDErgodox[40] = 'h06; //Report count: 1 reports
	
	DeviceHIDErgodox[41] = 'h75;  
	DeviceHIDErgodox[42] = 'h08; //Report size 8 bit
	
	DeviceHIDErgodox[43] = 'h81;
	DeviceHIDErgodox[44] = 'h00; //Input (array)
	
	DeviceHIDErgodox[45] = 'h05; 
	DeviceHIDErgodox[46] = 'h08; //Usage page 8 (Keyboard/Keypad)
	
	DeviceHIDErgodox[47] = 'h19; 
	DeviceHIDErgodox[48] = 'h01; //Local usage minimum: 01
	
	DeviceHIDErgodox[49] = 'h29; 
	DeviceHIDErgodox[50] = 'h05; //Local usage maximum 5
	
	DeviceHIDErgodox[51] = 'h15; 
	DeviceHIDErgodox[52] = 'h00; //Logical minimum: 0
	
	
	DeviceHIDErgodox[53] = 'h25; 
	DeviceHIDErgodox[54] = 'h01; //Logical maximum: 1
	
	DeviceHIDErgodox[55] = 'h95; 
	DeviceHIDErgodox[56] = 'h05; //Report count: 5 reports
	
	DeviceHIDErgodox[57] = 'h75;  
	DeviceHIDErgodox[58] = 'h01; //Report size 8 bit
	
	
	DeviceHIDErgodox[59] = 'h91;  
	DeviceHIDErgodox[60] = 'h02; //Output (variable)
	
	//Padding 3 bit for 8
	DeviceHIDErgodox[61] = 'h95; 
	DeviceHIDErgodox[62] = 'h01; //Report count: 1 reports
	
	DeviceHIDErgodox[63] = 'h75;  
	DeviceHIDErgodox[64] = 'h03; //Report size 3 bit
	
	DeviceHIDErgodox[65] = 'h91; 
	DeviceHIDErgodox[66] = 'h01; //Output (Constant)
	
	
	DeviceHIDErgodox[67] = 'hC0; //End collection
	
end




/* This Intrface for this structure

struct MouseReportDes
{
 	uint8_t Buttons; 
	struct
	{
		uint8_t X;
		uint8_t Y1;
		uint8_t Wheel;
	}
};



*/


reg [7:0] DeviceHIDMouse[51:0];

initial 
begin

	DeviceHIDMouse[0] = 'h05; 
	DeviceHIDMouse[1] = 'h01; //Usage page 1 (Generic desktop)
	
	DeviceHIDMouse[2] = 'h09; 
	DeviceHIDMouse[3] = 'h02; //Usage  (Mouse) 
	
	DeviceHIDMouse[4] = 'hA1; 
	DeviceHIDMouse[5] = 'h01; //Collection(Application)
	
	
	
	DeviceHIDMouse[6] = 'h09; 
	DeviceHIDMouse[7] = 'h01; //Usage (Pointer) 
	
	
	DeviceHIDMouse[8] = 'hA1; 
	DeviceHIDMouse[9] = 'h00; //Collection(Physicale)
	
	DeviceHIDMouse[10] = 'h05; 
	DeviceHIDMouse[11] = 'h09; //Usage page 9 (Button page)
	
	DeviceHIDMouse[12] = 'h19; 
	DeviceHIDMouse[13] = 'h01; //Local usage minimum: 01
	
	DeviceHIDMouse[14] = 'h29; 
	DeviceHIDMouse[15] = 'h03; //Local usage maximum 3
	
	
	
	//Fist Button 3 bit 
	DeviceHIDMouse[16] = 'h15; 
	DeviceHIDMouse[17] = 'h00; //Logical minimum: 0
	
	DeviceHIDMouse[18] = 'h25; 
	DeviceHIDMouse[19] = 'h01; //Logical maximum: 1
	
	DeviceHIDMouse[20] = 'h95; 
	DeviceHIDMouse[21] = 'h03; //Report count: 3 reports
	
	DeviceHIDMouse[22] = 'h75; 
	DeviceHIDMouse[23] = 'h01; //Report size 1 bit
	
	DeviceHIDMouse[24] = 'h81; 
	DeviceHIDMouse[25] = 'h02; //Input (variable)
	
	
	
	//Padding 5 bit for 8
	DeviceHIDMouse[26] = 'h95; 
	DeviceHIDMouse[27] = 'h01; //Report count: 1 reports
	
	DeviceHIDMouse[28] = 'h75; 
	DeviceHIDMouse[29] = 'h05; //Report size 5 bit
	
	DeviceHIDMouse[30] = 'h81; 
	DeviceHIDMouse[31] = 'h01; //Input (constant)
	
	
	//Fist 3 byte X,Y,Wheel
	DeviceHIDMouse[32] = 'h05; 
	DeviceHIDMouse[33] = 'h01; //Usage page 1 (Generic desktop)
	
	DeviceHIDMouse[34] = 'h09; 
	DeviceHIDMouse[35] = 'h30; // X
	
	DeviceHIDMouse[36] = 'h09; 
	DeviceHIDMouse[37] = 'h31; // Y
	
	DeviceHIDMouse[38] = 'h09; 
	DeviceHIDMouse[39] = 'h38; // Wheel
	
	DeviceHIDMouse[40] = 'h15; 
	DeviceHIDMouse[41] = 'h81; //Logical minimum: -127
	
	DeviceHIDMouse[42] = 'h25; 
	DeviceHIDMouse[43] = 'h7F; //Logical maximum: 127
	
	DeviceHIDMouse[44] = 'h75; 
	DeviceHIDMouse[45] = 'h08; //Report size 8 bit
	
	DeviceHIDMouse[46] = 'h95; 
	DeviceHIDMouse[47] = 'h03; //Report count: 3 reports
	
	DeviceHIDMouse[48] = 'h81; 
	DeviceHIDMouse[49] = 'h06; //Input Input (Variable  3 position bytes (X & Y & Wheel) )
	
	DeviceHIDMouse[50] = 'hc0; //End collection
	
	
	DeviceHIDMouse[51] = 'hC0; //End collection
	
end

reg [7:0] KeyBoardResponce[7:0];

initial 
begin
	KeyBoardResponce[0] = 'h01;
	KeyBoardResponce[1] = 'h00;
	KeyBoardResponce[2] = 'h00;
	KeyBoardResponce[3] = 'h04;
	KeyBoardResponce[4] = 'h05;
	KeyBoardResponce[5] = 'h06;
	KeyBoardResponce[6] = 'h00;
	KeyBoardResponce[7] = 'h00;
end

reg [7:0] KeyBoardResponce_02[2:0];

initial 
begin
	KeyBoardResponce_02[0] = 'h02;
	KeyBoardResponce_02[1] = 'h08;

end


endmodule 