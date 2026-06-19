module dice_controller(
    input CLK,                // Systemtakt
    input RST,                // Reset-Signal
    input TRIGGER,            // Würfeltaste
    input tick,               // Ereignisimpuls vom Event-Generator

    output reg [3:0] value,   // Aktueller Würfelwert
    output reg finish_flag,   // 1 = Würfeln beendet
    output [31:0] event_period// Aktuelle Tick-Periode
);

`ifdef SIMULATION
localparam CLK_FREQ  = 20;    // Reduzierte Taktfrequenz für Simulation
localparam BASE_FREQ = 10;    // Startfrequenz beim Würfeln
`else
localparam CLK_FREQ  = 12000000; // FPGA-Takt
localparam BASE_FREQ = 40;       // Würfelgeschwindigkeit
`endif

// Grundperiode des Event-Generators
localparam BASE_PERIOD = CLK_FREQ / BASE_FREQ;

// Verlangsamungsstufen
reg [31:0] second_counter;

// Bestimmt die aktuelle Verlangsamung
reg [3:0] decay_level;

// Tick-Periode wird mit jeder Stufe verdoppelt
assign event_period = BASE_PERIOD << decay_level;

initial begin
    $display("CLK_FREQ=%0d", CLK_FREQ);
    $display("BASE_PERIOD=%0d", BASE_PERIOD);
end
    
always @(posedge CLK) begin

    //  Reset 
    if(RST) begin
        value <= 0;                  // Anzeige zurücksetzen
        finish_flag <= 1;            // Würfeln beendet
        second_counter <= CLK_FREQ-1;
        decay_level <= 0;
    end

    //  Taste gedrückt
    else if(TRIGGER) begin

        decay_level <= 0;            // Verlangsamung zurücksetzen
        second_counter <= 0;
        finish_flag <= 0;            // Würfeln aktiv

        // Bei jedem Tick nächsten Würfelwert anzeigen
        if(tick) begin
            value <= value + 1;

            // Nach 6 wieder bei 1 beginnen
            if(value >= 6)
                value <= 1;
        end
    end

    // Taste losgelassen
    else begin

        // Jede Sekunde eine Verlangsamungsstufe erhöhen
        if(second_counter >= CLK_FREQ-1) begin

            second_counter <= 0;

            if(decay_level < 5)
                decay_level <= decay_level + 1;
            else
                finish_flag <= 1;    // Würfel stoppt
        end
        else begin
            second_counter <= second_counter + 1;
        end

        // Solange nicht fertig weiterwürfeln
        if(tick && !finish_flag) begin

            if(value >= 6)
                value <= 1;
            else
                value <= value + 1;
        end
    end
end

endmodule
