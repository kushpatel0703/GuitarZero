module sq_wave(
	input logic CLK,
	input logic RESET,
	input logic AUD_CLK,
	
	output logic [15:0] LData, RData
	
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
	
	always_ff @(posedge CLK) begin
		if (RESET) begin
			SRAM_ADDR <= 20'b0;
			current <= IDLE;
			occured_once <= 1'b0;
		end
		
		if (current == RL_1) begin
			SRAM_ADDR <= SRAM_ADDR + 20'b1;
		end
		if (AUD_CLK == 1'b0) begin
			occured_once <= 1'b0;
		end
		
		unique case (current)
			RL_0: begin
				occured_once <= 1'b1;
			end
			RL_1: begin
				LData <= Data_from_SRAM;
			end	
			RR_1: begin
				RData <= Data_from_SRAM;
			end
		endcase
		
		current <= next;
	end
	
	always_comb begin
		next = current;
		unique case (current)
			IDLE: begin
					if (AUD_CLK == 1'b1)begin
						if (occured_once == 1'b0) begin
							next = RL_0;
						end
					end
			end
			RL_0: begin
				next = RL_1;
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
	
	

	
	assign SRAM_ADDR = 20'd1;

	

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
