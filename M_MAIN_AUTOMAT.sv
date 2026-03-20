module M_MAIN_AUTOMAT
#(
	SKIP_POWER_RISE = 1'b0,
	DEVICE_ADDR = 'h01
)
(
	input wire clk,
	input wire rst,
	
	output reg KeyBoardData_En = 1'b0,
	
	output reg FullSpeedConnect = 1'b0,
	output wire USBReset,
	
	output wire Fail,
	
	input wire Eof1,
	output reg SOF_En = 1'b0,
	
	output wire Init_En,
	input wire InitComplite,
	input wire InitFail,
	
	output reg GetPacket_En = 1'b0,
	input wire GetPacketComplite,
	input wire GetPacketNAK,
	input wire GetPacketFail,
	output reg [7:0] PacketType = 'd0,
	
	output reg [6:0] Addr = 'd0,
	output reg [3:0] EndPoint = 'd0,
	
	
	
	output reg [15:0] AddrBace = 'd0,
	input wire [7:0] GetData,
	input wire [15:0] GetDataAddr,
	input wire DataValid,
	
	
	output reg [15:0] GetCollectionNumber = 'd0,
	input wire [7:0] CollectionNum,
	input wire [7:0] CollectionPacketSize,
	input wire [7:0] CollectionPacketCount,
	
	input wire EndOfPacket,
	
	output wire Disconnect,
	
	output reg [32:0] SetAddressRec = 'd0,
	
	inout tri Dp,
	inout tri Dm
	
	
);

assign Disconnect = (State_main == S_IDLE || State_main == S_DISCONNECT_DELAY);
assign Fail = (State_main == S_FAIL);
assign USBReset = (State_main == S_USB_RESET);
assign Init_En = (State_main == S_USB_INIT);

localparam 	P_OUT = 8'b11100001,
				P_IN = 8'b01101001,
				P_SOF_START_OF_FRAME = 8'b10100101,
				P_SETUP = 8'b00101101,
				P_DATA0 = 8'b11000011,
				P_DATA1 = 8'b01001011,
				P_ACK = 8'b11010010,
				P_NAK = 8'b01011010,
				P_STALL = 8'b00011110;

reg [32:0] WaiteCount = 'd0; 

reg [7:0] PacketCount = 'd0;

reg [4:0] DisconnectCount = 'd0;

reg [7:0] State_main = 'd0;

reg [32:0] ResetTime = 'd0; 
reg [32:0] PowerRiseTime = 'd0; 
reg [32:0] PollWaiteCount = 'd0; 


localparam 	S_IDLE = 8'd0,
				S_POWER_RISE = 8'd1,
				S_USB_RESET = 8'd2,
				S_USB_RESET_RECOWERY = 8'd3,
				S_INIT_SOF_SENDER = 8'd4,
				S_WAITE_SOF = 8'd5,
				S_USB_INIT = 8'd6,
				S_REQUEST = 8'd7,
				S_DELAY = 8'd8,
				S_WAIT = 8'd9,
				S_DISCONNECT_DELAY = 8'd10,
			

				S_FAIL = 8'd11;



