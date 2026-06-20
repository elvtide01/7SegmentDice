import os
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

# ------------------------------------------------------------
# Simulation Mode Detection
# ------------------------------------------------------------
print("ENV:")
for k, v in sorted(os.environ.items()):
    print(k, "=", v)
        
GATE_LEVEL = os.getenv("GATES", "").lower() == "yes"

if GATE_LEVEL:
    print("Running GATE LEVEL simulation")
else:
    print("Running RTL simulation")

# ------------------------------------------------------------
# Timing Parameters
# ------------------------------------------------------------

if GATE_LEVEL:
    DISPLAY_WAIT = 300000
    STATE_WAIT   = 1200000
    STOP_WAIT    = 7500000
    FINISH_WAIT  = 48000000
else:
    DISPLAY_WAIT = 200
    STATE_WAIT   = 300
    STOP_WAIT    = 5000
    FINISH_WAIT  = 300
    
print(DISPLAY_WAIT)
print(STATE_WAIT)
print(STOP_WAIT)
print(FINISH_WAIT)
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


