; movement.g - Configure motion-specific parameters

; Enables segmentation of moves to allow for faster
; pauses and position reporting.

; K0 = Cartesian movement mode
; S10 = 10 segments per second, or 100ms per segment
; T1 = 1mm minimum segment length
M669 K0 S10 T1