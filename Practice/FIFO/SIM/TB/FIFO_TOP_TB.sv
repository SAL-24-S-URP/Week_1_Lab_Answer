`define TIMEOUT_DELAY   500000
module FIFO_TOP_TB ();
    reg                     clk;
    reg                     rst_n;

    // clock generation
    initial begin
        clk                     = 1'b0;

        forever #10 clk         = !clk;
    end


    // reset generation
    initial begin
        rst_n                   = 1'b0;     // active at time 0

        repeat (3) @(posedge clk);          // after 3 cycles,
        rst_n                   = 1'b1;     // release the reset
    end
    
    //timeout
    initial begin
        #`TIMEOUT_DELAY $display("Timeout!");
        $finish;
    end

    // enable waveform dump
    //initial begin
    //    $dumpvars(0, u_DUT);
    //    $dumpfile("dump.vcd");
    //end

    //----------------------------------------------------------
    // Connection between DUT and test modules
    //----------------------------------------------------------

    reg                                 wren;
    reg        [31:0]                   wdata;
    reg                                 rden;
    wire       [31:0]                   rdata;    
    wire                                full;
    wire                                empty;         
    
    FIFO #(   .FIFO_DEPTH(16),
        .DATA_WIDTH(32),
        .AFULL_THRESHOLD(16),
        .AEMPTY_THRESHOLD(0)
    
    )
    u_DUT
    (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .full_o                 (full),
        .wren_i                 (wren),
        .wdata_i                (wdata),
        .empty_o                (empty),
        .rden_i                 (rden),
        .rdata_o                (rdata)
    );



    initial begin
        int count;
        count = 0;
        #1 wren = 1'b0; rden = 1'b0; wdata = 32'b0;
        repeat (5) @(posedge clk);

        while(count < 16) begin
            wren    = 1'b1;
            wdata   = count;
            @(posedge clk);
                #1 
                    count++;
        end

        @(posedge clk);
        wren = 1'b0;

        while(count > 0) begin
            @(posedge clk);
            rden    = 1'b1;
            count--;
        end

        @(posedge clk);
        rden = 1'b0;

        while(count < 17) begin
            @(posedge clk);
            wdata   = count;
            wren    = 1'b1;
            @(posedge clk);
                #1 
                    count++;
        end

        $display("Simulation Done!");
        $finish;
    end

endmodule