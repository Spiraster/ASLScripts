# LiveSplit.LADX
This is a [LiveSplit](http://livesplit.github.io) [ASL](https://github.com/LiveSplit/LiveSplit/blob/master/Documentation/Auto-Splitters.md) script for **The Legend of Zelda: Link's Awakening** (GB) and **The Legend of Zelda: Link's Awakening DX** (GBC) on emulator.

### Supported emulators:
- BGB 1.5.1+
- gambatte-speedrun r600+

## Features
- Automatically start the timer when you select a file
- Automatically reset the timer when you hard reset the emulator
- Automatically split for certain events (chosen in the settings)

## Installation
- Go to "Edit Splits..." in LiveSplit
- Enter the name of the game in "Game Name"
    - This must be entered correctly for LiveSplit to know which script to load
- Click the "Activate" button to download and enable the autosplitter script
    - If you ever want to stop using the autosplitter altogether, just click "Deactivate"

## Set-up
- Go to "Edit Splits..." in LiveSplit
- Click "Settings" to configure the autosplitter
    - **Note:** If for some reason LiveSplit does not automatically load the script, click "Browse...", navigate to "\LiveSplit\Components\\" and select the appropriate script.

Here you can enable/disable the options for auto start, auto reset, and auto splitting. If auto splitting is enabled, then you can select the events for which you want the autosplitter to split below under "Advanced".

## Different Split Timings (for Dungeon End Splits)
If you are playing LADX, the autosplitter will split upon touching the instrument of a given dungeon.

If you are playing LA, the autosplitter will instead split upon leaving the dungeon after obtaining the instrument. This is to account for the use of ICS (Instrument Cutscene Skip).

## Contact
If you encounter any issues or have any feature requests, please let me know! :)
- [Spiraster](http://twitch.tv/spiraster)