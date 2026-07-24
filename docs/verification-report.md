# Verification Report

## 1. Purpose

This verification report documents the evidence collected during the verification of the electronic dice design.
It records the outcome of each automated test, explains the relevance of each test with respect to the associated requirements, and provides an overall verification status.

The report is linked from [specification.md](specification.md) via the `Verification:` fields of each requirement.

## 2. Verification Environment

| Item | Detail |
|---|---|
| Simulation framework | cocotb (Python-based HDL co-simulation) |
| Testbench file | `test (1).py` |
| Simulation mode | RTL (`GATES` not set) |
| Test clock period | 10 ns (100 MHz testbench clock; design assumes 12 MHz in production) |
| Total simulation time | 51,004,010.01 ns |
| Total real execution time | 151.23 s |
| Runner | `cocotb.regression` |
| Result summary | **TESTS=8 PASS=8 FAIL=0 SKIP=0** |

The full cocotb console output, including per-test simulation times and pass/fail status, is reproduced in Section 4.

## 3. Test Results Summary

| Test ID | Cocotb Function | Status | Sim Time (ns) | Real Time (s) |
|---|---|---|---:|---:|
| VER-001 | `val001_reset` | **PASS** | 50.00 | 0.00 |
| VER-004 | `val002_display_changes` | **PASS** | 3,000,070.00 | 9.41 |
| VER-004 | `val003_multiple_states` | **PASS** | 12,000,060.00 | 38.57 |
| VER-008 | `val004_count_led` | **PASS** | 70.00 | 0.00 |
| VER-009 | `val005_finish_led_off` | **PASS** | 1,070.00 | 0.00 |
| VER-006 | `val006_stop_after_release` | **PASS** | 1,070.00 | 0.00 |
| VER-007 | `val008_final_value_constant` | **PASS** | 24,001,560.00 | 66.04 |
| VER-010 | `val009_multiple_dice_values` | **PASS** | 12,000,060.00 | 37.20 |

> **Note on test numbering:** the cocotb functions use the identifiers `val001`–`val009` (with `val007` absent from this run). The VER-IDs in this report follow the requirement numbering from `specification.md`, not the cocotb function names. The mapping is detailed in Section 5.

## 4. Cocotb Console Output (Evidence)

The following output was captured from the cocotb regression run:

```
    0.00ns INFO  cocotb                          Running tests
    0.00ns INFO  cocotb.regression               running testbench.val001_reset (1/8)
   50.00ns INFO  cocotb.regression               testbench.val001_reset passed
   50.00ns INFO  cocotb.regression               running testbench.val002_display_changes (2/8)
 3000120.00ns INFO  cocotb.regression             testbench.val002_display_changes passed
 3000120.00ns INFO  cocotb.regression             running testbench.val003_multiple_states (3/8)
15000180.00ns INFO  cocotb.regression             testbench.val003_multiple_states passed
15000180.00ns INFO  cocotb.regression             running testbench.val004_count_led (4/8)
15000250.00ns INFO  cocotb.regression             testbench.val004_count_led passed
15000250.00ns INFO  cocotb.regression             running testbench.val005_finish_led_off (5/8)
15001320.00ns INFO  cocotb.regression             testbench.val005_finish_led_off passed
15001320.00ns INFO  cocotb.regression             running testbench.val006_stop_after_release (6/8)
15002390.01ns INFO  cocotb.regression             testbench.val006_stop_after_release passed
15002390.01ns INFO  cocotb.regression             running testbench.val008_final_value_constant (7/8)
39003950.01ns INFO  cocotb.regression             testbench.val008_final_value_constant passed
39003950.01ns INFO  cocotb.regression             running testbench.val009_multiple_dice_values (8/8)
51004010.01ns INFO  cocotb.regression             testbench.val009_multiple_dice_values passed

** TEST                              STATUS   SIM TIME (ns)   REAL TIME (s)   RATIO (ns/s)
** testbench.val001_reset            PASS           50.00           0.00       34447.31
** testbench.val002_display_changes  PASS      3000070.00           9.41      318727.79
** testbench.val003_multiple_states  PASS     12000060.00          38.57      311090.83
** testbench.val004_count_led        PASS           70.00           0.00      202623.38
** testbench.val005_finish_led_off   PASS         1070.00           0.00      333847.00
** testbench.val006_stop_after_release PASS       1070.00           0.00      344138.12
** testbench.val008_final_value_constant PASS 24001560.00          66.04      363441.23
** testbench.val009_multiple_dice_values PASS 12000060.00          37.20      322613.51

** TESTS=8 PASS=8 FAIL=0 SKIP=0     51004010.01    151.23    337250.43
```

