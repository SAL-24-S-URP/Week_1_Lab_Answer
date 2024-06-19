interface FSM_INTF
#(
    parameter   CNT_WIDTH      = 4
)
(
    input                       clk
);
    logic   [CNT_WIDTH-1:0]     count;
    logic                       count_valid;
    logic                       start;
    logic                       _repeat;
    logic                       _repeat_valid;
    logic                       ready;
    logic                       done;
    
    semaphore                   sema;
    initial begin
        sema                    = new(1);
    end

    modport master (
        input           clk,
        input           done,
        input           ready,
        input           run,

        output          start,
        output          _repeat,
        output          _repeat_valid,
        output          count,
        output          count_valid
    );

    task init();
        start           = 1'b0;
        count           = {(CNT_WIDTH){1'b0}};
        count_valid     = 1'b0;
        _repeat         = 1'b0;
        _repeat_valid   = 1'b0;
    endtask

    task automatic start_fsm(input int num_count);
        sema.get(1);

        #1
        start           = 1'b1;
        @(posedge clk);
        start           = 1'b0;
        
        @(posedge clk);
        count           = num_count;
        count_valid     = 1'b1;

        while (done == 1'b0) begin
            @(posedge clk);
            count_valid = 1'b0;
        end

        _repeat_valid   = 1'b1;
        _repeat         = 1'b1;
        @(posedge clk);
        _repeat_valid   = 1'b0;
        

        while (done == 1'b0) begin
            @(posedge clk);
        end
        
        _repeat_valid   = 1'b1;
        _repeat         = 1'b0;
        @(posedge clk);
        _repeat_valid   = 1'b0;

        while (ready == 1'b0) begin
            @(posedge clk);
        end

        sema.put(1);
    endtask
    
endinterface