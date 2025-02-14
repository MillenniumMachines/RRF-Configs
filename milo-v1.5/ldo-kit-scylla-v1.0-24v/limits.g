; limits.g - Configure machine limits and endstops

; Set axis limits - minima
M208 X0 Y0 Z-120 S1

; Set axis limits - maxima
M208 X335 Y208 Z0 S0

; Endstops
; The spindle is stationary, so we're looking for 0,0
; to be when the bottom left of the work area is under
; the spindle. X homes to the _right_ (towards the
; spindle) so endstop position is 0, Y homes towards
; the operator (away from the spindle) so endstop
; position is MAX.
; Z homes upwards to zero.

; Endstop X=MIN: NC
M574 X1 S1 P"PD_11"

; Endstop Y=MAX: NC
M574 Y2 S1 P"PD_14"

; Endstop Z=MAX: NC
M574 Z2 S1 P"PD_12"
