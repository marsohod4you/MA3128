
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
	//inout wire [27:0]GPIO
	input wire SERIAL_RX,
	output wire SERIAL_TX
);

assign IOA = 10'd00;
assign IOB = 10'd00;
assign SERIAL_TX = 1'b1;

wire [7:0]rbyte;
wire [3:0]num_bits;
wire rbyte_ready;
serial serial_inst(
	.clk(CLK),
	.rx( SERIAL_RX ),
	.rx_byte(rbyte),
	.rbyte_ready(rbyte_ready),
	.onum_bits(num_bits)
);

assign LED = {MB,MA};

motor #(.IDX(0)) motor_inst0(
	.clk(CLK),
	.control(rbyte),
	.wr(rbyte_ready),
	.f0( MA[0] ),
	.f1( MA[1] ),
	.f2( MA[2] ),
	.f3( MA[3] )
);

motor #(.IDX(1)) motor_inst1(
	.clk(CLK),
	.control(rbyte),
	.wr(rbyte_ready),
	.f0( MB[0] ),
	.f1( MB[1] ),
	.f2( MB[2] ),
	.f3( MB[3] )
);

motor #(.IDX(2)) motor_inst2(
	.clk(CLK),
	.control(rbyte),
	.wr(rbyte_ready),
	.f0( MC[0] ),
	.f1( MC[1] ),
	.f2( MC[2] ),
	.f3( MC[3] )
);

motor #(.IDX(3)) motor_inst3(
	.clk(CLK),
	.control(rbyte),
	.wr(rbyte_ready),
	.f0( MD[0] ),
	.f1( MD[1] ),
	.f2( MD[2] ),
	.f3( MD[3] )
);

endmodule
