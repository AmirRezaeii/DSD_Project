module Elevator_Control (
    input clk,
    input reset,
    input [4:0] sensor,
    input [4:0] call_button,
    input [4:0] dest_button,
    output reg motor_dir,
    output reg motor_move
);

    parameter IDLE_GROUND = 3'b000,
              IDLE_1      = 3'b001,
              IDLE_2      = 3'b010,
              IDLE_3      = 3'b011,
              IDLE_4      = 3'b100,
              MOVING_UP   = 3'b101,
              MOVING_DOWN = 3'b110,
              STOPPING    = 3'b111;

    parameter GROUND = 3'b000, 
              FLOOR_1 = 3'b001, 
              FLOOR_2 = 3'b010, 
              FLOOR_3 = 3'b011, 
              FLOOR_4 = 3'b100;

    reg [2:0] state, next_state;
    reg [4:0] call_requests;
    reg [4:0] dest_requests;
    reg [2:0] current_floor;

    initial begin
        state = IDLE_GROUND;
        call_requests = 5'b0;
        dest_requests = 5'b0;
        current_floor = GROUND;
        motor_dir = 0;
        motor_move = 0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            call_requests <= 5'b0;
            dest_requests <= 5'b0;
        end else begin
            call_requests <= call_requests | call_button;
            dest_requests <= dest_requests | dest_button;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE_GROUND;
            current_floor <= GROUND;
        end else begin
            state <= next_state;
            case (sensor)
                5'b00001: current_floor <= GROUND;
                5'b00010: current_floor <= FLOOR_1;
                5'b00100: current_floor <= FLOOR_2;
                5'b01000: current_floor <= FLOOR_3;
                5'b10000: current_floor <= FLOOR_4;
                default: current_floor <= current_floor;
            endcase
        end
    end

    always @(*) begin
        next_state = state;
        motor_dir = 0;
        motor_move = 0;

        case (state)
            IDLE_GROUND: begin
                if (call_requests[FLOOR_1] || dest_requests[FLOOR_1]) begin
                    next_state = MOVING_UP;
                    motor_dir = 1;
                    motor_move = 1;
                end
            end
            IDLE_1: begin
                if (call_requests[GROUND] || dest_requests[GROUND]) begin
                    next_state = MOVING_DOWN;
                    motor_dir = 0;
                    motor_move = 1;
                end else if (call_requests[FLOOR_2] || dest_requests[FLOOR_2]) begin
                    next_state = MOVING_UP;
                    motor_dir = 1;
                    motor_move = 1;
                end
            end
            IDLE_2: begin
                if (call_requests[FLOOR_1] || dest_requests[FLOOR_1]) begin
                    next_state = MOVING_DOWN;
                    motor_dir = 0;
                    motor_move = 1;
                end else if (call_requests[FLOOR_3] || dest_requests[FLOOR_3]) begin
                    next_state = MOVING_UP;
                    motor_dir = 1;
                    motor_move = 1;
                end
            end
            IDLE_3: begin
                if (call_requests[FLOOR_2] || dest_requests[FLOOR_2]) begin
                    next_state = MOVING_DOWN;
                    motor_dir = 0;
                    motor_move = 1;
                end else if (call_requests[FLOOR_4] || dest_requests[FLOOR_4]) begin
                    next_state = MOVING_UP;
                    motor_dir = 1;
                    motor_move = 1;
                end
            end
            IDLE_4: begin
                if (call_requests[FLOOR_3] || dest_requests[FLOOR_3]) begin
                    next_state = MOVING_DOWN;
                    motor_dir = 0;
                    motor_move = 1;
                end
            end
            MOVING_UP: begin
                if (sensor[FLOOR_4]) begin
                    next_state = IDLE_4;
                    motor_move = 0;
                end else if (sensor[FLOOR_3]) begin
                    next_state = IDLE_3;
                    motor_move = 0;
                end else if (sensor[FLOOR_2]) begin
                    next_state = IDLE_2;
                    motor_move = 0;
                end else if (sensor[FLOOR_1]) begin
                    next_state = IDLE_1;
                    motor_move = 0;
                end else begin
                    next_state = MOVING_UP;
                    motor_move = 1;
                end
                motor_dir = 1;
            end
            MOVING_DOWN: begin
                if (sensor[GROUND]) begin
                    next_state = IDLE_GROUND;
                    motor_move = 0;
                end else if (sensor[FLOOR_1]) begin
                    next_state = IDLE_1;
                    motor_move = 0;
                end else if (sensor[FLOOR_2]) begin
                    next_state = IDLE_2;
                    motor_move = 0;
                end else if (sensor[FLOOR_3]) begin
                    next_state = IDLE_3;
                    motor_move = 0;
                end else begin
                    next_state = MOVING_DOWN;
                    motor_move = 1;
                end
                motor_dir = 0;
            end
            STOPPING: begin
                if (sensor[current_floor]) begin
                    next_state = state;
                    motor_move = 0;
                end
            end
            default: next_state = IDLE_GROUND;
        endcase
    end

    always @(posedge clk) begin
        if (motor_move == 0 && sensor[current_floor]) begin
            call_requests[current_floor] <= 1'b0;
            dest_requests[current_floor] <= 1'b0;
        end
    end

endmodule