
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
	inout wire [27:0]GPIO
);

wire wr_imp;
assign wr_imp = GPIO[23];

reg [1:0]wr;
always @(posedge CLK)
	wr <= {wr[0],wr_imp};

wire write; assign write = (wr==2'b01); //find raise edge

wire [2:0]sel;
assign sel = GPIO[22:20];

wire [9:0]bus;
assign bus = GPIO[19:10];

reg [7:0]led_reg; assign LED = led_reg;
reg [9:0]ioa_reg; assign IOA = ioa_reg;
reg [9:0]iob_reg; assign IOB = iob_reg;
reg [3:0]ma_reg;  assign MA  = ma_reg;
reg [3:0]mb_reg;  assign MB  = mb_reg;
reg [3:0]mc_reg;  assign MC  = mc_reg;
reg [3:0]md_reg;  assign MD  = md_reg;

always @(posedge CLK)
	if( write )
		case(sel)
			0: led_reg <= bus[7:0];
			1: ioa_reg <= bus[9:0];
			2: iob_reg <= bus[9:0];
			3: ma_reg  <= bus[3:0];
			4: mb_reg  <= bus[3:0];
			5: mc_reg  <= bus[3:0];
			6: md_reg  <= bus[3:0];
			7: led_reg <= bus[7:0];
		endcase

endmodule
