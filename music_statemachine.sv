module music_statemachine(
	input logic CLK,
	input logic RESET,
	output logic MUS_DONE, //Signal 
	//Output audio
	
	input logic AUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,
	output logic AUD_DACDAT, AUD_MCLK, I2C_SCLK, I2C_SDAT,
	
	
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
									.INIT_FINSH(mus_INIT_FINISH),
									.adc_full(mus_adc_full),
									.data_over(mus_data_over),
									.ADCDATA(mus_ADCDATA), .*);
									
	
	
	enum logic[4:0] {INIT, INIT_WAIT, INIT_DONE, ADC_START, ADC_WAIT, ADC_DONE, DAC, DONE}
						  current, next;
	
	logic [3:0] mus_counter;
	
	
	always_ff @(posedge CLK) begin
		if (RESET) begin
			current <= INIT;
			mus_counter <= 3'b0;
		end
		else begin
			if (current == ADC_DONE) begin
				mus_counter <= mus_counter + 1'b1;
			end
			
			current <= next;
			mus_LData <= mus_LData_in;
			mus_RData <= mus_RData_in;
			
		end
	end
	
	
	
	
	always_comb begin
		next = current;
		
		unique case (current)
			hold: begin
				if (INIT) begin
					next = INIT_WAIT;
				end
			end
			INIT_WAIT: begin
				if (mus_INIT_FINISH == 1'b1) begin
					next = INIT_DONE;
				end
			end
			INIT_DONE: begin
				next = ADC_START;
			end
			ADC_START: begin
				next = ADC_WAIT;
			end
			ADC_WAIT: begin
				if (mus_adc_full == 1'b1) begin
					next = ADC_WAIT;
				end
				else begin
					next = ADC_DONE;
				end
			end
			ADC_DONE: begin
				next = DAC;
			end
			DAC: begin
				if (mus_data_over = 1'b1) begin
					if (mus_counter < 32) begin
						next = ADC_START;
					end
					else begin
						next = DONE;
					end
				end
			end
			DONE: begin 
			
			end
			default: ;
		endcase
	end
	
	always_comb begin
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
			ADC_START: begin
				mus_LData_in = 16'b0; //Need to feed these with hex values from table every clock cycle
				mus_RData_in = 16'b0;
			end
			ADC_WAIT: begin
				
			end
			ADC_DONE: begin
				
			end
			DAC: begin
					
			end
			DONE: begin
				MUS_DONE = 1'b1;
			end
		endcase
	end
	
endmodule