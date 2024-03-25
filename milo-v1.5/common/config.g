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
M98 P"network.g"

; Toolsetter and touch probe are optional,
; and will only be loaded if the files exist.
if { fileexists("toolsetter.g") }
    M98 P"toolsetter.g"
if { fileexists("touchprobe.g") }
    M98 P"touchprobe.g"