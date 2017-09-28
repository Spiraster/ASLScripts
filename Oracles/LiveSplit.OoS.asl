state("bgb") {}
state("gambatte") {}
state("gambatte_qt") {}

startup
{
    //-------------------------------------------------------------//
    settings.Add("entrances", true, "Dungeon Entrance Splits");
    settings.Add("essences", true, "Dungeon End Splits (Essences)");
    settings.Add("boss", true, "Boss Splits");
    settings.Add("items", true, "Item Splits");

    settings.CurrentDefaultParent = "entrances";
    settings.Add("d1Enter", true, "Gnarled Root Dungeon (D1)");
    settings.Add("d2Enter", true, "Snake's Remains (D2)");
    settings.Add("d3Enter", true, "Poison Moth Lair (D3)");
    settings.Add("d4Enter", true, "Dancing Dragon Dungeon (D4)");
    settings.Add("d5Enter", true, "Unicorn's Cave (D5)");
    settings.Add("d6Enter", true, "Ancient Ruins (D6)");
    settings.Add("d7Enter", true, "Explorer's Crypt (D7)");
    settings.Add("d8Enter", true, "Sword & Shield Maze (D8)");
    settings.Add("northernPeakEnter", true, "Northern Peak");

    settings.CurrentDefaultParent = "essences";
    settings.Add("d1Ess", true, "Fertile Soil (D1)");
    settings.Add("d2Ess", true, "Gift of Time (D2)");
    settings.Add("d3Ess", true, "Bright Sun (D3)");
    settings.Add("d4Ess", true, "Soothing Rain (D4)");
    settings.Add("d5Ess", true, "Nurturing Warmth (D5)");
    settings.Add("d6Ess", true, "Blowing Wind (D6)");
    settings.Add("d7Ess", true, "Seed of Life (D7)");
    settings.Add("d8Ess", true, "Changing Seasons (D8)");

    settings.CurrentDefaultParent = "boss";
    settings.Add("onoxEnter", false, "Enter Onox Fight");
    settings.Add("onox", true, "Defeat Onox");
    
    settings.CurrentDefaultParent = "items";
    settings.Add("l1Sword", true, "Sword (L1)");
    //-------------------------------------------------------------//

    vars.stopwatch = new Stopwatch();

    vars.timer_OnStart = (EventHandler)((s, e) =>
    {
        vars.splits = vars.GetSplitList();
    });
    timer.OnStart += vars.timer_OnStart;

    vars.wramTarget = new SigScanTarget(-0x20, "05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ?? ?? ?? ?? ?? ?? ?? ?? F8 00 00 00"); //gambatte

    vars.FindWRAM = (Func<Process, int, IntPtr>)((proc, ptr) => 
    {
        if (ptr != 0) //bgb
            return proc.ReadPointer(proc.ReadPointer(proc.ReadPointer((IntPtr)ptr) + 0x34) + 0xC0) + 0xC000;
        else //gambatte
        {
            print("[Autosplitter] Scanning memory");
            var wramPtr = IntPtr.Zero;

            foreach (var page in proc.MemoryPages())
            {
                var scanner = new SignatureScanner(proc, page.BaseAddress, (int)page.RegionSize);

                if (wramPtr == IntPtr.Zero)
                    wramPtr = scanner.Scan(vars.wramTarget);

                if (wramPtr != IntPtr.Zero)
                    break;
            }

            if (wramPtr != IntPtr.Zero)
                return proc.ReadPointer(wramPtr);
            else
                return IntPtr.Zero;
        }
    });

    vars.GetWatcherList = (Func<IntPtr, MemoryWatcherList>)((wramOffset) =>
    {   
        return new MemoryWatcherList
        {
            new MemoryWatcher<byte>(wramOffset + 0x91C) { Name = "d1Enter" },
            new MemoryWatcher<byte>(wramOffset + 0x939) { Name = "d2Enter" },
            new MemoryWatcher<byte>(wramOffset + 0x94B) { Name = "d3Enter" },
            new MemoryWatcher<byte>(wramOffset + 0x981) { Name = "d4Enter" },
            new MemoryWatcher<byte>(wramOffset + 0x9A7) { Name = "d5Enter" },
            new MemoryWatcher<byte>(wramOffset + 0x9BA) { Name = "d6Enter" },
            new MemoryWatcher<byte>(wramOffset + 0xA5B) { Name = "d7Enter" },
            new MemoryWatcher<byte>(wramOffset + 0xA87) { Name = "d8Enter" },
            new MemoryWatcher<byte>(wramOffset + 0xA97) { Name = "northernPeakEnter" },
            new MemoryWatcher<byte>(wramOffset + 0xA91) { Name = "onoxEnter" },
            new MemoryWatcher<byte>(wramOffset + 0x913) { Name = "d1Ess" },
            new MemoryWatcher<byte>(wramOffset + 0x92C) { Name = "d2Ess" },
            new MemoryWatcher<byte>(wramOffset + 0x940) { Name = "d3Ess" },
            new MemoryWatcher<byte>(wramOffset + 0x960) { Name = "d4Ess" },
            new MemoryWatcher<byte>(wramOffset + 0x988) { Name = "d5Ess" },
            new MemoryWatcher<byte>(wramOffset + 0x898) { Name = "d6Ess" },
            new MemoryWatcher<byte>(wramOffset + 0xA4F) { Name = "d7Ess" },
            new MemoryWatcher<byte>(wramOffset + 0xA5F) { Name = "d8Ess" },
            new MemoryWatcher<byte>(wramOffset + 0x11A9) { Name = "onoxHP" },
            new MemoryWatcher<byte>(wramOffset + 0x6AC) { Name = "sword" },
            new MemoryWatcher<byte>(wramOffset + 0xB00) { Name = "fileSelect1" },
            new MemoryWatcher<short>(wramOffset + 0xBB3) { Name = "fileSelect2" },
            new MemoryWatcher<byte>(wramOffset + 0x1EFF) { Name = "resetCheck" },
        };
    });

    vars.GetSplitList = (Func<List<Tuple<string, List<Tuple<string, int>>>>>)(() =>
    {
        return new List<Tuple<string, List<Tuple<string, int>>>>
        {
            Tuple.Create("d1Enter", new List<Tuple<string, int>> { Tuple.Create("d1Enter", 0x10) }),
            Tuple.Create("d2Enter", new List<Tuple<string, int>> { Tuple.Create("d2Enter", 0x10) }),
            Tuple.Create("d3Enter", new List<Tuple<string, int>> { Tuple.Create("d3Enter", 0x10) }),
            Tuple.Create("d4Enter", new List<Tuple<string, int>> { Tuple.Create("d4Enter", 0x10) }),
            Tuple.Create("d5Enter", new List<Tuple<string, int>> { Tuple.Create("d5Enter", 0x10) }),
            Tuple.Create("d6Enter", new List<Tuple<string, int>> { Tuple.Create("d6Enter", 0x10) }),
            Tuple.Create("d7Enter", new List<Tuple<string, int>> { Tuple.Create("d7Enter", 0x10) }),
            Tuple.Create("d8Enter", new List<Tuple<string, int>> { Tuple.Create("d8Enter", 0x10) }),
            Tuple.Create("northernPeakEnter", new List<Tuple<string, int>> { Tuple.Create("northernPeakEnter", 0x10) }),
            Tuple.Create("onoxEnter", new List<Tuple<string, int>> { Tuple.Create("onoxEnter", 0x10) }),
            Tuple.Create("d1Ess", new List<Tuple<string, int>> { Tuple.Create("d1Ess", 0x30) }),
            Tuple.Create("d2Ess", new List<Tuple<string, int>> { Tuple.Create("d2Ess", 0x30) }),
            Tuple.Create("d3Ess", new List<Tuple<string, int>> { Tuple.Create("d3Ess", 0x30) }),
            Tuple.Create("d4Ess", new List<Tuple<string, int>> { Tuple.Create("d4Ess", 0x30) }),
            Tuple.Create("d5Ess", new List<Tuple<string, int>> { Tuple.Create("d5Ess", 0x30) }),
            Tuple.Create("d6Ess", new List<Tuple<string, int>> { Tuple.Create("d6Ess", 0x30) }),
            Tuple.Create("d7Ess", new List<Tuple<string, int>> { Tuple.Create("d7Ess", 0x30) }),
            Tuple.Create("d8Ess", new List<Tuple<string, int>> { Tuple.Create("d8Ess", 0x30) }),
            Tuple.Create("onox", new List<Tuple<string, int>> { Tuple.Create("onoxHP", 0x01), Tuple.Create("onoxEnter", 0x10) }),
            Tuple.Create("l1Sword", new List<Tuple<string, int>> { Tuple.Create("sword", 0x01) }),
        };
    });
}

