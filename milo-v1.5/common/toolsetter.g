; toolsetter.g - Configures the toolsetter

; Disabled by default.
; Configure the pin and uncomment to enable.

; P8       - Unfiltered switch
; C"<pin>" - Input pin
; H5       - Dive height (height for repeated probes)
; A5       - Max number of probes
; S0.01    - Required tolerance
; T1200    - Travel speed, mm/min
; F600:300 - Probe Speed rough / fine, mm/min

; M558 K1 P8 C"<pin>" H5 A5 S0.01 T1200 F600:300