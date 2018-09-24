state("bgb") {}
state("bgb64") {}
state("gambatte") {}
state("gambatte_qt") {}
state("gambatte_qt_nonpsr") {}
state("emuhawk") {}

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

    vars.TryFindOffsets = (Func<Process, int, long, bool>)((proc, memorySize, baseAddress) => 
    {
        var states = new Dictionary<int, int>
        {
            { 1691648, 0x55BC7C }, //BGB 1.5.1
            { 1699840, 0x55DCA0 }, //BGB 1.5.2
            { 1736704, 0x564EBC }, //BGB 1.5.3/1.5.4
            { 1740800, 0x566EDC }, //BGB 1.5.5/1.5.6
            { 1769472, 0x56CF14 }, //BGB 1.5.7
            { 4632576, 0x803100 }, //BGB 1.5.7 (x64)
            { 14290944, 0 }, //GSR r600
            { 14180352, 0 }, //GSR r604/614
            { 14209024, 0 }, //GSR r649
            { 7061504, 0 }, //BizHawk 2.3
        };

        int ptrOffset;
        if (states.TryGetValue(memorySize, out ptrOffset))
        {
            long romOffset = 0;
            long wramOffset = 0;

            var state = proc.ProcessName.ToLower();
            if (state.Contains("gambatte"))
            {
                var target = new SigScanTarget(0, "20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 05 00 00");

                var scanOffset = vars.SigScan(proc, target);
                if (scanOffset != 0)
                {
                    romOffset = scanOffset - 0x18;
                    wramOffset = scanOffset - 0x10;
                }
            }
            else if (state == "emuhawk")
            {
                var target = new SigScanTarget(0, "05 00 00 00 ?? 00 00 00 00 ?? ?? 00 00 ?? ?? 00 00 ?? ?? 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ?? ?? ?? ?? ?? ?? ?? ?? F8 00 00 00");

                var scanOffset = vars.SigScan(proc, target);
                if (scanOffset != 0)
                {
                    romOffset = scanOffset - 0x50;
                    wramOffset = scanOffset - 0x40;
                }
            }
            else if (state == "bgb")
            {
                romOffset = proc.ReadValue<int>(proc.ReadPointer((IntPtr)ptrOffset) + 0x34) + 0x10;
                wramOffset = proc.ReadValue<int>(proc.ReadPointer((IntPtr)ptrOffset) + 0x34) + 0x108;
            }
            else if (state == "bgb64")
            {
                romOffset = proc.ReadValue<int>(proc.ReadPointer((IntPtr)ptrOffset) + 0x44) + 0x18;
                wramOffset = proc.ReadValue<int>(proc.ReadPointer((IntPtr)ptrOffset) + 0x44) + 0x190;
            }

            if (proc.ReadValue<int>((IntPtr)romOffset) != 0)
            {
                print("[Autosplitter] ROM Pointer: " + romOffset.ToString("X8"));
                print("[Autosplitter] WRAM Pointer: " + wramOffset.ToString("X8"));

                vars.watchers = new MemoryWatcherList { new MemoryWatcher<byte>(new DeepPointer((int)(romOffset - baseAddress), 0x14A)) { Name = "version" } };
                vars.watchers.UpdateAll(proc);
                vars.watchers.AddRange(vars.GetWatcherList((int)(romOffset - baseAddress), (int)(wramOffset - baseAddress)));
                vars.stopwatch.Reset();
                
                return true;
            }
            else
                vars.stopwatch.Restart();
        }
        else
            vars.stopwatch.Reset();

        return false;
    });

    vars.SigScan = (Func<Process, SigScanTarget, long>)((proc, target) =>
    {
        print("[Autosplitter] Scanning memory");

        long result = 0;
        foreach (var page in proc.MemoryPages())
        {
            var scanner = new SignatureScanner(proc, page.BaseAddress, (int)page.RegionSize);
            if ((result = (long)scanner.Scan(target)) != 0)
                break;
        }

        return result;
    });

    vars.Current = (Func<string, int, bool>)((name, value) => 
    {
        return vars.watchers[name].Current == value;
    });

    vars.GetWatcherList = (Func<int, int, MemoryWatcherList>)((romOffset, wramOffset) =>
    {
        if (vars.watchers["version"].Current == 0) //JP
        {
            print("[Autosplitter] Game Version: JP");
            return new MemoryWatcherList
            {
                new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x630)) { Name = "EnemyActive" },
                new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x631)) { Name = "EnemyName" },
                new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x1834)) { Name = "TitleState" },
                new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x200)) { Name = "ResetCheck" },
            };
        }
        else //US
        {
            print("[Autosplitter] Game Version: US");
            return new MemoryWatcherList
            {
                new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x615)) { Name = "EnemyActive" },
                new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x616)) { Name = "EnemyName" },
                new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x151A)) { Name = "TitleState" },
                new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x200)) { Name = "ResetCheck" },
            };
        }
    });

    vars.GetSplitList = (Func<Dictionary<string, Dictionary<string, int>>>)(() =>
    {
        if (vars.watchers["version"].Current == 0) //JP
        {
            return new Dictionary<string, Dictionary<string, int>>
            {
                { "Tim", new Dictionary<string, int> { { "EnemyName", 0xE258 }, { "EnemyActive", 0 } } },
                { "Solvaring", new Dictionary<string, int> { { "EnemyName", 0x845A }, { "EnemyActive", 0 } } },
                { "Kiliac", new Dictionary<string, int> { { "EnemyName", 0x0859 }, { "EnemyActive", 0 } } },
                { "Dragon1", new Dictionary<string, int> { { "EnemyName", 0x2E59 }, { "EnemyActive", 0 } } },
                { "Zelse", new Dictionary<string, int> { { "EnemyName", 0xAA5A }, { "EnemyActive", 0 } } },
                { "Nepty", new Dictionary<string, int> { { "EnemyName", 0xD05A }, { "EnemyActive", 0 } } },
                { "Lavaar1", new Dictionary<string, int> { { "EnemyName", 0x425B }, { "EnemyActive", 0 } } },
                { "Fargo", new Dictionary<string, int> { { "EnemyName", 0xF65A }, { "EnemyActive", 0 } } },
                { "Lavaar2", new Dictionary<string, int> { { "EnemyName", 0x685B }, { "EnemyActive", 0 } } },
                { "Shilf", new Dictionary<string, int> { { "EnemyName", 0xC659 }, { "EnemyActive", 0 } } },
                { "Dragon2", new Dictionary<string, int> { { "EnemyName", 0xEC59 }, { "EnemyActive", 0 } } },
                { "Guilty", new Dictionary<string, int> { { "EnemyName", 0x8E5B }, { "EnemyActive", 0 } } },
                { "Beigis", new Dictionary<string, int> { { "EnemyName", 0x1C5B }, { "EnemyActive", 0 } } },
                { "Mammon", new Dictionary<string, int> { { "EnemyName", 0x125A }, { "EnemyActive", 0 } } },
            };
        }
        else //US
        {
            return new Dictionary<string, Dictionary<string, int>>
            {
                { "Tim", new Dictionary<string, int> { { "EnemyName", 0xF859 }, { "EnemyActive", 0 } } },
                { "Solvaring", new Dictionary<string, int> { { "EnemyName", 0x9A5B }, { "EnemyActive", 0 } } },
                { "Kiliac", new Dictionary<string, int> { { "EnemyName", 0x1E5A }, { "EnemyActive", 0 } } },
                { "Dragon1", new Dictionary<string, int> { { "EnemyName", 0x445A }, { "EnemyActive", 0 } } },
                { "Zelse", new Dictionary<string, int> { { "EnemyName", 0xC05B }, { "EnemyActive", 0 } } },
                { "Nepty", new Dictionary<string, int> { { "EnemyName", 0xE65B }, { "EnemyActive", 0 } } },
                { "Lavaar1", new Dictionary<string, int> { { "EnemyName", 0x585C }, { "EnemyActive", 0 } } },
                { "Fargo", new Dictionary<string, int> { { "EnemyName", 0x0C5C }, { "EnemyActive", 0 } } },
                { "Lavaar2", new Dictionary<string, int> { { "EnemyName", 0x7E5C }, { "EnemyActive", 0 } } },
                { "Shilf", new Dictionary<string, int> { { "EnemyName", 0xDC5A }, { "EnemyActive", 0 } } },
                { "Dragon2", new Dictionary<string, int> { { "EnemyName", 0x025B }, { "EnemyActive", 0 } } },
                { "Guilty", new Dictionary<string, int> { { "EnemyName", 0xA45C }, { "EnemyActive", 0 } } },
                { "Beigis", new Dictionary<string, int> { { "EnemyName", 0x325C }, { "EnemyActive", 0 } } },
                { "Mammon", new Dictionary<string, int> { { "EnemyName", 0x285B }, { "EnemyActive", 0 } } },
            };
        }
    });
}

init
{
    vars.watchers = new MemoryWatcherList();
    vars.splits = new Dictionary<string, Dictionary<string, int>>();

    vars.stopwatch.Restart();
}

update
{
	if (vars.stopwatch.ElapsedMilliseconds > 1500)
	{
        if (!vars.TryFindOffsets(game, modules.First().ModuleMemorySize, (long)modules.First().BaseAddress))
            return false;
	}
    else if (vars.watchers.Count == 0)
        return false;
    
    vars.watchers["version"].Update(game);
    if (vars.watchers["version"].Changed)
        vars.TryFindOffsets(game, modules.First().ModuleMemorySize, (long)modules.First().BaseAddress);

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
        if (settings[_split.Key])
        {
            var count = 0;
            foreach (var _condition in _split.Value)
            {
                if (vars.watchers[_condition.Key].Current == _condition.Value)
                    count++;
            }

            if (count == _split.Value.Count)
            {
                print("[Autosplitter] Split: " + _split.Key);
                vars.splits.Remove(_split.Key);
                return true;
            }
        }
    }
}

shutdown
{
    timer.OnStart -= vars.timer_OnStart;
}