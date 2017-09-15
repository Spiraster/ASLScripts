state("bgb") {}
state("gambatte") {}
state("gambatte_qt") {}
state("gambatte_qt_win32-r571") {}

startup
{
    //-------------------------------------------------------------//
    settings.Add("entrances", true, "Dungeon Entrance Splits");
    settings.Add("instruments", true, "Dungeon End Splits (Instruments)");
    settings.Add("items", true, "Item Splits");
    settings.Add("misc", true, "Miscellaneous Splits");

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
    settings.Add("tailKey", true, "Tail Key");
    settings.Add("anglerKey", false, "Angler Key");
    settings.Add("birdKey", true, "Bird Key");
    settings.Add("feather", false, "Feather");
    settings.Add("bracelet", false, "Bracelet (L1)");
    settings.Add("boots", false, "Boots");
    settings.Add("ocarina", false, "Ocarina");
    settings.Add("flippers", false, "Flippers");
    settings.Add("l2Shield", false, "Shield (L2)");
    settings.Add("magicRod", false, "Magic Rod");
    settings.Add("magnifyingLens", false, "Magnifying Lens");
    settings.Add("l1Sword", false, "Sword (L1)");
    settings.Add("l2Sword", false, "Sword (L2)");

    settings.CurrentDefaultParent = "misc";
    settings.Add("woods", false, "Leaving the Mysterious Woods");
    settings.Add("shop", false, "Shop Stealing");
    settings.Add("marin", false, "Marin");
    settings.Add("d8Exit", false, "Exit D8 to Mountaintop");
    settings.Add("song1", false, "Ballad of the Wind Fish (Song 1)");
    settings.Add("song2", false, "Manbo's Mambo (Song 2)");
    settings.Add("song3", false, "Frog's Song of Soul (Song 3)");
    settings.Add("creditsWarp", false, "Credits Warp (ACE)");
    //-------------------------------------------------------------//

    vars.stopwatch = new Stopwatch();

    vars.wramTarget_bgb = new SigScanTarget(0, "?? ?? ?? ?? 34 00 00 00 12 00 00 00 01 00 00 00 03 00 00 00 32 78 32");
    vars.wramTarget_gambatte = new SigScanTarget(0, "05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ?? ?? ?? ?? ?? ?? ?? ?? F8 00 00 00");
    vars.romTarget = new SigScanTarget(0, "BB B9 33 3E 5A 45 4C 44 41");

    timer.OnStart += (s, e) =>
    {
        vars.splits = vars.GetSplitList(vars.cgbFlag);
    };

    vars.FindWRAM = (Func<Process, IntPtr>)((proc) => 
    {
        print("[Autosplitter] Scanning memory for WRAM");

        var bgbPtr = IntPtr.Zero;
        var gambattePtr = IntPtr.Zero;

        foreach (var page in proc.MemoryPages())
        {
            var scanner = new SignatureScanner(proc, page.BaseAddress, (int)page.RegionSize);

            if (bgbPtr == IntPtr.Zero && gambattePtr == IntPtr.Zero)
            {
                bgbPtr = scanner.Scan(vars.wramTarget_bgb);
                gambattePtr = scanner.Scan(vars.wramTarget_gambatte);
            }
            else
                break;
        }

        if (bgbPtr != IntPtr.Zero)
            return (IntPtr)proc.ReadValue<int>(bgbPtr);
        else if (gambattePtr != IntPtr.Zero)
            return (IntPtr)proc.ReadValue<int>(gambattePtr - 0x20);
        else
            return IntPtr.Zero;
    });

    vars.FindROM = (Func<Process, IntPtr>)((proc) =>
    {
        print("[Autosplitter] Scanning memory for ROM");

        var ptr = IntPtr.Zero;

        foreach (var page in proc.MemoryPages())
        {
            var scanner = new SignatureScanner(proc, page.BaseAddress, (int)page.RegionSize);

            if (ptr == IntPtr.Zero)
                ptr = scanner.Scan(vars.romTarget);
            else
                break;
        }

        if (ptr != IntPtr.Zero)
            return ptr - 0x130;
        else
            return IntPtr.Zero;
    });

    vars.GetWatcherList = (Func<MemoryWatcherList>)(() =>
    {
        return new MemoryWatcherList
        {
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1917) { Name = "d1EntranceRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1936) { Name = "d2EntranceRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1952) { Name = "d3EntranceRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x197A) { Name = "d4EntranceRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x19A1) { Name = "d5EntranceRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x19D4) { Name = "d6EntranceRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1A0E) { Name = "d7EntranceRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1A5D) { Name = "d8EntranceRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1DF2) { Name = "d0EntranceRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1902) { Name = "d1InstrumentRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x192A) { Name = "d2InstrumentRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1959) { Name = "d3InstrumentRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1962) { Name = "d4InstrumentRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1982) { Name = "d5InstrumentRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x19B5) { Name = "d6InstrumentRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1A2C) { Name = "d7InstrumentRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1A30) { Name = "d8InstrumentRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B65) { Name = "d1Instrument" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B66) { Name = "d2Instrument" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B67) { Name = "d3Instrument" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B68) { Name = "d4Instrument" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B69) { Name = "d5Instrument" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B6A) { Name = "d6Instrument" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B6B) { Name = "d7Instrument" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B6C) { Name = "d8Instrument" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1800) { Name = "d8Mountaintop" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B54) { Name = "overworldTile" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1BAE) { Name = "dungeonTile" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x13CA) { Name = "music" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x13CB) { Name = "music2" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x13C8) { Name = "sound" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B11) { Name = "tailKey" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x191D) { Name = "featherRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1920) { Name = "braceletRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1946) { Name = "bootsRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1ABE) { Name = "ocarinaRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B0C) { Name = "flippers" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1A1A) { Name = "l2ShieldRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1A37) { Name = "magicRodRoom" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B73) { Name = "marin" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B6E) { Name = "shopThefts" },

            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B0F) { Name = "seashells" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B5B) { Name = "hearts" },
            new MemoryWatcher<short>((IntPtr)vars.wramAddr + 0x1C0C) { Name = "photos" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B76) { Name = "maxPowder" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B77) { Name = "maxBombs" },
            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0x1B78) { Name = "maxArrows" },

            new MemoryWatcher<byte>((IntPtr)vars.wramAddr + 0xEFF) { Name = "resetCheck" },
            new MemoryWatcher<short>((IntPtr)vars.wramAddr + 0x1B95) { Name = "gameState" },
        };
    });

    vars.GetSplitList = (Func<int, List<Tuple<string, List<Tuple<string, int>>>>>)((flag) =>
    {
        var list = new List<Tuple<string, List<Tuple<string, int>>>>
        {
            Tuple.Create("d1Enter", new List<Tuple<string, int>> { Tuple.Create("d1EntranceRoom", 0x8E) }),
            Tuple.Create("d2Enter", new List<Tuple<string, int>> { Tuple.Create("d2EntranceRoom", 0x8C) }),
            Tuple.Create("d3Enter", new List<Tuple<string, int>> { Tuple.Create("d3EntranceRoom", 0x8D) }),
            Tuple.Create("d4Enter", new List<Tuple<string, int>> { Tuple.Create("d4EntranceRoom", 0x8C) }),
            Tuple.Create("d5Enter", new List<Tuple<string, int>> { Tuple.Create("d5EntranceRoom", 0x8A) }),
            Tuple.Create("d6Enter", new List<Tuple<string, int>> { Tuple.Create("d6EntranceRoom", 0x8B) }),
            Tuple.Create("d7Enter", new List<Tuple<string, int>> { Tuple.Create("d7EntranceRoom", 0x8B) }),
            Tuple.Create("d8Enter", new List<Tuple<string, int>> { Tuple.Create("d8EntranceRoom", 0x8C) }),
            Tuple.Create("woods", new List<Tuple<string, int>> { Tuple.Create("overworldTile", 0x90), Tuple.Create("tailKey", 0x01) }),
            Tuple.Create("shop", new List<Tuple<string, int>> { Tuple.Create("shopThefts", 0x02) }),
            Tuple.Create("feather", new List<Tuple<string, int>> { Tuple.Create("featherRoom", 0x98) }),
            Tuple.Create("bracelet", new List<Tuple<string, int>> { Tuple.Create("braceletRoom", 0x91) }),
            Tuple.Create("boots", new List<Tuple<string, int>> { Tuple.Create("bootsRoom", 0x9B) }),
            Tuple.Create("ocarina", new List<Tuple<string, int>> { Tuple.Create("ocarinaRoom", 0x90) }),
            Tuple.Create("flippers", new List<Tuple<string, int>> { Tuple.Create("flippers", 0x01) }),
            Tuple.Create("l2Shield", new List<Tuple<string, int>> { Tuple.Create("l2ShieldRoom", 0x9E) }),
            Tuple.Create("magicRod", new List<Tuple<string, int>> { Tuple.Create("magicRodRoom", 0x98) }),
            Tuple.Create("marin", new List<Tuple<string, int>> { Tuple.Create("marin", 0x01) }),
            Tuple.Create("song1", new List<Tuple<string, int>> { Tuple.Create("music", 0x10), Tuple.Create("music2", 0x2A) }),
            Tuple.Create("song2", new List<Tuple<string, int>> { Tuple.Create("music", 0x10), Tuple.Create("overworldTile", 0x2A) }),
            Tuple.Create("song3", new List<Tuple<string, int>> { Tuple.Create("music", 0x10), Tuple.Create("overworldTile", 0xD4) }),
            Tuple.Create("tailKey", new List<Tuple<string, int>> { Tuple.Create("tailKey", 0x01) }),
            Tuple.Create("anglerKey", new List<Tuple<string, int>> { Tuple.Create("music", 0x10), Tuple.Create("overworldTile", 0xCE) }),
            Tuple.Create("birdKey", new List<Tuple<string, int>> { Tuple.Create("music", 0x10), Tuple.Create("overworldTile", 0x0A) }),
            Tuple.Create("magnifyingLens", new List<Tuple<string, int>> { Tuple.Create("music", 0x10), Tuple.Create("overworldTile", 0xE9) }),
            Tuple.Create("l1Sword", new List<Tuple<string, int>> { Tuple.Create("music", 0x0F), Tuple.Create("overworldTile", 0xF2) }),
            Tuple.Create("l2Sword", new List<Tuple<string, int>> { Tuple.Create("music", 0x0F), Tuple.Create("overworldTile", 0x8A) }),
            Tuple.Create("eggStairs", new List<Tuple<string, int>> { Tuple.Create("gameState", 0x0201) }),
            Tuple.Create("creditsWarp", new List<Tuple<string, int>> { Tuple.Create("gameState", 0x0301) }),
        };

        if (flag == 0) //LA
        {
            list.AddRange(new List<Tuple<string, List<Tuple<string, int>>>>
            {
                Tuple.Create("d1End", new List<Tuple<string, int>> { Tuple.Create("music", 0x05), Tuple.Create("d1InstrumentRoom", 0x90) }),
                Tuple.Create("d2End", new List<Tuple<string, int>> { Tuple.Create("music", 0x05), Tuple.Create("d2InstrumentRoom", 0x90) }),
                Tuple.Create("d3End", new List<Tuple<string, int>> { Tuple.Create("music", 0x05), Tuple.Create("d3InstrumentRoom", 0x90) }),
                Tuple.Create("d4End", new List<Tuple<string, int>> { Tuple.Create("music", 0x05), Tuple.Create("d4InstrumentRoom", 0x90) }),
                Tuple.Create("d5End", new List<Tuple<string, int>> { Tuple.Create("music", 0x05), Tuple.Create("d5InstrumentRoom", 0x90) }),
                Tuple.Create("d6End", new List<Tuple<string, int>> { Tuple.Create("music", 0x05), Tuple.Create("d6InstrumentRoom", 0x90) }),
                Tuple.Create("d7End", new List<Tuple<string, int>> { Tuple.Create("music", 0x06), Tuple.Create("d7InstrumentRoom", 0x98) }),
                Tuple.Create("d8End", new List<Tuple<string, int>> { Tuple.Create("music", 0x06), Tuple.Create("d8InstrumentRoom", 0x98) }),
                Tuple.Create("d8Exit", new List<Tuple<string, int>> { Tuple.Create("d8Mountaintop", 0x80) }),
            });
        }
        else if (flag == 0x80) //LADX
        {
            list.AddRange(new List<Tuple<string, List<Tuple<string, int>>>>
            {
                Tuple.Create("d1End", new List<Tuple<string, int>> { Tuple.Create("music", 0x0B), Tuple.Create("overworldTile", 0xD3) }),
                Tuple.Create("d2End", new List<Tuple<string, int>> { Tuple.Create("music", 0x0B), Tuple.Create("overworldTile", 0x24) }),
                Tuple.Create("d3End", new List<Tuple<string, int>> { Tuple.Create("music", 0x0B), Tuple.Create("overworldTile", 0xB5) }),
                Tuple.Create("d4End", new List<Tuple<string, int>> { Tuple.Create("music", 0x0B), Tuple.Create("overworldTile", 0x2B) }),
                Tuple.Create("d5End", new List<Tuple<string, int>> { Tuple.Create("music", 0x0B), Tuple.Create("overworldTile", 0xD9) }),
                Tuple.Create("d6End", new List<Tuple<string, int>> { Tuple.Create("music", 0x0B), Tuple.Create("overworldTile", 0x8C) }),
                Tuple.Create("d7End", new List<Tuple<string, int>> { Tuple.Create("music", 0x0B), Tuple.Create("overworldTile", 0x0E) }),
                Tuple.Create("d8End", new List<Tuple<string, int>> { Tuple.Create("music", 0x0B), Tuple.Create("overworldTile", 0x10) }),
                Tuple.Create("d0Enter", new List<Tuple<string, int>> { Tuple.Create("d0EntranceRoom", 0x84) }),
                Tuple.Create("d0End", new List<Tuple<string, int>> { Tuple.Create("sound", 0x01), Tuple.Create("music", 0x0C), Tuple.Create("overworldTile", 0x77) }),
            });
        }

        return list;
    });
}

