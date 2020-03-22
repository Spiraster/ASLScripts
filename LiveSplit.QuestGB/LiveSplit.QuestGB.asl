state("bgb") {}
state("bgb64") {}
state("gambatte") {}
state("gambatte_qt") {}
state("gambatte_qt_nonpsr") {}
state("gambatte_speedrun") {}
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

    refreshRate = 0.5;

    vars.timer_OnStart = (EventHandler)((s, e) =>
    {
        vars.splits = vars.GetSplitList();
    });
    timer.OnStart += vars.timer_OnStart;

    vars.TryFindOffsets = (Func<Process, int, long, bool>)((proc, memorySize, baseAddress) => 
    {
        long romOffset = 0;
        long wramOffset = 0;
        string state = proc.ProcessName.ToLower();
        if (state.Contains("gambatte"))
        {
            IntPtr scanOffset = vars.SigScan(proc, 0, "20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 05 00 00");            
            romOffset = (long)scanOffset - 0x18;
            wramOffset = (long)scanOffset - 0x10;
        }
        else if (state == "emuhawk")
        {
            IntPtr scanOffset = vars.SigScan(proc, 0, "05 00 00 00 ?? 00 00 00 00 ?? ?? 00 ?? 40 ?? 00 00 ?? ?? 00 00 00 00 00 ?? 00 00 00 00 00 00 00 00 00 00 00 ?? ?? ?? 00 ?? 00 00 00 00 00 ?? 00 ?? 00 00 00 00 00 00 00 ?? ?? ?? ?? ?? ?? 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F8 00 00 00");
            romOffset = (long)scanOffset - 0x50;
            wramOffset = (long)scanOffset - 0x40;
        }
        else if (state == "bgb")
        {
            IntPtr scanOffset = vars.SigScan(proc, 12, "6D 61 69 6E 6C 6F 6F 70 83 C4 F4 A1 ?? ?? ?? ??");
            var sharedOffset = new DeepPointer(scanOffset, 0, 0, 0x34).Deref<int>(proc);
            romOffset = sharedOffset + 0x10;
            wramOffset = sharedOffset + 0x108;
        }
        else if (state == "bgb64")
        {
            IntPtr scanOffset = vars.SigScan(proc, 20, "48 83 EC 28 48 8B 05 ?? ?? ?? ?? 48 83 38 00 74 1A 48 8B 05 ?? ?? ?? ?? 48 8B 00 80 B8 ?? ?? ?? ?? 00 74 07");
            IntPtr baseOffset = scanOffset + proc.ReadValue<int>(scanOffset) + 4;
            var sharedOffset = new DeepPointer(baseOffset, 0, 0x44).Deref<int>(proc);
            romOffset = sharedOffset + 0x18;
            wramOffset = sharedOffset + 0x190;
        }

        if (proc.ReadValue<int>((IntPtr)romOffset) != 0)
        {
            print("[Autosplitter] ROM Pointer: " + romOffset.ToString("X8"));
            print("[Autosplitter] WRAM Pointer: " + wramOffset.ToString("X8"));

            vars.watchers = new MemoryWatcherList { new MemoryWatcher<byte>(new DeepPointer((int)(romOffset - baseAddress), 0x14A)) { Name = "version" } };
            vars.watchers.UpdateAll(proc);
            vars.watchers.AddRange(vars.GetWatcherList((int)(romOffset - baseAddress), (int)(wramOffset - baseAddress)));
            
            return true;
        }

        return false;
    });

    vars.SigScan = (Func<Process, int, string, IntPtr>)((proc, offset, signature) =>
    {
        print("[Autosplitter] Scanning memory");

        var target = new SigScanTarget(offset, signature);
        IntPtr result = IntPtr.Zero;
        foreach (var page in proc.MemoryPages(true))
        {
            var scanner = new SignatureScanner(proc, page.BaseAddress, (int)page.RegionSize);
            if ((result = scanner.Scan(target)) != IntPtr.Zero)
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

    if (!vars.TryFindOffsets(game, modules.First().ModuleMemorySize, (long)modules.First().BaseAddress))
        throw new Exception("Emulated memory not yet initialized.");
    else
        refreshRate = 200/3.0;
}

update
{
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

exit
{
    refreshRate = 0.5;
}

shutdown
{
    timer.OnStart -= vars.timer_OnStart;
}