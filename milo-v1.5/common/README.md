# Milo V1.5 - Common Configuration

## Intro

This directory provides non-machine-specific configuration for RepRapFirmware to run a Millennium Machines Milo V1.5. The contents of this directory are included as a base configuration for each machine specific one, so any files here will be superceded by a file with the same name in a machine-specific directory.

Additionally, any files with the ".example" suffix will be included in the machine configuration, but if the machine-specific configuration includes the same filename _without_ the ".example" suffix then the example file will be removed.

## Notes

Do not use these files directly. Find a zip release for your machine and use that instead, this config is _not_ complete when used on its' own and must be supplemented with machine specific configuration.
