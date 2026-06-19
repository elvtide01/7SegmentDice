module dice_top (

    // Eingänge
    input CLK,
    input RST,
    input TRIGGER,

    // LEDs
    output LED1,
    output LED2,

    // 7-Segment-Anzeige
    output SEGA,
    output SEGB,
    output SEGC,
    output SEGD,
    output SEGE,
    output SEGF,
    output SEGG,
    output SEGCOM
);

// Aktueller Würfelwert
wire [3:0] dice_value;

// Segmentdaten
wire [6:0] seg_data;

// Statussignale
wire finish_flag;
wire tick;
wire tInd;

// Dynamische Tick-Periode
wire [31:0] event_period;


// -------------------------------------------------
// Würfelsteuerung
// -------------------------------------------------
dice_controller dice(
    .CLK(CLK),
    .RST(RST),
    .TRIGGER(TRIGGER),
    .tick(tick),

    .value(dice_value),
    .finish_flag(finish_flag),
    .event_period(event_period)
);


// -------------------------------------------------
// Tick-Erzeugung
// -------------------------------------------------
event_generator evt(
    .CLK(CLK),
    .RST(RST),
    .period(event_period),
    .tick(tick),
    .tickIndicator(tInd)
);


// -------------------------------------------------
// 7-Segment-Dekoder
// -------------------------------------------------
sevenseg_decoder seg7(
    .value(dice_value),
    .RST(RST),
    .seg(seg_data)
);


// -------------------------------------------------
// LEDs
// -------------------------------------------------

// LED1 blinkt bei jedem Tick solange gewürfelt wird
assign LED1 = ~(tInd && ~finish_flag && ~RST);

// LED2 zeigt Fertigzustand an (active-low)
assign LED2 = ~(finish_flag && ~RST);


// -------------------------------------------------
// Segmentausgänge (active-low)
// -------------------------------------------------
assign SEGA = ~seg_data[6];
assign SEGB = ~seg_data[5];
assign SEGC = ~seg_data[4];
assign SEGD = ~seg_data[3];
assign SEGE = ~seg_data[2];
assign SEGF = ~seg_data[1];
assign SEGG = ~seg_data[0];

// Gemeinsame Kathode/Anode fest aktiv
assign SEGCOM = 0;

endmodule


// -------------------------------------------------
// VCD-Dump für Cocotb/Icarus Simulation
// -------------------------------------------------
module cocotb_iverilog_dump();
    initial begin
        $dumpfile("sim_build/dice_top.vcd");
        $dumpvars(0, dice_top);
        #1;
    end
endmodule
