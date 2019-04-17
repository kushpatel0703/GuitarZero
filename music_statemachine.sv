module music_statemachine(
	input logic CLK,
	input logic RESET,
	output logic MUS_DONE, //Signal 
	output logic [3:0] debug,
	//Output audio
	
	input logic AUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,
	output logic AUD_DACDAT, AUD_MCLK, I2C_SCLK, I2C_SDAT
	
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
	logic tempo;
	logic [19:0] bts;
	
	assign bts = 20'h1BBE4;
	
	data_reader dr(.CLK(CLK), .RESET(RESET), .beats_per_50(bts), .LData(data_left), .RData(data_right), .tempo(tempo));
	
	
	always_ff @(posedge CLK) begin
		if (RESET) begin
			current <= INIT;
			mus_counter <= 4'b0;
			
			//TODO: DELETE!!
			debug <= 4'b0;
		
		end
		else begin
			if (current == DAC_DONE) begin
				mus_counter <= mus_counter + 1'b1;
			end
			
			//TODO: DELETE!
			if (current == INIT) begin
//				debug <= debug + 1'b1;
			end
			if (current == INIT_DONE) begin
				debug <= debug + 1'b1;
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
				next = DAC_START;
			end
			DAC_START: begin
				next = DAC;
			end
			DAC: begin
				if (mus_data_over == 1'b1) begin
						next = DAC_DONE;
				end
			end
			DAC_DONE: begin
				if (mus_counter < 320) begin
					next = DAC_START;
				end
				else begin
					next = DONE;
				end
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
				mus_LDATA_in = data_left; //Need to feed these with hex values from table every clock cycle
				mus_RDATA_in = data_right;
			end
			DAC: begin
				
			end
			DAC_DONE: begin
			
			end
			DONE: begin
				MUS_DONE = 1'b1;
			end
		endcase
	end
	
endmodule
