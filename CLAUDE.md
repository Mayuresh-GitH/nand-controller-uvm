# NAND Controller UVM Testbench — Karpathy Discipline

## Rule 1: No Silent Assumptions
✓ Protocol: ONFI async, x8/x16 auto-detect  
✓ Page: 2K (8628-byte buffer)  
✓ Commands: 0x03 (ID), 0x06 (read), 0x07 (write), 0x05 (status)  
✓ Success: Busy pulse + Status clean + Data match  

## Rule 2: Minimal Code
- Phase 1: JEDEC ID read only
- Phase 2: Add page write
- Phase 3: Add error injection

## Rule 3: Surgical Changes
- Every commit = one feature
- Each line traces to requirement

## Rule 4: Explicit Verification
Test passes when:
  1. Busy pulses (1→0)
  2. Status clean (bit 4 = 0)
  3. Data matches read-back
