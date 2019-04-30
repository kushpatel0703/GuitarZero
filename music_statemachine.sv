module music_statemachine(
	input logic CLK,
	input logic RESET,
	output logic MUS_DONE, //Signal 
	//Output audio
	
	input logic AUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,
	output logic AUD_DACDAT, AUD_MCLK, I2C_SCLK, I2C_SDAT,
	
	
	
	inout wire [15:0] SRAM_DQ,
	output logic [19:0] SRAM_ADDR,
	output logic SRAM_UB_N,
	output logic SRAM_LB_N,
	output logic SRAM_CE_N,
	output logic SRAM_OE_N,
	output logic SRAM_WE_N	
	
	
);




	logic [15:0] mus_LDATA, mus_RDATA, mus_LDATA_in, mus_RDATA_in;
	logic mus_INIT;
	logic mus_INIT_FINISH;
	logic mus_adc_full;
	logic mus_data_over;
	logic [31:0] mus_ADCDATA;
	
	audio_interface audint (.LDATA(mus_LDATA),
									.RDATA(mus_RDATA),
									.clk(CLK),
									.Reset(RESET),
									.INIT(mus_INIT),
									.INIT_FINISH(mus_INIT_FINISH),
									.adc_full(mus_adc_full),
									.data_over(mus_data_over),
									.ADCDATA(mus_ADCDATA),
									.AUD_MCLK(AUD_MCLK),
									.AUD_BCLK(AUD_BCLK),
									.AUD_ADCDAT(AUD_ADCDAT),
									.AUD_DACDAT(AUD_DACDAT),
									.AUD_DACLRCK(AUD_DACLRCK),
									.AUD_ADCLRCK(AUD_ADCLRCK),
									.I2C_SDAT(I2C_SDAT),
									.I2C_SCLK(I2C_SCLK)
);
	
	enum logic[4:0] {INIT, INIT_WAIT, INIT_DONE, ADC_START, ADC_WAIT, ADC_DONE, DAC_START, DAC, DAC_DONE, DONE}
						  current, next;
	
	logic [3:0] mus_counter;
	
	logic [15:0] data_left, data_right;
	logic [31:0] bts;

	
	logic clk_out;
	logic clk_one_sec;
	
	counter ctr (.CLK_SIG(AUD_MCLK), .RESET, .counter_val(32'd71), .clk_out(clk_out)); 
//	counter ctr_onesec (.CLK_SIG(AUD_MCLK), .RESET, .counter_val(32'd3125000), .clk_out(clk_one_sec)); 
//	sq_wave sqwave(.CLK(CLK), .RESET(RESET), .AUD_CLK(clk_out), .LData(data_left), .RData(data_right), .tempo(tempo));
	
	sram_reader rdr(.CLK, .RESET, .AUD_CLK(clk_out), .SRAM_DQ, .SRAM_ADDR, 
							.SRAM_UB_N, .SRAM_LB_N, .SRAM_CE_N, .SRAM_OE_N, .SRAM_WE_N, .LData(data_left), .RData(data_right));	
	
	
	
	
	always_ff @(posedge CLK) begin
		if (RESET) begin
			current <= INIT;
			mus_counter <= 4'b0;
		
		end
		else begin
			if (current == DAC_DONE) begin
				mus_counter <= mus_counter + 1'b1;
			end
			
			
			current <= next;
			mus_LDATA <= mus_LDATA_in;
			mus_RDATA <= mus_RDATA_in;
		end
	end
	
	
	
	
	always_comb begin
		next = current;
		
		unique case (current)
			INIT: begin
					next = INIT_WAIT;
			end
			INIT_WAIT: begin
				if (mus_INIT_FINISH == 1'b1) begin
					next = INIT_DONE;
				end
			end
			INIT_DONE: begin
				next = DAC;
			end
			DAC: begin
			end
			DAC_DONE: begin
			end
			DONE: begin end
			default: ;
		endcase
	end
	
	always_comb begin
		//Set defaults
		mus_INIT = 1'b0;
		mus_LDATA_in = mus_LDATA; //Need to feed these with hex values from table every clock cycle
		mus_RDATA_in = mus_RDATA;
		MUS_DONE = 1'b0;
		case (current)
			INIT: begin
				mus_INIT = 1'b1;
			end
			INIT_WAIT:	begin
				mus_INIT = 1'b0;
			end
			INIT_DONE: begin
				//No signals need to be set here. Unless we do some load screen animation.
			end
			DAC_START: begin
			end
			DAC: begin
				mus_LDATA_in = data_left; //Need to feed these with hex values from table every clock cycle
				mus_RDATA_in = data_right;
			end
			DAC_DONE: begin			
			end
			DONE: begin
				MUS_DONE = 1'b1;
			end
		endcase
	end
	
endmodule
