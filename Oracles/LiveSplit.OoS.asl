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
    settings.Add("ocEntrance", true, "Onox's Castle");

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
    settings.Add("l1Sword",      false, "Wooden Sword (L1)");
    settings.Add("l2Sword",      false, "Noble Sword (L2)");
    settings.Add("l1Boomerang",  false, "Boomerang (L1)");
    settings.Add("l2Boomerang",  false, "Magic Boomerang (L2)");
    settings.Add("l1Slingshot",  false, "Slingshot (L1)");
    settings.Add("l2Slingshot",  false, "Hyper Slingshot (L2)");
    settings.Add("l1Feather",    false, "Roc's Feather (L1)");
    settings.Add("l2Feather",    false, "Roc's Cape (L2)");
    settings.Add("rod",          false, "Rod of Seasons");
    settings.Add("shovel",       false, "Shovel");
    settings.Add("bracelet",     false, "Power Bracelet");
    settings.Add("flute",        false, "Flute");
    settings.Add("magnetGloves", false, "Magnetic Gloves");
    settings.Add("seedSatchel",  false, "Seed Satchel (+ Ember Seeds)");
    settings.Add("mysterySeeds", false, "Mystery Seeds");
    settings.Add("scentSeeds",   false, "Scent Seeds");
    settings.Add("pegasusSeeds", false, "Pegasus Seeds");
    settings.Add("galeSeeds",    false, "Gale Seeds");
    
    settings.CurrentDefaultParent = "keyItems";
    settings.Add("gnarledKey",    false, "Gnarled Key");
    settings.Add("floodgateKey",  false, "Floodgate Key");
    settings.Add("dragonKey",     false, "Dragon Key");
    settings.Add("rickysGloves",  false, "Ricky's Gloves");
    settings.Add("starOre",       false, "Star Ore");
    settings.Add("ribbon",        false, "Ribbon");
    settings.Add("mastersPlaque", false, "Master's Plaque");
    settings.Add("flippers",      false, "Flippers");
    settings.Add("bananas",       false, "Spring Bananas");
    settings.Add("bombFlower",    false, "Bomb Flower");
    settings.Add("squareJewel",   false, "Square Jewel");
    settings.Add("pyramidJewel",  false, "Pyramid Jewel");
    settings.Add("crossJewel",    false, "Cross Jewel");
    settings.Add("roundJewel",   false, "Circle Jewel");
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

    vars.GetFlag = (Func<string, int, bool>)((name, shift) => {
        var flags = vars.watchers[name].Current;
        return ((flags >> shift) & 1) == 1;
    });

    vars.Treasure = (Func<int, bool>)((shift) => {
        var name = "treasure0";
        if (shift > 0x3F) {
            name = "treasure8";
            shift -= 0x40;
        }

        return vars.GetFlag(name, shift);
    });

    vars.GetWatcherList = (Func<int, MemoryWatcherList>)((wramOffset) => {
        return new MemoryWatcherList {
            new MemoryWatcher<long>(new DeepPointer(wramOffset,  0x0692)) { Name = "treasure0" },
            new MemoryWatcher<int>(new DeepPointer(wramOffset,   0x069A)) { Name = "treasure8" },
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
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0A97)) { Name = "ocEntrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0A91)) { Name = "onoxRoom" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x11A9)) { Name = "enemy1HP" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0B00)) { Name = "oam0" },
            new MemoryWatcher<short>(new DeepPointer(wramOffset, 0x0BB3)) { Name = "fileSelectMode" },
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
            { "ocEntrance", vars.Current("ocEntrance", 0x10) },
            { "onoxRoom",   vars.Current("onoxRoom",   0x10) },

            { "d1Essence", vars.GetFlag("essences", 0) },
            { "d2Essence", vars.GetFlag("essences", 1) },
            { "d3Essence", vars.GetFlag("essences", 2) },
            { "d4Essence", vars.GetFlag("essences", 3) },
            { "d5Essence", vars.GetFlag("essences", 4) },
            { "d6Essence", vars.GetFlag("essences", 5) },
            { "d7Essence", vars.GetFlag("essences", 6) },
            { "d8Essence", vars.GetFlag("essences", 7) },

            { "onox", vars.Current("onoxRoom", 0x10) && vars.Current("enemy1HP", 0x01) }, // 0x05,0x010E

            { "l1Sword",       vars.Treasure(0x05) }, // t0,5
            { "rod",           vars.Treasure(0x07) }, // t0,7
            { "magnetGloves",  vars.Treasure(0x08) }, // t1,0
            { "flute",         vars.Treasure(0x0E) }, // t1,6
            { "l1Slingshot",   vars.Treasure(0x13) }, // t2,3
            { "shovel",        vars.Treasure(0x15) }, // t2,5
            { "bracelet",      vars.Treasure(0x16) }, // t2,6
            { "l1Feather",     vars.Treasure(0x17) }, // t2,7
            { "seedSatchel",   vars.Treasure(0x19) }, // t3,1; ember seeds t4,0
            { "scentSeeds",    vars.Treasure(0x21) }, // t4,1
            { "pegasusSeeds",  vars.Treasure(0x22) }, // t4,2
            { "galeSeeds",     vars.Treasure(0x23) }, // t4,3
            { "mysterySeeds",  vars.Treasure(0x24) }, // t4,4
            { "flippers",      vars.Treasure(0x2E) }, // t5,6
            { "makuSeed",      vars.Treasure(0x36) }, // t6,6
            { "gnarledKey",    vars.Treasure(0x42) }, // t8,2
            { "floodgateKey",  vars.Treasure(0x43) }, // t8,3
            { "dragonKey",     vars.Treasure(0x44) }, // t8,4
            { "starOre",       vars.Treasure(0x45) }, // t8,5
            { "ribbon",        vars.Treasure(0x46) }, // t8,6
            { "bananas",       vars.Treasure(0x47) }, // t8,7
            { "rickysGloves",  vars.Treasure(0x48) }, // t9,0
            { "bombFlower",    vars.Treasure(0x49) }, // t9,1; also t11,0
            { "rustyBell",     vars.Treasure(0x4A) }, // t9,2
            { "roundJewel",    vars.Treasure(0x4C) }, // t9,4
            { "pyramidJewel",  vars.Treasure(0x4D) }, // t9,5
            { "squareJewel",   vars.Treasure(0x4E) }, // t9,6
            { "crossJewel",    vars.Treasure(0x4F) }, // t9,7
            { "mastersPlaque", vars.Treasure(0x54) }, // t10,4
            { "piratesBell",   vars.Current("bellState",      0x01) },
            { "l2Sword",       vars.Current("swordLevel",     0x02) },
            { "l1Boomerang",   vars.Current("boomerangLevel", 0x01) }, // [0,6]
            { "l2Boomerang",   vars.Current("boomerangLevel", 0x02) },
            { "l2Feather",     vars.Current("featherLevel",   0x02) },
            { "l2Slingshot",   vars.Current("slingshotLevel", 0x02) },
            
            { "winter", vars.GetFlag("seasons", 3) },
            { "summer", vars.GetFlag("seasons", 1) },
            { "spring", vars.GetFlag("seasons", 0) },
            { "autumn", vars.GetFlag("seasons", 2) },
        };
    });
}

init {
    vars.pastSplits = new HashSet<string>();

    if (!vars.TryFindOffsets(game, (long)modules.First().BaseAddress)) {
        throw new Exception("[Autosplitter] Emulated memory not yet initialized.");
    } else {
        refreshRate = 200/3.0;
    }
}

update {
    vars.watchers.UpdateAll(game);
}

start {
    return vars.watchers["oam0"].Current == 0x23 && vars.watchers["fileSelectMode"].Current == 0x0301;
}

split {
    // prevent splitting on the file select screen
    var fs = vars.watchers["oam0"].Current;
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

onReset {
    vars.pastSplits.Clear();
}

exit {
    refreshRate = 0.5;
}
