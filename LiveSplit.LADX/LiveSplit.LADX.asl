state("bgb") {}
state("bgb64") {}
state("gambatte") {}
state("gambatte_qt") {}
state("gambatte_qt_nonpsr") {}
state("gambatte_speedrun") {}
state("emuhawk") {}

startup {
    //-------------------------------------------------------------//
    settings.Add("entrances", true, "Dungeon Entrances");
    settings.Add("instruments", true, "Dungeon Ends (Instruments)");
    settings.Add("items", true, "Items");
    settings.Add("misc", true, "Miscellaneous");

    settings.CurrentDefaultParent = "entrances";
    settings.Add("d1Enter", true, "Tail Cave (D1)");
    settings.Add("d2Enter", true, "Bottle Grotto (D2)");
    settings.Add("d3Enter", true, "Key Cavern (D3)");
    settings.Add("d4Enter", true, "Angler's Tunnel (D4)");
    settings.Add("d5Enter", true, "Catfish's Maw (D5)");
    settings.Add("d6Enter", true, "Face Shrine (D6)");
    settings.Add("d7Enter", true, "Eagle's Tower (D7)");
    settings.Add("d8Enter", true, "Turtle Rock (D8)");
    settings.Add("d0Enter", false, "Color Dungeon (D0)");

    settings.CurrentDefaultParent = "instruments";
    settings.Add("d1End", true, "Full Moon Cello (D1)");
    settings.Add("d2End", true, "Conch Horn (D2)");
    settings.Add("d3End", true, "Sea Lily's Bell (D3)");
    settings.Add("d4End", true, "Surf Harp (D4)");
    settings.Add("d5End", true, "Wind Marimba (D5)");
    settings.Add("d6End", true, "Coral Triangle (D6)");
    settings.Add("d7End", true, "Organ of Evening Calm (D7)");
    settings.Add("d8End", true, "Thunder Drum (D8)");
    settings.Add("d0End", false, "Tunic Upgrade (D0)");
    settings.Add("eggStairs", true, "Wind Fish's Egg (stairs)");

    settings.CurrentDefaultParent = "items";
    settings.Add("tailKey", false, "Tail Key");
    settings.Add("slimeKey", false, "Slime Key");
    settings.Add("anglerKey", false, "Angler Key");
    settings.Add("faceKey", false, "Face Key");
    settings.Add("birdKey", false, "Bird Key");
    settings.Add("feather", false, "Feather");
    settings.Add("bracelet", false, "Bracelet (L1)");
    settings.Add("boots", false, "Boots");
    settings.Add("ocarina", false, "Ocarina");
    settings.Add("flippers", false, "Flippers");
    settings.Add("hookshot", false, "Hookshot");
    settings.Add("l2Shield", false, "Shield (L2)");
    settings.Add("magicRod", false, "Magic Rod");
    settings.Add("magnifyingLens", false, "Magnifying Lens");
    settings.Add("boomerang", false, "Boomerang");
    settings.Add("l1Sword", false, "Sword (L1)");
    settings.Add("l2Sword", false, "Sword (L2)");
    settings.Add("yoshi", false, "Yoshi Doll");

    settings.CurrentDefaultParent = "misc";
    settings.Add("house", false, "Leave starting house");
    settings.Add("woods", false, "Leaving the Mysterious Woods");
    settings.Add("shop", false, "Shoplifting");
    settings.Add("marin", false, "Marin");
    settings.Add("walrus", false, "Walrus");
    settings.Add("d8Exit", false, "Exit D8 to Mountaintop");
    settings.Add("song1", false, "Song #1 (Ballad of the Wind Fish)");
    settings.Add("song2", false, "Song #2 (Manbo's Mambo)");
    settings.Add("song3", false, "Song #3 (Frog's Song of Soul)");
    settings.Add("creditsWarp", false, "Credits Warp (ACE)");
    //-------------------------------------------------------------//

    refreshRate = 0.5;

    vars.TryFindOffsets = (Func<Process, int, long, bool>)((proc, memorySize, baseAddress) => {
        long romOffset = 0;
        long wramOffset = 0;
        string state = proc.ProcessName.ToLower();
        if (state.Contains("gambatte")) {
            IntPtr scanOffset = vars.SigScan(proc, 0, "20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 05 00 00");
            romOffset = (long)scanOffset - 0x18;
            wramOffset = (long)scanOffset - 0x10;
        } else if (state == "emuhawk") {
            IntPtr scanOffset = vars.SigScan(proc, 0, "05 00 00 00 ?? 00 00 00 00 ?? ?? 00 ?? 40 ?? 00 00 ?? ?? 00 00 00 00 00 ?? 00 00 00 00 00 00 00 00 00 00 00 ?? ?? ?? 00 ?? 00 00 00 00 00 ?? 00 ?? 00 00 00 00 00 00 00 ?? ?? ?? ?? ?? ?? 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F8 00 00 00");
            romOffset = (long)scanOffset - 0x50;
            wramOffset = (long)scanOffset - 0x40;
        } else if (state == "bgb") {
            IntPtr scanOffset = vars.SigScan(proc, 12, "6D 61 69 6E 6C 6F 6F 70 83 C4 F4 A1 ?? ?? ?? ??");
            var sharedOffset = new DeepPointer(scanOffset, 0, 0, 0x34).Deref<int>(proc);
            romOffset = sharedOffset + 0x10;
            wramOffset = sharedOffset + 0x108;
        } else if (state == "bgb64") {
            IntPtr scanOffset = vars.SigScan(proc, 20, "48 83 EC 28 48 8B 05 ?? ?? ?? ?? 48 83 38 00 74 1A 48 8B 05 ?? ?? ?? ?? 48 8B 00 80 B8 ?? ?? ?? ?? 00 74 07");
            IntPtr baseOffset = scanOffset + proc.ReadValue<int>(scanOffset) + 4;
            var sharedOffset = new DeepPointer(baseOffset, 0, 0x44).Deref<int>(proc);
            romOffset = sharedOffset + 0x18;
            wramOffset = sharedOffset + 0x190;
        }

        if (proc.ReadValue<int>((IntPtr)romOffset) != 0) {
            vars.watchers = vars.GetWatcherList((int)(romOffset - baseAddress), (int)(wramOffset - baseAddress));
            vars.GetSplitList(); //calling now will prevent lag on first timer start

            vars.watchers["version"].Update(proc);
            print(string.Format("[Autosplitter] Game Version: {0}", (vars.watchers["version"].Current == 0x80) ? "LADX" : "LA"));
            print("[Autosplitter] ROM Pointer: " + romOffset.ToString("X8"));
            print("[Autosplitter] WRAM Pointer: " + wramOffset.ToString("X8"));
            
            return true;
        }
        
        return false;
    });

    vars.SigScan = (Func<Process, int, string, IntPtr>)((proc, offset, signature) => {
        var target = new SigScanTarget(offset, signature);
        IntPtr result = IntPtr.Zero;
        foreach (var page in proc.MemoryPages(true)) {
            var scanner = new SignatureScanner(proc, page.BaseAddress, (int)page.RegionSize);
            if ((result = scanner.Scan(target)) != IntPtr.Zero) {
                break;
            }
        }

        return result;
    });

    vars.Current = (Func<string, int, bool>)((name, value) => {
        return vars.watchers[name].Current == value;
    });

    vars.Changed = (Func<string, int, bool>)((name, value) => {
        return vars.watchers[name].Changed && vars.watchers[name].Current == value;
    });

    vars.Instrument = (Func<int, bool>)((index) => {
        var flags = vars.watchers["dungeonFlags"].Current;
        var dungeon = BitConverter.GetBytes(flags)[index];
        return ((dungeon >> 1) & 1) == 1;
    });

    vars.GetWatcherList = (Func<int, int, MemoryWatcherList>)((romOffset, wramOffset) => {
        return new MemoryWatcherList {
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x03B0)) { Name = "objectState" },
            new MemoryWatcher<long>(new DeepPointer(wramOffset, 0x1B65)) { Name = "dungeonFlags" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1B54)) { Name = "overworldScreen" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1BAE)) { Name = "submapScreen" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1B60)) { Name = "submapIndex" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x13CA)) { Name = "music" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x13C8)) { Name = "sound" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1B11)) { Name = "tailKey" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x191D)) { Name = "featherRoom" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1920)) { Name = "braceletRoom" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1946)) { Name = "bootsRoom" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1ABE)) { Name = "ocarinaRoom" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1B0C)) { Name = "flippers" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1B44)) { Name = "shieldLevel" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1A37)) { Name = "magicRodRoom" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1B0E)) { Name = "tradingItem" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1B6E)) { Name = "shopThefts" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1B73)) { Name = "marin" },

            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xEFF)) { Name = "resetCheck" },
            new MemoryWatcher<short>(new DeepPointer(wramOffset, 0x1B95)) { Name = "gameState" },
            new MemoryWatcher<byte>(new DeepPointer(romOffset, 0x143)) { Name = "version" },
        };
    });

    vars.GetSplitList = (Func<Dictionary<string, bool>>)(() => {
        var splits = new Dictionary<string, bool> {
            { "d1Enter", vars.Current("submapScreen", 0x3B) && vars.Current("overworldScreen", 0xD3) },
            { "d2Enter", vars.Current("submapIndex", 0x01) && vars.Current("submapScreen", 0x3A) },
            { "d3Enter", vars.Current("submapIndex", 0x02) && vars.Current("submapScreen", 0x39) },
            { "d4Enter", vars.Current("submapIndex", 0x03) && vars.Current("submapScreen", 0x3B) },
            { "d5Enter", vars.Current("submapIndex", 0x04) && vars.Current("submapScreen", 0x3F) },
            { "d6Enter", vars.Current("submapIndex", 0x05) && (vars.Current("submapScreen", 0x3B) || vars.Current("submapScreen", 0x08)) },
            { "d7Enter", vars.Current("submapIndex", 0x06) && vars.Current("submapScreen", 0x39) },
            { "d8Enter", vars.Current("submapIndex", 0x07) && (vars.Current("submapScreen", 0x3B) || vars.Current("submapScreen", 0x12) || vars.Current("submapScreen", 0x15)) },
            { "d0Enter", vars.Current("submapIndex", 0xFF) && vars.Current("submapScreen", 0x3A) },
            { "d0End", vars.Current("sound", 0x01) && vars.Current("music", 0x0C) && vars.Current("overworldScreen", 0x77) },
            { "eggStairs", vars.Current("gameState", 0x0201) },
            
            { "tailKey", vars.Changed("tailKey", 0x01) && vars.Current("overworldScreen", 0x41) },
            { "slimeKey", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0xC6) },
            { "anglerKey", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0xCE) },
            { "faceKey", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0xAC) },
            { "birdKey", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0x0A) },
            { "feather", vars.Changed("featherRoom", 0x98) && vars.Current("submapScreen", 0x20) },
            { "bracelet", vars.Changed("braceletRoom", 0x91) && vars.Current("submapIndex", 0x01) },
            { "boots", vars.Changed("bootsRoom", 0x9B) && vars.Current("submapIndex", 0x02) },
            { "ocarina", vars.Changed("ocarinaRoom", 0x90) && vars.Current("submapIndex", 0x13) },
            { "flippers", vars.Changed("flippers", 0x01) && vars.Current("submapIndex", 0x03) },
            { "hookshot", vars.Current("music", 0x10) && vars.Current("submapIndex", 0x04) },
            { "l2Shield", vars.Changed("shieldLevel", 0x02) && vars.Current("submapIndex", 0x06) },
            { "magicRod", vars.Changed("magicRodRoom", 0x98) && vars.Current("submapIndex", 0x07) },
            { "magnifyingLens", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0xE9) },
            { "boomerang", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0xF4) },
            { "l1Sword", vars.Current("music", 0x0F) && vars.Current("overworldScreen", 0xF2) },
            { "l2Sword", vars.Current("music", 0x0F) && vars.Current("overworldScreen", 0x8A) },
            { "yoshi", vars.Changed("tradingItem", 0x01) && vars.Current("overworldScreen", 0xB3) },

            { "house", vars.Current("overworldScreen", 0xA2) },
            { "woods", vars.Current("overworldScreen", 0x90) && vars.Current("tailKey", 0x01) },
            { "shop", vars.Changed("shopThefts", 0x02) && vars.Current("overworldScreen", 0x93) },
            { "marin", vars.Changed("marin", 0x01) && vars.Current("overworldScreen", 0xF5) },
            { "walrus", vars.Current("objectState", 0x05) && vars.Current("overworldScreen", 0xFD) },
            { "d8Exit", vars.Current("submapScreen", 0x12) && vars.Current("overworldScreen", 0x00) },
            { "song1", vars.Current("music", 0x10) && (vars.Current("overworldScreen", 0xDC) || vars.Current("overworldScreen", 0x92)) },
            { "song2", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0x2A) },
            { "song3", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0xD4) },
            { "creditsWarp", vars.Current("gameState", 0x0101) },
        };

        if (vars.watchers["version"].Current == 0) { //LA
            splits.Add("d1End", vars.Current("music", 0x05) && vars.Instrument(0));
            splits.Add("d2End", vars.Current("music", 0x05) && vars.Instrument(1));
            splits.Add("d3End", vars.Current("music", 0x05) && vars.Instrument(2));
            splits.Add("d4End", vars.Current("music", 0x05) && vars.Instrument(3));
            splits.Add("d5End", vars.Current("music", 0x05) && vars.Instrument(4));
            splits.Add("d6End", vars.Current("music", 0x05) && vars.Instrument(5));
            splits.Add("d7End", vars.Current("music", 0x06) && vars.Instrument(6));
            splits.Add("d8End", vars.Current("music", 0x06) && vars.Instrument(7));
        } else if (vars.watchers["version"].Current == 0x80) { //LADX
            splits.Add("d1End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x00));
            splits.Add("d2End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x01));
            splits.Add("d3End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x02));
            splits.Add("d4End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x03));
            splits.Add("d5End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x04));
            splits.Add("d6End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x05));
            splits.Add("d7End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x06));
            splits.Add("d8End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x07));
        }

        return splits;
    });
}

init {
    vars.watchers = new MemoryWatcherList();
    vars.pastSplits = new HashSet<string>();

    if (!vars.TryFindOffsets(game, modules.First().ModuleMemorySize, (long)modules.First().BaseAddress)) {
        throw new Exception("[Autosplitter] Emulated memory not yet initialized.");
    } else {
        refreshRate = 200/3.0;
    }
}

update {
    if (timer.CurrentPhase == TimerPhase.NotRunning && vars.pastSplits.Count > 0) {
        vars.pastSplits.Clear();
    }
    
    vars.watchers.UpdateAll(game);
}

start {
    return vars.watchers["gameState"].Current == 0x0902;
}

reset {
    return vars.watchers["resetCheck"].Current > 0;
}

split {
    var splits = vars.GetSplitList();

    foreach (var split in splits) {
        if (settings[split.Key] && split.Value && !vars.pastSplits.Contains(split.Key)) {
            vars.pastSplits.Add(split.Key);
            print("[Autosplitter] Split: " + split.Key);
            return true;
        }
    }
}

exit {
    refreshRate = 0.5;
}