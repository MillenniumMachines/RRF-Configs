; homeall.g - Homes Z, then homes X and Y together using existing machine limits.

; Relative positioning in mm and mm/min
G91
G21
G94

M98 P"homez.g"

; Move quickly to X and Y axis endstops and stop there (first pass)
G53 G1 H1 X{-(move.axes[0].max - move.axes[0].min + 5) } Y{ move.axes[1].max - move.axes[1].min + 5 } F{1800}

; Move away from X and Y endstops
G53 G1 H2 X{5} Y{-5}

; Repeat X and Y home at low speed. Do not move further than
; 2 * 5 further than the expected endstop locations.
G53 G1 H1 X{-5*2} Y{5*2} F{180}