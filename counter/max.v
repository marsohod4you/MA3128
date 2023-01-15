
module max(
	input wire CLK,
	input wire CLK2,
	output wire [7:0]LED,
	input wire  [1:0]KEY,
	inout wire [3:0]MA,
	inout wire [3:0]MB,
	inout wire [3:0]MC,
	inout wire [3:0]MD,
	inout wire [9:0]IOA,
	inout wire [9:0]IOB,
	//Raspberry GPIO pins
	inout wire [27:0]GPIO
);

reg [31:0]counter;
always @(posedge CLK)
	if( KEY[0]==1'b0 )
		counter <= 0;
	else
	if( KEY[1]==1'b1 )
		counter <= counter+1;
	else
		counter <= counter-1;

assign LED = counter[27:20];

endmodule
