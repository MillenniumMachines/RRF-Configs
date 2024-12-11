; fans.g - Configures fans

; TODO: Is Q500 appropriate?

; Configure aux0 as fan and enable at startup
; This runs at v-mos input voltage
M950 F0 C"PA_4" Q500
M106 P0 S1 H-1