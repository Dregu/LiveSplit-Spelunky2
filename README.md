# LiveSplit-Spelunky2
LiveSplit Autosplitter for Spelunky 2. This is automatically loaded by LiveSplit if you set your game to Spelunky 2.

## Features

Supports tracking ingame time, rta time, splitting on level changes, world changes, ending cutscenes, terra encounters, character unlocks and 100% journal. **Remember to check the settings in split editor for the right category options. LiveSplit may have a small heart attack to find the memory addresses when you launch the game. This is fine.**

You can also use the autosplitter to feed the [journal tracker](https://github.com/Dregu/s2tracker) if you enable it in the options.

## Game data

Data structure provided by BlitWorks to help with autosplitter and statistics stuff.

```cpp
struct AutoSplitter {
    uint64_t magic = 5499811404473258564;
    uint64_t uniq = 0;
    uint32 counter;
    byte screen;
    byte loading;
    byte trans;
    bool ingame;
    bool playing;
    bool playing2;
    byte pause;
    bool pause2;
    uint32 igt;
    byte  world;
    byte  level;
    byte  door;
    uint32 characters;
    uint32 unlockedCharacterCount;
    byte  shortcuts;
    uint32 tries;
    uint32 deaths;
    uint32 normalWins;
    uint32 hardWins;
    uint32 specialWins;
    uint64 averageScore;
    uint32 topScore;
    uint64 averageTime;
    uint32 bestTime;
    uint8 bestWorld;
    uint8 bestLevel;
    uint64 currentScore;
    bool udjatEyeAvailable;
    bool seededRun;
    struct {
        bool used;
        uint8 life;
        uint8 numBombs;
        uint8 numRopes;
        bool hasAnkh;
        bool hasKapala;
        bool isPoisoned;
        bool isCursed;
        uint8 reserved[128];
    } player[MAX_PLAYERS];
};
```
