(*
    =====================================================
    Mamée Line 1 - Mitsubishi to Beckhoff TwinCAT 3 Conversion
    =====================================================
    Original: Mitsubishi GXWorks3 (FX5U) - Ladder Logic
    Target: Beckhoff TwinCAT 3 (CX6015) - Structured Text
    
    Program Sections:
    1. Input Mapping (X → M)
    2. Alarm & Reset Logic
    3. Auto Start & Stop
    4. Output Mapping (M → Y)
    5. Recipe Selection
    6. Canister Counting
    7. Line Counting (6 Lines)
    8. Counting Sequence Comparison
    9. Recipe Setup (4 Recipes)
    10. Conveyor Traffic Control
    11. Conveyor Stopper
    12. Label 1 & 2 Communication
    13. Emergency Stop
*)

PROGRAM MAIN
VAR
    (* ========== INPUT MAPPING (X Inputs) ========== *)
    X0, X1, X2, X3, X4, X5, X6, X7: BOOL;
    X10, X11, X12, X13, X14, X15, X16, X17: BOOL;
    X20, X21, X22, X23, X24, X25, X26, X27: BOOL;
    X30, X31, X32, X33, X34, X35, X36, X37: BOOL;
    X40, X41, X42, X43, X44, X45, X46, X47: BOOL;
    X50, X51, X52, X53, X54, X55, X56, X57: BOOL;
    
    (* ========== INTERNAL MEMORY BITS (M Bits) ========== *)
    (* Input mapping *)
    M0, M1, M2, M3, M4, M5, M6, M7: BOOL;
    M10, M11, M12, M13, M14, M15, M16, M17: BOOL;
    M20, M21, M22, M23, M24, M25, M26, M27: BOOL;
    M30, M31, M32, M33, M34, M35, M36, M37: BOOL;
    
    (* Alarm flags *)
    M99, M100: BOOL;
    M101 TO M132: BOOL;
    
    (* Machine control *)
    M200, M201: BOOL;                  (* Machine RUN bits *)
    M299, M310: BOOL;                  (* Reset bits *)
    
    (* Output control *)
    M300, M301, M302, M305, M306, M307, M308, M309: BOOL;
    
    (* Recipe selection *)
    M600, M601, M602, M603, M604, M605: BOOL;
    M650, M651, M652, M653: BOOL;
    M610, M611, M612, M613, M614, M615: BOOL;
    
    (* Conveyor sequence *)
    M680, M681, M682, M683, M684, M685, M686, M687: BOOL;
    M800: BOOL;                        (* Stopper control *)
    
    (* Communication flags *)
    M2000, M2001: BOOL;
    M2020: BOOL;                       (* Emergency stop *)
    M2051, M2052: BOOL;
    M2070: BOOL;                       (* Watchdog *)
    M2200, M2201, M2202, M2210, M2211, M2212, M2213, M2214, M2215: BOOL;
    M2220, M2221: BOOL;
    M2251, M2252: BOOL;
    M2253, M2254, M2255, M2256, M2257, M2258, M2259, M2260: BOOL;
    M2261, M2262, M2263, M2270: BOOL;
    
    (* ========== OUTPUT MAPPING (Y Outputs) ========== *)
    Y6, Y7, Y10, Y11, Y12, Y13, Y14, Y15: BOOL;
    Y16, Y17, Y20, Y21, Y22, Y23, Y24, Y25: BOOL;
    Y26, Y27: BOOL;
    
    (* ========== TIMERS ========== *)
    T0, T1, T2, T3, T4, T5, T6, T7: TON;
    T10, T11, T12, T13: TON;
    T20: TON;                          (* Main countdown timer *)
    T30, T31: TON;                     (* Stopper timers *)
    T50, T51, T52, T53, T54, T55, T56, T57, T58, T59: TON;  (* Counting timers *)
    T60, T61: TON;
    T70, T71, T72: TON;                (* Traffic control *)
    T80, T81: TON;                     (* Label 1 comm *)
    T82, T83: TON;                     (* Watchdog *)
    T100, T101, T102, T103: TON;       (* Label 2 comm *)
    T104, T105: TON;                   (* Watchdog 2 *)
    
    (* ========== DATA REGISTERS (D) ========== *)
    D0, D1, D2, D3, D4: INT;
    D610, D611, D612, D613, D614, D615: INT;  (* Counting *)
    D620, D621, D622, D623, D624, D625: INT;  (* Recipe values *)
    D630, D631: INT;
    D640, D641: INT;
    D650: INT;                         (* State variable *)
    D700, D701: INT;
    D800, D801: INT;
    D820, D821, D822, D823: INT;
    D860, D861, D862: INT;
    D2200, D2202, D2204, D2206, D2208, D2210: INT;
    
    (* ========== SPECIAL FLAGS ========== *)
    SM400: BOOL;                       (* Pulse on first scan *)
    SM412: BOOL;                       (* Always TRUE *)
    
