; limits.g - Configure machine limits and endstops

; Set axis limits - minima
M208 X0 Y0 Z-120 S1

; Set axis limits - maxima
M208 X348 Y210 Z0 S0

; Endstops
; The spindle is stationary, so we're looking for 0,0
; to be when the bottom left of the work area is under
; the spindle. X homes to the _right_ (towards the
; spindle) so endstop position is 0, Y homes towards
; the operator (away from the spindle) so endstop
; position is MAX.
; Z homes upwards to zero.

; If M119 shows an endstop as triggered while nothing is near it, remove the ! from its pin (for example LJ8A3-2-Z/AX sensors or a D2F microswitch on Y).
; Endstop X=MIN: LJ8A3-2-Z/AY inductive sensor (PNP, NC), UEB X-MIN connector (PD_11)
M574 X1 S1 P"!PD_11"

; Endstop Y=MAX: LJ8A3-2-Z/AY inductive sensor (PNP, NC), UEB Y-MAX connector (PD_14)
; A D2F microswitch on Y may need the ! removed
M574 Y2 S1 P"!PD_14"

; Endstop Z=MAX: LJ8A3-2-Z/AY inductive sensor (PNP, NC), UEB Z-MAX connector (PD_12)
M574 Z2 S1 P"!PD_12"
