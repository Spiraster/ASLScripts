state("bgb") {}
state("bgb64") {}
state("gambatte") {}
state("gambatte_qt") {}
state("gambatte_qt_nonpsr") {}
state("gambatte_speedrun") {}
state("emuhawk") {}

startup {
    settings.Add("entrances", true, "Dungeon Entrances");
    settings.Add("essences",  true, "Essences");
    settings.Add("boss",      true, "Boss");
    settings.Add("items",     true, "Items");
    settings.Add("keyItems",  true, "Key Items");
    settings.Add("seasons",   true, "Seasons");

    settings.CurrentDefaultParent = "entrances";
    settings.Add("d1Entrance", true, "Gnarled Root Dungeon (D1)");
    settings.Add("d2Entrance", true, "Snake's Remains (D2)");
    settings.Add("d3Entrance", true, "Poison Moth Lair (D3)");
    settings.Add("d4Entrance", true, "Dancing Dragon Dungeon (D4)");
    settings.Add("d5Entrance", true, "Unicorn's Cave (D5)");
    settings.Add("d6Entrance", true, "Ancient Ruins (D6)");
    settings.Add("d7Entrance", true, "Explorer's Crypt (D7)");
    settings.Add("d8Entrance", true, "Sword & Shield Maze (D8)");
    settings.Add("d9Entrance", true, "Onox's Castle");

    settings.CurrentDefaultParent = "essences";
    settings.Add("d1Essence", true, "Fertile Soil (D1)");
    settings.Add("d2Essence", true, "Gift of Time (D2)");
    settings.Add("d3Essence", true, "Bright Sun (D3)");
    settings.Add("d4Essence", true, "Soothing Rain (D4)");
    settings.Add("d5Essence", true, "Nurturing Warmth (D5)");
    settings.Add("d6Essence", true, "Blowing Wind (D6)");
    settings.Add("d7Essence", true, "Seed of Life (D7)");
    settings.Add("d8Essence", true, "Changing Seasons (D8)");

    settings.CurrentDefaultParent = "boss";
    settings.Add("onoxRoom", false, "Enter Onox Fight");
    settings.Add("onox",     true,  "Defeat Onox");
    
    settings.CurrentDefaultParent = "items";
    settings.Add("l1Sword",        false, "Sword (L1)");
    settings.Add("l2Sword",        false, "Sword (L2)");
    settings.Add("l1Boomerang",    false, "Boomerang (L1)");
    settings.Add("l2Boomerang",    false, "Boomerang (L2)");
    settings.Add("l1Slingshot",    false, "Slingshot (L1)");
    settings.Add("l2Slingshot",    false, "Slingshot (L2)");
    settings.Add("l1Feather",      false, "Feather");
    settings.Add("l2Feather",      false, "Cape");
    settings.Add("rodOfSeasons",   false, "Rod of Seasons");
    settings.Add("shovel",         false, "Shovel");
    settings.Add("bracelet",       false, "Bracelet");
    settings.Add("flute",          false, "Flute");
    settings.Add("magnetGloves",   false, "Magnet Gloves");
    settings.Add("seedSatchel",    false, "Seed Satchel (+ Ember Seeds)");
    settings.Add("mysterySeeds",   false, "Mystery Seeds");
    settings.Add("scentSeeds",     false, "Scent Seeds");
    settings.Add("pegasusSeeds",   false, "Pegasus Seeds");
    settings.Add("hurricaneSeeds", false, "Hurricane Seeds");
    
    settings.CurrentDefaultParent = "keyItems";
    settings.Add("gnarledKey",    false, "Gnarled Key");
    settings.Add("floodgateKey",  false, "Floodgate Key");
    settings.Add("dragonKey",     false, "Dragon Key");
    settings.Add("rickysGloves",  false, "Ricky's Gloves");
    settings.Add("starOre",       false, "Star Ore");
    settings.Add("ribbon",        false, "Ribbon");
    settings.Add("mastersPlaque", false, "Master's Plaque");
    settings.Add("flippers",      false, "Flippers");
    settings.Add("bananas",       false, "Bananas");
    settings.Add("bombFlower",    false, "Bomb Flower");
    settings.Add("squareJewel",   false, "Square Jewel");
    settings.Add("pyramidJewel",  false, "Pyramid Jewel");
    settings.Add("crossJewel",    false, "Cross Jewel");
    settings.Add("circleJewel",   false, "Circle Jewel");
    settings.Add("rustyBell",     false, "Rusty Bell");
    settings.Add("piratesBell",   false, "Pirate's Bell");
    settings.Add("makuSeed",      false, "Maku Seed");
    
    settings.CurrentDefaultParent = "seasons";
    settings.Add("winter", false, "Winter");
    settings.Add("summer", false, "Summer");
    settings.Add("spring", false, "Spring");
    settings.Add("autumn", false, "Autumn");

    refreshRate = 0.5;

    vars.TryFindOffsets = (Func<Process, long, bool>)((proc, baseAddress) => {
        long wramOffset = 0;
        string state = proc.ProcessName.ToLower();
        if (state.Contains("gambatte")) {
            IntPtr scanOffset = vars.SigScan(proc, 0, "20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 05 00 00");
            wramOffset = (long)scanOffset - 0x10;
        } else if (state == "emuhawk") {
            IntPtr scanOffset = vars.SigScan(proc, 0, "05 00 00 00 ?? 00 00 00 00 ?? ?? 00 ?? 40 ?? 00 00 ?? ?? 00 00 00 00 00 ?? 00 00 00 00 00 00 00 00 00 00 00 ?? ?? ?? 00 ?? 00 00 00 00 00 ?? 00 ?? 00 00 00 00 00 00 00 ?? ?? ?? ?? ?? ?? 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F8 00 00 00");
            wramOffset = (long)scanOffset - 0x40;
        } else if (state == "bgb") {
            IntPtr scanOffset = vars.SigScan(proc, 12, "6D 61 69 6E 6C 6F 6F 70 83 C4 F4 A1 ?? ?? ?? ??");
            wramOffset = new DeepPointer(scanOffset, 0, 0, 0x34).Deref<int>(proc) + 0x108;
        } else if (state == "bgb64") {
            IntPtr scanOffset = vars.SigScan(proc, 20, "48 83 EC 28 48 8B 05 ?? ?? ?? ?? 48 83 38 00 74 1A 48 8B 05 ?? ?? ?? ?? 48 8B 00 80 B8 ?? ?? ?? ?? 00 74 07");
            IntPtr baseOffset = scanOffset + proc.ReadValue<int>(scanOffset) + 4;
            wramOffset = new DeepPointer(baseOffset, 0, 0x44).Deref<int>(proc) + 0x190;
        }

        if (wramOffset != 0) {
            vars.watchers = vars.GetWatcherList((int)(wramOffset - baseAddress));
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

    vars.GetBit = (Func<byte, int, bool>)((flags, shift) => {
        return ((flags >> shift) & 1) == 1;
    });

    vars.Treasure = (Func<int, int, bool>)((index, bit) => {
        var name = "treasure1";
        if (index > 7) {
            name = "treasure3";
        } else if (index > 3) {
            name = "treasure2";
        }

        var value = vars.watchers[name].Current;
        var flags = BitConverter.GetBytes(value)[index % 4];
        return vars.GetBit(flags, bit);
    });

    vars.Essence = (Func<int, bool>)((bit) => {
        var flags = vars.watchers["essences"].Current;
        return vars.GetBit(flags, bit);
    });

    vars.Season = (Func<int, bool>)((bit) => {
        var flags = vars.watchers["seasons"].Current;
        return vars.GetBit(flags, bit);
    });

    vars.GetWatcherList = (Func<int, MemoryWatcherList>)((wramOffset) => {
        return new MemoryWatcherList {
            new MemoryWatcher<int>(new DeepPointer(wramOffset,   0x0692)) { Name = "treasure1" },
            new MemoryWatcher<int>(new DeepPointer(wramOffset,   0x0696)) { Name = "treasure2" },
            new MemoryWatcher<int>(new DeepPointer(wramOffset,   0x069A)) { Name = "treasure3" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x06AC)) { Name = "swordLevel" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x06B0)) { Name = "seasons" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x06B1)) { Name = "boomerangLevel" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x06B3)) { Name = "slingshotLevel" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x06B4)) { Name = "featherLevel" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x06BB)) { Name = "essences" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x06BD)) { Name = "bellState" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x091C)) { Name = "d1Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0939)) { Name = "d2Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x094B)) { Name = "d3Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0981)) { Name = "d4Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x09A7)) { Name = "d5Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x09BA)) { Name = "d6Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0A5B)) { Name = "d7Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0A87)) { Name = "d8Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0A97)) { Name = "d9Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0A91)) { Name = "onoxRoom" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x11A9)) { Name = "onoxHP" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0B00)) { Name = "oam" },
            new MemoryWatcher<short>(new DeepPointer(wramOffset, 0x0BB3)) { Name = "fileSelectMode" },
            // new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1EFF)) { Name = "resetCheck" },
        };
    });

    vars.GetSplitList = (Func<Dictionary<string, bool>>)(() => {
        return new Dictionary<string, bool> {
            { "d1Entrance", vars.Current("d1Entrance", 0x10) },
            { "d2Entrance", vars.Current("d2Entrance", 0x10) },
            { "d3Entrance", vars.Current("d3Entrance", 0x10) },
            { "d4Entrance", vars.Current("d4Entrance", 0x10) },
            { "d5Entrance", vars.Current("d5Entrance", 0x10) },
            { "d6Entrance", vars.Current("d6Entrance", 0x10) },
            { "d7Entrance", vars.Current("d7Entrance", 0x10) },
            { "d8Entrance", vars.Current("d8Entrance", 0x10) },
            { "d9Entrance", vars.Current("d9Entrance", 0x10) },
            { "onoxRoom",   vars.Current("onoxRoom", 0x10) },

            { "d1Essence", vars.Essence(0) },
            { "d2Essence", vars.Essence(1) },
            { "d3Essence", vars.Essence(2) },
            { "d4Essence", vars.Essence(3) },
            { "d5Essence", vars.Essence(4) },
            { "d6Essence", vars.Essence(5) },
            { "d7Essence", vars.Essence(6) },
            { "d8Essence", vars.Essence(7) },
            { "onox",      vars.Current("onoxHP", 0x01) && 
                           vars.Current("onoxRoom", 0x10) },

            { "l1Sword",        vars.Treasure(0, 5) },
            { "rodOfSeasons",   vars.Treasure(0, 7) },
            { "magnetGloves",   vars.Treasure(1, 0) },
            { "flute",          vars.Treasure(1, 6) },
            { "l1Slingshot",    vars.Treasure(2, 3) },
            { "shovel",         vars.Treasure(2, 5) },
            { "bracelet",       vars.Treasure(2, 6) },
            { "l1Feather",      vars.Treasure(2, 7) },
            { "seedSatchel",    vars.Treasure(3, 1) }, // ember seeds [4,0]
            { "scentSeeds",     vars.Treasure(4, 1) },
            { "pegasusSeeds",   vars.Treasure(4, 2) },
            { "hurricaneSeeds", vars.Treasure(4, 3) },
            { "mysterySeeds",   vars.Treasure(4, 4) },
            { "flippers",       vars.Treasure(5, 6) },
            { "makuSeed",       vars.Treasure(6, 6) },
            { "gnarledKey",     vars.Treasure(8, 2) },
            { "floodgateKey",   vars.Treasure(8, 3) },
            { "dragonKey",      vars.Treasure(8, 4) },
            { "starOre",        vars.Treasure(8, 5) },
            { "ribbon",         vars.Treasure(8, 6) },
            { "bananas",        vars.Treasure(8, 7) },
            { "rickysGloves",   vars.Treasure(9, 0) },
            { "bombFlower",     vars.Treasure(9, 1) },
            { "rustyBell",      vars.Treasure(9, 2) },
            { "circleJewel",    vars.Treasure(9, 4) },
            { "pyramidJewel",   vars.Treasure(9, 5) },
            { "squareJewel",    vars.Treasure(9, 6) },
            { "crossJewel",     vars.Treasure(9, 7) },
            { "mastersPlaque",  vars.Treasure(10, 4) },
            { "piratesBell",    vars.Current("bellState", 0x01) },
            { "l2Sword",        vars.Current("swordLevel", 0x02) },
            { "l1Boomerang",    vars.Current("boomerangLevel", 0x01) }, // [0,6]
            { "l2Boomerang",    vars.Current("boomerangLevel", 0x02) },
            { "l2Feather",      vars.Current("featherLevel", 0x02) },
            { "l2Slingshot",    vars.Current("slingshotLevel", 0x02) },
            
            { "winter", vars.Season(3) },
            { "summer", vars.Season(1) },
            { "spring", vars.Season(0) },
            { "autumn", vars.Season(2) },
        };
    });
}

init {
    vars.watchers = new MemoryWatcherList();
    vars.pastSplits = new HashSet<string>();

    if (!vars.TryFindOffsets(game, (long)modules.First().BaseAddress)) {
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
    return vars.watchers["oam"].Current == 0x23 && vars.watchers["fileSelectMode"].Current == 0x0301;
}

reset {
    // return vars.watchers["resetCheck"].Current > 0;
}

split {
    // prevent splitting on the file select screen
    var fs = vars.watchers["oam"].Current;
    if (fs == 0x17 || fs == 0x23) {
        return false;
    }

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
