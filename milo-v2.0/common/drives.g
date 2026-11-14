; drives.g - Configures motor driver settings

; Physical drive 0 (X) goes forwards using default driver timings
M569 P0 S1

; Physical drive 1 (Y) goes forwards using default driver timings
M569 P1 S1

; Physical drive 2 (Z) goes forwards using default driver timings.
; On Milo/Miley 2.0 the Z drive turns the other way from 1.5 (S1, not S0).
M569 P2 S1

; Set non-standard sense resistors for the Scylla's integrated TMC2160 drivers
M569.9 P0.0 R0.05
M569.9 P0.1 R0.05
M569.9 P0.2 R0.05
M569.9 P0.3 R0.05

; Set drive mappings to relevant axes
M584 X0 Y1 Z2

; Configure microstepping, no interpolation.
; This is about as high as we can go without losing
; significant amounts of torque.
; This puts our positional accuracy around the 0.02-0.04mm range.
M350 X32 Y32 Z32 I0

; Milo lead-screws are 8mm pitch, with 1.8 degree motors or 200 steps per revolution
; On 2.0 the Z motor drives the lead screw directly through a coupler
; (1.5 has a 2:1 belt reduction), so Z uses the same steps per mm as X and Y.

; Set steps per mm.
M92 X800 Y800 Z800

; Set motor currents (mA)
; 2800mA matches the 2.8A NEMA23 motors in the Milo/Miley 2.0 BOM.
; RRF's M906 value is the peak (not RMS) current.
M906 X2800 Y2800 Z2800

; Set standstill current to 10% of the motor current
M917 X10 Y10 Z10

; Enable motor idle current reduction after 30 seconds
M84 S30