; fans.g - Configures fans

; TODO: Is Q500 appropriate?

; Configure aux1 as fan and enable at startup 50% speed.
; This runs at v-mos input voltage
M950 F0 C"PA_5" Q500
M106 P0 S0.5 H-1