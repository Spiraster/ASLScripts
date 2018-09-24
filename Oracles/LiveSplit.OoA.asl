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
    settings.Add("keyItems", true, "Key Items Splits");
    settings.Add("misc", true, "Miscellaneous Splits");

    settings.CurrentDefaultParent = "entrances";
    settings.Add("d1Enter", true, "Spirit's Grave (D1)");
    settings.Add("d2Enter", true, "Wing Dungeon (D2)");
    settings.Add("d3Enter", true, "Moonlit Grotto (D3)");
    settings.Add("d4Enter", true, "Skull Dungeon (D4)");
    settings.Add("d5Enter", true, "Crown Dungeon (D5)");
    settings.Add("d6Enter", true, "Mermaid's Cave (D6)");

    settings.CurrentDefaultParent = "essences";
    settings.Add("d1Ess", true, "Eternal Spirit (D1)");
    settings.Add("d2Ess", true, "Ancient Wood (D2)");
    settings.Add("d3Ess", true, "Echoing Howl (D3)");
    settings.Add("d6Ess", true, "Bereft Peak (D6)");

    settings.CurrentDefaultParent = "boss";
    settings.Add("greatMoblin", true, "Great Moblin");
    settings.Add("nayru", true, "Save Nayru");
    settings.Add("veranEnter", false, "Enter Veran Fight");
    settings.Add("veran", true, "Defeat Veran");

    settings.CurrentDefaultParent = "items";
    settings.Add("l1Sword", true, "Sword (L1)");
    settings.Add("seedSatchel", false, "Seed Satchel");
    settings.Add("feather", true, "Feather");
    settings.Add("seedShooter", true, "Seed Shooter");
    settings.Add("switchHook", true, "Switch Hook");
    settings.Add("cane", true, "Cane of Somaria");
    settings.Add("fluteR", false, "Flute (Ricky)");
    settings.Add("fluteD", true, "Flute (Dimitri)");
    settings.Add("fluteM", false, "Flute (Moosh)");
    settings.Add("harp1", true, "Harp of Ages");
    settings.Add("harp2", true, "Tune of Currents");

    settings.CurrentDefaultParent = "keyItems";
    settings.Add("rope", false, "Rope");
    settings.Add("chart", false, "Chart");
    settings.Add("tuniNut", false, "Tuni Nut");
    settings.Add("lavaJuice", true, "Lava Juice");
    settings.Add("mermaidSuit", false, "Mermaid Suit");
    settings.Add("d6BossKey", true, "D6 Boss Key");

    settings.CurrentDefaultParent = "misc";
    settings.Add("d2Skip", false, "D2 Skip");
    settings.Add("shipwreck", true, "Crescent Island (shipwreck)");
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
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x924)) { Name = "d1Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x946)) { Name = "d2Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x966)) { Name = "d3Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x991)) { Name = "d4Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x9BB)) { Name = "d5Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA44)) { Name = "d6Enter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x9D4)) { Name = "veranEnter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x911)) { Name = "d1Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x938)) { Name = "d2Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x949)) { Name = "d3Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA37)) { Name = "d6Ess" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x10B3)) { Name = "nayruHP" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x10A9)) { Name = "veranHP" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1084)) { Name = "bossPhase" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x6B2)) { Name = "sword" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x738)) { Name = "seedSatchel" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x928)) { Name = "feather" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x958)) { Name = "seedShooter" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x987)) { Name = "switchHook" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x9A5)) { Name = "cane" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x6B5)) { Name = "flute" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x8AE)) { Name = "harp1" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x88F)) { Name = "harp2" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x6A4)) { Name = "raft" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x6C2)) { Name = "tuniNut" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x8E7)) { Name = "lavaJuice" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA13)) { Name = "mermaidSuit" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xA1C)) { Name = "d6BossKey" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x82E)) { Name = "d2Skip" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x8AA)) { Name = "shipwreck" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x709)) { Name = "greatMoblin" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0xB00)) { Name = "fileSelect1" },
            new MemoryWatcher<short>(new DeepPointer(wramOffset, 0xBB3)) { Name = "fileSelect2" },
            //new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1EFF)) { Name = "resetCheck" },
        };
    });

    vars.GetSplitList = (Func<Dictionary<string, Dictionary<string, int>>>)(() =>
    {
        return new Dictionary<string, Dictionary<string, int>>
        {
            { "d1Enter", new Dictionary<string, int> { { "d1Enter", 0x10 } } },
            { "d2Enter", new Dictionary<string, int> { { "d2Enter", 0x10 } } },
            { "d3Enter", new Dictionary<string, int> { { "d3Enter", 0x10 } } },
            { "d4Enter", new Dictionary<string, int> { { "d4Enter", 0x10 } } },
            { "d5Enter", new Dictionary<string, int> { { "d5Enter", 0x10 } } },
            { "d6Enter", new Dictionary<string, int> { { "d6Enter", 0x10 } } },
            { "veranEnter", new Dictionary<string, int> { { "veranEnter", 0x10 } } },
            { "d1Ess", new Dictionary<string, int> { { "d1Ess", 0x30 } } },
            { "d2Ess", new Dictionary<string, int> { { "d2Ess", 0x30 } } },
            { "d3Ess", new Dictionary<string, int> { { "d3Ess", 0x30 } } },
            { "d6Ess", new Dictionary<string, int> { { "d6Ess", 0x30 } } },
            { "nayru", new Dictionary<string, int> { { "nayruHP", 0x01 }, { "bossPhase", 0x12 } } },
            { "veran", new Dictionary<string, int> { { "veranHP", 0x01 }, { "veranEnter", 0x10 } } },
            { "l1Sword", new Dictionary<string, int> { { "sword", 0x01 } } },
            { "seedSatchel", new Dictionary<string, int> { { "seedSatchel", 0xB0 } } },
            { "feather", new Dictionary<string, int> { { "feather", 0x30 } } },
            { "seedShooter", new Dictionary<string, int> { { "seedShooter", 0x30 } } },
            { "switchHook", new Dictionary<string, int> { { "switchHook", 0x34 } } },
            { "cane", new Dictionary<string, int> { { "cane", 0x30 } } },
            { "fluteR", new Dictionary<string, int> { { "flute", 0x01 } } },
            { "fluteD", new Dictionary<string, int> { { "flute", 0x02 } } },
            { "fluteM", new Dictionary<string, int> { { "flute", 0x03 } } },
            { "harp1", new Dictionary<string, int> { { "harp1", 0x30 } } },
            { "harp2", new Dictionary<string, int> { { "harp2", 0x30 } } },
            { "rope", new Dictionary<string, int> { { "raft", 0x04 } } },
            { "chart", new Dictionary<string, int> { { "raft", 0x10 } } },
            { "tuniNut", new Dictionary<string, int> { { "tuniNut", 0x02 } } },
            { "lavaJuice", new Dictionary<string, int> { { "lavaJuice", 0x30 } } },
            { "mermaidSuit", new Dictionary<string, int> { { "mermaidSuit", 0x30 } } },
            { "d6BossKey", new Dictionary<string, int> { { "d6BossKey", 0x30 } } },
            { "d2Skip", new Dictionary<string, int> { { "d2Skip", 0x10 } } },
            { "shipwreck", new Dictionary<string, int> { { "shipwreck", 0x10 } } },
            { "greatMoblin", new Dictionary<string, int> { { "greatMoblin", 0x11 } } },
        };
    });
}

init
{
    vars.watchers = new MemoryWatcherList();
    vars.splits = new List<Tuple<string, List<Tuple<string, int>>>>();

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