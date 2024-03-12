# Milo V1.5 - Reference Build with Fly CDY-v3

## Intro

Provided here is a known-good configuration for the hardware specified by the Millennium Machines team for a standard build of the Milo v1.5. This is `X=0 to 335mm`, `Y=0 to 208mm` and `Z=0 to -120mm` machine with the speed limits set appropriately for a Z column using 3D printed joiner parts.

To use, follow the instructions in the main [README.md](../../README.md) file.

## Notes

There is no toolsetter or touch probe automatically enabled in this configuration because they are not part of the standard Milo v1.5 build. If you want to use these, you will need to edit the `touchprobe.g` and `toolsetter.g` files to enable them on the right pins.

If you are using a machine with FMJ's, you can likely increase the speed limits in the `speed.g` file significantly.

When using FMJ and increasing the Z clearance of the machine, the length of the Z rails does not change - there is still 120mm of movement - however with a standard clearance machine, it will be possible to move the nose of the spindle below the level of the table.

You should be aware of this when using the machine.
