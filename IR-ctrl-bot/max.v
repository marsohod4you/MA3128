
module max(
	input wire CLK,
	input wire CLK2,
	output wire [7:0]LED,
	input wire  [1:0]KEY,
	output wire [3:0]MA,
	output wire [3:0]MB,
	output wire [3:0]MC,
	input  wire [3:0]MD, //IR receiver attached here
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

reg [20:0]cnt=0;
always @(posedge CLK)
    cnt<=cnt+1;

//80MHz / 2048 = 39062,5Hz
wire clk39K; assign clk39K = cnt[11];

//capture IO[8] pin from IR port
reg [1:0]ir_reg = 2'b00;
always @(posedge clk39K)
    ir_reg <= { ir_reg[0], MD[0] };

reg [7:0]ir_cnt = 0;
always @(posedge clk39K)
    if( ir_reg==2'b01 )
        ir_cnt <= 0;
    else
    if( ir_cnt[6]==1'b0 )
        ir_cnt <=ir_cnt+1;

reg [31:0]cmd;
reg [ 7:0]cmd_len = 0;
always @(posedge clk39K)
    if( ir_reg==2'b10 )
    begin
        if( ir_cnt==8'h40 )
            cmd_len <=0;
        else
            cmd_len <= cmd_len+1;

        cmd <= { cmd[30:0], ((ir_cnt>8'h18)? 1'b1:1'b0) };
    end

reg motor0_ena=1'b0;
reg motor0_dir=1'b0;
reg motor1_ena=1'b0;
reg motor1_dir=1'b0;
always @(posedge clk39K)
    if( ir_reg==2'b01 && cmd_len==8'h20 )
    begin
        if( cmd[7:0]==8'hF9 )
        begin
            //forward
            motor0_ena <= 1'b1;
            motor0_dir <= 1'b1;
            motor1_ena <= 1'b1;
            motor1_dir <= 1'b1;
        end
        else
        if( cmd[7:0]==8'h79 )
        begin
            //backward
            motor0_ena <= 1'b1;
            motor0_dir <= 1'b0;
            motor1_ena <= 1'b1;
            motor1_dir <= 1'b0;
        end
        else
        if( cmd[7:0]==8'hB9 )
        begin
            //left
            motor0_ena <= 1'b1;
            motor0_dir <= 1'b0;
            motor1_ena <= 1'b1;
            motor1_dir <= 1'b1;
        end
        else
        if( cmd[7:0]==8'h59 )
        begin
            //right
            motor0_ena <= 1'b1;
            motor0_dir <= 1'b1;
            motor1_ena <= 1'b1;
            motor1_dir <= 1'b0;
        end
        else
        if( cmd[7:0]==8'hE9 )
        begin
            //stop
            motor0_ena <= 1'b0;
            motor0_dir <= 1'b0;
            motor1_ena <= 1'b0;
            motor1_dir <= 1'b0;
        end
    end

assign LED = cmd[7:0];

motor motor_inst0(
	.clk(CLK),
	.enable( motor0_ena | (~KEY[0]) ),
	.dir( motor0_dir ),
	.cnt8( cnt[19:17] ),
	.f0( MA[0] ),
	.f1( MA[1] ),
	.f2( MA[2] ),
	.f3( MA[3] )
);

motor motor_inst1(
	.clk(CLK),
	.enable( motor1_ena | (~KEY[1]) ),
	.dir( motor1_dir ),
	.cnt8( cnt[19:17] ),
	.f0( MB[0] ),
	.f1( MB[1] ),
	.f2( MB[2] ),
	.f3( MB[3] )
);

endmodule
