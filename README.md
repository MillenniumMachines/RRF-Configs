# Millennium Machines RepRapFirmware Configurations

## Intro

RepRapFirmware provides the simplest approach to powerful machining functionality in a package that still feels familiar to those of us with a 3D printing background. To get up and running with your Millennium Machine as quickly as possible, we provide known-good RRF configurations for endorsed setups, including for those produced by kit manufacturers and our suggested BOM electronics.

## Usage

These configurations are designed to be zero-touch to start with. Simply download the correct Zip file from the Releases page for your setup, extract it to the root of your freshly FAT-formatted SD card and place it into the machine.

On first boot, the machine will flash the included version of RepRapFirmware, update the WiFi device and then configure a WiFi Access Point, named after the machine (e.g. `Milo` for a Milo Desktop CNC Mill). This process will take up to 5 minutes, and it will not be possible to tell if it has worked or not until the WiFi network has appeared.

The password for the WiFi network is always `millenniummachines`, and Duet Web Control will be available at [http://192.168.40.1](http://192.168.40.1). Both of these settings can be changed via the configuration once you have connected to the access point for the first time.

You can also configure the machine to connect to your own home WiFi, although this is outside the scope of our documentation - please read [here](https://teamgloomy.github.io/fly_cdyv3_connected_wifi.html#sending-your-wifi-credentials) for an example - this may be different depending on your mainboard and WiFi chip.

## Notes

The releases for these configurations bundle firmware binaries from both [TeamGloomy](https://github.com/gloomyandy/RepRapFirmware) and [Duet3D](https://github.com/duet3d/RepRapFirmware) to make the install process seamless.

We are eternally grateful for their work on RepRapFirmware, the support they provide, and the time spent assisting in the development of these configurations.
