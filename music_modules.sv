module sq_wave(
	input logic CLK,
	input logic RESET,
	input logic AUD_CLK,
//	input logic [19:0] beats_per_50, // 50MHz/input = freq attained. Lowest possible value is approx 50Hz.
//	output logic MUS_DONE, //Signal 
	//Output audio
	
	output logic [15:0] LData, RData
//	output logic tempo //turns 1 when the counter resets to 0.
	
);

	logic [16:0] counter;
	logic [15:0] out;

	logic [15:0] ADDR;
	
	always_ff @(posedge AUD_CLK) begin
		if (RESET) begin
			out <= 16'b0;
		end
		if (out == 16'b0) begin
			out <= 16'h7FFF;
		end
		else begin
			out <= 16'b0;
		end
		LData <= out;
		RData <= out;
	end

endmodule


module sram_reader(
	input logic CLK,
	input logic RESET,
	
	input logic AUD_CLK,
	
	inout wire [15:0] SRAM_DQ,

//	output logic [3:0] debug00,
//	output logic [3:0] debug01,
//	output logic [3:0] debug02,
//	output logic [3:0] debug03,
//
//
//	output logic [3:0] debug10,
//	output logic [3:0] debug11,
//	output logic [3:0] debug12,
//	output logic [3:0] debug13,

	
	output logic [15:0] LData, RData,	
	output logic [19:0] SRAM_ADDR,
	output logic SRAM_UB_N,
	output logic SRAM_LB_N,
	output logic SRAM_CE_N,
	output logic SRAM_OE_N,
	output logic SRAM_WE_N
);

	enum logic [3:0] {RL_0,RR_0, RL_1, RR_1, IDLE} current, next; //ReadLeft_0 state used because it takes a while to read from SRAM

	logic [15:0] Data_to_SRAM, Data_from_SRAM;
	logic occured_once, occured_once_in;
	
	tristate #(.N(16)) ts0(.Clk(CLK), .tristate_output_enable(~SRAM_WE_N), .Data_write(Data_to_SRAM), .Data_read(Data_from_SRAM), .Data(SRAM_DQ));
	
	assign SRAM_UB_N = 1'b0;
	assign SRAM_LB_N = 1'b0;
	assign SRAM_CE_N = 1'b0;
	assign SRAM_WE_N = 1'b1;
	assign SRAM_OE_N = 1'b0;
	
	logic invert; 
//	logic [3:0] count; 
	
//	logic [15:0] debug0, debug1;
//
//	assign debug03[3:0] = debug0[15:12];
//	assign debug02[3:0] = debug0[11:8];	
//	assign debug01[3:0] = debug0[7:4];
//	assign debug00[3:0] = debug0[3:0];
//	
//	assign debug13[3:0] = debug1[15:12];
//	assign debug12[3:0] = debug1[11:8];	
//	assign debug11[3:0] = debug1[7:4];
//	assign debug10[3:0] = debug1[3:0];
	
	
//	assign debug0[15:0] = SRAM_ADDR[15:0];
//	assign debug1[15:0] = Data_from_SRAM[15:0];
	
	always_ff @(posedge CLK) begin
		if (RESET) begin
			//TODO: DELETE!!
//			debug <= 8'b0;
			SRAM_ADDR <= 20'b0;
			current <= IDLE;
			occured_once <= 1'b0;
		end
		
		if (current == RL_1) begin
			SRAM_ADDR <= SRAM_ADDR + 20'b1;
		end
		else if (current == RR_1) begin
//			SRAM_ADDR <= SRAM_ADDR + 20'b1;
		end
		if (AUD_CLK == 1'b0) begin
			occured_once <= 1'b0;
		end
		
		unique case (current)
			RL_0: begin
				occured_once <= 1'b1;
//				debug <= extra[7:0];
			end
			RL_1: begin
				LData <= Data_from_SRAM;
//				extra <= extra + 20'b1;
			end	
			RR_1: begin
				RData <= Data_from_SRAM;
//				extra <= extra + 20'b1;
			end
		endcase
		
		current <= next;
//		occured_once <= occured_once_in;
	end
	
	
//	always_ff @(posedge AUD_CLK) begin
//		debug <= Data_from_SRAM;
//	end
	
	always_comb begin
		next = current;
//		occured_once_in = occured_once;
		unique case (current)
			IDLE: begin
					if (AUD_CLK == 1'b1)begin
						if (occured_once == 1'b0) begin
							next = RL_0;
							//debug = 4'b0001;
						end
					end
			end
			RL_0: begin
				next = RL_1;
//				occured_once_in = 1'b1;
			end
			RL_1: begin
				next = RR_0;
			end
			RR_0: begin
				next = RR_1;
			end
			RR_1: begin
				next = IDLE;
			end
			default: ;
		endcase
	end

endmodule

module sram_tester(
	input logic CLK,
	input logic RESET,
	
	input logic AUD_CLK,
	
	inout wire [15:0] SRAM_DQ,

	output logic [3:0] debug00,
	output logic [3:0] debug01,
	output logic [3:0] debug02,
	output logic [3:0] debug03,


	output logic [3:0] debug10,
	output logic [3:0] debug11,
	output logic [3:0] debug12,
	output logic [3:0] debug13,

	
	output logic [15:0] LData, RData,	
	output logic [19:0] SRAM_ADDR,
	output logic SRAM_UB_N,
	output logic SRAM_LB_N,
	output logic SRAM_CE_N,
	output logic SRAM_OE_N,
	output logic SRAM_WE_N
);

	
	logic [15:0] Data_to_SRAM, Data_from_SRAM;
	
	tristate #(.N(16)) ts0(.Clk(CLK), .tristate_output_enable(~SRAM_WE_N), .Data_write(Data_to_SRAM), .Data_read(Data_from_SRAM), .Data(SRAM_DQ));
	
	assign SRAM_UB_N = 1'b0;
	assign SRAM_LB_N = 1'b0;
	assign SRAM_CE_N = 1'b0;
	assign SRAM_WE_N = 1'b1;
	assign SRAM_OE_N = 1'b0;
	
	
	logic [15:0] debug0, debug1;

	assign debug03[3:0] = debug0[15:12];
	assign debug02[3:0] = debug0[11:8];	
	assign debug01[3:0] = debug0[7:4];
	assign debug00[3:0] = debug0[3:0];
	
	assign debug13[3:0] = debug1[15:12];
	assign debug12[3:0] = debug1[11:8];	
	assign debug11[3:0] = debug1[7:4];
	assign debug10[3:0] = debug1[3:0];
	

	assign debug0[15:0] = SRAM_ADDR[15:0];
//	assign debug0[15:0] = Data_from_SRAM[15:0];
	
	assign SRAM_ADDR = 20'd1;
	
	
	always_ff @(posedge AUD_CLK) begin
		debug1[15:0] <= Data_from_SRAM[15:0];
//		SRAM_OE_N = 1'b1^SRAM_OE_N;
		
	end
	
	

endmodule



module counter(
	input logic CLK_SIG,
	input logic RESET,
	input logic [31:0] counter_val,
	
	output logic clk_out //turns 1 when the counter resets to 0.
	
);

	logic [31:0] counter;
	
	always_ff @(posedge CLK_SIG) begin
		if (RESET) begin
			counter <= 32'b0;
		end
		if ((~RESET) && (counter >= counter_val)) begin
				counter <= 32'b0;
				clk_out <= 1'b1;
		end
		else if (~RESET) begin
			counter <= counter + 1;
			clk_out <= 0;
		end
	end

endmodule
