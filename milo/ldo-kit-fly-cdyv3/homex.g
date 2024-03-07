; homex.g - Lifts Z, then homes X using existing machine limits.

; Relative positioning
G91

; Raise Z towards machine limit as it is already homed
G53 G0 Z{move.axes[2].max}

; Move quickly to X axis endstop and stop there (first pass)
G53 G1 H1 X{-(move.axes[0].max - move.axes[0].min + 5) } F{1800}

; Move away from X endstop
G53 G1 H2 X{5}

; Repeat X home at low speed. Do not move further than
; 2 * 5 further than the expected endstop location.
G53 G1 H1 X{-5*2} F{180}