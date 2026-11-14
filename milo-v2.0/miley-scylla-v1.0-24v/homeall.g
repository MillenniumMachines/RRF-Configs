; homeall.g - Homes Z, then homes X and Y together using existing machine limits.

; Relative positioning in mm and mm/min
G91
G21
G94

; Home Z first to move spindle out of the way
M98 P"homez.g"

; Move quickly towards X MAX and Y MIN (Y0) endstops and stop there (first pass)
; LJ8A3-2-Z/AY inductive sensor: first pass at most 1000mm/min (Milo V2 manual, p.105)
G53 G1 H1 X{move.axes[0].max - move.axes[0].min + 5} Y{-(move.axes[1].max - move.axes[1].min + 5)} F{1000}

; Endstops should now be triggered, verify
if { ! sensors.endstops[0].triggered }
    abort {"X endstop not triggered after full axis travel. Check that your X motor is connected and the endstop is working!"}
if { ! sensors.endstops[1].triggered }
    abort {"Y endstop not triggered after full axis travel. Check that your Y motor is connected and the endstop is working!"}

; Move away from X and Y endstops
G53 G1 H2 X{-5} Y{5}

; Repeat X and Y home at low speed. Do not move further than
; 2 * 5 further than the expected endstop locations.
G53 G1 H1 X{5*2} Y{-5*2} F{180}