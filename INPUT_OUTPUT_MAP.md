# Mamée Line 1: Input/Output Mapping Reference

## Digital Inputs (X Contacts - Read from Physical Inputs)

### Input Group 1 (X0-X7)
| Input | Name/Function | Description | Status |
|---|---|---|---|
| X0 | Manual/Auto SS | Manual/Auto selector switch | Mapped to M0 |
| X1 | AUTO START | Auto start button | Mapped to M1 |
| X2 | Manual/Auto SS | Manual/Auto condition check | Mapped to M2 |
| X3 | Input Signal 3 | General input | Mapped to M3 |
| X4 | Alarm Input | Sensor alarm (low = triggered) | Mapped to M4 |
| X5 | Input Signal 5 | General input | Mapped to M5 |
| X6 | Input Signal 6 | General input | Mapped to M6 |
| X7 | Sensor 7 | Equipment sensor | Mapped to M7 |

### Input Group 4 (X30-X37)
| Input | Name/Function | Description | Status |
|---|---|---|---|
| X30 | - | Reserved | Mapped to M30 |
| X31 | Sensor 31 | Equipment sensor (low = alarm) | Mapped to M31 |
| X32 | Motor RUN Enable | Motor running check | Mapped to M32 |
| X33 | Sensor 33 | Equipment sensor (low = alarm) | Mapped to M33 |
| X34 | Counter Reset | Pulse input to reset counters | Mapped to M34 |
| X35 | Sensor 35 | Equipment sensor (low = alarm) | Mapped to M35 |
| X36 | Hold Enable | Enable hold bit | Mapped to M36 |
| X37 | Sensor 37 | Equipment sensor (low = alarm) | Mapped to M37 |

### Input Group 5 (X40-X47) - Alarm Inputs
| Input | Name/Function | Description |
|---|---|---|
| X40 | Motor Overload | Motor overload alarm |
| X41 | Temperature High | Temperature sensor alarm |
| X42 | Pressure High | Pressure sensor alarm |
| X43 | Flow Error | Flow rate alarm |
| X44 | Conveyor Jam | Conveyor jam detection |
| X45 | Emergency Button | Emergency stop pressed |
| X46 | Traffic Signal 1 | Conveyor traffic control |
| X47 | Traffic Signal 2 | Conveyor traffic control |

### Input Group 6 (X50-X57) - Equipment Status
| Input | Name/Function | Description | Alarm |
|---|---|---|---|
| X50 | Stopper Ready | Stopper in ready position | X50 low = M129 alarm |
| X51 | Door Closed | Door sensor (low = M129 alarm) | X51 low = M129 alarm |
| X52 | Cover Locked | Safety cover locked (low = M130 alarm) | X52 low = M130 alarm |
| X53 | Cylinder Ready | Pneumatic cylinder ready (low = M131 alarm) | X53 low = M131 alarm |
| X54 | Supply Pressure | Pneumatic supply pressure OK | General use |
| X55 | Supply Voltage | Electrical supply voltage OK | General use |
| X56 | Gearbox Oil | Gearbox oil level sensor (low = M132 alarm) | X56 low = M132 alarm |
| X57 | Cooling Fan | Cooling fan running | General use |

---

## Digital Outputs (Y Coils - Write to Physical Outputs)

### Output Group 1 (Y6-Y7)
| Output | Name/Function | Control | Activated By |
|---|---|---|---|
| Y6 | Label Feeder 1 | Start/stop label feeder 1 | M200 & M36 or M299 |
| Y7 | Label Feeder 2 | Start/stop label feeder 2 | M200 & M30 or M300 |

### Output Group 2 (Y10-Y15)
| Output | Name/Function | Control | Activated By |
|---|---|---|---|
| Y10 | Conveyor Motor | Main conveyor motor start | M305 or (M200 & NOT T72.Q) |
| Y11 | Conveyor Direction | Conveyor direction control | M306 or (M200 & NOT M800) |
| Y12 | Stopper Pneumatic | Stopper pneumatic valve | M307 or (M200 & NOT T71.Q) |
| Y13 | Air Pump | Air pump for pneumatics | M308 or M200 |
| Y14 | Diverter 1 | Diverter valve 1 | M309 or (M200 & NOT T70.Q & M54) |
| Y15 | Diverter 2 | Diverter valve 2 | M310 or (M200 & M54) |

### Output Group 3 (Y16-Y17)
| Output | Name/Function | Control | Activated By |
|---|---|---|---|
| Y16 | Motor Encoder Enable | Enable motor encoder signal | M200 & M32 or M301 |
| Y17 | Line Counter Enable | Enable line counter | M200 & M34 or M302 |

