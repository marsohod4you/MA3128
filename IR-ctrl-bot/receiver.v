
module receiver(
    input wire clk80,
    input wire serial_in,
    output wire [7:0]rbyte
);

reg [1:0]sr;
reg recv_start = 1'b0;

reg [15:0]cnt = 16'd0;
reg [3:0]nbits = 4'd0;
wire recv; assign recv = (nbits!=0);
reg  recv_=1'b0;
wire bit_imp; assign bit_imp = (cnt==16'd0)&&recv;

always @(posedge clk80)
begin
    sr <= { sr[0], serial_in };    
    recv_start <= (sr==2'b10)&(~recv);
    recv_ <= recv;
end

reg [8:0]shiftreg = 0;
always @(posedge clk80)
    if( recv_start )
    begin
        cnt <= 16'd0;
        nbits <= 4'd11;
        shiftreg <= 0;
    end
    else
    if(nbits)
    begin
        cnt <= cnt+1;
        nbits <= (bit_imp) ? nbits-1 : nbits;
        if(bit_imp)
            shiftreg <= { sr[1], shiftreg[8:1] };
    end

reg [7:0]out_data=8'h0;
assign rbyte = out_data;

always @(posedge clk80)
    if( recv_==1'b1 && recv==1'b0 && shiftreg[3:0]==4'h5 )
        out_data <= shiftreg[7:0];

endmodule
