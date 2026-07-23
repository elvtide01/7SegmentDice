# Validation Plan

## 1. Purpose

This validation plan checks whether the requirements in the system specification correctly describe the intended electronic dice project, and cross-references each item with the actual cocotb testbench in `test (1).py`.
Each validation item is linked to one requirement and, where an automated check exists, to the corresponding `@cocotb.test()` function.

## 2. Validation Items

### VAL-001: Reset Behavior

Requirement: [REQ-001](specification.md#req-001-reset-behavior)

The requirement is valid because a well-defined power-up/reset state is necessary before the dice controller can be trusted to start a new round; the user should see a defined, idle "finish" state rather than an arbitrary segment pattern.

Validation method: automated simulation (`val001_reset` in `test.py`).
Acceptance criterion: after `reset_dut()` completes, `LED2 == 0` (finish indicator active, active-low).

### VAL-002: Dice Value Range

Requirement: [REQ-002](specification.md#req-002-dice-value-range)

The requirement is valid because a physical dice has exactly six possible result values and no zero value.
The accepted output range is therefore limited to the numbers 1, 2, 3, 4, 5 and 6.

Validation method: the testbench checks pattern diversity via `read_segments()`.
Acceptance criterion: no requirement or implementation path intentionally displays a normal dice result outside 1 to 6.

### VAL-003: Cyclic Dice Counting

Requirement: [REQ-003](specification.md#req-003-cyclic-dice-counting)

The requirement is valid because a compact electronic dice can reuse a cyclic counter instead of storing six independent states.
The wrap from 6 to 1 is necessary to keep all values reachable.

Validation method: requirement review and counter-behavior inspection. Partially covered by `val003_multiple_states` in `test.py`, which confirms that at least 4 distinct segment patterns occur while `TRIGGER` is held, but does not confirm the exact order 1, 2, 3, 4, 5, 6, 1, ….
Acceptance criterion: the counting sequence is 1, 2, 3, 4, 5, 6, 1, ... .

### VAL-004: Fast Counting While Trigger Is Pressed

Requirement: [REQ-004](specification.md#req-004-fast-counting-while-trigger-is-pressed)

The requirement is valid because the user expects a visibly active dice while the button is held.
A base frequency of 40 Hz is fast enough to appear dynamic while still being simple to derive from a 12 MHz clock.

Validation method: automated simulation (`val002_display_changes` and `val003_multiple_states` in `test.py`), plus timing review for the exact 40 Hz / `BASE_PERIOD = 300,000` cycle figure.
Acceptance criterion: the segment pattern changes within `DISPLAY_WAIT` cycles of `TRIGGER` going high, and at least 4 distinct patterns occur within `STATE_WAIT` cycles. The precise `BASE_PERIOD = 300,000` cycles (12 MHz) figure is validated by timing review, not by direct frequency measurement in the testbench.

### VAL-005: Deceleration After Trigger Release

Requirement: [REQ-005](specification.md#req-005-deceleration-after-trigger-release)

The requirement is valid because the project description expects the counting speed to decrease after the push button is released.
The selected one-second step interval creates a clear and observable slowdown.

Validation method: behavior review and timing planning.
Acceptance criterion: the counting period increases monotonically after release until the finish state is reached.

### VAL-006: Stop After Approximately Seven Seconds

Requirement: [REQ-006](specification.md#req-006-stop-after-approximately-seven-seconds)

The requirement is valid because the project description expects counting to stop after about seven seconds.
The word "approximately" is acceptable because the final visible tick depends on the phase of the event generator at the moment of release.

Validation method: automated simulation (`val006_stop_after_release` in `test.py`), plus timing review for the exact ~7 s figure.
Acceptance criterion: the segment pattern becomes and stays stable for more than 50 consecutive clock cycles within `STOP_WAIT` cycles after release. The exact "~7 seconds" duration is validated separately by timing review (`gate-level STOP_WAIT = 7,500,000` cycles), with a tolerance of one clock cycle for the second counter.

### VAL-007: Final Value Remains Constant

Requirement: [REQ-007](specification.md#req-007-final-value-remains-constant)

The requirement is valid because the user needs the displayed result to be trustworthy and unambiguous once the round has ended.

Validation method: automated simulation (`val007_final_value_constant` in `test.py`).
Acceptance criterion: after `TRIGGER` release, once `LED2 == 0` (finish active) is observed (within `FINISH_WAIT` cycles), the segment pattern must not change for the following 100 clock cycles.

### VAL-008: Counting Pulse LED

Requirement: [REQ-008](specification.md#req-008-counting-pulse-led)

The requirement is valid because the project description asks for an LED that shows counting activity, and the LED also improves observability during FPGA or hardware demonstration.

Validation method: automated simulation (`val004_count_led` in `test.py`).
Acceptance criterion: `LED1` is observed to become active (`LED1 == 1`) at least once within 500 clock cycles of `TRIGGER` being asserted.

### VAL-009: Finish LED

Requirement: [REQ-009](specification.md#req-009-finish-led)

The requirement is valid because the user needs a clear status signal that shows when the dice result is final.
This is especially important because the final value remains visible after counting stops.

Validation method: automated simulation (`val005_finish_led_off` in `test.py`, together with `val001_reset` and `val007_final_value_constant`).
Acceptance criterion: `LED2 == 1` (inactive, active-low) is observed continuously for 100 clock cycles while `TRIGGER` is held (rolling phase); `LED2` becomes `0` only in the finish state (checked by VAL-001 and VAL-007).

### VAL-010: 7-Segment Output Encoding

Requirement: [REQ-010](specification.md#req-010-7-segment-output-encoding)

The requirement is valid because the dice value is only useful to the user when it is shown on the 7-segment display.
The decoder must therefore map internal values to visible segment patterns.

Validation method: automated simulation (`val008_multiple_dice_values` in `test (1).py`), plus decoder-table review for correctness of individual patterns.
Acceptance criterion: at least 4 distinct segment patterns are observed via `read_segments()` within `STATE_WAIT` cycles while `TRIGGER` is held.

### VAL-011: Hierarchical Design

Requirement: [REQ-011](specification.md#req-011-hierarchical-design)

The requirement is valid because the laboratory description requires several interconnected submodules.
The project naturally separates into event generation, dice control and display decoding.

Validation method: architecture review (not covered by `test.py`, which only drives/observes the top-level DUT ports).
Acceptance criterion: the top-level module instantiates at least two lower-level modules.

### VAL-012: Simplicity

Requirement: [REQ-012](specification.md#req-012-simplicity)

The requirement is valid because the laboratory project should remain small and manufacturable within a limited student-project scope.
The electronic dice function can be implemented with counters, a small controller and a decoder.

Validation method: design review.
Acceptance criterion: no unnecessary protocol interface, memory block, arithmetic unit or complex random generator is required.

### VAL-013: Testability

Requirement: [REQ-013](specification.md#req-013-testability)

The requirement is valid because the laboratory description emphasizes verification before fabrication or hardware testing.
A top-level testbench is sufficient for a first end-to-end behavior check.

Validation method: repository review.
Acceptance criterion: at least one testbench exists and covers both RTL and gate-level simulation. Satisfied by `test.py`, which provides 8 `@cocotb.test()` functions (`val001_reset` … `val008_multiple_dice_values`) and switches its timing constants based on the `GATES` environment variable to support both simulation modes.


## 3. Validation Summary

All validation items are aligned with the intended electronic dice behavior and, where applicable, with the actual `test.py` cocotb testbench.
The requirements are specific, measurable, atomic, relevant and achievable within the project scope. Several requirements are currently validated by review and by automated simulation.