### Output Group 4 (Y20-Y21)
| Output | Name/Function | Control | Activated By |
|---|---|---|---|
| Y20 | Conveyor Phase 1 | Conveyor sequence phase 1 | M200 & (M680 OR M682 OR M684 OR M686) |
| Y21 | Conveyor Phase 2 | Conveyor sequence phase 2 | M200 & (M681 OR M683 OR M685 OR M687) |

### Output Group 5 (Y22-Y27)
| Output | Name/Function | Control | Activated By | Priority |
|---|---|---|---|---|
| Y22 | **EMERGENCY STOP** | **Alarm aggregation** | **ANY alarm condition** | **HIGHEST** |
| Y23 | Machine RUN Indicator | Visual indicator: machine running | M200 OR (M201 & SM412) | HIGH |
| Y24 | Mode Indicator | Visual indicator: manual mode | NOT M0 | HIGH |
| Y25 | Alarm Indicator Red | Red alarm light | M100 OR M99 OR Y22 | HIGH |
| Y26 | Warning Indicator Yellow | Yellow warning light | M100 OR M201 OR Y22 | MEDIUM |
| Y27 | Stopper Status | Stopper active indicator | M800 | LOW |

---

## Internal Memory Bits (M) - Control Logic

### Machine Control Bits
| Bit | Name | Function | Set By | Reset By |
|---|---|---|---|---|
| M200 | Machine RUN | Main machine running signal | Start logic & T20.Q | Manual stop |
| M201 | Machine HOLD | Hold running after timeout | T20.Q | M299 or reset |
| M299 | Reset Trigger | Trigger reset sequence | Alarm condition | Auto-clear |
| M310 | Reset Output | Reset output bit | M299 trigger | Auto-clear |

### Recipe Selection Bits (M600-M605)
| Bit | Recipe | Configuration |
|---|---|---|
| M600 | Recipe 1 | Line configuration M20 |
| M601 | Recipe 2 | Line configuration M21 |
| M602 | Recipe 3 | Line configuration M22 |
| M603 | Recipe 4 | Line configuration M23 |
| M604 | Recipe 5 | Line configuration M24 |
| M605 | Recipe 6 | Line configuration M25 |

### Recipe Definition Bits (M650-M653)
| Bit | Recipe | Configuration |
|---|---|---|
| M650 | Recipe 1 (4x3) | 4 canisters, 3 per line |
| M651 | Recipe 2 (4x2) | 4 canisters, 2 per line |
| M652 | Recipe 3 (5x2) | 5 canisters, 2 per line |
| M653 | Recipe 4 (5x4x5) | 5-4-5 mixed pattern |

### Counting Ready Bits (M610-M615)
| Bit | Function | Trigger | Clear By |
|---|---|---|---|
| M610 | Line 1 Ready | D610 >= D620 | Counter reset |
| M611 | Line 2 Ready | D611 >= D621 | Counter reset |
| M612 | Line 3 Ready | D612 >= D622 | Counter reset |
| M613 | Line 4 Ready | D613 >= D623 | Counter reset |
| M614 | Line 5 Ready | D614 >= D624 | Counter reset |
| M615 | Line 6 Ready | D615 >= D625 | Counter reset |

### Conveyor Sequence Bits (M680-M687)
| Bit | Path | Trigger Condition |
|---|---|---|
| M680 | Recipe1-Path1 | M650 & M610 & M611 & M612 |
| M681 | Recipe1-Path2 | M650 & M613 & M614 & M615 |
| M682 | Recipe2-Path1 | M651 & M610 & M611 |
| M683 | Recipe2-Path2 | M651 & M613 & M614 |
| M684 | Recipe3-Path1 | M652 & M610 & M611 |
| M685 | Recipe3-Path2 | M652 & M613 & M614 |
| M686 | Recipe4-Path1 | M653 & M610 & M611 & M612 |
| M687 | Recipe4-Path2 | M653 & M613 & M614 & M615 |

### Alarm Bits (M99-M132)
| Bit | Alarm Type | Trigger | Status |
|---|---|---|---|
| M99 | Collective Alarm 1 | OR of M106-M121 | Sent to Y22 |
| M100 | Emergency Stop | Any alarm condition | Latched |
| M101-M108 | Sensor Alarms | Low signal on specific sensors | On sensor edge |
| M109-M115 | Input Alarms | High signal on alarm inputs | Immediate |
| M116-M128 | System Alarms | Various system conditions | Conditional |
| M129-M132 | Equipment Alarms | Equipment status sensors | On sensor edge |

### Communication Bits (M2000-M2270)
| Bit | Function | Direction | Purpose |
|---|---|---|---|
| M2000-M2001 | Label 1 Status | OUT | Label printer 1 status |
| M2020 | Label 1 Emergency | OUT | Emergency stop to Label 1 |
| M2051-M2052 | Label 1 Feedback | IN | Feedback from Label 1 |
| M2070 | Label 1 Watchdog | IN | Watchdog signal from Label 1 |
| M2200-M2215 | Label 2 Status | OUT | Label printer 2 status |
| M2220 | Label 2 Emergency | OUT | Emergency stop to Label 2 |
| M2251-M2263 | Label 2 Feedback | IN | Feedback from Label 2 |
| M2270 | Label 2 Watchdog | IN | Watchdog signal from Label 2 |

