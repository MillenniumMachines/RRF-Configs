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

; WiFi modes
var wStates = { "disabled", "idle", "active", "active" }

; Ethernet modes
var eStates = { "disabled", "active" }

; SSID or IP address
var netip = { exists(param.P) ? param.P : null }

; Get interface number, default to first one
var iface = { exists(param.I) ? param.I : 0 }

; Check status every second by default
var delay = { exists(param.D) ? param.D : 1 }

; Retry after 30 seconds by default
; NOTE: This conflicts with the underlying M552 R parameter
; which specifies an HTTP port for RRF 1.17 and earlier.
; Since we only target RRF 3.5 and above this is a non-issue.
var retry = { (exists(param.R) ? param.R : 30) / var.delay }

; Reboot after 5 minutes by default
var reboot = { (exists(param.B) ? param.B : 300) / var.delay }

; Check if interface is WiFi
var isWifi = { network.interfaces[var.iface].type == "wifi" }

var ifaceType = { var.isWifi ? "WiFi" : "LAN" }

if { !exists(param.S) }
    abort {"Must provide valid target mode number with S parameter!"}

; Target state index
var stateID = { var.isWifi ? param.S+1 : param.S }

; Validate S parameter based on interface type.
; NOTE: S=-1 and S=2 are not valid for Ethernet interfaces.
if { var.stateID < 0 || (var.isWifi && var.stateID >= #var.wStates) || (!var.isWifi && var.stateID >= #var.eStates) }
    abort {"Must provide valid target mode number with S parameter!"}

; Get expected state based on interface type.
; Ethernet does not have a -1 state so we don't
; need to add 1 to the index.
var tS = { (var.isWifi)? var.wStates[var.stateID] : var.eStates[var.stateID] }

; While network is not in target state
; attempt to change mode using M552 and wait
; until the target state is reached. Retry
; the M552 command every <retry> seconds and
; reboot after <reboot> seconds if the state
; has not been reached.
while { network.interfaces[var.iface].state != var.tS }
    if { iterations == var.reboot }
        echo { "Network adapter did not change mode to " ^ param.S ^ ", expected state: " ^ var.tS ^ ", actual state: " ^ network.interfaces[var.iface].state ^ ". Rebooting." }
        M999

    if { iterations == 0 || mod(iterations, var.retry) == 0 }
        echo { "Switching " ^ var.ifaceType ^ " to mode " ^ param.S ^ ", expected state: " ^ var.tS }
        ; Cannot pass null to the P parameter
        ; so must call conditionally.
        if { var.netip == null }
            M552 S{ param.S } I{ var.iface }
        else
            M552 S{ param.S } P{ var.netip } I{ var.iface }

    ; Wait for delay
    G4 S{ var.delay }
