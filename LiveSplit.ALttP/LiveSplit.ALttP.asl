state("snes9x") {}
state("snes9x-x64") {}
state("bsnes") {}
state("higan") {}
state("emuhawk") {}

startup {
    settings.Add("escape", true, "Escape");
    settings.Add("pendants", true, "Pendants (sword up)");
    settings.Add("masterSword", false, "Master Sword");
    settings.Add("agaEntry", true, "Agahnim 1 room entry");
    settings.Add("agahnim1", true, "Agahnim 1 (sword up)");
    settings.Add("crystals", true, "Crystals (sword up)");
    settings.Add("agahnim2", true, "Agahnim 2");
    settings.Add("end", true, "Enter Triforce Room");
}

init {
    var states = new Dictionary<int, long> {
        { 9646080,   0x97EE04 },      // Snes9x-rr 1.60
        { 13565952,  0x140925118 },   // Snes9x-rr 1.60 (x64)
        { 9027584,   0x94DB54 },      // Snes9x 1.60
        { 12836864,  0x1408D8BE8 },   // Snes9x 1.60 (x64)
        { 10399744,  0x9B74D0 },      // Snes9x 1.62.3
        { 15474688,  0x140A62390 },   // Snes9x 1.62.3 (x64)
        { 11124736,  0xA63DF0 },      // Snes9x 1.63
        { 16994304,  0x140BC1CA0 },   // Snes9x 1.63 (x64)
        { 16019456,  0x94D144 },      // higan v106
        { 15360000,  0x8AB144 },      // higan v106.112
        { 10096640,  0x72BECC },      // bsnes v107
        { 10338304,  0x762F2C },      // bsnes v107.1
        { 47230976,  0x765F2C },      // bsnes v107.2/107.3
        { 131543040, 0xA9BD5C },      // bsnes v110
        { 51924992,  0xA9DD5C },      // bsnes v111
        { 52056064,  0xAAED7C },      // bsnes v112
        { 52477952,  0xB16D7C },      // bsnes v115
        { 7061504,   0x36F11500240 }, // BizHawk 2.3.0
        { 7249920,   0x36F11500240 }, // BizHawk 2.3.1
        { 6938624,   0x36F11500240 }, // BizHawk 2.3.2
        { 4538368,   0x36F05F94040 }, // BizHawk 2.6.0
    };

    long memoryOffset;
    if (states.TryGetValue(modules.First().ModuleMemorySize, out memoryOffset)) {
        var procName = memory.ProcessName.ToLower();
        if (procName.Contains("snes9x")) {
            if (procName.Contains("x64")) {
                memoryOffset = memory.ReadValue<long>((IntPtr)memoryOffset);
            } else {
                memoryOffset = memory.ReadValue<int>((IntPtr)memoryOffset);
            }
        }
    }

    if (memoryOffset == 0) {
        throw new Exception("Memory not yet initialized.");
    } else {
        print("[Autosplitter] Memory address: " + memoryOffset.ToString("X8"));
    }

    vars.watchers = new MemoryWatcherList {
        new MemoryWatcher<ushort>((IntPtr)memoryOffset + 0x221) { Name = "fileSelect" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x354) { Name = "linkState" },
        new MemoryWatcher<short>((IntPtr)memoryOffset + 0x0A0) { Name = "mapTile" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x2D8) { Name = "itemValue" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0xAA4) { Name = "world" },
        new MemoryWatcher<short>((IntPtr)memoryOffset + 0xFC4) { Name = "yPos" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x130) { Name = "bossMusic" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x418) { Name = "end" },
    };

    vars.lastItem = 0;
}

update {
    vars.watchers.UpdateAll(game);

    if (vars.watchers["itemValue"].Changed && vars.watchers["itemValue"].Current != 0) {
        vars.lastItem = vars.watchers["itemValue"].Current;
    }
}

start {
    return vars.watchers["fileSelect"].Old == 0 && vars.watchers["fileSelect"].Current == 0xFFFF;
}

reset {
    return vars.watchers["fileSelect"].Old == 0xFFFF && vars.watchers["fileSelect"].Current != 0xFFFF;
}

split {
    var swordUp = vars.watchers["linkState"].Changed && vars.watchers["linkState"].Current == 0x24;

    var escape = settings["escape"] && vars.watchers["yPos"].Current > vars.watchers["yPos"].Old && vars.watchers["yPos"].Current == 0x0218 && vars.watchers["mapTile"].Current == 0x0012; //old.yPos == 0x01 && current.yPos == 0x02 && current.world == 0x0A && current.mapTile == 0x36;
    var pendant = settings["pendants"] && swordUp && vars.watchers["world"].Current == 0x0A && (vars.lastItem == 0x37 || vars.lastItem == 0x39 || vars.lastItem == 0x38);
    var crystal = settings["crystals"] && swordUp && vars.watchers["world"].Current == 0x0A && vars.lastItem == 0x20;
    var masterSword = settings["masterSword"] && vars.watchers["linkState"].Changed && vars.watchers["linkState"].Current == 0x17 && vars.watchers["world"].Current == 0x01;
    var agaEntry = settings["agaEntry"] && vars.watchers["bossMusic"].Old != 0x15 && vars.watchers["bossMusic"].Current == 0x15 && vars.watchers["mapTile"].Current == 0x0020;
    var agahnim1 = settings["agahnim1"] && swordUp && vars.watchers["mapTile"].Current == 0x0020;
    var agahnim2 = settings["agahnim2"] && vars.watchers["linkState"].Old == 0x1D && vars.watchers["linkState"].Current == 0 && vars.watchers["mapTile"].Current == 0x000D;
    var end = settings["end"] && vars.watchers["end"].Old == 0 && vars.watchers["end"].Current == 1 && vars.watchers["mapTile"].Current == 0;

    return escape || pendant || crystal || masterSword || agaEntry || agahnim1 || agahnim2 || end;
}
