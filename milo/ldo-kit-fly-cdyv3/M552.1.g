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

; Check status every second by default
var delay = { exists(param.D) ? param.D : 1 }

; Retry after 30 seconds by default
var retry = { (exists(param.R) ? param.R : 30) / var.delay }

; Reboot after 5 minutes by default
var reboot = { (exists(param.B) ? param.B : 300) / var.delay }

; Validate S parameter
if { !exists(param.S) || param.S < -1 || param.S > 2 }
    abort {"Must provide valid target mode number with S parameter!"}

; Get expected state
var tS = { var.states[param.S+1] }

; While network is not in target state
; attempt to change mode using M552 and wait
; until the target state is reached. Retry
; the M552 command every <retry> seconds and
; reboot after <reboot> seconds if the state
; has not been reached.
while { network.interfaces[0].state != var.tS }
    if { iterations == var.reboot }
        echo { "WiFi module did not change mode to " ^ param.S ^ ", expected state: " ^ var.tS ^ ", actual state: " ^ network.interfaces[0].state ^ ". Rebooting." }
        M999

    if { iterations == 0 || mod(iterations,var.retry) == 0 }
        echo { "Switching WiFi mode to " ^ param.S ^ ", expected state: " ^ var.tS }
        M552 S{ param.S }

    ; Wait for delay
    G4 S{ var.delay }
