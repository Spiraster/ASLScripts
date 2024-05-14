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
    settings.Add("boss",      true, "Bosses");
    settings.Add("items",     true, "Items");
    settings.Add("keyItems",  true, "Key Items");
    settings.Add("misc",      true, "Miscellaneous");

    settings.CurrentDefaultParent = "entrances";
    settings.Add("d1Entrance",  true,  "Spirit's Grave (D1)");
    settings.Add("d2Entrance",  true,  "Wing Dungeon (D2)");
    settings.Add("d3Entrance",  true,  "Moonlit Grotto (D3)");
    settings.Add("d4Entrance",  true,  "Skull Dungeon (D4)");
    settings.Add("d5Entrance",  true,  "Crown Dungeon (D5)");
    settings.Add("d6Entrance1", false, "Mermaid's Cave (D6) [Present]");
    settings.Add("d6Entrance2", true,  "Mermaid's Cave (D6) [Past]");
    settings.Add("d7Entrance",  true,  "Jabu-Jabu's Belly (D7)");
    settings.Add("d8Entrance",  true,  "Ancient Tomb (D8)");
    settings.Add("btEntranceL", true,  "Black Tower");
    settings.Add("btEntranceU", true,  "Black Tower Turret");

    settings.CurrentDefaultParent = "essences";
    settings.Add("d1Essence", true, "Eternal Spirit (D1)");
    settings.Add("d2Essence", true, "Ancient Wood (D2)");
    settings.Add("d3Essence", true, "Echoing Howl (D3)");
    settings.Add("d4Essence", true, "Burning Flame (D4)");
    settings.Add("d5Essence", true, "Sacred Soil (D5)");
    settings.Add("d6Essence", true, "Bereft Peak (D6)");
    settings.Add("d7Essence", true, "Rolling Sea (D7)");
    settings.Add("d8Essence", true, "Falling Star (D8)");

    settings.CurrentDefaultParent = "boss";
    settings.Add("greatMoblin", false, "Defeat Great Moblin");
    settings.Add("nayru",       false, "Defeat Nayru");
    settings.Add("veranRoom",   false, "Enter Veran Fight");
    settings.Add("veran",       true,  "Defeat Veran");

    settings.CurrentDefaultParent = "items";
    settings.Add("l1Sword",       false, "Wooden Sword (L1)");
    settings.Add("l1Shield",      false, "Wooden Shield (L1)");
    settings.Add("l1SwitchHook",  false, "Switch Hook (L1)");
    settings.Add("l2SwitchHook",  false, "Long Hook (L2)");
    settings.Add("l1Bracelet",    false, "Power Bracelet (L1)");
    settings.Add("l2Bracelet",    false, "Power Glove (L2)");
    settings.Add("shovel",        false, "Shovel");
    settings.Add("bombs",         false, "Bombs");
    settings.Add("feather",       false, "Roc's Feather");
    settings.Add("seedShooter",   false, "Seed Shooter");
    settings.Add("cane",          false, "Cane of Somaria");
    settings.Add("boomerang",     false, "Boomerang");
    settings.Add("strangeFlute",  false, "Strange Flute");
    settings.Add("dimitrisFlute", false, "Dimitri's Flute");
    settings.Add("harp",          false, "Harp of Ages");
    settings.Add("tune1",         false, "Tune of Echoes");
    settings.Add("tune2",         false, "Tune of Currents");
    settings.Add("tune3",         false, "Tune of Ages");
    settings.Add("seedSatchel",   false, "Seed Satchel (+ Ember Seeds)");
    settings.Add("mysterySeeds",  false, "Mystery Seeds");
    settings.Add("scentSeeds",    false, "Scent Seeds");
    settings.Add("pegasusSeeds",  false, "Pegasus Seeds");
    settings.Add("galeSeeds",     false, "Gale Seeds");

    settings.CurrentDefaultParent = "keyItems";
    settings.Add("graveyardKey",  false, "Graveyard Key");
    settings.Add("crownKey",      false, "Crown Key");
    settings.Add("mermaidKey",    false, "Mermaid Key");
    settings.Add("oldMermaidKey", false, "Old Mermaid Key");
    settings.Add("libraryKey",    false, "Library Key");
    settings.Add("flippers",      false, "Flippers");
    settings.Add("rope",          false, "Cheval Rope");
    settings.Add("rickysGloves",  false, "Ricky's Gloves");
    settings.Add("chart",         false, "Island Chart");
    settings.Add("tuniNut",       false, "Tuni Nut (Cracked)");
    settings.Add("tuniNutFixed",  false, "Tuni Nut (Fixed)");
    settings.Add("bombFlower",    false, "Bomb Flower");
    settings.Add("brotherEmblem", false, "Brother Emblem");
    settings.Add("rockBrisket",   false, "Rock Brisket");
    settings.Add("goronVase",     false, "Goron Vase");
    settings.Add("goronade",      false, "Goronade");
    settings.Add("lavaJuice",     false, "Lava Juice");
    settings.Add("letter",        false, "Letter of Introduction");
    settings.Add("mermaidSuit",   false, "Mermaid Suit");
    settings.Add("book",          false, "Book of Seals");
    settings.Add("fairyPowder",   false, "Fairy Powder");
    settings.Add("zoraScale",     false, "Zora Scale");
    settings.Add("tokayEyeball",  false, "Tokay Eyeball");
    settings.Add("nwSlate",       false, "Slate #1 (NW)");
    settings.Add("swSlate",       false, "Slate #2 (SW)");
    settings.Add("seSlate",       false, "Slate #3 (SE)");
    settings.Add("neSlate",       false, "Slate #4 (NE)");
    settings.Add("makuSeed",      false, "Maku Seed");

    settings.CurrentDefaultParent = "misc";
    settings.Add("d2Skip",    false, "D2 Skip");
    settings.Add("shipwreck", false, "Crescent Island (Shipwreck)");
    settings.Add("d6BossKey", false, "D6 Boss Key");
    settings.Add("d8BossKey", false, "D8 Boss Key");

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
            new MemoryWatcher<short>(new DeepPointer(wramOffset, 0x0682)) { Name = "bossKeys" },
            new MemoryWatcher<long>(new DeepPointer(wramOffset,  0x069A)) { Name = "treasure0" },
            new MemoryWatcher<int>(new DeepPointer(wramOffset,   0x06A2)) { Name = "treasure8" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x06B5)) { Name = "fluteType" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x06B6)) { Name = "switchHookLevel" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x06B8)) { Name = "braceletLevel" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x06BF)) { Name = "essences" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x06C2)) { Name = "tuniNutState" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x06D3)) { Name = "global3" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0924)) { Name = "d1Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0946)) { Name = "d2Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0966)) { Name = "d3Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0991)) { Name = "d4Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x09BB)) { Name = "d5Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0A26)) { Name = "d6Entrance1" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0A44)) { Name = "d6Entrance2" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0A56)) { Name = "d7Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0AAA)) { Name = "d8Entrance" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x09F3)) { Name = "btEntranceL" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x09D0)) { Name = "btEntranceU" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x09D4)) { Name = "veranRoom" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x082E)) { Name = "d2Skip" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x08AA)) { Name = "shipwreck" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0A7C)) { Name = "nwSlate" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0A7E)) { Name = "neSlate" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0A92)) { Name = "seSlate" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0A94)) { Name = "swSlate" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x0B00)) { Name = "oam0" },
            new MemoryWatcher<short>(new DeepPointer(wramOffset, 0x0BB3)) { Name = "fileSelectMode" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset,  0x1081)) { Name = "enemy0ID" },
            new MemoryWatcher<short>(new DeepPointer(wramOffset, 0x1084)) { Name = "enemy0State" },
        };
    });

    vars.GetSplitList = (Func<Dictionary<string, bool>>)(() => {
        return new Dictionary<string, bool> {
            { "d1Entrance",  vars.Current("d1Entrance",  0x10) },
            { "d2Entrance",  vars.Current("d2Entrance",  0x10) },
            { "d3Entrance",  vars.Current("d3Entrance",  0x10) },
            { "d4Entrance",  vars.Current("d4Entrance",  0x10) },
            { "d5Entrance",  vars.Current("d5Entrance",  0x10) },
            { "d6Entrance1", vars.Current("d6Entrance1", 0x10) },
            { "d6Entrance2", vars.Current("d6Entrance2", 0x10) },
            { "d7Entrance",  vars.Current("d7Entrance",  0x10) },
            { "d8Entrance",  vars.Current("d8Entrance",  0x10) },
            { "btEntranceL", vars.Current("btEntranceL", 0x10) },
            { "btEntranceU", vars.Current("btEntranceU", 0x10) },
            { "veranRoom",   vars.Current("veranRoom",   0x10) },
            { "d2Skip",      vars.Current("d2Skip",      0x10) },
            { "shipwreck",   vars.Current("shipwreck",   0x10) },
            { "nwSlate",     vars.Current("nwSlate",     0x30) }, // 0x4B/t9,3
            { "swSlate",     vars.Current("swSlate",     0x30) },
            { "seSlate",     vars.Current("seSlate",     0x30) },
            { "neSlate",     vars.Current("neSlate",     0x30) },

            { "d1Essence", vars.GetFlag("essences", 0) },
            { "d2Essence", vars.GetFlag("essences", 1) },
            { "d3Essence", vars.GetFlag("essences", 2) },
            { "d4Essence", vars.GetFlag("essences", 3) },
            { "d5Essence", vars.GetFlag("essences", 4) },
            { "d6Essence", vars.GetFlag("essences", 5) },
            { "d7Essence", vars.GetFlag("essences", 6) },
            { "d8Essence", vars.GetFlag("essences", 7) },

            { "greatMoblin", vars.GetFlag("global3", 2) },
            { "nayru",       vars.Current("enemy0ID", 0x61) && vars.Current("enemy0State", 0x0012) }, // g3,1
            { "veran",       vars.Current("enemy0ID", 0x02) && vars.Current("enemy0State", 0x010A) },

            { "l1Shield",      vars.Treasure(0x01) }, // t0,1
            { "bombs",         vars.Treasure(0x03) }, // t0,3
            { "cane",          vars.Treasure(0x04) }, // t0,4
            { "l1Sword",       vars.Treasure(0x05) }, // t0,5
            { "boomerang",     vars.Treasure(0x06) }, // t0,6
            { "l1SwitchHook",  vars.Treasure(0x0A) }, // t1,2
            { "strangeFlute",  vars.Treasure(0x0E) }, // t1,6
            { "seedShooter",   vars.Treasure(0x0F) }, // t1,7
            { "harp",          vars.Treasure(0x11) }, // t2,1
            { "shovel",        vars.Treasure(0x15) }, // t2,5
            { "l1Bracelet",    vars.Treasure(0x16) }, // t2,6
            { "feather",       vars.Treasure(0x17) }, // t2,7
            { "seedSatchel",   vars.Treasure(0x19) }, // t3,1; ember seeds 0x20/t4,0
            { "scentSeeds",    vars.Treasure(0x21) }, // t4,1
            { "pegasusSeeds",  vars.Treasure(0x22) }, // t4,2
            { "galeSeeds",     vars.Treasure(0x23) }, // t4,3
            { "mysterySeeds",  vars.Treasure(0x24) }, // t4,4
            { "tune1",         vars.Treasure(0x25) }, // t4,5
            { "tune2",         vars.Treasure(0x26) }, // t4,6
            { "tune3",         vars.Treasure(0x27) }, // t4,7
            { "flippers",      vars.Treasure(0x2E) }, // t5,6
            { "makuSeed",      vars.Treasure(0x36) }, // t6,6
            { "graveyardKey",  vars.Treasure(0x42) }, // t8,2
            { "crownKey",      vars.Treasure(0x43) }, // t8,3
            { "mermaidKey",    vars.Treasure(0x44) }, // t8,4
            { "oldMermaidKey", vars.Treasure(0x45) }, // t8,5
            { "libraryKey",    vars.Treasure(0x46) }, // t8,6
            { "rickysGloves",  vars.Treasure(0x48) }, // t9,0
            { "bombFlower",    vars.Treasure(0x49) }, // t9,1; also 0x58/t11,0
            { "mermaidSuit",   vars.Treasure(0x4A) }, // t9,2
            { "tuniNut",       vars.Treasure(0x4C) }, // t9,4
            { "zoraScale",     vars.Treasure(0x4E) }, // t9,6
            { "tokayEyeball",  vars.Treasure(0x4F) }, // t9,7
            { "fairyPowder",   vars.Treasure(0x51) }, // t10,1
            { "rope",          vars.Treasure(0x52) }, // t10,2
            { "chart",         vars.Treasure(0x54) }, // t10,4
            { "book",          vars.Treasure(0x55) }, // t10,5
            { "letter",        vars.Treasure(0x59) }, // t11,1
            { "lavaJuice",     vars.Treasure(0x5A) }, // t11,2
            { "brotherEmblem", vars.Treasure(0x5B) }, // t11,3
            { "goronVase",     vars.Treasure(0x5C) }, // t11,4
            { "goronade",      vars.Treasure(0x5D) }, // t11,5
            { "rockBrisket",   vars.Treasure(0x5E) }, // t11,6
            { "dimitrisFlute", vars.Current("fluteType",       0x02) },
            { "tuniNutFixed",  vars.Current("tuniNutState",    0x02) },
            { "l2SwitchHook",  vars.Current("switchHookLevel", 0x02) },
            { "l2Bracelet",    vars.Current("braceletLevel",   0x02) },
            { "d6BossKey",     vars.GetFlag("bossKeys", 6) },
            { "d8BossKey",     vars.GetFlag("bossKeys", 8) },
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
    //prevent splitting on the file select screen
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
