module event_generator(
    input CLK,                // Systemtakt
    input RST,                // Reset
    input [31:0] period,      // Tick-Periode
    output reg tick,          // Ein-Takt-Impuls
    output reg tickIndicator  // LED-Indikator
);

reg [31:0] counter;           // Zähler für Tick-Erzeugung

`ifdef SIMULATION
localparam INDICATOR_TIME = 2;
`else
localparam INDICATOR_TIME = 500000;
`endif

always @(posedge CLK) begin

    if(RST) begin
        counter <= 0;
        tick <= 0;
        tickIndicator <= 0;
    end
    else begin

        // Tick standardmäßig zurücksetzen
        tick <= 0;

        // Tick erzeugen wenn Periode erreicht
        if(counter >= period - 1) begin
            counter <= 0;
            tick <= 1;
            tickIndicator <= 1;
        end
        else begin
            counter <= counter + 1;

            // LED-Indikator nach kurzer Zeit wieder aus
            if(counter >= INDICATOR_TIME)
                tickIndicator <= 0;
        end
    end
end

endmodule
