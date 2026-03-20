module M_TRANZACTION
(
	input wire clk,
	input wire rst,

	
	input wire Tranzaction_En,
	output reg TranzactionComplite = 1'b0,
	output reg TranzactionFail = 1'b0,
	
	output reg [7:0] PacketType = 'd0,

	output reg [15:0] DataAddrBace = 'd0,
	output wire [15:0] PacketLength,
	
	output reg SendPacket_En = 1'b0,
	input wire SendPacketComplite,
	input wire SendPacketFail,
	
	output reg GetPacket_En = 1'b0,
	input wire GetPacketComplite,
	input wire GetPacketNAK,
	input wire GetPacketFail,
	

	output reg [7:0] DataPacketType = 'd0,
	
	input wire [15:0] DataLength,
	input wire DataTransferDirection,
	input wire IgnorDataLength,
	
	input wire [7:0] MAX_Packet_Size
	
	
);
reg [15:0] DataLengthCalk = 'd0;
reg [7:0] TranzactionDataCount = 'd0;
reg [15:0] LastDataPacket = 'd0;
reg [4:0] NAKCount = 'd0;

assign Analiz_Num = NAKCount[3:0];

localparam  DTD_HOST_TO_DEVICE = 1'b0,
				DTD_DEVICE_TO_HOST = 1'b1;

localparam 	P_OUT = 8'b11100001,
				P_IN = 8'b01101001,
				P_SOF_START_OF_FRAME = 8'b10100101,
				P_SETUP = 8'b00101101,
				P_DATA0 = 8'b11000011,
				P_DATA1 = 8'b01001011,
				P_ACK = 8'b11010010,
				P_NAK = 8'b01011010,
				P_STALL = 8'b00011110;


assign PacketLength = (TranzactionDataCount == 'd1) ? LastDataPacket : (TranzactionDataCount != 'd0) ? MAX_Packet_Size : 16'd0;

reg [7:0] State_Tranzaction = 8'd0;


localparam 	S_IDLE = 8'd0,
				S_DIVISION =  8'd1,

				S_CALCULATE_DATA_TRANZACTION =  8'd2,
				S_SETUP_SEND = 8'd3,
				S_DELAY_01 = 8'd4,
				
				S_SEND_DATA_TO_DEVICE = 8'd5,
				S_DELAY_02 =  8'd6,
				
				S_GET_DATA_FROM_DEVICE = 8'd7,
				S_DELAY_03 =  8'd8,
				S_DELAY_04 = 8'd9,
				
				S_GET_STATUS_FROM_DEVICE =  8'd10,
				S_DELAY_05 =  8'd11,
				
				S_SEND_STATUS_TO_DEVICE = 8'd12,
				
				
				S_FAIL = 8'd254,
				S_COMPLITE = 8'd255;


