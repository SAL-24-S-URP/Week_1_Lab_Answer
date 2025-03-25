// Copyright (c) 2024 Sungkyunkwan University
//
// Authors:
// - Sanghyun Park <psh2018314072@gmail.com>


module FSM
(
    input   wire                    clk,
    input   wire                    rst_n,

    input   wire    [3:0]           count_i,
    input   wire                    count_valid_i,
    input   wire                    start_i,
    input   wire                    _repeat_i,
    input   wire                    _repeat_valid_i,

    output  wire                    ready_o,
    output  wire                    run_o,
    output  wire                    done_o
);

    localparam  S_IDLE              = 3'b000;
    localparam  S_CONF              = 3'b001;
    localparam  S_RUN               = 3'b010;
    localparam  S_DONE              = 3'b011;
    localparam  S_ASK               = 3'b100;

    logic    [2:0]                  state, state_n;
    logic    [3:0]                  cnt, cnt_n;
    logic    [3:0]                  count, count_n;

    logic                           done;
    logic                           run;
    logic                           ready;
    
    always_ff @(posedge clk) begin
        if(!rst_n) begin
            state                   <= S_IDLE;
            cnt                     <= 4'h0;
            count                   <= 4'h0;
        end else begin
            state                   <= state_n;
            cnt                     <= cnt_n;
            count                   <= count_n;
        end
    end

    always_comb begin
        ready                       = 1'b0;
        run                         = 1'b0;
        done                        = 1'b0;
        state_n                     = state;
        cnt_n                       = cnt;
        count_n                     = count;

        case(state)
            S_IDLE: begin
                ready               = 1'b1;
                if(start_i) begin
                    state_n         = S_CONF; 
                end
            end
            
            S_CONF: begin
                if(count_valid_i) begin
                    count_n         = count_i;
                    state_n         = S_RUN;
                end else begin
                    state_n         = S_CONF;
                end
            end

            S_RUN: begin
                run                 = 1'b1;
                if(cnt == count) begin
                    cnt_n           = 4'h0;
                    state_n         = S_DONE;
                end else begin
                    cnt_n           = cnt + 1'b1;
                end
            end

            S_DONE: begin
                done                = 1'b1;
                state_n             = S_ASK;
            end

            S_ASK: begin
                if(_repeat_valid_i == 1'b1) begin
                    if(_repeat_i == 1'b1) begin
                        state_n     = S_RUN;
                    end else begin
                        state_n     = S_IDLE;
                    end
                end else begin
                    state_n         = S_ASK;
                end
            end
        endcase
    end

    assign  done_o                  = done;
    assign  run_o                   = run;
    assign  ready_o                 = ready;

endmodule
