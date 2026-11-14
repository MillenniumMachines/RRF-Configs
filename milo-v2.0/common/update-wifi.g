; update-wifi.g - Default update script for WiFi module.

; Sometimes the SD card is not available when this file is run.
; M997 S1 tries to identify the WiFi module to update it with the
; correct firmware file. Since we build for specific board and WiFi
; module combinations, we can call M997 S1 P"..." with the correct
; firmware filename to avoid the error when calling this code during
; runonce.g.

; Make sure the WiFi adapter is disabled
M552.1 S-1

var wiFiFirmwareType = { "%%WIFI_FIRMWARE_TYPE%%" }

if { var.wiFiFirmwareType != "" }
    echo {"Updating " ^ var.wiFiFirmwareType ^ " WiFi firmware."}
    M997 S1 P{var.wiFiFirmwareType}
else
    echo { "WiFi firmware type not set, attempting automatic firmware update." }
    M997 S1