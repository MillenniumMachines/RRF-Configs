; limits.g - Configure machine limits and endstops

; Set axis limits - minima
M208 X0 Y0 Z-120 S1

; Set axis limits - maxima
M208 X308 Y210 Z0 S0

; Endstops
; The spindle is stationary, so we're looking for 0,0
; to be when the bottom left of the work area is under
; the spindle. X homes to MAX (the X axis is stationary
; relative to the spindle, so the endstop is at the right
; hand end of travel), Y homes to MIN (towards Y0, away
; from the operator side).
; Z homes upwards to zero.
; The endstop connectors are unchanged: X-MIN, Y-MAX and Z-MAX.

; Endstop X=MAX: LJ8A3-2-Z/AY inductive sensor (PNP, NC), UEB X-MIN connector (PD_11)
M574 X2 S1 P"!PD_11"

; Endstop Y=MIN: LJ8A3-2-Z/AY inductive sensor (PNP, NC), UEB Y-MAX connector (PD_14)
; A D2F microswitch on Y may need the ! removed
M574 Y1 S1 P"!PD_14"

; Endstop Z=MAX: LJ8A3-2-Z/AY inductive sensor (PNP, NC), UEB Z-MAX connector (PD_12)
M574 Z2 S1 P"!PD_12"
