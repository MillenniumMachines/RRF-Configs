; estop.g - Configure software-based latching emergency-stop

; Safety Net is a configuration for RepRapFirmware that allows the
; machine operator to verify that a machine is in a known-safe state
; before re-enabling any motors and spindles.

; Safety Net uses the integrated, IO controlled relay on the Scylla mainboard
; to act as a failsafe between the emergency stop circuit and the
; contactor that cuts power to any motors and spindles.

; This acts roughly similarly to a latching switch setup, with the
; MASSIVE caveat that this is software controlled.

; It's about as good as we can get without specifying a latching
; power and emergency stop setup.

; When the mainboard receives an emergency stop signal, it will:
;   - Open the safety net relay using M81
;   - Run M112 to trigger a machine halt

; On boot, the safety relay will be closed either by:
;   - A user-defined M80 command closing the relay on every boot or
;   - MillenniumOS, if installed, will prompt the operator to close the relay.

; The relay that is controlled by the Safety Net configuration MUST interrupt
; the physical circuit that controls the contactor (with the emergency stop
; button in series), and NOT the circuit that sends an emergency stop signal
; to the mainboard. These MUST be 2 separate circuits.

; REMEMBER - a Software Emergency Stop is NOT a replacement for a Hardware
; Emergency Stop. Please use this IN ADDITION TO a hardware emergency stop -
; NOT AS A REPLACEMENT.

; Configure emergency stop input. You must set the C"..." parameter to
; the pin identifier where your emergency stop input is connected.
M950 J1 C"extin0"

; Configure safety net output. You must set the C"..." parameter to
; the pin identifier where your safety net relay output is connected.
; We use RRFs inbuilt ATX POWER control system, as this shows some
; feedback in Duet Web Control showing the machine is 'OFF'.
; Scylla's relay is always open on boot.
; RRF assumes that ATX POWER is on, otherwise it wouldn't be able to run,
; so we configure the power port using M81 .. S1 to force the RRF and
; physical state to match.
M81 C"relayctr" S0

; Fire trigger 2 (Safety Net emergency macro) on emergency stop input.
M581 P1 T2 S1 R0

; Check e-stop is not active before continuing startup
echo {"Checking E-Stop status..."}
M582 T2
echo {"E-Stop is not activated, continuing startup"}
