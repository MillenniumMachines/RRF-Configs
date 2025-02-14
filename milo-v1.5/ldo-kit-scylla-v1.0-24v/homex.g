; homex.g - Lifts Z, then homes X using existing machine limits.

; Relative positioning in mm and mm/min
G91
G21
G94

; Raise Z towards machine limit as it is already homed
G53 G0 Z{move.axes[2].max}

; Move quickly to X axis endstop and stop there (first pass)
G53 G1 H1 X{-(move.axes[0].max - move.axes[0].min + 5) } F{2500}

; Endstop should now be triggered, verify
if { ! sensors.endstops[0].triggered }
    abort {"X endstop not triggered after full axis travel. Check that your X motor is connected and the endstop is working!"}

; Move away from X endstop
G53 G1 H2 X{5}

; Repeat X home at low speed. Do not move further than
; 2 * 5 further than the expected endstop location.
G53 G1 H1 X{-5*2} F{180}