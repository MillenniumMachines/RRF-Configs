; fans.g - Configures fans

; TODO: Is Q500 appropriate?

; Configure fan port 0 and 1 and enable at startup
M950 F0 C"fan0" Q500
M106 P0 S1 H-1

M950 F1 C"fan1" Q500
M106 P1 S1 H-1