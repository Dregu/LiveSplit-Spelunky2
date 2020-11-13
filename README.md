# LiveSplit-Spelunky2
LiveSplit Autosplitter for Spelunky 2

## Features

Supports tracking ingame time, splitting on level changes, world changes, ending cutscenes, terra encounters, load time removal for All Shortcuts + Tiamat and other realtime categories. **Remember to set LiveSplit to Compare Agains -> Game Time** and check the settings for the right category options.

### Level Pace (for Celeritas etc)
The autosplitter supports tracking the average time per level needed to PB. The amount of levels left is calculated from the ending you selected in the settings.

You can set it up by extracting the [ASLVarViewer](https://github.com/hawkerm/LiveSplit.ASLVarViewer/releases/latest) component to your LiveSplit\Components directory and setting it up like so: ![ASLVarViewer settings](https://cdn.discordapp.com/attachments/756241793753809106/776845172373192754/unknown.png)

The level pace doesn't need actual splits for every level! Here's an example Cosmic Ocean setup with splits on world transitions only: ![CO setup](https://cdn.discordapp.com/attachments/756241793753809106/776849296162422804/unknown.png)
