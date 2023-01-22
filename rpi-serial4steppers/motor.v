
module motor(
	input wire clk,
	input wire [7:0]control,
	input wire wr,
	output reg f0,
	output reg f1,
	output reg f2,
	output reg f3
);

parameter IDX = 0;

wire ctrl_step;  assign ctrl_step  = control[0];
wire ctrl_dir;   assign ctrl_dir   = control[1];
wire ctrl_halfstep; assign ctrl_halfstep = control[2];
wire ctrl_sleep; assign ctrl_sleep = control[3];
wire ctrl_reset; assign ctrl_reset = control[4];
wire [1:0]ctrl_addr; assign ctrl_addr = control[6:5];

reg [2:0]cnt8 = 3'd0;
reg sleep=1'b0;
reg halfstep=1'b0;
always @( posedge clk )
begin
	if( wr && ctrl_addr==IDX )
	begin
		sleep <= ctrl_sleep;
		halfstep <= ctrl_halfstep;
		if( ctrl_reset )
			cnt8 <= 3'd0;
		else
		if( ctrl_step)
			cnt8 <= ctrl_dir ? cnt8+1'b1 : cnt8-1'b1;
	end
end

always @(posedge clk)
	if( sleep )
	begin
		f3 <= 1'b0;
		f2 <= 1'b0;
		f1 <= 1'b0;
		f0 <= 1'b0;
	end
	else
	if(halfstep)
	begin
		f0 <= (cnt8==0 || cnt8==6 || cnt8==7 );
		f1 <= (cnt8==0 || cnt8==1 || cnt8==2 );
		f2 <= (cnt8==2 || cnt8==3 || cnt8==4 );
		f3 <= (cnt8==4 || cnt8==5 || cnt8==6 );
	end
	else
	begin
		f0 <= (cnt8[1:0]==0 || cnt8[1:0]==3);
		f1 <= (cnt8[1:0]==0 || cnt8[1:0]==1);
		f2 <= (cnt8[1:0]==1 || cnt8[1:0]==2);
		f3 <= (cnt8[1:0]==2 || cnt8[1:0]==3);
	end

endmodule