END_VAR

BEGIN

(* ================================================================
   SECTION 1: INPUT MAPPING (X → M)
   ================================================================ *)
M0 := X0;
M1 := X1;
M2 := X2;
M3 := X3;
M4 := X4;
M5 := X5;
M6 := X6;
M7 := X7;
M10 := X10;
M11 := X11;
M12 := X12;
M13 := X13;
M14 := X14;
M15 := X15;
M16 := X16;
M17 := X17;
M20 := X20;
M21 := X21;
M22 := X22;
M23 := X23;
M24 := X24;
M25 := X25;
M26 := X26;
M27 := X27;
M30 := X30;
M31 := X31;
M32 := X32;
M33 := X33;
M34 := X34;
M35 := X35;
M36 := X36;
M37 := X37;

(* ================================================================
   SECTION 2: ALARM & RESET LOGIC
   ================================================================ *)
(* Alarm aggregation - Set M100 if any alarm condition *)
IF M100 THEN
    (* ZRST equivalent: Clear M299 to M310 *)
    M299 := FALSE;
    M310 := FALSE;
END_IF;

(* Pulse on M3 rising edge - Clear alarms *)
IF M3 AND NOT M3 THEN  (* Rising edge detection *)
    M100 := FALSE;
    M101 := FALSE; M102 := FALSE; M103 := FALSE; M104 := FALSE;
    M105 := FALSE; M106 := FALSE; M107 := FALSE; M108 := FALSE;
    M109 := FALSE; M110 := FALSE; M111 := FALSE; M112 := FALSE;
    M113 := FALSE; M114 := FALSE; M115 := FALSE; M116 := FALSE;
    M117 := FALSE; M118 := FALSE; M119 := FALSE; M120 := FALSE;
    M121 := FALSE; M122 := FALSE; M123 := FALSE; M124 := FALSE;
    M125 := FALSE; M126 := FALSE; M127 := FALSE; M128 := FALSE;
    M129 := FALSE; M130 := FALSE; M131 := FALSE; M132 := FALSE;
END_IF;

(* Collect all alarm conditions *)
M99 := M106 OR M107 OR M108 OR M110 OR M111 OR M112 OR M113 OR M114 OR
       M115 OR M116 OR M117 OR M118 OR M119 OR M120 OR M121;

(* Set individual alarms based on rising edge conditions *)
IF NOT X4 THEN M101 := TRUE; END_IF;
IF NOT X31 THEN M102 := TRUE; END_IF;
IF NOT X33 THEN M103 := TRUE; END_IF;
IF NOT X35 THEN M104 := TRUE; END_IF;
IF NOT X37 THEN M105 := TRUE; END_IF;
IF NOT X7 THEN M106 := TRUE; END_IF;
IF NOT X26 THEN M107 := TRUE; END_IF;
IF NOT X27 THEN M108 := TRUE; END_IF;
IF X40 THEN M110 := TRUE; END_IF;
IF X41 THEN M111 := TRUE; END_IF;
IF X42 THEN M112 := TRUE; END_IF;
IF X43 THEN M113 := TRUE; END_IF;
IF X44 THEN M114 := TRUE; END_IF;
IF X45 THEN M115 := TRUE; END_IF;

(* Additional alarm conditions *)
M122 := M2259;
M123 := M2260;
M124 := M2263;
M125 := T104.Q OR T105.Q;
M126 := T82.Q OR T83.Q;
M127 := M2261;
M128 := M2262;
IF NOT X51 THEN M129 := TRUE; END_IF;
IF NOT X52 THEN M130 := TRUE; END_IF;
IF NOT X53 THEN M131 := TRUE; END_IF;
IF NOT X56 THEN M132 := TRUE; END_IF;

M133 := M2051 AND NOT Y22;
M134 := M2251 AND NOT Y22;

(* ================================================================
   SECTION 3: AUTO START & STOP (Main Machine Control)
   ================================================================ *)

