; homey.g - Lifts Z, then homes Y using existing machine limits.

; Relative positioning
G91
G21
G94

; Raise Z towards machine limit as it is already homed
G53 G0 Z{move.axes[2].max}

; Move quickly towards Y MAX endstop and stop there (first pass)
; LJ8A3-2-Z/AY inductive sensor: first pass at most 1000mm/min (Milo V2 manual, p.105)
G53 G1 H1 Y{ move.axes[1].max - move.axes[1].min + 5 } F{1000}

; Endstop should now be triggered, verify
if { ! sensors.endstops[1].triggered }
    abort {"Y endstop not triggered after full axis travel. Check that your Y motor is connected and the endstop is working!"}

; Move away from Y endstop
G53 G1 H2 Y{-5}

; Repeat Y home at low speed. Do not move further than
; 2 * 5 further than the expected endstop locations.
G53 G1 H1 Y{5*2} F{180}