---

## Data Registers (D) - Numerical Values

### Display & Timer Registers
| Register | Usage | Range | Unit |
|---|---|---|---|  
| D0 | T20 Elapsed Time Display | 0-5000 | ms |
| D1-D4 | Working registers | 0-65535 | - |

### Counting Registers
| Register | Function | Incremented By | Reset Condition |
|---|---|---|---|  
| D610 | Line 1 Count | Edge on T50 | X34 pulse or M200 OFF |
| D611 | Line 2 Count | Edge on T52 | X34 pulse or M200 OFF |
| D612 | Line 3 Count | Edge on T54 | X34 pulse or M200 OFF |
| D613 | Line 4 Count | Edge on T56 | X34 pulse or M200 OFF |
| D614 | Line 5 Count | Edge on T58 | X34 pulse or M200 OFF |
| D615 | Line 6 Count | Edge on T60 | X34 pulse or M200 OFF |

### Recipe Configuration Registers
| Register | Recipe | Default | Configurable |
|---|---|---|---|  
| D620 | Recipe 1 Line 1 Target | 4 | Yes, via M650 |
| D621 | Recipe 1 Line 2 Target | 4 | Yes |
| D622 | Recipe 1 Line 3 Target | 4 | Yes |
| D623 | Recipe 1 Line 4 Target | 4 | Yes |
| D624 | Recipe 1 Line 5 Target | 4 | Yes |
| D625 | Recipe 1 Line 6 Target | 4 | Yes |

### Timing Registers
| Register | Function | Usage |
|---|---|---|  
| D630 | Timer Display 1 | Shows elapsed time |
| D631 | Timer Display 2 | Shows elapsed time |
| D640 | Sequence Timing | Delay for M680-M687 |
| D641 | Reset Timing | Delay for M10-M13 resets |
| D700 | Stopper ON Time | T30 preset value |
| D701 | Stopper OFF Time | T31 preset value |

### Traffic Control Registers
| Register | Function | Related Timer |
|---|---|---|  
| D800 | Label 1 Timeout | T80-T81 |
| D801 | Label 1 Response | T80-T81 |
| D820 | Label 2 Timeout | T100-T101 |
| D821 | Label 2 Response | T100-T101 |
| D822 | Label 2 Handshake | T102 |
| D823 | Label 2 Timing | T103 |
| D860 | Traffic Control 1 | T70 |
| D861 | Traffic Control 2 | T71 |
| D862 | Traffic Control 3 | T72 |

### External PLC Data Registers
| Register | Function | Source | Destination |
|---|---|---|---|  
| D2200 | Recipe Line 1 Target | D620 | INOVANCE PLC 3 |
| D2202 | Recipe Line 2 Target | D621 | INOVANCE PLC 3 |
| D2204 | Recipe Line 3 Target | D622 | INOVANCE PLC 3 |
| D2206 | Recipe Line 4 Target | D623 | INOVANCE PLC 3 |
| D2208 | Recipe Line 5 Target | D624 | INOVANCE PLC 3 |
| D2210 | Recipe Line 6 Target | D625 | INOVANCE PLC 3 |

---

## Timer Reference (T Timers)

### Line Counting Timers
| Timer | Function | Preset | Type |
|---|---|---|---|
| T50, T51 | Line 1 debounce | 100ms | TON |
| T52, T53 | Line 2 debounce | 100ms | TON |
| T54, T55 | Line 3 debounce | 100ms | TON |
| T56, T57 | Line 4 debounce | 100ms | TON |
| T58, T59 | Line 5 debounce | 100ms | TON |
| T60, T61 | Line 6 debounce | 100ms | TON |

### Sequence Control Timers
| Timer | Function | Preset | Type |
|---|---|---|---|
| T0-T7 | Recipe sequence delays | D640 | TON |
| T10-T13 | Sequence reset delays | D641 | TON |
| T20 | Main countdown | 5000ms | TON |
| T30, T31 | Stopper control | D700, D701 | TON |

### Traffic & Communication Timers
| Timer | Function | Preset | Type |
|---|---|---|---|
| T70, T71, T72 | Traffic control | D860-D862 | TON |
| T80, T81 | Label 1 communication | 500ms | TON |
| T82, T83 | Label 1 watchdog | 1000ms | TON |
| T100, T101, T102, T103 | Label 2 communication | 500ms | TON |
| T104, T105 | Label 2 watchdog | 1000ms | TON |

---

End of Input/Output Map
