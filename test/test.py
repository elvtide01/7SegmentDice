import os
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

# ------------------------------------------------------------
# Simulation Mode Detection
# ------------------------------------------------------------

GATE_LEVEL = os.getenv("GATES", "").lower() == "yes"

if GATE_LEVEL:
    print("Running GATE LEVEL simulation")
else:
    print("Running RTL simulation")

# ------------------------------------------------------------
# Timing Parameters
# ------------------------------------------------------------

if GATE_LEVEL:
    DISPLAY_WAIT = 5000
    STATE_WAIT   = 10000
    STOP_WAIT    = 50000
    FINISH_WAIT  = 50000
else:
    DISPLAY_WAIT = 200
    STATE_WAIT   = 300
    STOP_WAIT    = 5000
    FINISH_WAIT  = 300

# ============================================================
# Hilfsfunktionen
# ============================================================

async def reset_dut(dut):

    dut.rst_n.value = 1
    dut.TRIGGER.value = 0

    for _ in range(5):
        await RisingEdge(dut.clk)
        
    dut.rst_n.value = 0
    
    await RisingEdge(dut.clk)

def read_segments(dut):
    return (
        (int(dut.SEGA.value) << 6)
        | (int(dut.SEGB.value) << 5)
        | (int(dut.SEGC.value) << 4)
        | (int(dut.SEGD.value) << 3)
        | (int(dut.SEGE.value) << 2)
        | (int(dut.SEGF.value) << 1)
        | int(dut.SEGG.value)
    )

# VAL-001
# Reset Behaviour
@cocotb.test()
async def val001_reset(dut):

    cocotb.start_soon(
        Clock(dut.clk, 10, unit="ns").start()
    )

    await reset_dut(dut)

    # finish_flag=1 -> LED2=0
    assert int(dut.LED2.value) == 0, \
        "LED2 sollte nach Reset aktiv sein"

# VAL-002
# Dice Display Changes While Trigger Pressed

@cocotb.test()
async def val002_display_changes(dut):

    cocotb.start_soon(
        Clock(dut.clk, 10, unit="ns").start()
    )

    await reset_dut(dut)

    dut.TRIGGER.value = 1

    await RisingEdge(dut.clk)

    start_pattern = read_segments(dut)

    changed = False

    for _ in range(DISPLAY_WAIT):

        await RisingEdge(dut.clk)

        if read_segments(dut) != start_pattern:
            changed = True
            break

    assert changed, \
        "Anzeige verändert sich nicht"


# VAL-003
# Multiple Dice States Reachable

@cocotb.test()
async def val003_multiple_states(dut):

    cocotb.start_soon(
        Clock(dut.clk, 10, unit="ns").start()
    )

    await reset_dut(dut)

    dut.TRIGGER.value = 1

    patterns = set()

    for _ in range(STATE_WAIT):

        await RisingEdge(dut.clk)

        patterns.add(read_segments(dut))

    assert len(patterns) >= 4, \
        f"Zu wenige Zustände gefunden ({len(patterns)})"

# VAL-004
# Count LED Activity

@cocotb.test()
async def val004_count_led(dut):

    cocotb.start_soon(
        Clock(dut.clk, 10, unit="ns").start()
    )

    await reset_dut(dut)

    dut.TRIGGER.value = 1

    seen_high = False

    for _ in range(500):

        await RisingEdge(dut.clk)

        if int(dut.LED1.value):
            seen_high = True
            break

    assert seen_high, \
        "LED1 wurde nie aktiv"

# VAL-005
# Finish LED Off During Rolling

@cocotb.test()
async def val005_finish_led_off(dut):

    cocotb.start_soon(
        Clock(dut.clk, 10, unit="ns").start()
    )

    await reset_dut(dut)

    dut.TRIGGER.value = 1

    await RisingEdge(dut.clk)

    for _ in range(100):

        await RisingEdge(dut.clk)

        # active-low
        assert int(dut.LED2.value) == 1, \
            "LED2 sollte während Würfeln AUS sein"

# VAL-006
# Dice Eventually Stops After Release

@cocotb.test()
async def val006_stop_after_release(dut):

    cocotb.start_soon(
        Clock(dut.clk, 10, unit="ns").start()
    )

    await reset_dut(dut)

    dut.TRIGGER.value = 1

    for _ in range(50):
        await RisingEdge(dut.clk)

    dut.TRIGGER.value = 0

    stable_count = 0
    last_pattern = read_segments(dut)

    for _ in range(STOP_WAIT):

        await RisingEdge(dut.clk)

        current = read_segments(dut)

        if current == last_pattern:
            stable_count += 1
        else:
            stable_count = 0

        last_pattern = current

        if stable_count > 50:
            return

    assert False, \
        "Anzeige wird nicht stabil"

# VAL-007
# Finish LED Eventually Activates

@cocotb.test()
async def val007_finish_led(dut):

    cocotb.start_soon(
        Clock(dut.clk, 10, unit="ns").start()
    )

    await reset_dut(dut)

    dut.TRIGGER.value = 1

    for _ in range(50):
        await RisingEdge(dut.clk)

    dut.TRIGGER.value = 0

    for _ in range(FINISH_WAIT):

        await RisingEdge(dut.clk)

        if int(dut.LED2.value) == 0:
            return

    assert False, \
        "LED2 wurde nie aktiviert"


# VAL-008
# Final Value Remains Constant

@cocotb.test()
async def val008_final_value_constant(dut):

    cocotb.start_soon(
        Clock(dut.clk, 10, unit="ns").start()
    )

    await reset_dut(dut)

    dut.TRIGGER.value = 1

    for _ in range(50):
        await RisingEdge(dut.clk)

    dut.TRIGGER.value = 0

    for _ in range(FINISH_WAIT):

        await RisingEdge(dut.clk)

        if int(dut.LED2.value) == 0:
            break

    value = read_segments(dut)

    for _ in range(100):
        
        await RisingEdge(dut.clk)

        assert read_segments(dut) == value, \
            "Endwert verändert sich nach Stop"

# VAL-009
     
@cocotb.test()
async def val009_multiple_dice_values(dut):

    cocotb.start_soon(
        Clock(dut.clk, 10, unit="ns").start()
    )

    await reset_dut(dut)

    dut.TRIGGER.value = 1

    seen = set()

    for _ in range(STATE_WAIT):

        await RisingEdge(dut.clk)

        seen.add(read_segments(dut))

    assert len(seen) >= 4, \
        f"Zu wenige Würfelwerte sichtbar: {len(seen)}"
