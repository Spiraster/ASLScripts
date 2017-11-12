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
        vars.splits = vars.GetSplitList(vars.version);
    });
    timer.OnStart += vars.timer_OnStart;

    vars.FindOffsets = (Action<Process, int>)((proc, memorySize) => 
    {
        var baseOffset = 0;
        switch (memorySize)
        {
            case 1691648: //bgb (1.5.1)
                baseOffset = 0x55BC7C;
                break;
            case 1699840: //bgb (1.5.2)
                baseOffset = 0x55DCA0;
                break;
            case 1736704: //bgb (1.5.3/1.5.4)
                baseOffset = 0x564EBC;
                break;
            case 14290944: //gambatte-speedrun (r600)
            case 14180352: //gambatte-speedrun (r604/r614)
                baseOffset = int.MaxValue;
                break;
        }

        if (baseOffset == 0)
        {
            vars.romOffset = (IntPtr)1;
            vars.wramOffset = (IntPtr)1;            
        }
        else
        {
            vars.romOffset = IntPtr.Zero;
            vars.wramOffset = IntPtr.Zero;

            if (baseOffset == int.MaxValue) //gambatte
            {
                if (vars.ptrOffset == IntPtr.Zero)
                {
                    print("[Autosplitter] Scanning memory");
                    var target = new SigScanTarget(0, "05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ?? ?? ?? ?? ?? ?? ?? ?? F8 00 00 00");

                    foreach (var page in proc.MemoryPages())
                    {
                        var scanner = new SignatureScanner(proc, page.BaseAddress, (int)page.RegionSize);
                        var ptrOffset = scanner.Scan(target);

                        if (ptrOffset != IntPtr.Zero)
                        {
                            vars.ptrOffset = ptrOffset;
                            break;
                        }
                    }

                    if (vars.ptrOffset != IntPtr.Zero)
                    {
                        vars.romPtr = new MemoryWatcher<int>(vars.ptrOffset - 0x28);
                        vars.wramPtr = new MemoryWatcher<int>(vars.ptrOffset - 0x20);
                    }
                }
            }
            else if (baseOffset != 0) //bgb
            {
                if (vars.ptrOffset == IntPtr.Zero)
                {
                    vars.ptrOffset = proc.ReadPointer(proc.ReadPointer((IntPtr)baseOffset) + 0x34);

                    if (vars.ptrOffset != IntPtr.Zero)
                    {
                        vars.romPtr = new MemoryWatcher<int>(vars.ptrOffset + 0x10);
                        vars.wramPtr = new MemoryWatcher<int>(vars.ptrOffset + 0xC0);
                    }
                }

                vars.wramOffset += 0xC000;
            }
            
            if (vars.ptrOffset != IntPtr.Zero)
            {
                vars.romPtr.Update(proc);
                vars.romOffset += vars.romPtr.Current;
                
                vars.wramPtr.Update(proc);
                vars.wramOffset += vars.wramPtr.Current;
            }

            if (vars.romOffset != IntPtr.Zero && vars.wramOffset != IntPtr.Zero)
            {
                print("[Autosplitter] ROM: " + vars.romOffset.ToString("X8"));
                print("[Autosplitter] WRAM: " + vars.wramOffset.ToString("X8"));
            }
        }
    });

    vars.GetWatcherList = (Func<IntPtr, byte, MemoryWatcherList>)((wramOffset, version) =>
    {   
        if (version == 0) //JP
        {
            print("[Autosplitter] JP");
            return new MemoryWatcherList
            {
                new MemoryWatcher<byte>(wramOffset + 0x630) { Name = "EnemyActive" },
                new MemoryWatcher<ushort>(wramOffset + 0x631) { Name = "EnemyName" },
                new MemoryWatcher<ushort>(wramOffset + 0x1834) { Name = "TitleState" },
                new MemoryWatcher<ushort>(wramOffset + 0x200) { Name = "ResetCheck" },
            };
        }
        else //US
        {
            print("[Autosplitter] US");
            return new MemoryWatcherList
            {
                new MemoryWatcher<byte>(wramOffset + 0x615) { Name = "EnemyActive" },
                new MemoryWatcher<ushort>(wramOffset + 0x616) { Name = "EnemyName" },
                new MemoryWatcher<ushort>(wramOffset + 0x151A) { Name = "TitleState" },
                new MemoryWatcher<ushort>(wramOffset + 0x200) { Name = "ResetCheck" },
            };
        }
    });

    vars.GetSplitList = (Func<int, List<Tuple<string, List<Tuple<string, int>>>>>)((version) =>
    {
        if (version == 0) //JP
        {
            return new List<Tuple<string, List<Tuple<string, int>>>>
            {
                Tuple.Create("Tim", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0xE2F8), Tuple.Create("EnemyActive", 0) }),
                Tuple.Create("Solvaring", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x845A), Tuple.Create("EnemyActive", 0) }),
                Tuple.Create("Kiliac", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x0859), Tuple.Create("EnemyActive", 0) }),
                Tuple.Create("Dragon1", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x2E59), Tuple.Create("EnemyActive", 0) }),
                Tuple.Create("Zelse", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0xAA5A), Tuple.Create("EnemyActive", 0) }),
                Tuple.Create("Nepty", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0xD05A), Tuple.Create("EnemyActive", 0) }),
                Tuple.Create("Lavaar1", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x425B), Tuple.Create("EnemyActive", 0) }),
                Tuple.Create("Fargo", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0xF65A), Tuple.Create("EnemyActive", 0) }),
                Tuple.Create("Lavaar2", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x685B), Tuple.Create("EnemyActive", 0) }),
                Tuple.Create("Shilf", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0xC659), Tuple.Create("EnemyActive", 0) }),
                Tuple.Create("Dragon2", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0xEC59), Tuple.Create("EnemyActive", 0) }),
                Tuple.Create("Guilty", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x8E5B), Tuple.Create("EnemyActive", 0) }),
                Tuple.Create("Beigis", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x1C5B), Tuple.Create("EnemyActive", 0) }),
                Tuple.Create("Mammon", new List<Tuple<string, int>> { Tuple.Create("EnemyName", 0x125A), Tuple.Create("EnemyActive", 0) }),
            };
        }
        else //US
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
        }
    });
}

