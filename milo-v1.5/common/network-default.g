; network-default.g - Configure default network settings

; This file is only loaded if network.g does not exist,
; and configures the WiFi adapter into AP mode.

; Enable WiFi adapter in AP mode
M552 S2

; Enable HTTP, disable FTP and Telnet
M586 P0 S1
M586 P1 S0