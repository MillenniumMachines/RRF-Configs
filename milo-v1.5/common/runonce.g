; runonce.g - Runs _after_ config.g is processed.

; Disable WiFi adapter
M552.1 S-1

echo { "Updating WiFi firmware..." }

; Update the WiFi firmware
M997 S1

; Make sure the WiFi adapter is disabled
M552.1 S-1

; Enable the WiFi adapter again
M552.1 S0

echo { "Configuring WiFI Access Point - password is ""millenniummachines""." }

; Configure WiFi AP
M589 S"Milo" P"millenniummachines" I192.168.40.1 C1

; Enable WiFi in AP mode
M552.1 S2