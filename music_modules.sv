module data_reader(
	input logic CLK,
	input logic RESET,
	input logic [19:0] beats_per_50, // 50MHz/input = freq attained. Lowest possible value is approx 50Hz.
//	output logic MUS_DONE, //Signal 
	//Output audio
	
	output logic [15:0] LData, RData,
	output logic tempo //turns 1 when the counter resets to 0.
	
);

	logic [16:0] counter;
	logic [15:0] out;

	logic [15:0] ADDR;
	
	always_ff @(posedge CLK) begin
		if (RESET) begin
			counter <= 16'b0;
		end
		if ((~RESET) && (counter == beats_per_50)) begin
			if (out == 16'h7FFF) begin
				out = 16'h0000;
			end
			else begin
				out = 16'h7FFF;
			end
			counter <= 0;
			tempo <= 1;
		end
		if (~RESET) begin
			counter <= counter + 1;
			tempo <= 0;
		end
		LData <= out;
		RData <= out;
	end

endmodule
