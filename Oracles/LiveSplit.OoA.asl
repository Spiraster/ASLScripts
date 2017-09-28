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
            new MemoryWatcher<byte>(wramOffset + 0x924) { Name = "d1Enter" },
            new MemoryWatcher<byte>(wramOffset + 0x946) { Name = "d2Enter" },
            new MemoryWatcher<byte>(wramOffset + 0x966) { Name = "d3Enter" },
            new MemoryWatcher<byte>(wramOffset + 0x991) { Name = "d4Enter" },
            new MemoryWatcher<byte>(wramOffset + 0x9BB) { Name = "d5Enter" },
            new MemoryWatcher<byte>(wramOffset + 0xA44) { Name = "d6Enter" },
            new MemoryWatcher<byte>(wramOffset + 0x9D4) { Name = "veranEnter" },
            new MemoryWatcher<byte>(wramOffset + 0x911) { Name = "d1Ess" },
            new MemoryWatcher<byte>(wramOffset + 0x938) { Name = "d2Ess" },
            new MemoryWatcher<byte>(wramOffset + 0x949) { Name = "d3Ess" },
            new MemoryWatcher<byte>(wramOffset + 0xA37) { Name = "d6Ess" },
            new MemoryWatcher<byte>(wramOffset + 0x10B3) { Name = "nayruHP" },
            new MemoryWatcher<byte>(wramOffset + 0x10A9) { Name = "veranHP" },
            new MemoryWatcher<byte>(wramOffset + 0x1084) { Name = "bossPhase" },
            new MemoryWatcher<byte>(wramOffset + 0x6B2) { Name = "sword" },
            new MemoryWatcher<byte>(wramOffset + 0x738) { Name = "seedSatchel" },
            new MemoryWatcher<byte>(wramOffset + 0x928) { Name = "feather" },
            new MemoryWatcher<byte>(wramOffset + 0x958) { Name = "seedShooter" },
            new MemoryWatcher<byte>(wramOffset + 0x987) { Name = "switchHook" },
            new MemoryWatcher<byte>(wramOffset + 0x9A5) { Name = "cane" },
            new MemoryWatcher<byte>(wramOffset + 0x6B5) { Name = "flute" },
            new MemoryWatcher<byte>(wramOffset + 0x8AE) { Name = "harp1" },
            new MemoryWatcher<byte>(wramOffset + 0x88F) { Name = "harp2" },
            new MemoryWatcher<byte>(wramOffset + 0x6A4) { Name = "raft" },
            new MemoryWatcher<byte>(wramOffset + 0x6C2) { Name = "tuniNut" },
            new MemoryWatcher<byte>(wramOffset + 0x8E7) { Name = "lavaJuice" },
            new MemoryWatcher<byte>(wramOffset + 0xA13) { Name = "mermaidSuit" },
            new MemoryWatcher<byte>(wramOffset + 0xA1C) { Name = "d6BossKey" },
            new MemoryWatcher<byte>(wramOffset + 0x82E) { Name = "d2Skip" },
            new MemoryWatcher<byte>(wramOffset + 0x8AA) { Name = "shipwreck" },
            new MemoryWatcher<byte>(wramOffset + 0x709) { Name = "greatMoblin" },
            new MemoryWatcher<byte>(wramOffset + 0xB00) { Name = "fileSelect1" },
            new MemoryWatcher<short>(wramOffset + 0xBB3) { Name = "fileSelect2" },
            //new MemoryWatcher<byte>(wramOffset + 0x1EFF) { Name = "resetCheck" },
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
            Tuple.Create("veranEnter", new List<Tuple<string, int>> { Tuple.Create("veranEnter", 0x10) }),
            Tuple.Create("d1Ess", new List<Tuple<string, int>> { Tuple.Create("d1Ess", 0x30) }),
            Tuple.Create("d2Ess", new List<Tuple<string, int>> { Tuple.Create("d2Ess", 0x30) }),
            Tuple.Create("d3Ess", new List<Tuple<string, int>> { Tuple.Create("d3Ess", 0x30) }),
            Tuple.Create("d6Ess", new List<Tuple<string, int>> { Tuple.Create("d6Ess", 0x30) }),
            Tuple.Create("nayru", new List<Tuple<string, int>> { Tuple.Create("nayruHP", 0x01), Tuple.Create("bossPhase", 0x12) }),
            Tuple.Create("veran", new List<Tuple<string, int>> { Tuple.Create("veranHP", 0x01), Tuple.Create("veranEnter", 0x10) }),
            Tuple.Create("l1Sword", new List<Tuple<string, int>> { Tuple.Create("sword", 0x01) }),
            Tuple.Create("seedSatchel", new List<Tuple<string, int>> { Tuple.Create("seedSatchel", 0xB0) }),
            Tuple.Create("feather", new List<Tuple<string, int>> { Tuple.Create("feather", 0x30) }),
            Tuple.Create("seedShooter", new List<Tuple<string, int>> { Tuple.Create("seedShooter", 0x30) }),
            Tuple.Create("switchHook", new List<Tuple<string, int>> { Tuple.Create("switchHook", 0x34) }),
            Tuple.Create("cane", new List<Tuple<string, int>> { Tuple.Create("cane", 0x30) }),
            Tuple.Create("fluteR", new List<Tuple<string, int>> { Tuple.Create("flute", 0x01) }),
            Tuple.Create("fluteD", new List<Tuple<string, int>> { Tuple.Create("flute", 0x02) }),
            Tuple.Create("fluteM", new List<Tuple<string, int>> { Tuple.Create("flute", 0x03) }),
            Tuple.Create("harp1", new List<Tuple<string, int>> { Tuple.Create("harp1", 0x30) }),
            Tuple.Create("harp2", new List<Tuple<string, int>> { Tuple.Create("harp2", 0x30) }),
            Tuple.Create("rope", new List<Tuple<string, int>> { Tuple.Create("raft", 0x04) }),
            Tuple.Create("chart", new List<Tuple<string, int>> { Tuple.Create("raft", 0x10) }),
            Tuple.Create("tuniNut", new List<Tuple<string, int>> { Tuple.Create("tuniNut", 0x02) }),
            Tuple.Create("lavaJuice", new List<Tuple<string, int>> { Tuple.Create("lavaJuice", 0x30) }),
            Tuple.Create("mermaidSuit", new List<Tuple<string, int>> { Tuple.Create("mermaidSuit", 0x30) }),
            Tuple.Create("d6BossKey", new List<Tuple<string, int>> { Tuple.Create("d6BossKey", 0x30) }),
            Tuple.Create("d2Skip", new List<Tuple<string, int>> { Tuple.Create("d2Skip", 0x10) }),
            Tuple.Create("shipwreck", new List<Tuple<string, int>> { Tuple.Create("shipwreck", 0x10) }),
            Tuple.Create("greatMoblin", new List<Tuple<string, int>> { Tuple.Create("greatMoblin", 0x11) }),
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