init
{
    vars.ptrOffset = IntPtr.Zero;
    vars.romOffset = IntPtr.Zero;
    vars.wramOffset = IntPtr.Zero;

    vars.romPtr = new MemoryWatcher<byte>(IntPtr.Zero);
    vars.wramPtr = new MemoryWatcher<byte>(IntPtr.Zero);

    vars.version = 0xFF;
    vars.watchers = new MemoryWatcherList();
    vars.splits = new List<Tuple<string, List<Tuple<string, int>>>>();

    vars.stopwatch.Restart();
}

update
{
    if (vars.stopwatch.ElapsedMilliseconds > 1500)
    {
        if (vars.romOffset == IntPtr.Zero || vars.wramOffset == IntPtr.Zero)
            vars.FindOffsets(game, modules.First().ModuleMemorySize);

        if (vars.romOffset != IntPtr.Zero && vars.wramOffset != IntPtr.Zero)
        {
            vars.version = game.ReadValue<byte>((IntPtr)vars.romOffset + 0x14A);
            vars.watchers = vars.GetWatcherList((IntPtr)vars.wramOffset, vars.version);
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

    vars.romPtr.Update(game);
    vars.wramPtr.Update(game);

    if (vars.romPtr.Changed || vars.wramPtr.Changed)
    {
        vars.FindOffsets(game, modules.First().ModuleMemorySize);
        vars.version = game.ReadValue<byte>((IntPtr)vars.romOffset + 0x14A);
        vars.watchers = vars.GetWatcherList((IntPtr)vars.wramOffset, vars.version);
    }

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