always @(posedge clk) 
begin 

	if (rst)
	begin
		State_main <= S_IDLE;
		
		SOF_En <= 1'b0;
		FullSpeedConnect <= 1'b0;
		KeyBoardData_En <= 1'b0;
		GetPacket_En <= 1'b0;
		WaiteCount <= 'd0;
		DisconnectCount <= 'd0;
	end
	else
	begin
	
		case (State_main)
		
		S_IDLE:
		begin
			if (Dm & !Dp) 
			begin
				FullSpeedConnect <= 1'b0;
				ResetTime <= 'd15_000; // 10 ms on 1.5 mHz => 15_000 thics
				PowerRiseTime <= 'd150_000; // 100 ms on 1.5 mHz => 150_000 thics
				PollWaiteCount <= 'd36_000; // 24 ms on 1.5 mHz => 36000 thics
				SetAddressRec = 'd2_500;// 1.6 ms on 1.5 mHz => 2_500 thics
				State_main <= S_POWER_RISE;
				
			end
			
			else if(Dp & !Dm)
			begin
				FullSpeedConnect <= 1'b1;
				ResetTime <= 'd120_000; // 10 ms on 12 mHz => 120_000 thics
				PowerRiseTime <= 'd1_200_000; // 100 ms on 12 mHz => 1_200_000 thics
				PollWaiteCount <= 'd288_000; // 24 ms on 12 mHz => 288000 thics
				SetAddressRec = 'd20_000;// 1.6 ms on 12 mHz => 20_000 thics
				State_main <= S_POWER_RISE;
			end
			else
			begin
				SOF_En <= 1'b0;
				FullSpeedConnect <= 1'b0;
				KeyBoardData_En <= 1'b0;
				GetPacket_En <= 1'b0;
				WaiteCount <= 'd0;
				DisconnectCount <= 'd0;
			end
		end
		
		S_POWER_RISE:
		begin
			if (WaiteCount == PowerRiseTime  || SKIP_POWER_RISE) 
			begin
				WaiteCount <= 'd0;
				State_main <= S_USB_RESET;
			end
			
			else
			begin
				if (!Dm && !Dp)
				begin
					State_main <= S_IDLE;
					WaiteCount <= 'd0;
				end
				else
					WaiteCount <= WaiteCount + 1'b1;
			end
			
		end
		
		S_USB_RESET:
		begin
			if (WaiteCount == ResetTime || SKIP_POWER_RISE) 
			begin
				WaiteCount <= 'd0;
				State_main <= S_INIT_SOF_SENDER;
			end
			
			else 
			begin
				WaiteCount <= WaiteCount + 1'b1;
			end
			
			
		end
		
		

		S_INIT_SOF_SENDER:
		begin
			if (Eof1) State_main <= S_WAITE_SOF;
			else SOF_En <= 1'b1;
			
		end
		
		S_WAITE_SOF:
		begin
			if (!Eof1) State_main <= S_USB_RESET_RECOWERY;
		end
		
		S_USB_RESET_RECOWERY:
		begin
			if (WaiteCount == ResetTime || SKIP_POWER_RISE) 
			begin
				WaiteCount <= 'd0;
				State_main <= S_USB_INIT;
			end
			
			else WaiteCount <= WaiteCount + 1'b1;
		end
		
		S_USB_INIT:
		begin
			if (InitComplite)
			begin
				GetCollectionNumber <= 'd0;
				AddrBace <= 'd0;
				State_main <= S_REQUEST;
			end
			else if (InitFail)
				State_main <= S_FAIL;
			
		end
		
		S_REQUEST:
		begin
			if (GetPacketComplite && !DataValid)
			begin
				
				if (PacketCount + 1'b1 == CollectionPacketCount)
				begin
					PacketCount <= 'd0;
					WaiteCount <= 'd0;
					KeyBoardData_En <= 1'b0;
					State_main <= S_WAIT;
				end
				else
				begin
					AddrBace <= AddrBace + CollectionPacketSize;
					PacketCount <= PacketCount + 1'b1;
					
					State_main <= S_DELAY;
				end
				
				GetPacket_En <= 1'b0;
				
				
			end
			else if (GetPacketNAK)
			begin
				GetPacket_En <= 1'b0;
				
				WaiteCount <= 'd0;
				if (PacketCount == 'd0)
				begin
					State_main <= S_WAIT;
					KeyBoardData_En <= 1'b0;
				end
			end
			else if (GetPacketFail)
			begin
				GetPacket_En <= 1'b0;
				KeyBoardData_En <= 1'b0;
				WaiteCount <= 'd0;
				State_main <= S_WAIT;
			
			end
			else
			begin
				Addr <= DEVICE_ADDR;
				EndPoint <= 'h01;
				
				PacketType <= P_IN;
				GetPacket_En <= 1'b1;
				
				if (CollectionNum > 1)
				begin
					if (DataValid)
					begin
						if (GetDataAddr == 'd0)
							GetCollectionNumber <= GetData - 'd1;
							
						if (GetDataAddr == 'd2) // Skip fist 3 bytes.
							KeyBoardData_En <= 1'b1;
						
					end
					
				end
				else
				begin
					if (DataValid)
					begin
							
						if (GetDataAddr == 'd1) // Skip fist 2 bytes. If not ID
							KeyBoardData_En <= 1'b1;
						
					end
				end
					
				
			end
		end
		S_DELAY:
		begin
			if (!GetPacketComplite) 
				State_main <= S_REQUEST;
		end
		
		S_WAIT:
		begin
			if (EndOfPacket)
			begin
				if (&DisconnectCount)
				begin
					State_main <= S_DISCONNECT_DELAY;
					DisconnectCount <= 'd0;
				end
				else
					DisconnectCount <= DisconnectCount + 1'b1;
			end
			else if (WaiteCount == PollWaiteCount   || SKIP_POWER_RISE) 
			begin
				PacketCount <= 'd0;
				AddrBace <= 'd0;
				GetCollectionNumber <= 'd0;
				DisconnectCount <= 'd0;
				State_main <= S_REQUEST;
			end
			else
			begin
				DisconnectCount <= 'd0;
				WaiteCount <= WaiteCount + 1'b1;
			end
				
			
		end
		S_DISCONNECT_DELAY:
		begin
			if (WaiteCount == PowerRiseTime  || SKIP_POWER_RISE) 
			begin
				WaiteCount <= 'd0;
				State_main <= S_IDLE;
			end
			
			else WaiteCount <= WaiteCount + 1'b1;
			
		end
	
		
		
		S_FAIL:
		begin
			if (EndOfPacket)
			begin
				if (&DisconnectCount)
				begin
					State_main <= S_DISCONNECT_DELAY;
					DisconnectCount <= 'd0;
				end
				else
					DisconnectCount <= DisconnectCount + 1'b1;
			end
			else
				DisconnectCount <= 'd0;
		end
		
		
		
		
		endcase
	end
end

endmodule 