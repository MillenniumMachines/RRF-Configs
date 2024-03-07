; touchprobe.g - Configures a touch probe.

; Disabled by default.
; Configure the pin and uncomment to enable.

; P5       - Filtered Switch
; C"<pin>" - Input pin
; H2       - Dive height (distance for repeat probes, used for X/Y too)
; A10      - Max number of probes
; S0.01    - Required tolerance
; T1200    - Travel speed, mm/min
; F300:50  - Probe Speed rough / fine, mm/min

; M558 K0 P5 C"<pin>" H2 A10 S0.01 T1200 F300:50