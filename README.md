# Mitsubishi GXWorks3 to Beckhoff TwinCAT 3 Conversion

Complete conversion of **Mamée Line 1** PLC program from:
- **Source:** Mitsubishi FX5U (GXWorks3) - Ladder Logic
- **Target:** Beckhoff CX6015 (TwinCAT 3) - Structured Text

## Files Included

1. **MaméeLine1_TwinCAT3.st** - Complete ST program (2000+ lines)
2. **CONVERSION_GUIDE.md** - Technical conversion reference
3. **INPUT_OUTPUT_MAP.md** - Complete I/O documentation
4. **README.md** - This file

## Quick Start

1. Import `MaméeLine1_TwinCAT3.st` into your TwinCAT 3 project
2. Configure I/O mapping in TwinCAT (X0-X57 → inputs, Y6-Y27 → outputs)
3. Review CONVERSION_GUIDE.md for any system-specific adjustments
4. Test on simulator before deployment to CX6015

## Conversion Highlights

✅ **All 15 Program Sections Converted:**
- Input/Output Mapping
- Alarm & Reset Logic
- Auto Start/Stop with Timer
- Recipe Selection (4 recipes)
- Line Counting (6 lines)
- Conveyor Traffic Control
- Communication with Label PLCs
- Emergency Stop Logic

✅ **Key Instructions Mapped:**
- Timers (TON)
- Stack Operations (MPS/MRD/MPP → IF branches)
- Comparisons (AND>= → >= operator)
- Data transfers (OUTHS → INT conversions)

## Important Notes

- Review rising edge detection implementation (Section A in guide)
- Verify SM400 and SM412 system flags in your TwinCAT version
- All timers use 10ms base resolution
- Test communication bits before deployment

For detailed technical info, see [CONVERSION_GUIDE.md](CONVERSION_GUIDE.md)
