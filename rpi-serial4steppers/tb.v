`timescale 1ns / 1ns

module tb;

// Inputs
reg clk = 0;
always
	begin
		#5;
		clk = ~clk;
	end

reg TX=1'b1;
wire wf0,wf1,wf2,wf3;

wire [7:0]rbyte;
wire rbyte_ready;
serial serial_inst(
	.clk(clk),
	.rx( TX ),
	.rx_byte(rbyte),
	.rbyte_ready(rbyte_ready)
);

motor motor_inst(
	.clk(clk),
	.control(rbyte),
	.wr(rbyte_ready),
	.f0( wf0  ),
	.f1( wf1 ),
	.f2( wf2 ),
	.f3( wf3 )
);

integer i=0;
initial begin
	$dumpfile("out.vcd");
	$dumpvars(0,tb);
	#2000000;
	for (i=0; i<10; i=i+1)
	begin
		send_serial( 8'h01 );
		send_serial( 8'h00 );
		send_serial( 8'h00 );
		send_serial( 8'h00 );
		send_serial( 8'h00 );
	end
	#200;
	$finish(0);
end

reg [31:0]cnt=0;
reg send_impulse=1'b0;
always @(posedge clk)
	if(cnt==868)
	begin
		cnt<=0;
		send_impulse=1'b1;
	end
	else
	begin
		cnt<=cnt+1;
		send_impulse=1'b0;
	end

task send_serial;
input [7:0]sbyte;
begin
	@(posedge send_impulse);
		TX<=1'b0;
	@(posedge send_impulse);
		TX<=sbyte[0];
	@(posedge send_impulse);
		TX<=sbyte[1];
	@(posedge send_impulse);
		TX<=sbyte[2];
	@(posedge send_impulse);
		TX<=sbyte[3];
	@(posedge send_impulse);
		TX<=sbyte[4];
	@(posedge send_impulse);
		TX<=sbyte[5];
	@(posedge send_impulse);
		TX<=sbyte[6];
	@(posedge send_impulse);
		TX<=sbyte[7];
	@(posedge send_impulse);
		TX<=1'b1;
	//@(posedge send_impulse);
end
endtask

endmodule

