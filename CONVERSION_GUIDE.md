# Mitsubishi GXWorks3 to Beckhoff TwinCAT 3 Conversion Guide

## Project Information
- **Source:** Mitsubishi FX5U (GXWorks3)
- **Target:** Beckhoff CX6015 (TwinCAT 3)
- **Program:** Mamée Line 1
- **Date:** 2026-06-24

---

## Conversion Mapping Reference

### 1. Input/Output Mapping

| Mitsubishi | TwinCAT 3 | Description |
|---|---|---|
| X0-X57 | X0-X57 (BOOL) | Physical inputs |
| Y6-Y27 | Y6-Y27 (BOOL) | Physical outputs |
| M0-M37 | M0-M37 (BOOL) | Internal memory (input mapping) |
| M99-M134 | M99-M134 (BOOL) | Alarm flags |
| M200-M310 | M200-M310 (BOOL) | Machine control bits |
| M600-M687 | M600-M687 (BOOL) | Recipe & sequence control |
| M2000-M2270 | M2000-M2270 (BOOL) | Communication bits |

### 2. Timer Conversion

**Mitsubishi Ladder Logic:**
```
LD M200
OUT T20 K5000
```

**TwinCAT 3 ST:**
```st
T20(
    IN := M200,
    PT := T#5S
);
```

**Timer Properties:**
- Type: `TON` (On-Delay Timer)
- Access timer output: `T20.Q` (output bit)
- Access elapsed time: `T20.ET` (elapsed time)
- Access running state: `T20.IN` (is timer running)

### 3. Data Register Conversion

| Mitsubishi | TwinCAT 3 | Usage |
|---|---|---|
| D0-D4 | INT D0-D4 | Display/working registers |
| D610-D615 | INT D610-D615 | Counting registers (6 lines) |
| D620-D625 | INT D620-D625 | Recipe values |
| D630-D641 | INT D630-D641 | Timer/sequence data |
| D700-D862 | INT D700-D862 | Configuration data |
| D2200-D2210 | INT D2200-D2210 | External PLC data |

### 4. Instruction Conversion

| Mitsubishi | TwinCAT 3 | Notes |
|---|---|---|
| `LD` | Conditional check | `IF ... THEN` |
| `LDI` | Inverted check | `IF NOT ... THEN` |
| `OR` | OR operator | `OR` |
| `AND` | AND operator | `AND` |
| `OUT` | Assignment | `:= TRUE` |
| `SET` | Latch ON | `:= TRUE` |
| `RST` | Latch OFF | `:= FALSE` |
| `ZRST` | Clear range | Bulk `:= 0` or `:= FALSE` |
| `MOV` | Move/Copy | Direct assignment `:=` |
| `INC` | Increment | `D610 := D610 + 1` |
| `AND>=` | Greater/equal | `>=` operator |
| `MPS/MRD/MPP` | Stack logic | IF branches |
| `OUTHS` | Output with register | `D0 := INT(...)` |
| `LDP` | Rising edge | Edge detection logic |

---

## Key Implementation Details

### A. Rising Edge Detection

**Problem:** Mitsubishi `LDP` instruction detects rising edges.

**Solution in TwinCAT 3:**
```st
(* Requires buffering previous state *)
VAR
    prev_state: BOOL := FALSE;
END_VAR

(* In program *)
IF NOT prev_state AND current_state THEN
    (* Rising edge detected *)
END_IF;
prev_state := current_state;
```

### B. Timer Value Transfer (OUTHS)

**Mitsubishi:**
```
OUTHS T20 K5000
```

**TwinCAT 3:**
```st
IF T20.IN THEN
    D0 := INT(T20.ET * 1000);  (* Convert to milliseconds *)
ELSE
    D0 := 0;
END_IF;
```

### C. Stack Operations (MPS/MRD/MPP)

**Mitsubishi Ladder:**
```
LD M0
MPS
AND M1
OUT M100
MRD
AND M2
OUT M101
MPP
```