## 5. Detailed Verification Items

---

### VER-001: Reset Behavior

Requirement: [REQ-001](specification.md#req-001-reset-behavior)
Validation: [VAL-001](validation.md#val-001-reset-behavior)
Cocotb test: `val001_reset`
Status: **PASS** (sim time: 50.00 ns, real time: 0.00 s)

**Test procedure:** `reset_dut()` is called, which drives `rst_n = 1` for 5 rising edges and then asserts `rst_n = 0`. Immediately after, the test checks `LED2 == 0`.

**Result and relevance:** `LED2` was measured as `0` after reset, confirming that `finish_flag` is set upon reset, placing the design in the idle/finish state as required. This is the most fundamental precondition for all other tests; if reset behaviour were incorrect, every subsequent test result would be unreliable.

**Limitation:** The reset polarity ambiguity documented in specification Section 3 (the `_n` suffix suggests active-low, but the testbench behaviour is consistent with `rst_n = 0` being the active/running condition) is observable but does not affect the pass result as long as the RTL and testbench are consistent with each other. This should be clarified at RTL level before tape-out.

---

### VER-002: Dice Value Range

Requirement: [REQ-002](specification.md#req-002-dice-value-range)
Validation: [VAL-002](validation.md#val-002-dice-value-range)
Cocotb test: none (review-based)
Status: **PENDING — design review required**

**Relevance:** REQ-002 requires that only values 1–6 are displayed. The automated testbench does not decode segment patterns back to dice values and therefore cannot directly assert this range constraint. The requirement is partially covered by VER-010 (pattern diversity) and by design review of `sevenseg_decoder.v` and `dice_controller.v`.

**Recommended action:** Extend the testbench to decode the 7-bit `read_segments()` output against a reference lookup table and assert that every observed pattern corresponds to a value in {1, 2, 3, 4, 5, 6}.

---

### VER-003: Cyclic Dice Counting

Requirement: [REQ-003](specification.md#req-003-cyclic-dice-counting)
Validation: [VAL-003](validation.md#val-003-cyclic-dice-counting)
Cocotb test: partially covered by `val002_display_changes` and `val003_multiple_states`
Status: **PENDING — sequence order not verified**

**Relevance:** REQ-003 requires the exact sequence 1→2→3→4→5→6→1. The automated tests confirm that the pattern changes (`val002`) and that at least four distinct patterns occur (`val003`), but neither test records the transition order. Correct wrap-around (6→1) is not explicitly confirmed by simulation.

**Recommended action:** Add a test that records the full decoded sequence over at least one complete cycle and asserts the order and wrap.

---

### VER-004: Fast Counting While Trigger Is Pressed

Requirement: [REQ-004](specification.md#req-004-fast-counting-while-trigger-is-pressed)
Validation: [VAL-004](validation.md#val-004-fast-counting-while-trigger-is-pressed)
Cocotb tests: `val002_display_changes`, `val003_multiple_states`
Status: **PASS** (both tests passed)

**Test procedure — `val002_display_changes`:** `TRIGGER` is asserted; the test waits up to `DISPLAY_WAIT = 200` clock cycles and checks that the segment pattern changes at least once. Passed in 3,000,070 ns (including reset overhead).

**Test procedure — `val003_multiple_states`:** `TRIGGER` is asserted; the test collects all distinct segment patterns over `STATE_WAIT = 300` clock cycles and asserts that at least 4 distinct patterns are seen. Passed in 12,000,060 ns.

**Relevance:** Together these tests confirm that the design actively cycles through multiple dice values while the trigger is held, satisfying the observable counting behaviour of REQ-004. The exact 40 Hz frequency is validated by design/timing review (see specification Section 6) rather than by direct frequency measurement in RTL mode.

---

### VER-005: Deceleration After Trigger Release

Requirement: [REQ-005](specification.md#req-005-deceleration-after-trigger-release)
Validation: [VAL-005](validation.md#val-005-deceleration-after-trigger-release)
Cocotb test: none (review-based; indirectly supported by VER-006)
Status: **PENDING — monotonic deceleration not directly measured**

**Relevance:** REQ-005 requires that tick intervals increase monotonically after `TRIGGER` release. The Vivado waveform screenshots (`SimulationFull.PNG`, `SimulationStart.PNG`) provide visual evidence of progressive slowdown, but the cocotb regression suite does not contain a dedicated test that measures successive tick timestamps and asserts monotonically increasing intervals.

---

### VER-006: Stop After Approximately Seven Seconds

Requirement: [REQ-006](specification.md#req-006-stop-after-approximately-seven-seconds)
Validation: [VAL-006](validation.md#val-006-stop-after-approximately-seven-seconds)
Cocotb test: `val006_stop_after_release`
Status: **PASS** (sim time: 1,070.00 ns, real time: 0.00 s)

**Test procedure:** `TRIGGER` is asserted for 50 clock cycles, then released. The test then monitors the segment pattern and waits for it to remain stable for more than 50 consecutive clock cycles, within a window of `STOP_WAIT = 5,000` clock cycles.

**Relevance:** The test confirms that the design eventually enters a stable state after trigger release. The short RTL-mode window (5,000 cycles) tests behavioral stability rather than the exact ~7 s real-time duration; the 7-second timing constraint is verified by the Vivado full-simulation waveform (`SimulationFull.PNG`, cursor at 7.35 s) and by design review of the decay-level logic.

---

### VER-007: Final Value Remains Constant

Requirement: [REQ-007](specification.md#req-007-final-value-remains-constant)
Validation: [VAL-007](validation.md#val-007-final-value-remains-constant)
Cocotb test: `val008_final_value_constant`
Status: **PASS** (sim time: 24,001,560.00 ns, real time: 66.04 s)

**Test procedure:** After `TRIGGER` release, the test waits for `LED2 == 0` (finish active) within `FINISH_WAIT = 300` cycles, captures the current segment pattern, and then checks over 100 subsequent clock cycles that the pattern does not change.

**Relevance:** This is the strongest end-to-end test of the complete dice round. It confirms that the finish state is reached, that `LED2` correctly indicates it (active-low, `LED2 = 0`), and that the final displayed value is frozen. This directly satisfies REQ-007 and provides supporting evidence for REQ-009.

---

### VER-008: Counting Pulse LED

Requirement: [REQ-008](specification.md#req-008-counting-pulse-led)
Validation: [VAL-008](validation.md#val-008-counting-pulse-led)
Cocotb test: `val004_count_led`
Status: **PASS** (sim time: 70.00 ns, real time: 0.00 s)

**Test procedure:** `TRIGGER` is asserted; the test monitors `LED1` for up to 500 clock cycles and checks that `LED1` becomes active (`LED1 == 1`) at least once.

**Relevance:** Confirms that the `TICK_INDICATOR` signal from the event generator is correctly routed to `LED1` and that the active-low inversion at the top-level output mapping works as intended. The test passes very quickly (70 ns sim time), indicating that `LED1` activates well within the first few cycles after trigger assertion.

**Limitation:** The test confirms that `LED1` activates at least once, but does not verify that it pulses on every counting tick. A more thorough test would assert pulse-per-tick correspondence.

---

### VER-009: Finish LED

Requirement: [REQ-009](specification.md#req-009-finish-led)
Validation: [VAL-009](validation.md#val-009-finish-led)
Cocotb test: `val005_finish_led_off`
Status: **PASS** (sim time: 1,070.00 ns, real time: 0.00 s)

**Test procedure:** `TRIGGER` is asserted; over the next 100 clock cycles the test asserts on every rising edge that `LED2 == 1` (inactive, active-low), confirming that the finish indicator is not active during the rolling phase.

**Relevance:** Confirms that `LED2` is correctly held inactive while the dice is counting, satisfying the "finish LED off during rolling" aspect of REQ-009. The complementary assertion (`LED2 == 0` in finish state) is covered by VER-001 and VER-007.

---

### VER-010: 7-Segment Output Encoding

Requirement: [REQ-010](specification.md#req-010-7-segment-output-encoding)
Validation: [VAL-010](validation.md#val-010-7-segment-output-encoding)
Cocotb test: `val009_multiple_dice_values`
Status: **PASS** (sim time: 12,000,060.00 ns, real time: 37.20 s)

**Test procedure:** `TRIGGER` is asserted; the test collects all distinct 7-bit patterns from `read_segments()` over `STATE_WAIT = 300` clock cycles and asserts that at least 4 distinct patterns are present.

**Relevance:** Confirms that the `sevenseg_decoder` produces multiple distinct segment patterns, demonstrating that the encoder is functional and that different dice values map to different display outputs. The test satisfies the observable aspect of REQ-010.

**Limitation:** The test does not compare observed patterns against a reference lookup table. It therefore cannot confirm that each specific dice value (1–6) maps to the correct standard 7-segment encoding. A reference-table comparison is recommended as a follow-up test.

---

### VER-011: Hierarchical Design

Requirement: [REQ-011](specification.md#req-011-hierarchical-design)
Validation: [VAL-011](validation.md#val-011-hierarchical-design)
Cocotb test: none (architecture review)
Status: **PASS — confirmed by architecture review**

**Evidence:** The Vivado simulation tab bar visible in the waveform screenshots shows the files `main_tb.v`, `event_generator.v`, `dice_controller.v`, `main.v`, and `sevenseg_decoder.v` as separate open modules. The block diagram (`blockCD.jpeg`) confirms that `main.v` instantiates `DICE_CONTROLLER`, `EVENT_GENERATOR`, and `SEVENSEG_DECODER` as distinct submodules. This satisfies the requirement for at least two lower-level modules.

---

### VER-012: Simplicity

Requirement: [REQ-012](specification.md#req-012-simplicity)
Validation: [VAL-012](validation.md#val-012-simplicity)
Cocotb test: none (design review)
Status: **PASS — confirmed by design review**

**Evidence:** The design consists of exactly three functional submodules plus a top-level integration module. No memory blocks, arithmetic units, protocol interfaces, or hardware random-number generators are present. The entire design fits within the scope of a student laboratory project.

---

### VER-013: Testability

Requirement: [REQ-013](specification.md#req-013-testability)
Validation: [VAL-013](validation.md#val-013-testability)
Cocotb test: entire test suite
Status: **PASS**

**Evidence:** The cocotb regression suite (`test (1).py`) executed 8 tests in RTL simulation mode and all 8 passed. The testbench supports both RTL and gate-level simulation via the `GATES` environment variable. The Vivado waveform screenshots provide additional visual evidence of a working simulation environment.

---

## 6. Coverage Gaps Summary

The following requirements are not fully covered by the automated test suite and retain a **PENDING** status:

| VER-ID | Requirement | Gap | Action Required |
|---|---|---|---|
| VER-002 | REQ-002: Dice Value Range | No segment-to-value decoding in testbench | Add reference-table comparison |
| VER-003 | REQ-003: Cyclic Dice Counting | Transition order and wrap-around not verified | Add sequence-order test |
| VER-005 | REQ-005: Deceleration After Trigger Release | No monotonic-interval measurement | Add timestamp-based deceleration test |

All other requirements are covered by at least one passing automated test, Vivado waveform evidence, or a documented review-based check.

## 7. Overall Verification Status

>
> **8 of 8 automated cocotb tests passed (FAIL=0, SKIP=0).**
> All functional requirements that are exercised by the current test suite are verified as correct.
>
> Three requirements — REQ-002 (Dice Value Range), REQ-003 (Cyclic Dice Counting), and REQ-005 (Deceleration After Trigger Release) — are not fully covered by automated simulation in this run. They are partially supported by design review, Vivado waveform evidence, and the passing results of related tests (VER-004, VER-006), but dedicated automated tests are still outstanding.
