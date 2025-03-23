
module motor(
	input wire clk,
	input wire enable,
	input wire dir,
	input wire [2:0]cnt8,
	output reg f0,
	output reg f1,
	output reg f2,
	output reg f3
);

always @(posedge clk)
	if( ~enable )
	begin
		f3 <= 1'b0;
		f2 <= 1'b0;
		f1 <= 1'b0;
		f0 <= 1'b0;
	end
	else
	if(dir)
	begin
		f0 <= (cnt8[1:0]==0 || cnt8[1:0]==3);
		f1 <= (cnt8[1:0]==0 || cnt8[1:0]==1);
		f2 <= (cnt8[1:0]==1 || cnt8[1:0]==2);
		f3 <= (cnt8[1:0]==2 || cnt8[1:0]==3);
	end
	else
	begin
		f3 <= (cnt8[1:0]==0 || cnt8[1:0]==3);
		f2 <= (cnt8[1:0]==0 || cnt8[1:0]==1);
		f1 <= (cnt8[1:0]==1 || cnt8[1:0]==2);
		f0 <= (cnt8[1:0]==2 || cnt8[1:0]==3);
	end

endmodule
