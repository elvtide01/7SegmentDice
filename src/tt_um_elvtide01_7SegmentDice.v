// ============================================================
// Tiny Tapeout Top-Level Wrapper
// Project: 7-Segment-Dice
//
// This module connects the Tiny Tapeout interface to the
// actual dice implementation.
//
// Responsibilities:
// - Map Tiny Tapeout pins to internal signals
// - Instantiate the dice logic
// - Route the seven-segment display outputs
// - Route status indicator outputs
//
// The actual dice functionality is implemented in:
//   - dice_controller.v
//   - event_generator.v
//   - sevenseg_decoder.v
//
// ============================================================
module tt_um_elvtide01_7SegmentDice (
    
    input wire clk,
  
    input wire rst_n,

    input wire [7:0] ui_in,

    output wire [7:0] uo_out,

    input wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input wire ena
);
    wire trigger;

    wire sega;
    wire segb;
    wire segc;
    wire segd;
    wire sege;
    wire segf;
    wire segg;

    wire common;

    wire pulsecount;
    wire finish;

    assign trigger = ui_in[0];

    assign uio_oe = 8'b00000011;

    dice_top dice_inst (
        // System clock
        .CLK(clk),
        .RST(~rst_n),

        // Trigger input
        .TRIGGER(trigger),

        
        .LED1(pulsecount),

        .LED2(finish),

        .SEGA(sega),
        .SEGB(segb),
        .SEGC(segc),
        .SEGD(segd),
        .SEGE(sege),
        .SEGF(segf),
        .SEGG(segg),

        .SEGCOM(common)
    );

    assign uo_out[0] = sega;     // Segment A
    assign uo_out[1] = segb;     // Segment B
    assign uo_out[2] = segc;     // Segment C
    assign uo_out[3] = segd;     // Segment D
    assign uo_out[4] = sege;     // Segment E
    assign uo_out[5] = segf;     // Segment F
    assign uo_out[6] = segg;     // Segment G

    assign uo_out[7] = common;

    assign uio_out[0] = pulsecount;
    assign uio_out[1] = finish;

    assign uio_out[7:2] = 6'b000000;
endmodule