always @(posedge clk) 
begin 

	if (rst)
	begin
		
		State_Tranzaction <= S_IDLE;
		TranzactionComplite <= 1'b0;
		TranzactionFail <= 1'b0;
		
		SendPacket_En <= 1'b0;
		GetPacket_En <= 1'b0;
		
	end
	else
	begin
	
		case (State_Tranzaction)
		
		S_IDLE:
		begin
			if (Tranzaction_En)
			begin
				TranzactionDataCount <= 'd0;
				LastDataPacket <= 'd0;
				DataLengthCalk <= DataLength;
				NAKCount <= 'd0;
				
				State_Tranzaction <= S_DIVISION;
			end
		end
		S_DIVISION:
		begin
			if (IgnorDataLength)
				State_Tranzaction <= S_SETUP_SEND;
			
			
			else if (DataLengthCalk > MAX_Packet_Size)
			begin
				DataLengthCalk <= DataLengthCalk - MAX_Packet_Size;
				TranzactionDataCount <= TranzactionDataCount + 1'b1;
			end
			else 
			begin
				if (DataLengthCalk != 'd0) 
				begin
					TranzactionDataCount <= TranzactionDataCount + 8'd1;
					LastDataPacket <= DataLengthCalk;
				end
				State_Tranzaction <= S_CALCULATE_DATA_TRANZACTION;
			end
		end
		S_CALCULATE_DATA_TRANZACTION:
		begin
			
				
			State_Tranzaction <= S_SETUP_SEND;
			
		end
		

		S_SETUP_SEND:
		begin
			
			if (SendPacketComplite)
			begin
				SendPacket_En <= 1'b0;
				
				if (DataTransferDirection == DTD_HOST_TO_DEVICE) 
					State_Tranzaction <= S_DELAY_01;
			
				else State_Tranzaction <= S_GET_DATA_FROM_DEVICE;
				
			end
			else if (SendPacketFail)
			begin
				SendPacket_En <= 1'b0;
				State_Tranzaction <= S_FAIL;
			end
			
			else
			begin
				DataPacketType <= 8'b11000011;
				PacketType <= P_SETUP;
				SendPacket_En <= 1'b1;
				
			end
			
		end
		
		S_DELAY_01:
		begin
			if (!SendPacketComplite)
			begin
				DataPacketType <= 8'b01001011;
				State_Tranzaction <= S_SEND_DATA_TO_DEVICE;
			end
		end
		
		
		S_SEND_DATA_TO_DEVICE:
		begin
			if (TranzactionDataCount == 'd0)
			begin
				State_Tranzaction <= S_GET_STATUS_FROM_DEVICE;
				DataAddrBace <= 'd0;
			end
			else
			begin
				if (SendPacketComplite)
				begin
					SendPacket_En <= 1'b0;
					State_Tranzaction <= S_DELAY_02;
				end
				else if (SendPacketFail)
				begin
					SendPacket_En <= 1'b0;
					State_Tranzaction <= S_FAIL;
				end
				else
				begin
					
					PacketType <= P_OUT;
					SendPacket_En <= 1'b1;
					
				end
			end
			
		end
		
		S_DELAY_02:
		begin
			 if (!SendPacketComplite)
			 begin
				TranzactionDataCount <= TranzactionDataCount - 1'b1;
				DataAddrBace <= DataAddrBace + MAX_Packet_Size;
				
				DataPacketType <= 8'b11000011;
				State_Tranzaction <= S_SEND_DATA_TO_DEVICE;
				
			 end
		end
		
		S_GET_DATA_FROM_DEVICE:
		begin
			if (TranzactionDataCount == 'd0)
			begin
				State_Tranzaction <= S_SEND_STATUS_TO_DEVICE;
				DataAddrBace <= 'd0;
			end
			
			else if (GetPacketComplite)
			begin
				GetPacket_En <= 1'b0;
				State_Tranzaction <= S_DELAY_04;
			end
			else if (GetPacketNAK)
			begin
				if (&NAKCount)
					State_Tranzaction <= S_FAIL;
				else
					State_Tranzaction <= S_DELAY_03;
				
				NAKCount <= NAKCount + 1'b1;
				GetPacket_En <= 1'b0;
				
			end
			else if (GetPacketFail)
			begin
				GetPacket_En <= 1'b0;
				State_Tranzaction <= S_FAIL;
			end
			else
			begin
				PacketType <= P_IN;
				GetPacket_En <= 1'b1;
			end
			
		end
		
		S_DELAY_03:
			if (!GetPacketNAK) 
				State_Tranzaction <= S_GET_DATA_FROM_DEVICE;
		
		
		S_DELAY_04:
		begin
			if (!GetPacketComplite)
			begin
				
					
				TranzactionDataCount <= TranzactionDataCount - 1'b1;
					
				DataAddrBace <= DataAddrBace + MAX_Packet_Size;
				State_Tranzaction <= S_GET_DATA_FROM_DEVICE;
			end
		end
		
		S_GET_STATUS_FROM_DEVICE:
		begin
			if (GetPacketComplite)
			begin
				GetPacket_En <= 1'b0;
				State_Tranzaction <= S_COMPLITE;
			end
			else if (GetPacketNAK)
			begin
				if (&NAKCount)
					State_Tranzaction <= S_FAIL;
				else
					State_Tranzaction <= S_DELAY_05;
					
				NAKCount <= NAKCount + 1'b1;
				GetPacket_En <= 1'b0;
			end
			else if (GetPacketFail)
			begin
				GetPacket_En <= 1'b0;
				State_Tranzaction <= S_FAIL;
			end
			else
			begin
				PacketType <= P_IN;
				GetPacket_En <= 1'b1;
			end
			
			
		end
		
		S_DELAY_05:
		begin
			if (!GetPacketNAK) State_Tranzaction <= S_GET_STATUS_FROM_DEVICE;
		end
		
		S_SEND_STATUS_TO_DEVICE: 
		begin 
			
			if (SendPacketComplite)
			begin
				SendPacket_En <= 1'b0;
				State_Tranzaction <= S_COMPLITE;
			end
			else if (SendPacketFail)
			begin
				SendPacket_En <= 1'b0;
				State_Tranzaction <= S_FAIL;
			end
			else
			begin
				DataPacketType <= 8'b01001011;
				PacketType <= P_OUT;
				SendPacket_En <= 1'b1;
			end
			
		end
		
	
		
		S_COMPLITE:
		begin
			if (Tranzaction_En) 
				TranzactionComplite <= 1'b1;
			else 
			begin
				TranzactionComplite <= 1'b0;
				State_Tranzaction <= S_IDLE;
			end
		end
		
		default:
		begin
			if (Tranzaction_En) 
				TranzactionFail <= 1'b1;
			else 
			begin
				$display("Tranzaction--> Tranzaction fail");
				TranzactionFail <= 1'b0;
				State_Tranzaction <= S_IDLE;
			end
		end
		
		
		endcase
	end
end

endmodule 