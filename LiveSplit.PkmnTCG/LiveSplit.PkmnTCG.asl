state("gambatte_qt") {}

startup
{
    //-------------------------------------------------------------//
    settings.Add("isaac", true, "Isaac");
    settings.Add("nikki", true, "Nikki");
    settings.Add("amy", true, "Amy");
    settings.Add("gene", true, "Gene");
    settings.Add("ken", true, "Ken");
    settings.Add("murray", true, "Murray");
    settings.Add("rick", true, "Rick");
    settings.Add("mitch", true, "Mitch");
    settings.Add("courtney", true, "Courtney");
    settings.Add("steve", true, "Steve");
    settings.Add("jack", true, "Jack");
    settings.Add("rod", true, "Rod");
    settings.Add("ronald", false, "Ronald");
    settings.Add("end", true, "End");
    //-------------------------------------------------------------//

    refreshRate = 0.5;

    vars.timer_OnStart = (EventHandler)((s, e) =>
    {
        vars.splits = vars.GetSplitList();
    });
    timer.OnStart += vars.timer_OnStart;

    vars.TryFindOffsets = (Func<Process, bool>)((proc) =>
    {
        print("[Autosplitter] Scanning memory");
        var target = new SigScanTarget(0, "20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 05 00 00");

        int scanOffset = 0;
        foreach (var page in proc.MemoryPages())
        {
            var scanner = new SignatureScanner(proc, page.BaseAddress, (int)page.RegionSize);
            if ((scanOffset = (int)scanner.Scan(target)) != 0)
                break;
        }

        if (scanOffset != 0)
        {
            var wramOffset = scanOffset - 0x10;
            print("[Autosplitter] WRAM Pointer: " + wramOffset.ToString("X8"));

            vars.watchers = vars.GetWatcherList((int)(wramOffset - 0x400000), (IntPtr)(scanOffset + 0x147C), (IntPtr)(scanOffset + 0x1443));

            return true;
        }

        return false;
    });

    vars.GetWatcherList = (Func<int, IntPtr, IntPtr, MemoryWatcherList>)((wramOffset, hramOffset, rBGP) =>
    {
        return new MemoryWatcherList
        {
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x10BB)) { Name = "roomID" },
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x0C16)) { Name = "opponentName" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0C07)) { Name = "duelFinished"},
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0C05)) { Name = "whoseTurn"}, //C2 is ours, C3 is theirs
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x10B5)) { Name = "inEvent"},
        };
    });

    vars.GetSplitList = (Func<Dictionary<string, Dictionary<string, uint>>>)(() =>
    {
        return new Dictionary<string, Dictionary<string, uint>>
        {
            { "isaac", new Dictionary<string, uint> { { "opponentName", 0x03C3u }, { "duelFinished", 0x01u }, { "whoseTurn", 0xC2u }, { "inEvent", 0x00u } } },
            { "nikki", new Dictionary<string, uint> { { "opponentName", 0x03C7u }, { "duelFinished", 0x01u }, { "whoseTurn", 0xC2u }, { "inEvent", 0x00u } } },
            { "amy", new Dictionary<string, uint> { { "opponentName", 0x03BFu }, { "duelFinished", 0x01u }, { "whoseTurn", 0xC2u }, { "inEvent", 0x00u } } },
            { "gene", new Dictionary<string, uint> { { "opponentName", 0x03BBu }, { "duelFinished", 0x01u }, { "whoseTurn", 0xC2u }, { "inEvent", 0x00u } } },
            { "ken", new Dictionary<string, uint> { { "opponentName", 0x03E3u }, { "duelFinished", 0x01u }, { "whoseTurn", 0xC2u }, { "inEvent", 0x00u } } },
            { "murray", new Dictionary<string, uint> { { "opponentName", 0x03CBu }, { "duelFinished", 0x01u }, { "whoseTurn", 0xC2u }, { "inEvent", 0x00u } } },
            { "rick", new Dictionary<string, uint> { { "opponentName", 0x03CFu }, { "duelFinished", 0x01u }, { "whoseTurn", 0xC2u }, { "inEvent", 0x00u } } },
            { "mitch", new Dictionary<string, uint> { { "opponentName", 0x03B7u }, { "duelFinished", 0x01u }, { "whoseTurn", 0xC2u }, { "inEvent", 0x00u } } },
            { "courtney", new Dictionary<string, uint> { { "opponentName", 0x03D4u }, { "duelFinished", 0x01u }, { "whoseTurn", 0xC2u }, { "inEvent", 0x00u } } },
            { "steve", new Dictionary<string, uint> { { "opponentName", 0x03D5u }, { "duelFinished", 0x01u }, { "whoseTurn", 0xC2u }, { "inEvent", 0x00u } } },
            { "jack", new Dictionary<string, uint> { { "opponentName", 0x03D6u }, { "duelFinished", 0x01u }, { "whoseTurn", 0xC2u }, { "inEvent", 0x00u } } },
            { "rod", new Dictionary<string, uint> { { "opponentName", 0x03D7u }, { "duelFinished", 0x01u }, { "whoseTurn", 0xC2u }, { "inEvent", 0x00u } } },
            { "ronald", new Dictionary<string, uint> { { "opponentName", 0x3ADu }, { "duelFinished", 0x01u }, { "whoseTurn", 0xC2u }, { "inEvent", 0x00u }, { "roomID", 0x20u } } },
            { "end", new Dictionary<string, uint> { { "roomID", 0x21u }, { "inEvent", 0x04u } } },
        };
    });
}

init
{
    vars.watchers = new MemoryWatcherList();
    vars.splits = new Dictionary<string, Dictionary<string, uint>>();

    if (!vars.TryFindOffsets(game))
        throw new Exception("Emulated memory not yet initialized.");
    else
        refreshRate = 200/3.0;
}

update
{
    vars.watchers.UpdateAll(game);
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
