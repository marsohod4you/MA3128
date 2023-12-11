
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
	input wire [27:0]GPIO
);

reg [31:0]counter;
always @(posedge CLK)
	counter <= counter+1;
	
reg [2:0]cnt8a=0;
always @(posedge CLK)
	if(counter[19:0]==0)
		cnt8a<=cnt8a+1;

reg fa3,fa2,fa1,fa0;
always @(posedge CLK)
begin
	fa3 <= (cnt8a[1:0]==1 || cnt8a[1:0]==2);
	fa2 <= (cnt8a[1:0]==2 || cnt8a[1:0]==3);
	fa1 <= (cnt8a[1:0]==0 || cnt8a[1:0]==3);
	fa0 <= (cnt8a[1:0]==0 || cnt8a[1:0]==1);
end

assign MA[0]=fa0;
assign MA[1]=fa1;
assign MA[2]=fa2;
assign MA[3]=fa3;

reg [31:0]shift_reg = 0;
wire next_bit;
assign next_bit =
  shift_reg[31] ^
  shift_reg[30] ^
  shift_reg[29] ^
  shift_reg[27] ^
  shift_reg[25] ^
  shift_reg[ 0];

wire enable = (counter[23:0]==0);
always @(posedge CLK)
	if(shift_reg==0)
		shift_reg<=1;
	else
	if(enable)
		shift_reg <= { next_bit, shift_reg[31:1] };

assign LED = 0;
assign MC=shift_reg[3:0] & {4{counter[1]}};
assign MD=shift_reg[7:4] & {4{counter[1]}};

endmodule
