module player (
	input  logic Clk,
	input  logic OtherClk, //Clk should be operating at 1/30 Hz
	input  logic RESET,
	output logic player_flag
);

	// This module will be synthesized into a RAM
	always_ff @ (posedge OtherClk or posedge RESET) begin
		if (RESET) begin
			player_flag <= 1'b0;
		end
		else begin
			player_flag <= ~player_flag;
		end
	end
	
endmodule


//module RNG2 (
//	input logic Clk,
//	input logic OtherClk,
//	input logic RESET,
//		
//	output logic g_activate,
//	output logic r_activate,
//	output logic y_activate,
//	output logic b_activate,
//	output logic o_activate
//     
//);
//
//	logic [12:0] random, random_next, random_done;
//	logic [3:0] count, count_next; //to keep track of the shifts
//	
//	logic [12:0] rnd;
//
//	wire feedback = random[12] ^ random[3] ^ random[2] ^ random[0]; 
//
//
//	always_ff @ (posedge Clk or posedge RESET) begin
//		if (RESET) begin
//		  random <= 13'b0000000000001; //An LFSR cannot have an all 0 state, thus Reset to 01
//		  count <= 0;
//		end
//		else begin
//		  random <= random_next;
//		  count <= count_next;
//		end
//	end
//	
//	always_ff @(posedge OtherClk) begin
//		if (rnd[2:0] == 3'b000) begin
//			g_activate <= 1'b1;
//			r_activate <= 1'b0;
//			y_activate <= 1'b0;
//			b_activate <= 1'b0;
//			o_activate <= 1'b0;
//		end
//		else if (rnd[2:0] == 3'b001) begin
//			g_activate <= 1'b0;
//			r_activate <= 1'b1;
//			y_activate <= 1'b0;
//			b_activate <= 1'b0;
//			o_activate <= 1'b0;
//		end
//		else if (rnd[2:0] == 3'b010) begin
//			g_activate <= 1'b0;
//			r_activate <= 1'b0;
//			y_activate <= 1'b1;
//			b_activate <= 1'b0;
//			o_activate <= 1'b0;
//		end
//		else if (rnd[2:0] == 3'b011) begin
//			g_activate <= 1'b0;
//			r_activate <= 1'b0;
//			y_activate <= 1'b0;
//			b_activate <= 1'b1;
//			o_activate <= 1'b0;
//		end
//		else if (rnd[2:0] == 3'b100) begin
//			g_activate <= 1'b0;
//			r_activate <= 1'b0;
//			y_activate <= 1'b0;
//			b_activate <= 1'b0;
//			o_activate <= 1'b1;
//		end
//		else begin
//			g_activate <= 1'b0;
//			r_activate <= 1'b0;
//			y_activate <= 1'b0;
//			b_activate <= 1'b0;
//			o_activate <= 1'b0;
//		end
//
//	end
//
//	always @ (*) begin
//		random_next = random; //default state stays the same
//		count_next = count;
//		// random_done = 12'h1;
//  
//		random_next = {random[11:0], feedback}; //shift left the xor'd every posedge clock
//		count_next = count + 1;
//
//		if (count == 13) begin
//			count_next = 0;
//			random_done = random; //assign the random number to output after 13 shifts
//		end
// 
//	end
//
//
//	assign rnd = random_done;
//
//endmodule

module RNG2 (
	input logic Clk,
	input logic OtherClk,
	input logic RESET,
		
	output logic g_activate,
	output logic r_activate,
	output logic y_activate,
	output logic b_activate,
	output logic o_activate
     
);

	logic [12:0] random, rnd;

	wire feedback = random[12] ^ random[3] ^ random[2] ^ random[0]; 


	always_ff @ (posedge Clk or posedge RESET) begin
		if (RESET) begin // active high reset
			random <= 13'b0000000000001 ;
		end
		else begin
			random <= {random[12:0], feedback};
		end 
  end
	
	always_ff @(posedge OtherClk) begin
		if (rnd[2:0] == 3'b000) begin
			g_activate <= 1'b1;
			r_activate <= 1'b0;
			y_activate <= 1'b0;
			b_activate <= 1'b0;
			o_activate <= 1'b0;
		end
		else if (rnd[2:0] == 3'b001) begin
			g_activate <= 1'b0;
			r_activate <= 1'b1;
			y_activate <= 1'b0;
			b_activate <= 1'b0;
			o_activate <= 1'b0;
		end
		else if (rnd[2:0] == 3'b010) begin
			g_activate <= 1'b0;
			r_activate <= 1'b0;
			y_activate <= 1'b1;
			b_activate <= 1'b0;
			o_activate <= 1'b0;
		end
		else if (rnd[2:0] == 3'b011) begin
			g_activate <= 1'b0;
			r_activate <= 1'b0;
			y_activate <= 1'b0;
			b_activate <= 1'b1;
			o_activate <= 1'b0;
		end
		else if (rnd[2:0] == 3'b100) begin
			g_activate <= 1'b0;
			r_activate <= 1'b0;
			y_activate <= 1'b0;
			b_activate <= 1'b0;
			o_activate <= 1'b1;
		end
		else begin
			g_activate <= 1'b0;
			r_activate <= 1'b0;
			y_activate <= 1'b0;
			b_activate <= 1'b0;
			o_activate <= 1'b0;
		end
		

	end

	assign rnd = random;

endmodule
