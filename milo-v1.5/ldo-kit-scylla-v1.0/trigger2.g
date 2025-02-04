; trigger2.g - Safety Net emergency stop macro
; Switch off the Safety Net relay using M81,
; and then trigger a machine halt.
; This does _not_ restart the machine automatically.
M81
M112
echo {"Safety Net activated due to emergency stop."}