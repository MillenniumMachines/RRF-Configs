; runonce.g - Runs _after_ config.g is processed.

; Call board-specific WiFi firmware update file
M98 P"update-wifi.g"

; Try to enable the WiFi adapter
M552.1 S0

echo { "Configuring WiFI Access Point - password is ""millenniummachines""." }

; Configure WiFi AP
M589 S"Milo" P"millenniummachines" I192.168.40.1 C1

; Settle for a couple of seconds to allow the WiFi module to save the configuration
G4 S5

; Rename this file so we can delete it
M471 S"0:/sys/runonce.g" T"0:/sys/runonce.old" D1

; Delete the runonce file
M472 P"0:/sys/runonce.old"

; Now restart. If the user has not added their own network.g configuration, the
; board will come back in AP mode. We must rename and delete the runonce file
; because the M999 command below causes the board to reset before the file is
; deleted by RRF itself.

echo { "WiFi Access Point details configured. Rebooting..." }

M999