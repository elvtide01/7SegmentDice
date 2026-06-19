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
    // --------------------------------------------------------
    // Global clock input
    // --------------------------------------------------------
    // Tiny Tapeout provides a 12 MHz clock according to the
    // project configuration file.
    //
    input wire clk,
  
    // --------------------------------------------------------
    // Active-low reset input
    // --------------------------------------------------------
    // The current design does not use reset explicitly because
    // the internal modules initialize their registers.
    //
    // This signal is kept to fulfill the Tiny Tapeout interface.
    //
    input wire rst_n,

    // --------------------------------------------------------
    // User input pins
    // --------------------------------------------------------
    //
    // Mapping according to info.yaml:
    //
    // ui[0] = Dice trigger button
    // ui[1..7] = unused
    //
    input wire [7:0] ui_in,

    // --------------------------------------------------------
    // User output pins
    // --------------------------------------------------------
    //
    // Seven-segment display mapping:
    //
    // uo[0] -> Segment A
    // uo[1] -> Segment B
    // uo[2] -> Segment C
    // uo[3] -> Segment D
    // uo[4] -> Segment E
    // uo[5] -> Segment F
    // uo[6] -> Segment G
    // uo[7] -> Common connection
    //
    output wire [7:0] uo_out,

    // --------------------------------------------------------
    // Bidirectional user pins
    // --------------------------------------------------------
    //
    // These pins are used as outputs only:
    //
    // uio[0] -> Counting pulse indicator
    // uio[1] -> Finished indicator
    //
    input wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input wire ena
);

    // ========================================================
    // Internal signal declarations
    // ========================================================

    // Trigger signal connected to the dice controller
    wire trigger;

    // Seven-segment display signals
    wire sega;
    wire segb;
    wire segc;
    wire segd;
    wire sege;
    wire segf;
    wire segg;

    // Common pin of the seven-segment display
    wire common;

    // Status indicators
    wire pulsecount;
    wire finish;

    // ========================================================
    // Input mapping
    // ========================================================
    //
    // Connect Tiny Tapeout input pin ui[0] to the internal
    // dice trigger signal.
    //
    // trigger = 1 starts the rolling process.
    //
    assign trigger = ui_in[0];

    // ========================================================
    // Configure bidirectional pins
    // ========================================================
    //
    // uio_oe controls the direction of bidirectional pins:
    //
    // 1 = output mode
    // 0 = input mode
    //
    // Only uio[0] and uio[1] are required as outputs.
    // All other bidirectional pins remain unused.
    //
    assign uio_oe = 8'b00000011;

    // ========================================================
    // Instantiate dice logic
    // ========================================================
    //
    // dice_top contains:
    //
    // - Dice controller
    // - Event generator
    // - Seven-segment decoder
    //
    // This wrapper only provides the Tiny Tapeout interface.
    //
    dice_top dice_inst (
        // System clock
        .CLK(clk),

        // Trigger input
        .TRIGGER(trigger),

        // ----------------------------------------------------
        // Status outputs
        // ----------------------------------------------------

        // Indicates every counting event
        .LED1(pulsecount),

        // Indicates that the dice stopped rolling
        .LED2(finish),

        // ----------------------------------------------------
        // Seven-segment outputs
        // ----------------------------------------------------
        .SEGA(sega),
        .SEGB(segb),
        .SEGC(segc),
        .SEGD(segd),
        .SEGE(sege),
        .SEGF(segf),
        .SEGG(segg),

        // Common display connection
        .SEGCOM(common)
    );

    // ========================================================
    // Seven-segment output mapping
    // ========================================================
    //
    // Connect internal display signals to Tiny Tapeout pins.
    //
    assign uo_out[0] = sega;     // Segment A
    assign uo_out[1] = segb;     // Segment B
    assign uo_out[2] = segc;     // Segment C
    assign uo_out[3] = segd;     // Segment D
    assign uo_out[4] = sege;     // Segment E
    assign uo_out[5] = segf;     // Segment F
    assign uo_out[6] = segg;     // Segment G

    // Common terminal of the seven-segment display
    assign uo_out[7] = common;

    // ========================================================
    // Status output mapping
    // ========================================================
    //
    // Bidirectional pins are used as output-only LED signals.
    //
    // uio[0]:
    //   Pulses whenever the dice value changes.
    //
    // uio[1]:
    //   Becomes active when the rolling process has finished.
    //

    assign uio_out[0] = pulsecount;
    assign uio_out[1] = finish;

    // Drive unused outputs low to avoid undefined states.
    //
    assign uio_out[7:2] = 6'b000000;

endmodule
