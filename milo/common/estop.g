; estop.g - Configure software-based emergency stop

; Configure emergency stop input if software estop is enabled.
; Do not configure this for a specific machine if the machine uses
; an emergency stop that cuts all power to the mainboard and spindle.

; This is only for use in cases where the emergency stop is an input
; to the mainboard, and rather than cutting all power (the safest)
; we rely on the firmware to stop the machine and the spindle.

; Configure emergency stop pin
; M950 J1 C"<pin>"

; Fire trigger 0 (emergency stop) on status change
; M581 P1 T0 S1 R0

; Check e-stop is not active before continuing startup
; echo {"Checking E-Stop status..."}
; M582 T0
; echo {"E-Stop is not activated, continuing startup"}