(* Start condition: M0 AND M1 OR M200 OR M201, then M0 AND M2 AND NOT M100 AND NOT M99 *)
IF ((M0 AND M1) OR M200 OR M201) AND M0 AND M2 AND NOT M100 AND NOT M99 THEN
    
    (* MPS: Main Push Stack - parallel logic branches *)
    (* Branch 1: AND T20 *)
    IF T20.Q THEN
        M200 := TRUE;
    END_IF;
    
    (* Branch 2: AND NOT T20 *)
    IF NOT T20.Q THEN
        M201 := TRUE;
    END_IF;
    
END_IF;

(* Timer T20 logic *)
T20(
    IN := M200,
    PT := T#5S
);

(* Hold the machine run bit when timer completes *)
IF T20.Q THEN
    M201 := TRUE;
END_IF;

(* Reset sequence *)
IF M299 THEN
    M310 := TRUE;
    M201 := FALSE;
    M299 := FALSE;
END_IF;

(* MOV equivalent - Transfer timer value to display *)
IF T20.IN THEN
    D0 := INT(T20.ET * 1000);  (* Convert to milliseconds *)
ELSE
    D0 := 0;
END_IF;

(* ================================================================
   SECTION 4: OUTPUT MAPPING (M → Y)
   ================================================================ *)

(* Y6 Output *)
Y6 := (M200 AND M36) OR (NOT M200 AND NOT M0 AND M299 AND M36);

(* Y7 Output *)
Y7 := (M200 AND M30) OR (NOT M200 AND NOT M0 AND M300 AND M30);

(* Y10 Output *)
Y10 := (NOT M200 AND NOT M0 AND M305) OR (M200 AND NOT M800 AND NOT T72.Q);

(* Y11 Output *)
Y11 := (NOT M200 AND NOT M0 AND M306) OR (M200 AND NOT M800);

(* Y12 Output *)
Y12 := (NOT M200 AND NOT M0 AND M307) OR (M200 AND NOT T71.Q);

(* Y13 Output *)
Y13 := (NOT M200 AND NOT M0 AND M308) OR M200;

(* Y14 Output *)
Y14 := (NOT M200 AND NOT M0 AND M309) OR (M200 AND NOT T70.Q AND M54);

(* Y15 Output *)
Y15 := (NOT M200 AND NOT M0 AND M310) OR (M200 AND M54);

(* Y16 Output *)
Y16 := (M200 AND M32) OR (NOT M200 AND NOT M0 AND M301 AND M32);

(* Y17 Output *)
Y17 := (M200 AND M34) OR (NOT M200 AND NOT M0 AND M302 AND M34);

(* Y20 & Y21 - Conveyor outputs *)
Y20 := M200 AND (M680 OR M682 OR M684 OR M686);
Y21 := M200 AND (M681 OR M683 OR M685 OR M687);

(* Y22 - Emergency Stop / Alarm output *)
Y22 := M101 OR M102 OR M103 OR M104 OR M105 OR M109 OR M124 OR M2052 OR M2252 OR
       M129 OR M130 OR M131 OR M132;

(* Y23 - Machine RUN + Timer Q or SM412 *)
Y23 := M200 OR (M201 AND SM412);

(* Y24 - NOT M0 *)
Y24 := NOT M0;

(* Y25 - Alarm or M99 or Y22 *)
Y25 := M100 OR M99 OR Y22;

(* Y26 - M100 or M201 or Y22 *)
Y26 := M100 OR M201 OR Y22;

(* Y27 - M800 *)
Y27 := M800;

(* ================================================================
   SECTION 5: RECIPE SELECTION
   ================================================================ *)

IF M200 THEN
    IF M20 THEN M600 := TRUE; END_IF;
    IF M21 THEN M601 := TRUE; END_IF;
    IF M22 THEN M602 := TRUE; END_IF;
    IF M23 THEN M603 := TRUE; END_IF;
    IF M24 THEN M604 := TRUE; END_IF;
    IF M25 THEN M605 := TRUE; END_IF;
END_IF;

(* ================================================================
   SECTION 6: CANISTER COUNTING RESET
   ================================================================ *)

IF NOT M200 THEN
    (* ZRST D610 D616 - Clear counting registers *)
    D610 := 0; D611 := 0; D612 := 0; D613 := 0; D614 := 0; D615 := 0;
END_IF;

