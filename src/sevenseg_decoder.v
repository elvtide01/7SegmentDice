module sevenseg_decoder(
    input  [3:0] value,   // Anzuzeigender Wert
    input RST,            // Reset
    output reg [6:0] seg  // Segmentmuster
);

always @(*) begin

    // Bei Reset Anzeige löschen
    if(RST) begin
        seg = 7'h00;
    end
    else begin

        // Umwandlung von Hex-Zahl zu Segmentmuster
        case(value)
            4'h0: seg = 7'h7E;
            4'h1: seg = 7'h30;
            4'h2: seg = 7'h6D;
            4'h3: seg = 7'h79;
            4'h4: seg = 7'h33;
            4'h5: seg = 7'h5B;
            4'h6: seg = 7'h5F;
            4'h7: seg = 7'h70;
            4'h8: seg = 7'h7F;
            4'h9: seg = 7'h7B;
            4'hA: seg = 7'h77;
            4'hB: seg = 7'h1F;
            4'hC: seg = 7'h4E;
            4'hD: seg = 7'h3D;
            4'hE: seg = 7'h4F;
            4'hF: seg = 7'h47;

            // Ungültiger Wert
            default: seg = 7'h00;
        endcase
    end
end

endmodule
