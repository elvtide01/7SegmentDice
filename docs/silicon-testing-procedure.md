# Silicon Testing Procedure

## 1. Purpose

This document describes, as precisely as possible, how the fabricated chip
(`tt_um_elvtide01_7SegmentDice`, 7-Segment Electronic Dice, submitted via the
Tiny Tapeout platform) is to be tested once silicon is available. It specifies which
input signals shall be applied and which output signals are expected in response, for
a representative sequence of clock cycles covering the fast-counting phase, the
deceleration phase, and the finish state.

This procedure is derived from the requirements in [specification.md](specification.md)
and from the functional behaviour already confirmed by simulation and FPGA testing, see
[verification-report.md](verification-report.md) and
[fpga-test-report.md](fpga-test-report.md). All signal names and pin assignments below
are taken directly from `src/tt_um_elvtide01_7SegmentDice.v`, `src/dice_top.v`,
`src/dice_controller.v`, and `src/event_generator.v`.

## 2. Device Under Test

| Item | Detail |
|---|---|
| Design name | `tt_um_elvtide01_7SegmentDice` |
| Target platform | Tiny Tapeout ASIC shuttle |
| Process / PDK | GlobalFoundries 180 nm MCU (GF180MCU), standard-cell library `gf180mcu_fd_sc_mcu7t5v0` |
| Supply voltage | 3.3 V (`VDD_PIN_VOLTAGE = 3.3`, see `config_merged.json`) |
| Timing-closure target | 50 MHz (`CLOCK_PERIOD = 20 ns` in the LibreLane configuration; this is the closure target used during hardening, not necessarily the intended application frequency) |
| Application clock frequency | 12 MHz (`CLK_FREQ = 12000000` in `dice_controller.v`, non-`SIMULATION` branch) |
| Die area | 346.64 µm × 160.72 µm (`DIE_AREA` in `config_merged.json`) |
| Package / interface | Tiny Tapeout standard user I/O (`ui_in`, `uo_out`, `uio_in`/`uio_out`/`uio_oe`, `ena`) |

## 3. Required Measurement Equipment

| Equipment | Purpose |
|---|---|
| Tiny Tapeout demo board (or equivalent breakout PCB) | Hosts the fabricated die and provides access to the user I/O pins |
| Clock source, 12 MHz (application) and/or up to 50 MHz (closure limit) | Provides `clk` |
| Push-button or logic-level switch | Drives `TRIGGER` via `ui_in[0]` |
| Push-button or logic-level switch (or host-controlled GPIO) | Drives `rst_n` |
| Logic analyzer or oscilloscope (≥ 4 channels, ≥ 1 MHz bandwidth) | Captures `clk`, `rst_n`, `ui_in[0]`, `uo_out[7:0]`, `uio_out[1:0]` |
| 7-segment display, common-anode-compatible wiring, or logic-level probes | Visual/electrical readout of the segment outputs (`uo_out[6:0]`) and common line (`uo_out[7]`) |
| USB-to-serial or GPIO interface (standard Tiny Tapeout demo board) | Convenient control of `ui_in`/`rst_n` and readback of `uo_out`/`uio_out` |

No additional analog signal conditioning is required, since all inputs and outputs of
this design are purely digital.

## 4. Pin Mapping

The following mapping is taken directly from `tt_um_elvtide01_7SegmentDice.v`.

| Signal | Direction | Tiny Tapeout Pin | Description |
|---|---|---|---|
| `clk` | Input | dedicated clock pin | System clock, drives `dice_top.CLK` |
| `rst_n` | Input | dedicated reset pin | Connected **directly** (no inversion) to `dice_top.RST` — see Section 4.1 for the resulting polarity behaviour |
| `TRIGGER` | Input | `ui_in[0]` | Dice-roll trigger button (`assign trigger = ui_in[0];`) |
| `SEGA` | Output | `uo_out[0]` | 7-segment output A (active-low, inverted inside `dice_top`) |
| `SEGB` | Output | `uo_out[1]` | 7-segment output B (active-low) |
| `SEGC` | Output | `uo_out[2]` | 7-segment output C (active-low) |
| `SEGD` | Output | `uo_out[3]` | 7-segment output D (active-low) |
| `SEGE` | Output | `uo_out[4]` | 7-segment output E (active-low) |
| `SEGF` | Output | `uo_out[5]` | 7-segment output F (active-low) |
| `SEGG` | Output | `uo_out[6]` | 7-segment output G (active-low) |
| `SEGCOM` | Output | `uo_out[7]` | Common line, permanently tied to `0` (`assign SEGCOM = 0;` in `dice_top.v`) |
| `LED1` (pulse count) | Output | `uio_out[0]` | Counting-event indicator, active-low pulse per tick |
| `LED2` (finish) | Output | `uio_out[1]` | Finish indicator, active-low (`0` = finished) |
| `uio_out[7:2]` | Output | — | Tied to `0` (`assign uio_out[7:2] = 6'b000000;`), unused |
| `uio_oe` | — | fixed | `8'b00000011`: only `uio[1:0]` are driven as outputs, all other `uio` pins remain inputs |
| `ena` | Input | fixed by TT harness | Standard Tiny Tapeout enable signal, not used by the design logic |

### 4.1 Reset Polarity Note

Although the Tiny Tapeout pin is named `rst_n` (suggesting active-low, per Tiny Tapeout
convention), it is wired **without inversion** to the internal `RST` signal used
throughout `dice_top.v`, `dice_controller.v`, and `event_generator.v`. Inside these
modules, `RST` is evaluated directly (`if (RST) begin ... end`, i.e. active-**high**
behaviour). Consequently, on the fabricated chip:

