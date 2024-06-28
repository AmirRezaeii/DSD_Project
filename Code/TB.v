module TB;
    reg clk;
    reg reset;
    wire move;
    wire direction;
    reg [4:0] intenral_buttons;
    reg [4:0] external_buttons;
    wire [4:0] current_floor;
    reg [1:0] prev_floor_indi [4:0];
    wire [1:0] floor_indi [4:0];

    elevator #(5) e_inst (
        .clk(clk),
        .state({move, direction}),
        .current_floor(current_floor),
        .reset(reset),
        .floor_indi(floor_indi)
    );
    elevator_controller #(5) ec_inst (
        .clk(clk),
        .external_buttons(external_buttons),
        .floor_indi(floor_indi),
        .reset(reset),
        .intenral_buttons(intenral_buttons),
        .current_floor(current_floor),
        .direction(direction),
        .move(move)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        intenral_buttons = 0;
        external_buttons = 0;
        
        #10 reset = 0;
        external_buttons[0] = 1'b1;          // همکف
        #10 external_buttons[0] = 1'b0;      // همکف
        #10 intenral_buttons[3] = 1'b1;      // سوم
        #10 intenral_buttons[3] = 1'b0;      // سوم
        #200 external_buttons[2] = 1'b1;     // دوم
        #10 external_buttons[2] = 1'b0;      // دوم
        #10 external_buttons[4] = 1'b1;      // چهارم
        #10 external_buttons[4] = 1'b0;      // چهارم
        #10 external_buttons[1] = 1'b1;      // اول
        #10 external_buttons[1] = 1'b0;      // اول
        #100 intenral_buttons[2] = 1'b1;     // دوم و چون در مسیر اسانسور قرار دارد پس در ان توقف میکند
        #10 intenral_buttons[2] = 1'b0;      // همکف
        #2500 intenral_buttons[0] = 1'b1;    // اول
        #10 intenral_buttons[0] = 1'b0;      // همکف
        #150 intenral_buttons[4] = 1'b1;     // اول
        #10 intenral_buttons[4] = 1'b0;      // همکف
        #20 external_buttons[0] = 1'b1;      // اول
        #10 external_buttons[0] = 1'b0;      // همکف
        #1000;
        $stop();
    end
    
    always @(posedge clk) begin
        if (floor_indi !== prev_floor_indi) begin
            $display("at time %3d", $time, " Floor indicators changed:");
            $display("Current value:  %p", floor_indi);
        end
        prev_floor_indi <= floor_indi;
    end

endmodule

