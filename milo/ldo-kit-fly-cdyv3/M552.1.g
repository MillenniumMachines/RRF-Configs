; M552.1.g - Change WiFi mode and wait until it has changed
; Will retry after a set interval and reboot after 5 minutes
; as this indicates a problem with communication with the
; WiFi module.

; NOTE: WiFi client and AP mode both have "active" as their
; target state, and there is no way to identify the difference.
; If using this macro to switch between client and AP mode, you
; must switch to idle mode first (S0).

; List of expected modes when passed an S-number.
; First one corresponds to S=-1, second to S=0, etc.
var states = { "disabled", "idle", "active", "active" }

var delay  = 1   ; Check status every 1 seconds
var retry  = 30  ; Retry after 30 delays (30 seconds)
var reboot = 300 ; Reboot after 300 delays (5 minutes)

; Validate S parameter
if { !exists(param.S) || param.S < -1 || param.S > 2}
    abort {"Must provide valid target mode number with S parameter!"}

; Get expected state
var tS = { var.states[param.S+1] }

; Check if network is already in target state
; If so, exit
if { network.interfaces[0].state == var.tS }
    M99

while { network.interfaces[0].state != var.tS }
    if { iterations == var.reboot }
        echo { "WiFi module did not change mode to " ^ param.S ^ ", expected state: " ^ var.tS ^ ", actual state: " ^ network.interfaces[0].state ^ ". Rebooting."}
        M999

    if { iterations == 0 || mod(iterations,var.retry) == 0 }
        echo { "Switching WiFi mode to " ^ param.S ^ ", expected state: " ^ var.tS }
        M552 S{param.S}

    ; Wait for delay
    G4 S{var.delay}
