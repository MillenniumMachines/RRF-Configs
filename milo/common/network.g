; network.g - Configure network settings

; Note: M552.1 is a custom macro included
; with the RRF config that waits for the
; WiFi module to reach the desired state
; before returning. It allows us to write
; simpler code while also handling transient
; communications errors with the WiFi modules
; which are sometimes... less than reliable.

; Switch WiFi adapter to idle mode
M552.1 S0

; Enable WiFi adapter in AP mode
; Change this to S1 for client mode _after_
; configuring WiFi network details using M587
; to store the details in the WiFi module.
M552.1 S2

; Enable HTTP, disable FTP and Telnet
M586 P0 S1
M586 P1 S0
M586 P2 S0