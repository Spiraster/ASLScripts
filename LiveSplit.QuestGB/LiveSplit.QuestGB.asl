state("bgb") {}
state("gambatte") {}
state("gambatte_qt") {}

startup
{
    //-------------------------------------------------------------//
    settings.Add("Tim", true, "Tim");
    settings.Add("Solvaring", true, "Solvaring");
    settings.Add("Kiliac", true, "Kiliac");
    settings.Add("Dragon1", true, "Dragon (1)");
    settings.Add("Zelse", true, "Zelse");
    settings.Add("Nepty", true, "Nepty");
    settings.Add("Lavaar1", true, "Lavaar (1)");
    settings.Add("Fargo", true, "Fargo");
    settings.Add("Lavaar2", true, "Lavaar (2)");
    settings.Add("Shilf", true, "Shilf");
    settings.Add("Dragon2", true, "Dragon (2)");
    settings.Add("Guilty", true, "Guilty");
    settings.Add("Beigis", true, "Beigis");
    settings.Add("Mammon", true, "Mammon");
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
            new MemoryWatcher<byte>(wramOffset + 0x615) { Name = "EnemyActive" },
            new MemoryWatcher<ushort>(wramOffset + 0x616) { Name = "EnemyName" },

            new MemoryWatcher<ushort>(wramOffset + 0x151A) { Name = "TitleState" },
            new MemoryWatcher<ushort>(wramOffset + 0x200) { Name = "ResetCheck" },
        };
    });

    vars.GetSplitList = (Func<List<Tuple<string, List<Tuple<string, int>>>>>)(() =>
    {
        return new List<Tuple<string, List<Tuple<string, int>>>>
        {
            Tuple.Create("Tim", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0xF859), Tuple.Create("EnemyActive", 0) }),
            Tuple.Create("Solvaring", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x9A5B), Tuple.Create("EnemyActive", 0) }),
            Tuple.Create("Kiliac", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x1E5A), Tuple.Create("EnemyActive", 0) }),
            Tuple.Create("Dragon1", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x445A), Tuple.Create("EnemyActive", 0) }),
            Tuple.Create("Zelse", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0xC05B), Tuple.Create("EnemyActive", 0) }),
            Tuple.Create("Nepty", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0xE65B), Tuple.Create("EnemyActive", 0) }),
            Tuple.Create("Lavaar1", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x585C), Tuple.Create("EnemyActive", 0) }),
            Tuple.Create("Fargo", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x0C5C), Tuple.Create("EnemyActive", 0) }),
            Tuple.Create("Lavaar2", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x7E5C), Tuple.Create("EnemyActive", 0) }),
            Tuple.Create("Shilf", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0xDC5A), Tuple.Create("EnemyActive", 0) }),
            Tuple.Create("Dragon2", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x025B), Tuple.Create("EnemyActive", 0) }),
            Tuple.Create("Guilty", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0xA45C), Tuple.Create("EnemyActive", 0) }),
            Tuple.Create("Beigis", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x325C), Tuple.Create("EnemyActive", 0) }),
            Tuple.Create("Mammon", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x285B), Tuple.Create("EnemyActive", 0) }),
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
    return vars.watchers["TitleState"].Current == 0x0B06;
}

reset
{
    return vars.watchers["ResetCheck"].Current > 0;
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

shutdown
{
    timer.OnStart -= vars.timer_OnStart;
}