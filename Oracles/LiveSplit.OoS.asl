state("bgb") {}
state("bgb64") {}
state("gambatte") {}
state("gambatte_qt") {}
state("gambatte_qt_nonpsr") {}
state("emuhawk") {}

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
            { 7249920, 0 }, //BizHawk 2.3.1
        };

        int ptrOffset;
        if (states.TryGetValue(memorySize, out ptrOffset))
        {
            long wramOffset = 0;

            var state = proc.ProcessName.ToLower();
            if (state.Contains("gambatte"))
            {
                var target = new SigScanTarget(0, "20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 05 00 00");

                var scanOffset = vars.SigScan(proc, target);
                if (scanOffset != 0)
                    wramOffset = scanOffset - 0x10;
            }
            else if (state == "emuhawk")
            {
                var target = new SigScanTarget(0, "05 00 00 00 ?? 00 00 00 00 ?? ?? 00 00 ?? ?? 00 00 ?? ?? 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ?? ?? ?? ?? ?? ?? ?? ?? F8 00 00 00");

                var scanOffset = vars.SigScan(proc, target);
                if (scanOffset != 0)
                    wramOffset = scanOffset - 0x40;
            }
            else if (state == "bgb")
                wramOffset = proc.ReadValue<int>(proc.ReadPointer((IntPtr)ptrOffset) + 0x34) + 0x108;
            else if (state == "bgb64")
                wramOffset = proc.ReadValue<int>(proc.ReadPointer((IntPtr)ptrOffset) + 0x44) + 0x190;

            if (proc.ReadValue<int>(proc.ReadPointer((IntPtr)wramOffset)) != 0)
            {
                print("[Autosplitter] WRAM Pointer: " + wramOffset.ToString("X8"));

                vars.watchers = vars.GetWatcherList((int)(wramOffset - baseAddress));
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

    vars.GetWatcherList = (Func<int, MemoryWatcherList>)((wramOffset) =>
    {
        return new MemoryWatcherList
        {
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x91C)) { Name = "d1Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x939)) { Name = "d2Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x94B)) { Name = "d3Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x981)) { Name = "d4Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x9A7)) { Name = "d5Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x9BA)) { Name = "d6Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA5B)) { Name = "d7Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA87)) { Name = "d8Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA97)) { Name = "northernPeakEnter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA91)) { Name = "onoxEnter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x913)) { Name = "d1Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x92C)) { Name = "d2Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x940)) { Name = "d3Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x960)) { Name = "d4Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x988)) { Name = "d5Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x898)) { Name = "d6Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA4F)) { Name = "d7Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA5F)) { Name = "d8Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x11A9)) { Name = "onoxHP" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x6AC)) { Name = "sword" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xB00)) { Name = "fileSelect1" },
            new MemoryWatcher<short>(new DeepPointer(wramOffset, 0xBB3)) { Name = "fileSelect2" },
            // new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1EFF)) { Name = "resetCheck" },
        };
    });

    vars.GetSplitList = (Func<Dictionary<string, Dictionary<string, int>>>)(() =>
    {
        return new Dictionary<string, Dictionary<string, int>>
        {
            { "d1Enter", new Dictionary<string, int> { {"d1Enter", 0x10} } },
            { "d2Enter", new Dictionary<string, int> { {"d2Enter", 0x10} } },
            { "d3Enter", new Dictionary<string, int> { {"d3Enter", 0x10} } },
            { "d4Enter", new Dictionary<string, int> { {"d4Enter", 0x10} } },
            { "d5Enter", new Dictionary<string, int> { {"d5Enter", 0x10} } },
            { "d6Enter", new Dictionary<string, int> { {"d6Enter", 0x10} } },
            { "d7Enter", new Dictionary<string, int> { {"d7Enter", 0x10} } },
            { "d8Enter", new Dictionary<string, int> { {"d8Enter", 0x10} } },
            { "northernPeakEnter", new Dictionary<string, int> { {"northernPeakEnter", 0x10} } },
            { "onoxEnter", new Dictionary<string, int> { {"onoxEnter", 0x10} } },
            { "d1Ess", new Dictionary<string, int> { {"d1Ess", 0x30} } },
            { "d2Ess", new Dictionary<string, int> { {"d2Ess", 0x30} } },
            { "d3Ess", new Dictionary<string, int> { {"d3Ess", 0x30} } },
            { "d4Ess", new Dictionary<string, int> { {"d4Ess", 0x30} } },
            { "d5Ess", new Dictionary<string, int> { {"d5Ess", 0x30} } },
            { "d6Ess", new Dictionary<string, int> { {"d6Ess", 0x30} } },
            { "d7Ess", new Dictionary<string, int> { {"d7Ess", 0x30} } },
            { "d8Ess", new Dictionary<string, int> { {"d8Ess", 0x30} } },
            { "onox", new Dictionary<string, int> { {"onoxHP", 0x01}, {"onoxEnter", 0x10} } },
            { "l1Sword", new Dictionary<string, int> { {"sword", 0x01} } },
        };
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