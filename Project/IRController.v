module IRController(
	input clk,
	input res,
	input ir,
	output reg [31:0] code,
	output reg dataValid
);

	// The state machine registers for decoding NEC IR Protocol:
	reg [1:0] state;

	// Shift register to stream binary IR signals over:
	reg [23:0] IRBitStream;
	
	// Registers for demodulating Pulse Distance Modulation:
	reg bitDecoded;
	reg [4:0] nBitDecoded;
	reg bit;
	reg [8:0] pdCount;

	// Registers for generating carrier clock by frequency division:
	reg sampleCLK;
	reg [12:0] counter;
	
	// Counter register for setting countdowns to match timing:
	reg [9:0] pulseCount;
	
	initial begin
		code <= 32'h00000000;
		dataValid <= 1'b0;
	
		state <= 2'h0;
		IRBitStream <= 24'h000000;
		
		code <= 32'h00000000;
		bitDecoded <= 1'b0;
		nBitDecoded <= 5'd0;
		bit <= 1'b0;
		pdCount <= 9'd0;
		
		counter <= 13'd0;
		sampleCLK <= 1'b0;
		
		pulseCount <= 10'd0;
	end
	
	// Lets create a slower clock to get around 5 samples each pulse (0.5625 ms / 5 = 0.1125 ms)
	always @(posedge clk)
	begin
		if(res)
		begin
			counter <= 13'd0;
			sampleCLK <= 1'b0;
		end
		
		// 0.1125 ms period / 8.889KHz clock
		if(counter == 13'd5625)
		begin
			counter <= 13'd0;
			sampleCLK <= 1'b0;
		end
		else 
		begin
			if(counter == 13'd2812)
			begin
				sampleCLK <= 1'b1;
			end
			
			counter <= counter + 13'd1;
		end
	end
	
	always @(posedge sampleCLK)
	begin
		if(res)
		begin
			code <= 32'h00000000;
			dataValid <= 1'b0;
			
			state <= 2'h0;
			IRBitStream <= 24'h000000;
			bitDecoded <= 1'b0;
			nBitDecoded <= 5'd0;
			bit <= 1'b0;
			pdCount <= 9'd0;
			
			pulseCount <= 10'd0;
		end
	
		// Sample IR data into shift register to create a bitstream:
		IRBitStream <= {IRBitStream[22:0], ir};
	
		if(pulseCount == 10'd0) // If no wait is required
			// State Machine for reading NEC protocol IR signal:
			case(state)
				2'h0: begin // IDLE | START
					// If start signal is matched. Start reading data transmitted.
					if(IRBitStream == {16'b1111111111111111, 8'b00000000})
					begin
						dataValid <= 1'b0;
						code <= 32'h00000000;
						
						pulseCount <= 10'd1; // Wait for 1 clock.
						state <= 2'h1; // Go to READ state
					end
				end
				2'h1: begin // READ
					
					// If a bit is decoded add it to the shift register and if all decoded than give data to output.
					if(bitDecoded)
					begin
						code <= {bit, code[31:1]}; // Sample IR data into shift register to create a bitstream
						bitDecoded <= 1'b0; // Set flag back to zero.
						
						if(nBitDecoded == 5'd31)
						begin
							// If all the message is demodulated (except last) and streamed using shift register go to next state:
							nBitDecoded <= 5'd0;
							pulseCount <= 10'd1; // Wait for 1 clock.
							state <= 2'h2; // Go to CHECK END state
						end
					end
					else
					begin
						// Count pulse distances if we are trying to demodulate pulse distance.
						pdCount <= pdCount + 9'd1;
						
						// If next pulse is here calculate the distance and decode the bit:
						if(~IRBitStream[1] & IRBitStream[0])
						begin
							// If the distance count is 15 clocks (1.678 ms) next bit is a 1 bit or less (0.5625 ms) which means 0 bit is the next bit.
							bit <= pdCount < 9'd14 ? 1'b0 : 1'b1;
							pdCount <= 9'd0;
							bitDecoded <= 1'b1;
							nBitDecoded <= nBitDecoded + 5'd1;
						end
					end
				end
				2'h2: begin // CHECK END
					if(bitDecoded)
					begin
						if(pdCount > 9'd15)
						begin
							// No end pulse is recieved instead next mark for REPEAT is recieved:
							
							// Get the difference between next repeat mark and last pulse to get last bit:
							
							// If the pulse distance count between is 40.5 + 1.6875 = 42.1875 ms than last bit is 1
							// or less (40.5 + 0.5625 = 41.0625 ms) than last bit is 0
							code[31] <= pdCount < 9'd370 ? 1'b0 : 1'b1;
							
							pulseCount <= 10'd460; // Wait 460 clocks (51.75 ms) to reach next repeat mark.
							state <= 2'h3; // Go to REPEAT
						end
						else
						begin
							// If next pulse is here calculate the distance and decode the last bit and END:
							
							// If the distance count is 15 clocks (1.678 ms) last bit is a 1 bit or less (0.5625 ms) which means 0 bit is the last bit.
							code[31] <= pdCount < 9'd14 ? 1'b0 : 1'b1;
							
							pulseCount <= 10'd24; // Back to IDLE and wait for 24 clocks (70.65 ms) so we have enough time to load new samples for next state.
							state <= 2'h0; // Go back to IDLE
						end
						
						bitDecoded <= 1'b0;
						dataValid <= 1'b1;
						pdCount <= 9'd0;
					end
					else
					begin
						if(~IRBitStream[1] & IRBitStream[0])
						begin
							// Last bit decoded:
							bitDecoded <= 1'b1;
						end
						else
						begin
							// Count pulse distances if we are trying to demodulate pulse distance.
							pdCount <= pdCount + 9'd1;
						end
					end
				end
				2'h3: begin // REPEAT
					if(IRBitStream == {3'b000, 16'b1111111111111111, 4'b0000, 1'b1})
					begin
						// Continue repeating
						pulseCount <= 10'd960; // Wait for 960 clocks (108 ms).
					end
					else
					begin
						// END repeating
						pulseCount <= 10'd24; // Back to IDLE and wait for 24 clocks (70.65 ms) so we have enough time to load new samples for next state.
						state <= 2'h0; // Back to IDLE
					end
				end
			endcase
		else
		begin
			// Countdown if wait is required
			pulseCount <= pulseCount - 13'd1;
		end
		
	end

endmodule
