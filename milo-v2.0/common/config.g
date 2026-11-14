; config.g: Load modular configuration for Milo CNC Mill

; Configure general settings
M98 P"general.g"

; Configure optional software emergency stop.
if { fileexists("estop.g") }
    M98 P"estop.g"

; Continue with configuration.
M98 P"movement.g"
M98 P"drives.g"
M98 P"speed.g"
M98 P"limits.g"
M98 P"fans.g"
M98 P"spindle.g"

if { fileexists("network.g") }
    M98 P"network.g"
else
    M98 P"network-default.g"

; Toolsetter and touch probe are optional,
; and will only be loaded if the files exist.
if { fileexists("toolsetter.g") }
    M98 P"toolsetter.g"
if { fileexists("touchprobe.g") }
    M98 P"touchprobe.g"

; Load a user configuration file if it exists
if { fileexists("user-config.g") }
    M98 P"user-config.g"

; Load MillenniumOS if it has been installed.
if { fileexists("mos.g") }
    M98 P"mos.g"