
module max(
	input wire CLK,
	input wire CLK2,
	output wire [7:0]LED,
	input wire  [1:0]KEY,
	output wire [3:0]MA,
	output wire [3:0]MB,
	output wire [3:0]MC,
	output wire [3:0]MD,
	output wire [9:0]IOA,
	output wire [9:0]IOB,
	//Raspberry GPIO pins
	output wire [27:0]GPIO
);

reg [31:0]counter;
wire xclk;
assign xclk = counter[25];
always @(posedge CLK)
	if( xclk )
		counter <= 0;
	else
		counter <= counter+1;

reg [61:0]R;
always @(posedge xclk)
	if( KEY[0]==1'b0 )
		R<=1;
	else
		R<={ R[60:0], R[61] };

assign LED = { R[7:2], R[1] | (~KEY[1]), R[0] | (~KEY[0]) } ;
assign MA  = R[11: 8];
assign MB  = R[15:12];
assign MC  = R[19:16];
assign MD  = R[23:20];
assign IOA = R[33:24];
assign IOB = R[33:24];
assign GPIO= R[61:34];

endmodule
