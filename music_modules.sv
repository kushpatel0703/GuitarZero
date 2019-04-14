module music_statemachine(
	input logic CLK,
	input logic RESET,
	output logic MUS_DONE, //Signal 
	//Output audio
	
	output [15:0] LData, RData;
	
);

	logic [15:0] ADDR;

	always_ff @(posedge CLK) begin
		//Every other clock cycle, put new data from SRAM into LData and RData
	end

endmodule
