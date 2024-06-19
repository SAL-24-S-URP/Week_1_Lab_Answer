interface FSM_INTF
#(
    parameter   CNT_WIDTH      = 4
)
(
    input                       clk
);
    logic   [CNT_WIDTH-1:0]     count;
    logic                       start;
    logic                       _repeat;
    logic                       config_en;
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
        input           config_en,

        output          start,
        output          count
    );

    task init();
        start           = 1'b0;
        count           = {(CNT_WIDTH){1'b0}};
    endtask

    task automatic start(input int num_count);
        sema.get(1);

        #1
        start           = 1'b1;
        @(posedge clk);
        
        while (config_en == 1'b0) begin
            @(posedge clk);
        end
        count           = num_count;
        
        while (done == 1'b0) begin
            @(posedge clk);
        end
        _repeat         = 1'b1;

        while (done == 1'b0) begin
            @(posedge clk);
        end
        _repeat         = 1'b0;

        sema.put(1);
    endtask

endinterface