**TwinCAT 3 ST:**
```st
IF M0 THEN
    (* Branch 1 *)
    IF M1 THEN
        M100 := TRUE;
    END_IF;
    
    (* Branch 2 *)
    IF M2 THEN
        M101 := TRUE;
    END_IF;
END_IF;
```

### D. Comparison Instructions

**Mitsubishi:**
```
LD M600
AND>= D610 D620
OUT M610
```

**TwinCAT 3:**
```st
M610 := (M600 AND D610 >= D620);
```

---

## Special Flags & Variables

### System Flags (TwinCAT 3)

| Flag | Type | Description | Usage |
|---|---|---|---|
| SM400 | BOOL | First scan pulse | Initialize on startup |
| SM412 | BOOL | Always TRUE | Used in output logic |

**Note:** These must be implemented in TwinCAT as system variables or simulated. Check your TwinCAT version for availability.

### Time Constants

```st
T#5S     (* 5 seconds *)
T#100MS  (* 100 milliseconds *)
T#1S     (* 1 second *)
T#500MS  (* 500 milliseconds *)
```

---

## Testing Checklist

- [ ] All X inputs properly mapped to M bits
- [ ] All Y outputs properly driven
- [ ] Timer T20 countdown working (5 second delay)
- [ ] Machine start/stop logic functional
- [ ] Recipe selection (M650-M653) switching correctly
- [ ] Line counting incrementing properly
- [ ] Alarm aggregation in M99 and M100
- [ ] Communication outputs (Y22-Y27) responding
- [ ] External PLC data exchange (D2200-D2210) updating
- [ ] Conveyor traffic control (T70-T72) timing correctly
- [ ] Stopper logic (M800) engaging/disengaging

---

## Common Issues & Troubleshooting

### Issue 1: Rising Edge Detection Not Working
**Cause:** Missing state buffer or incorrect logic
**Fix:** Implement state buffering as shown in Section A above

### Issue 2: Timer Not Resetting
**Cause:** IN parameter still TRUE
**Fix:** Ensure `T20.IN` is FALSE to reset. Use separate branches for start/stop.

### Issue 3: Counting Increments Multiple Times
**Cause:** Counter logic runs every cycle instead of on edge
**Fix:** Implement pulse detection on timer output (T50.Q rising edge)

### Issue 4: M200 Not Latching
**Cause:** Start condition continuously setting/resetting
**Fix:** Separate start and stop conditions into different IF blocks

---

## Performance Considerations

1. **Scan Time:** This program has ~2000 instructions. Expect 10-50ms scan time on CX6015.
2. **Memory:** Total VAR space ~15KB. CX6015 has sufficient memory.
3. **Timer Resolution:** All timers use 10ms resolution (default for TON).
4. **Communication:** Ensure adequate bandwidth for label PLC data exchange.

---

## Integration Steps

1. **Import into TwinCAT 3:**
   - Create new PLC project
   - Add ST file to project
   - Define I/O mapping in TwinCAT (X0-X57 → inputs, Y6-Y27 → outputs)

2. **Configure Timers:**
   - Verify timer library included
   - Set base time unit (recommend 10ms)

3. **Test on Simulator:**
   - Run on TwinCAT simulation
   - Manually trigger inputs
   - Monitor M bits and outputs

4. **Deploy to CX6015:**
   - Download project to target
   - Enable RUN mode
   - Monitor via TwinCAT Real-time Interface

---

## Revision History

| Date | Version | Changes |
|---|---|---|
| 2026-06-24 | 1.0 | Initial conversion from GXWorks3 |

---

## Contact & Support

For issues with this conversion:
1. Review the section in this guide corresponding to your problem
2. Check the code comments in MaméeLine1_TwinCAT3.st
3. Verify input/output mapping in TwinCAT configuration
4. Enable RUN mode with breakpoints to debug