init
{    
    vars.memorySize = modules.First().ModuleMemorySize;

    vars.wramOffset = IntPtr.Zero;
    vars.watchers = new MemoryWatcherList();
    vars.splits = new List<Tuple<string, List<Tuple<string, int>>>>();

    vars.stopwatch.Restart();
}

update
{
    if (vars.stopwatch.ElapsedMilliseconds > 1500)
    {
        switch ((int)vars.memorySize)
        {
            case 1691648: //bgb (1.5.1)
                vars.wramOffset = vars.FindWRAM(game, 0x55BC7C);
                break;
            case 1699840: //bgb (1.5.2)
                vars.wramOffset = vars.FindWRAM(game, 0x55DCA0);
                break;
            case 1736704: //bgb (1.5.3/1.5.4)
                vars.wramOffset = vars.FindWRAM(game, 0x564EBC);
                break;
            case 14290944: //gambatte-speedrun (r600)
            case 14180352: //gambatte-speedrun (r604)
                vars.wramOffset = vars.FindWRAM(game, 0);
                break;
            default:
                vars.wramOffset = (IntPtr)1;
                break;
        }

        if (vars.wramOffset != IntPtr.Zero)
        {
            print("[Autosplitter] WRAM: " + vars.wramOffset.ToString("X8"));
            vars.watchers = vars.GetWatcherList(vars.wramOffset);
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
    return vars.watchers["fileSelect1"].Current == 0x23 && vars.watchers["fileSelect2"].Current == 0x0301;
}

reset
{
    //return vars.watchers["resetCheck"].Current > 0;
}

split
{
    //prevent splitting on the file select screen
    var fs = vars.watchers["fileSelect1"].Current;
    if (fs == 0x17 || fs == 0x23)
        return false;

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

shutdown
{
    timer.OnStart -= vars.timer_OnStart;
}