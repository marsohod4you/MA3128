
module max(
	input wire CLK,
	input wire CLK2,
	output wire [7:0]LED,
	input wire  [1:0]KEY,
	output wire [3:0]MA,
	output wire [3:0]MB,
	output wire [3:0]MC,
	input  wire [3:0]MD, //IR receiver attached here
	inout  wire [9:0]IOA,
	output wire [9:0]IOB,
	//Raspberry GPIO pins
	//inout wire [27:0]GPIO
	input wire SERIAL_RX,
	output wire SERIAL_TX
);

assign IOA[9] = 1'b1;
wire opto1; assign opto1 = IOA[8];
wire opto0; assign opto0 = IOA[7];
assign IOA[6] = 1'b1;
assign IOA[5:0] = 6'd00;

assign IOB = 10'd00;
assign SERIAL_TX = 1'b1;

reg [20:0]cnt=0;
always @(posedge CLK)
    cnt<=cnt+1;

reg key0_r  = 1'b1;
reg key1_r  = 1'b1;
reg opto0_r = 1'b1;
reg opto1_r = 1'b1;
always @(posedge CLK)
begin
	key0_r  <= ~KEY[0];
	key1_r  <= ~KEY[1];
	opto0_r <= ~opto0;
	opto1_r <= ~opto1;
end

assign LED = { 6'd00, opto1_r, opto0_r };

motor motor_inst0(
	.clk(CLK),
	.enable( opto0_r | key0_r ),
	.dir( 1'b1 ),
	.cnt8( cnt[19:17] ),
	.f0( MA[0] ),
	.f1( MA[1] ),
	.f2( MA[2] ),
	.f3( MA[3] )
);

motor motor_inst1(
	.clk(CLK),
	.enable( opto1_r | key1_r ),
	.dir( 1'b1 ),
	.cnt8( cnt[19:17] ),
	.f0( MB[0] ),
	.f1( MB[1] ),
	.f2( MB[2] ),
	.f3( MB[3] )
);

endmodule