(* ================================================================
   SECTION 7: LINE COUNTING (6 Lines)
   ================================================================ *)

(* LINE 1 COUNTING *)
IF M200 AND M11 THEN
    T50(IN := NOT T51.Q, PT := T#100MS);
    IF NOT T51.Q THEN
        D630 := INT(T50.ET);
    END_IF;
    IF NOT T50.Q AND T50.Q THEN  (* Rising edge of T50 *)
        D610 := D610 + 1;
    END_IF;
END_IF;

(* LINE 2 COUNTING *)
IF M200 AND M12 THEN
    T52(IN := NOT T53.Q, PT := T#100MS);
    IF NOT T53.Q THEN
        D630 := INT(T52.ET);
    END_IF;
    IF NOT T52.Q AND T52.Q THEN
        D611 := D611 + 1;
    END_IF;
END_IF;

(* LINE 3 COUNTING *)
IF M200 AND M13 THEN
    T54(IN := NOT T55.Q, PT := T#100MS);
    IF NOT T55.Q THEN
        D630 := INT(T54.ET);
    END_IF;
    IF NOT T54.Q AND T54.Q THEN
        D612 := D612 + 1;
    END_IF;
END_IF;

(* LINE 4 COUNTING *)
IF M200 AND M14 THEN
    T56(IN := NOT T57.Q, PT := T#100MS);
    IF NOT T57.Q THEN
        D630 := INT(T56.ET);
    END_IF;
    IF NOT T56.Q AND T56.Q THEN
        D613 := D613 + 1;
    END_IF;
END_IF;

(* LINE 5 COUNTING *)
IF M200 AND M15 THEN
    T58(IN := NOT T59.Q, PT := T#100MS);
    IF NOT T59.Q THEN
        D630 := INT(T58.ET);
    END_IF;
    IF NOT T58.Q AND T58.Q THEN
        D614 := D614 + 1;
    END_IF;
END_IF;

(* LINE 6 COUNTING *)
IF M200 AND M16 THEN
    T60(IN := NOT T61.Q, PT := T#100MS);
    IF NOT T61.Q THEN
        D630 := INT(T60.ET);
    END_IF;
    IF NOT T60.Q AND T60.Q THEN
        D615 := D615 + 1;
    END_IF;
END_IF;

(* Clear counters on X34 rising edge *)
IF X34 THEN
    D610 := 0; D611 := 0; D612 := 0; D613 := 0; D614 := 0; D615 := 0;
END_IF;

(* ================================================================
   SECTION 8: COUNTING SEQUENCE COMPARISON
   ================================================================ *)

M610 := (M600 AND D610 >= D620);
M611 := (M601 AND D611 >= D621);
M612 := (M602 AND D612 >= D622);
M613 := (M603 AND D613 >= D623);
M614 := (M604 AND D614 >= D624);
M615 := (M605 AND D615 >= D625);

(* ================================================================
   SECTION 9: RECIPE SETUP
   ================================================================ *)

(* RECIPE 1: 4x3 *)
IF M650 THEN
    D620 := 4; D621 := 4; D622 := 4; D623 := 4; D624 := 4; D625 := 4;
END_IF;

(* M650 rising edge - clear other recipes *)
IF NOT M650 THEN
    M651 := FALSE;
    M652 := FALSE;
    M653 := FALSE;
END_IF;

(* RECIPE 2: 4x2 *)
IF M651 THEN
    D620 := 4; D621 := 4; D622 := 0; D623 := 4; D624 := 4; D625 := 0;
END_IF;

IF NOT M651 THEN
    M650 := FALSE;
    M652 := FALSE;
    M653 := FALSE;
END_IF;

(* RECIPE 3: 5x2 *)
IF M652 THEN
    D620 := 5; D621 := 5; D622 := 0; D623 := 5; D624 := 5; D625 := 0;
END_IF;

IF NOT M652 THEN
    M650 := FALSE;
    M651 := FALSE;
    M653 := FALSE;
END_IF;

(* RECIPE 4: 5x4x5 *)
IF M653 THEN
    D620 := 5; D621 := 4; D622 := 5; D623 := 5; D624 := 4; D625 := 5;
END_IF;

IF NOT M653 THEN
    M650 := FALSE;
    M651 := FALSE;
    M652 := FALSE;
END_IF;

(* ================================================================
   SECTION 10: CONVEYOR TRAFFIC CONTROL
   ================================================================ *)

T70(IN := (M200 OR NOT M200) AND M46, PT := INT_TO_TIME(D860));
T71(IN := (M200 OR NOT M200) AND M47, PT := INT_TO_TIME(D861));
T72(IN := (M200 OR NOT M200) AND M50, PT := INT_TO_TIME(D862));

(* ================================================================
   SECTION 11: CONVEYOR STOPPER
   ================================================================ *)

IF M50 AND NOT M46 AND NOT M800 THEN
    T30(IN := TRUE, PT := INT_TO_TIME(D700));
END_IF;

IF T30.Q THEN
    M800 := TRUE;
END_IF;

IF M800 AND NOT M50 THEN
    T31(IN := TRUE, PT := INT_TO_TIME(D701));
END_IF;

IF T31.Q THEN
    M800 := FALSE;
END_IF;

(* ================================================================
   SECTION 12: CONVEYOR SEQUENCE LOGIC
   ================================================================ *)

(* This section handles complex MPS/MRD/MPP stack-based logic *)
(* Converting to TwinCAT 3 standard logic *)

IF M200 AND D650 = 0 THEN
    D650 := 1;
END_IF;

IF NOT M200 THEN
    D650 := 0;
    M680 := FALSE; M681 := FALSE; M682 := FALSE; M683 := FALSE;
    M684 := FALSE; M685 := FALSE; M686 := FALSE; M687 := FALSE;
END_IF;

(* Recipe 1 path (M650) *)
IF D650 = 1 AND M650 AND M610 AND M611 AND M612 THEN
    T0(IN := NOT T0.Q, PT := INT_TO_TIME(D640));
    IF T0.Q THEN
        M680 := TRUE;
    END_IF;
END_IF;

IF D650 = 1 AND M650 AND M613 AND M614 AND M615 THEN
    T1(IN := NOT T1.Q, PT := INT_TO_TIME(D640));
    IF T1.Q THEN
        M681 := TRUE;
    END_IF;
END_IF;

(* Recipe 2 path (M651) *)
IF D650 = 1 AND M651 AND M610 AND M611 THEN
    T2(IN := NOT T2.Q, PT := INT_TO_TIME(D640));
    IF T2.Q THEN
        M682 := TRUE;
    END_IF;
END_IF;

IF D650 = 1 AND M651 AND M613 AND M614 THEN
    T3(IN := NOT T3.Q, PT := INT_TO_TIME(D640));
    IF T3.Q THEN
        M683 := TRUE;
    END_IF;
END_IF;

(* Recipe 3 path (M652) *)
IF D650 = 1 AND M652 AND M610 AND M611 THEN
    T4(IN := NOT T4.Q, PT := INT_TO_TIME(D640));
    IF T4.Q THEN
        M684 := TRUE;
    END_IF;
END_IF;

IF D650 = 1 AND M652 AND M613 AND M614 THEN
    T5(IN := NOT T5.Q, PT := INT_TO_TIME(D640));
    IF T5.Q THEN
        M685 := TRUE;
    END_IF;
END_IF;

(* Recipe 4 path (M653) *)
IF D650 = 1 AND M653 AND M610 AND M611 AND M612 THEN
    T6(IN := NOT T6.Q, PT := INT_TO_TIME(D640));
    IF T6.Q THEN
        M686 := TRUE;
    END_IF;
END_IF;

IF D650 = 1 AND M653 AND M613 AND M614 AND M615 THEN
    T7(IN := NOT T7.Q, PT := INT_TO_TIME(D640));
    IF T7.Q THEN
        M687 := TRUE;
    END_IF;
END_IF;

(* Transition to state 2 when all conveyor bits are set *)
IF (M680 OR M681 OR M682 OR M683 OR M684 OR M685 OR M686 OR M687) THEN
    D650 := 2;
END_IF;

(* State 2: Handle line resets and transitions *)
IF D650 = 2 THEN
    (* Recipe 1 completion *)
    IF (M650 AND M680) OR (M653 AND M686) THEN
        T10(IN := ((NOT M610 AND NOT M611 AND NOT M612) OR M55), PT := INT_TO_TIME(D641));
        IF T10.Q THEN
            D610 := 0; D611 := 0; D612 := 0;
            D650 := 1;
            IF M650 THEN M680 := FALSE; END_IF;
            IF M653 THEN M686 := FALSE; END_IF;
        END_IF;
    END_IF;
    
    (* Recipe 1 second half *)
    IF (M650 AND M681) OR (M653 AND M687) THEN
        T11(IN := ((NOT M613 AND NOT M614 AND NOT M615) OR M55), PT := INT_TO_TIME(D641));
        IF T11.Q THEN
            D613 := 0; D614 := 0; D615 := 0;
            D650 := 1;
            IF M650 THEN M681 := FALSE; END_IF;
            IF M653 THEN M687 := FALSE; END_IF;
        END_IF;
    END_IF;
    
    (* Recipe 2 path *)
    IF (M651 AND M682) OR (M652 AND M684) THEN
        T12(IN := ((NOT M610 AND NOT M611) OR M55), PT := INT_TO_TIME(D641));
        IF T12.Q THEN
            D610 := 0; D611 := 0;
            D650 := 1;
            IF M651 THEN M682 := FALSE; END_IF;
            IF M652 THEN M684 := FALSE; END_IF;
        END_IF;
    END_IF;
    
    (* Recipe 2 second half *)
    IF (M651 AND M683) OR (M652 AND M685) THEN
        T13(IN := ((NOT M613 AND NOT M614) OR M55), PT := INT_TO_TIME(D641));
        IF T13.Q THEN
            D613 := 0; D614 := 0;
            D650 := 1;
            IF M651 THEN M683 := FALSE; END_IF;
            IF M652 THEN M685 := FALSE; END_IF;
        END_IF;
    END_IF;
END_IF;

(* ================================================================
   SECTION 13: LABEL 1 COMMUNICATION
   ================================================================ *)

IF M200 AND Y6 THEN
    T80(IN := TRUE, PT := T#500MS);
    IF T80.Q THEN
        M2000 := TRUE;
    END_IF;
END_IF;

IF M200 AND Y16 THEN
    T81(IN := TRUE, PT := T#500MS);
    IF T81.Q THEN
        M2001 := TRUE;
    END_IF;
END_IF;

M2051 := M2051;  (* Hold bit *)
M2052 := M2052;  (* Hold bit *)

(* Watchdog *)
T82(IN := M2070, PT := T#1S);
T83(IN := NOT M2070, PT := T#1S);

M2020 := Y22;  (* Emergency stop *)

(* ================================================================
   SECTION 14: LABEL 2 COMMUNICATION
   ================================================================ *)

IF M200 AND Y7 THEN
    T100(IN := TRUE, PT := T#500MS);
    IF T100.Q THEN
        M2200 := TRUE;
    END_IF;
END_IF;

IF M200 AND Y16 THEN
    T101(IN := TRUE, PT := T#500MS);
    IF T101.Q THEN
        M2201 := TRUE;
    END_IF;
END_IF;

IF M200 AND (NOT Y17 OR M2202) THEN
    T102(IN := NOT T102.Q, PT := T#500MS);
    IF T102.Q AND Y17 THEN
        M2202 := TRUE;
    END_IF;
END_IF;

T103(IN := M200, PT := T#500MS);
IF T103.Q THEN
    M2210 := TRUE;
END_IF;

M2211 := NOT M200;
M2212 := M651 OR M652;
M2213 := M650 OR M653;
M2214 := NOT Y20;
M2215 := NOT Y21;

M2251 := M2251;  (* Hold *)
M2252 := M2252;  (* Hold *)
M2253 := M2253;  (* Hold *)
M2254 := M2254;  (* Hold *)
M2255 := M2255;  (* Hold *)
M2256 := M2256;  (* Hold *)
M2257 := M2257;  (* Hold *)
M2258 := M2258;  (* Hold *)
M2259 := M2259;  (* Hold *)
M2260 := M2260;  (* Hold *)
M2261 := M2261;  (* Hold *)
M2262 := M2262;  (* Hold *)
M2263 := M2263;  (* Hold *)
M2221 := M3;

M2220 := Y22;  (* Emergency stop *)

(* ================================================================
   SECTION 15: INOVANCE PLC 3 INTEGRATION
   ================================================================ *)

(* First scan pulse - Move counting values to external PLC *)
IF SM400 THEN
    D2200 := D620;
    D2202 := D621;
    D2204 := D622;
    D2206 := D623;
    D2208 := D624;
    D2210 := D625;
END_IF;

(* Watchdog for external communication *)
T104(IN := M2270, PT := T#1S);
T105(IN := NOT M2270, PT := T#1S);

END_PROGRAM
