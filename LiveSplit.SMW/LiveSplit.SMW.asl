state("snes9x") {}
state("snes9x-x64") {}
state("bsnes") {}
state("higan") {}
state("emuhawk") {}

startup {
    settings.Add("levels", true, "Normal Levels");
    settings.SetToolTip("levels", "Split on crossing goal tapes and activating keyholes");
    settings.Add("bosses", true, "Boss Levels");
    settings.SetToolTip("bosses", "Split on boss fanfare");
    settings.Add("switchPalaces", false, "Switch Palaces");
    settings.SetToolTip("switchPalaces", "Split on completing a switch palace");
    settings.Add("levelDoorPipe", false, "Level Room Transitions");
    settings.SetToolTip("levelDoorPipe", "Split on door and pipe transitions within standard levels and switch palaces");
    settings.Add("castleDoorPipe", false, "Castle/GH Room Transitions");
    settings.SetToolTip("castleDoorPipe", "Split on door and pipe transitions within ghost houses and castles");
    settings.Add("bowserPhase", false, "Bowser Phase Transition");
    settings.SetToolTip("bowserPhase", "Split on the transition between Bowser's phases (not tested on Cloud runs)");
}

init {
    var states = new Dictionary<int, long> {
        { 9646080, 0x97EE04 },      // Snes9x-rr 1.60
        { 13565952, 0x140925118 },  // Snes9x-rr 1.60 (x64)
        { 9027584, 0x94DB54 },      // Snes9x 1.60
        { 12836864, 0x1408D8BE8 },  // Snes9x 1.60 (x64)
        { 16019456, 0x94D144 },     // higan v106
        { 15360000, 0x8AB144 },     // higan v106.112
        { 10096640, 0x72BECC },     // bsnes v107
        { 10338304, 0x762F2C },     // bsnes v107.1
        { 47230976, 0x765F2C },     // bsnes v107.2/107.3
        { 131543040, 0xA9BD5C },    // bsnes v110
        { 51924992, 0xA9DD5C },     // bsnes v111
        { 52056064, 0xAAED7C },     // bsnes v112
        { 7061504, 0x36F11500240 }, // BizHawk 2.3
        { 7249920, 0x36F11500240 }, // BizHawk 2.3.1
        { 6938624, 0x36F11500240 }, // BizHawk 2.3.2
    };

    long memoryOffset;
    if (states.TryGetValue(modules.First().ModuleMemorySize, out memoryOffset)) {
        if (memory.ProcessName.ToLower().Contains("snes9x")) {
            memoryOffset = memory.ReadValue<int>((IntPtr)memoryOffset);
        }
    }

    if (memoryOffset == 0) {
        throw new Exception("Memory not yet initialized.");
    }

    vars.watchers = new MemoryWatcherList {
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1ED2) { Name = "fileSelect" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x906) { Name = "fanfare" },
        new MemoryWatcher<short>((IntPtr)memoryOffset + 0x1434) { Name = "keyholeTimer" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f28) { Name = "yellowSwitch" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f27) { Name = "greenSwitch" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f29) { Name = "blueSwitch" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f2a) { Name = "redSwitch" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x141A) { Name = "roomCounter" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1B9B) { Name = "yoshiBanned" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x13C6) { Name = "bossDefeat" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1429) { Name = "bowserPalette" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x190D) { Name = "peach" },
    };
}

update {
    vars.watchers.UpdateAll(game);
}

start {
    return vars.watchers["fileSelect"].Old == 0 && vars.watchers["fileSelect"].Current == 1;
}

reset {
    return vars.watchers["fileSelect"].Old != 0 && vars.watchers["fileSelect"].Current == 0;
}

split {
    var goalExit = settings["levels"] && vars.watchers["fanfare"].Old == 0 && vars.watchers["fanfare"].Current == 1 && vars.watchers["bossDefeat"].Current == 0;
    var keyExit = settings["levels"] && vars.watchers["keyholeTimer"].Old == 0 && vars.watchers["keyholeTimer"].Current == 0x0030;
    
    var yellowPalace = settings["switchPalaces"] && vars.watchers["yellowSwitch"].Old == 0 && vars.watchers["yellowSwitch"].Current == 1;
    var greenPalace = settings["switchPalaces"] && vars.watchers["greenSwitch"].Old == 0 && vars.watchers["greenSwitch"].Current == 1;
    var bluePalace = settings["switchPalaces"] && vars.watchers["blueSwitch"].Old == 0 && vars.watchers["blueSwitch"].Current == 1;
    var redPalace = settings["switchPalaces"] && vars.watchers["redSwitch"].Old == 0 && vars.watchers["redSwitch"].Current == 1;
    var switchPalaceExit = yellowPalace || greenPalace || bluePalace || redPalace;

    var levelDoorPipe = settings["levelDoorPipe"] && (vars.watchers["roomCounter"].Old + 1) == vars.watchers["roomCounter"].Current && vars.watchers["yoshiBanned"].Current == 0;
    var castleDoorPipe = settings["castleDoorPipe"] && (vars.watchers["roomCounter"].Old + 1) == vars.watchers["roomCounter"].Current && vars.watchers["yoshiBanned"].Current == 1;
    
    var bossExit = settings["bosses"] && vars.watchers["fanfare"].Old == 0 && vars.watchers["fanfare"].Current == 1 && vars.watchers["bossDefeat"].Current == 1;
    var bowserPhase = settings["bowserPhase"] && vars.watchers["bowserPalette"].Old == 4 && vars.watchers["bowserPalette"].Current == 7;
    var bowserDefeated = settings["bosses"] && vars.watchers["peach"].Old == 0 && vars.watchers["peach"].Current == 1;

    return goalExit || keyExit || switchPalaceExit || levelDoorPipe || castleDoorPipe || bossExit || bowserPhase || bowserDefeated;
}
