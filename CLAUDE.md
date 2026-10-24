## Rule 1: No Silent Assumptions

### Verified
- Device: Samsung K9F1208 behavioral model, legacy (NOT ONFI)
- Model power-up: 10 us before it accepts any command
- Host handshake: activate (1 cycle) -> busy rises 1 clk later -> busy falls at M_IDLE
- Memory reset: M_NAND_RESET -> 0xFF latched -> RSTDONE after RstReadT (5 us) -> rnb high
- ID bytes in model: 4 (EC 76 A5 C0). Controller reads 5 — do not assert on byte 4.

### UNVERIFIED — check datasheet before use
- Page geometry (model PageSize = 527; earlier "2K / 8628-byte buffer" note is wrong)
- Read-ID opcode (legacy Samsung is believed 0x90 + addr 0x00; the earlier
  0x03/0x06/0x07/0x05 list matches nothing found in RTL or model)
- Read-confirm 0x30 — controller sends it, no decode found in the model
- Model bus timing: all tpd/tsetup/thold values are 1 ns placeholders

### Success criteria (per test)
1. busy pulses (rises then falls within the command's bounded timeout)
2. rnb returns high for any command that touches the memory
3. status clean
4. data matches expected