init
{
    vars.wramAddr = IntPtr.Zero;
    vars.romAddr = IntPtr.Zero;
    vars.cgbFlag = 0xFF;
    vars.watchers = new MemoryWatcherList();

    vars.stopwatch.Restart();
}

update
{
    if (vars.stopwatch.ElapsedMilliseconds > 1000)
    {
        if (vars.wramAddr == IntPtr.Zero)
            vars.wramAddr = vars.FindWRAM(game);

        if (vars.romAddr == IntPtr.Zero)
            vars.romAddr = vars.FindROM(game);

        if (vars.wramAddr != IntPtr.Zero && vars.romAddr != IntPtr.Zero)
        {
            vars.cgbFlag = memory.ReadValue<byte>((IntPtr)vars.romAddr + 0x143);
            vars.watchers = vars.GetWatcherList();

            vars.stopwatch.Reset();
        }
        else
        {
            vars.stopwatch.Restart();
            return false;
        }
    }
    else if (vars.watchers.Count == 0)
        return false;

    vars.watchers.UpdateAll(game);
}

start
{
    return vars.watchers["gameState"].Current == 0x0902;
}

reset
{
    return vars.watchers["resetCheck"].Current > 0;
}

split
{
    foreach (var _split in vars.splits)
    {
        if (settings[_split.Item1])
        {
            var count = 0;
            foreach (var _condition in _split.Item2)
            {
                if (vars.watchers[_condition.Item1].Current == _condition.Item2)
                    count++;
            }

            if (count == _split.Item2.Count)
            {
                print("[Autosplitter] Split: " + _split.Item1);
                vars.splits.Remove(_split);
                return true;
            }
        }
    }
}