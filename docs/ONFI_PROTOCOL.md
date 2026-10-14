# ONFI Protocol Reference

## Commands Used

| Command | Code | Purpose |
|---------|------|---------|
| Read ID | 0x03 | Read JEDEC ID (5 bytes) |
| Read Page | 0x06 | Read 2K page |
| Write Page | 0x07 | Write page |
| Status | 0x05 | Read status |

## Signals

- **Cmd_in[8]**: Command input
- **Data_in[8]**: Data input
- **Data_out[8]**: Data output
- **Busy**: Controller busy (1=busy, 0=idle)
- **Activate**: Execute command

## Success Criteria

1. Busy transitions 0→1→0
2. Status[4] = 0 (no errors)
3. Data integrity preserved