- **`rst_n = 1`** → internal `RST = 1` → the design is held in reset (`value = 0`,
  `finish_flag = 1`, i.e. `LED2` inactive/finished state).
- **`rst_n = 0`** → internal `RST = 0` → the design runs normally.

This is the opposite of the naming convention suggested by the `_n` suffix and must be
taken into account when applying the reset signal during silicon testing (this
inconsistency was already noted as a limitation in
[verification-report.md](verification-report.md), VER-001).

## 5. Test Procedure

The following table specifies, for each labeled test phase, the applied input signals
and the expected output values, following the format suggested by the laboratory
description (Table 1: "Example silicon testing procedure for a synchronous digital
module"). Clock cycle numbers are relative to the start of each phase. All signals use
the pin mapping and reset polarity defined in Section 4.

| Phase | Clock Cycle | `rst_n` | `ui_in[0]` (`TRIGGER`) | Expected `uio_out[0]` (`LED1`) | Expected `uio_out[1]` (`LED2`) | Expected `uo_out[6:0]` (segments) | Measured | Pass / Fail |
|---|---:|---|---|---|---|---|---|---|
| Reset asserted | 0 | 1 | 0 | inactive (1) | 0 (finished) | all segments off (inactive-high, i.e. `0000000`) | | |
| Reset released | 1 | 0 | 0 | inactive (1) | 0 (finished) | value 0 pattern (dice controller resets `value` to 0) | | |
| Trigger asserted | 2 | 0 | 1 | pulses (0 briefly) | 1 (not finished) | value 1 pattern | | |
| Fast counting | 2 + 25 ms/cycle × N | 0 | 1 | pulses every ≈25 ms (at 12 MHz application clock) | 1 | cycles 1→2→3→4→5→6→1 | | |
| Trigger released | at $t = t_0$ | 0 | 0 | pulses, interval doubling each second | 1 | continues cycling, slowing down | | |
| Deceleration step 1 (after +1 s) | $t_0$ + 1 s | 0 | 0 | pulse interval ≈ 50 ms | 1 | still cycling | | |
| Deceleration step 2 (after +2 s) | $t_0$ + 2 s | 0 | 0 | pulse interval ≈ 100 ms | 1 | still cycling | | |
| Deceleration steps 3–5 (after +3…+5 s) | $t_0$ + 3…5 s | 0 | 0 | pulse interval doubling further (200/400/800 ms) | 1 | still cycling | | |
| Finish state | $t_0$ + ≈6 s (decay level reaches 5, see `dice_controller.v`) | 0 | 0 | inactive (no further pulses) | 0 (finished) | final value held constant (1–6) | | |
| Value persistence | until next trigger | 0 | 0 | inactive | 0 | identical value on repeated reads | | |
| Re-trigger | any time after finish | 0 | 1 | resumes pulsing | 1 | resumes cycling from current value | | |

Each row shall be repeated for at least three independent dice rolls to confirm
repeatability, and the finish value shall be recorded for each run to visually confirm
that only values 1–6 ever occur (REQ-002).

> **Note on finish timing:** `dice_controller.v` sets `finish_flag <= 1` once
> `decay_level` has already reached its maximum value of 5 and a further full second
> elapses without a new trigger; combined with the initial fast-counting interval, this
> results in an overall stop time of approximately 6–7 seconds after trigger release,
> consistent with REQ-006 ("approximately seven seconds").

## 6. Additional Checks

1. **Reset behaviour (REQ-001):** Assert `rst_n = 1` for at least 5 clock cycles at any
   point during operation and confirm that `uio_out[1]` (`LED2`) returns to `0`
   (finished) immediately after `rst_n` is released back to `0`, regardless of the
   prior state. See Section 4.1 for the (inverted) polarity convention.
2. **Value range (REQ-002):** Over at least 10 complete dice rolls, confirm by visual
   inspection of the 7-segment display that only the digits 1–6 are ever shown (segment
   patterns corresponding to `sevenseg_decoder.v` values 1–6 only).
3. **Timing accuracy (REQ-006):** Using the logic analyzer, measure the time between
   trigger release (`ui_in[0]: 1→0`) and the last pulse on `uio_out[0]` and confirm it
   lies within $7\,\text{s} \pm 1\,\text{s}$ when clocked at the intended application
   frequency of 12 MHz.
4. **Segment polarity check:** Confirm that `uo_out[6:0]` are active-low (segment
   driven low = segment on), consistent with the inversion performed in `dice_top.v`
   (`assign SEGA = ~seg_data[6];`, etc.), and that `uo_out[7]` (`SEGCOM`) remains
   permanently at `0`.
5. **Power supply:** Confirm nominal supply current draw at `VPWR = 3.3 V` is within
   the expected range for the GF180MCU process at the application clock frequency (no
   excessive static or dynamic current, which could indicate a fabrication defect such
   as a short).

## 7. Pass / Fail Criteria

The silicon test is considered **Pass** if:
- all rows of the procedure table in Section 5 are marked Pass,
- all additional checks in Section 6 are satisfied,
- no unexpected latch-up, excessive current draw, or non-responsive behaviour is
  observed during any test run.

Any deviation shall be documented in a manner analogous to
[fpga-test-report.md](fpga-test-report.md), cross-referencing the corresponding
requirement in [specification.md](specification.md).

## 8. Status

> **Not yet executed.** Silicon for this design has not been received at the time of
> report submission, as fabrication and shuttle turnaround times exceed the duration of
> this laboratory course. This procedure will be executed once the manufactured chip is
> available for testing, as indicated by the "Optional: Silicon Testing Procedure"
> chapter of the laboratory description.
