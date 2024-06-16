; runonce.g - Runs _after_ config.g is processed.

; Disable WiFi adapter
M552.1 S-1

echo { "Updating WiFi firmware..." }

; Update the WiFi firmware
M997 S1

; If update failed, retry up to 10 times with a max delay of 10 seconds
while { result != 0 || iterations < 10 }
    echo { "Failed to update WiFi firmware. Retrying after a short random delay..." }
    G4 P{ 1000 + random(9000) }
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