state("gambatte") {}
state("gambatte_qt") {}

startup
{
    //-------------------------------------------------------------//
    settings.Add("nidoran", true, "Catch Nidoran");
    settings.Add("enterMtMoon", true, "Enter Mt. Moon");
    settings.Add("exitMtMoon", true, "Exit Mt. Moon");
    settings.Add("nuggetBridge", true, "Nugget Bridge");
    settings.Add("hm02", true, "Obtain HM02");
    settings.Add("flute", true, "Obtain Poké Flute");
    settings.Add("silphGiovanni", true, "Silph Co. (Giovanni)");
    settings.Add("exitVictoryRoad", true, "Exit Victory Road");
    settings.Add("gym1", true, "Pewter Gym (Brock)");
    settings.Add("gym2", true, "Cerulean Gym (Misty)");
    settings.Add("gym3", true, "Vermilion Gym (Lt. Surge)");
    settings.Add("gym4", true, "Celadon Gym (Erika)");
    settings.Add("gym5", true, "Fuchsia Gym (Koga)");
    settings.Add("gym6", true, "Saffron Gym (Sabrina)");
    settings.Add("gym7", true, "Cinnabar Gym (Blaine)");
    settings.Add("gym8", true, "Viridian Gym (Giovanni)");
    settings.Add("elite4_1", true, "Lorelei");
    settings.Add("elite4_2", true, "Bruno");
    settings.Add("elite4_3", true, "Agatha");
    settings.Add("elite4_4", true, "Lance");
    settings.Add("elite4_5", true, "Champion");
    settings.Add("hofFade", true, "HoF Fade Out (Final Split)");
    //-------------------------------------------------------------//

    vars.stopwatch = new Stopwatch();

    vars.timer_OnStart = (EventHandler)((s, e) =>
    {
        vars.splits = vars.GetSplitList();
    });
    timer.OnStart += vars.timer_OnStart;

    vars.FindOffsets = (Action<Process>)((proc) => 
    {
        if (vars.ptrOffset == IntPtr.Zero)
        {
            print("[Autosplitter] Scanning memory");
            var target = new SigScanTarget(0, "05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ?? ?? ?? ?? ?? ?? ?? ?? F8 00 00 00");

            var ptrOffset = IntPtr.Zero;
            foreach (var page in proc.MemoryPages())
            {
                var scanner = new SignatureScanner(proc, page.BaseAddress, (int)page.RegionSize);

                if ((ptrOffset = scanner.Scan(target)) != IntPtr.Zero)
                    break;
            }

            vars.ptrOffset = ptrOffset;
            vars.hramOffset = vars.ptrOffset + 0x1E0;
            vars.wramPtr = new MemoryWatcher<int>(vars.ptrOffset - 0x20);
        }

        if (vars.ptrOffset != IntPtr.Zero)
        {
            vars.wramPtr.Update(proc);
            vars.wramOffset = (IntPtr)vars.wramPtr.Current;
        }

        if (vars.wramOffset != IntPtr.Zero && vars.hramOffset != IntPtr.Zero)
        {
            print("[Autosplitter] WRAM: " + vars.wramOffset.ToString("X8"));
            print("[Autosplitter] HRAM: " + vars.hramOffset.ToString("X8"));
        }
    });

    vars.GetWatcherList = (Func<IntPtr, IntPtr, MemoryWatcherList>)((wramOffset, hramOffset) =>
    {   
        return new MemoryWatcherList
        {
            //WRAM
            new MemoryWatcher<byte>(wramOffset + 0x0001) { Name = "soundID" },
            new MemoryWatcher<uint>(wramOffset + 0x03C9) { Name = "fileSelectTiles" },
            new MemoryWatcher<uint>(wramOffset + 0x0477) { Name = "resetTiles" },
            new MemoryWatcher<uint>(wramOffset + 0x0D40) { Name = "hofPlayerShown" },
            new MemoryWatcher<byte>(wramOffset + 0x0FD8) { Name = "opponentPkmn" },
            new MemoryWatcher<uint>(wramOffset + 0x0FDA) { Name = "opponentPkmnName" },
            new MemoryWatcher<uint>(wramOffset + 0x104A) { Name = "opponentName" },
            new MemoryWatcher<byte>(wramOffset + 0x1163) { Name = "partyCount" },
            new MemoryWatcher<byte>(wramOffset + 0x135E) { Name = "mapIndex" },
            new MemoryWatcher<ushort>(wramOffset + 0x1361) { Name = "playerPos" },
            new MemoryWatcher<ushort>(wramOffset + 0x1FD7) { Name = "hofFadeTimer" },
            new MemoryWatcher<ushort>(wramOffset + 0x1FFD) { Name = "state" },

            //HRAM  
            new MemoryWatcher<byte>(hramOffset + 0x33) { Name = "input" },         
        };
    });

    vars.GetSplitList = (Func<List<Tuple<string, List<Tuple<string, uint>>>>>)(() =>
    {
        return new List<Tuple<string, List<Tuple<string, uint>>>>
        {
            Tuple.Create("nidoran", new List<Tuple<string, uint>> { Tuple.Create("partyCount", 2u), Tuple.Create("state", 0x03AEu) }),
            Tuple.Create("enterMtMoon", new List<Tuple<string, uint>> { Tuple.Create("mapIndex", 0x3Bu), Tuple.Create("playerPos", 0x0E23u) }),
            Tuple.Create("exitMtMoon", new List<Tuple<string, uint>> { Tuple.Create("mapIndex", 0x0Fu), Tuple.Create("playerPos", 0x1805u) }),
            Tuple.Create("nuggetBridge", new List<Tuple<string, uint>> { Tuple.Create("opponentName", 0x8A828E91), Tuple.Create("mapIndex", 0x23u), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }),
            Tuple.Create("hm02", new List<Tuple<string, uint>> { Tuple.Create("soundID", 0x94u), Tuple.Create("mapIndex", 0xBCu) }),
            Tuple.Create("flute", new List<Tuple<string, uint>> { Tuple.Create("soundID", 0x94u), Tuple.Create("mapIndex", 0x95u) }),
            Tuple.Create("silphGiovanni", new List<Tuple<string, uint>> { Tuple.Create("opponentName", 0x958E8886), Tuple.Create("mapIndex", 0xEBu), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }),
            Tuple.Create("exitVictoryRoad", new List<Tuple<string, uint>> { Tuple.Create("mapIndex", 0x22u), Tuple.Create("playerPos", 0x0E1Fu) }),
            Tuple.Create("gym1", new List<Tuple<string, uint>> { Tuple.Create("opponentName", 0x828E9181), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }),
            Tuple.Create("gym2", new List<Tuple<string, uint>> { Tuple.Create("opponentName", 0x9392888C), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }),
            Tuple.Create("gym3", new List<Tuple<string, uint>> { Tuple.Create("opponentName", 0x92E8938B), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }),
            Tuple.Create("gym4", new List<Tuple<string, uint>> { Tuple.Create("opponentName", 0x8A889184), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }),
            Tuple.Create("gym5", new List<Tuple<string, uint>> { Tuple.Create("opponentName", 0x80868E8A), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }),
            Tuple.Create("gym6", new List<Tuple<string, uint>> { Tuple.Create("opponentName", 0x91818092), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }),
            Tuple.Create("gym7", new List<Tuple<string, uint>> { Tuple.Create("opponentName", 0x88808B81), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }),
            Tuple.Create("gym8", new List<Tuple<string, uint>> { Tuple.Create("opponentName", 0x958E8886), Tuple.Create("mapIndex", 0x2Du), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }),
            Tuple.Create("elite4_1", new List<Tuple<string, uint>> { Tuple.Create("opponentName", 0x84918E8B), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }), //Tuple.Create("mapIndex", 0xF5u)
            Tuple.Create("elite4_2", new List<Tuple<string, uint>> { Tuple.Create("opponentName", 0x8D949181), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }), //Tuple.Create("mapIndex", 0xF6u)
            Tuple.Create("elite4_3", new List<Tuple<string, uint>> { Tuple.Create("opponentName", 0x93808680), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }), //Tuple.Create("mapIndex", 0xF7u)
            Tuple.Create("elite4_4", new List<Tuple<string, uint>> { Tuple.Create("opponentName", 0x828D808B), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }), //Tuple.Create("mapIndex", 0x71u)
            Tuple.Create("elite4_5", new List<Tuple<string, uint>> { Tuple.Create("opponentPkmnName", 0x948D8495), Tuple.Create("mapIndex", 0x78u), Tuple.Create("opponentPkmn", 0u), Tuple.Create("state", 0x03AEu) }),
            Tuple.Create("hofFade", new List<Tuple<string, uint>> { Tuple.Create("mapIndex", 0x76u), Tuple.Create("hofPlayerShown", 1u), Tuple.Create("hofFadeTimer", 0x0108u) }),
        };
    });
}

init
{
    vars.ptrOffset = IntPtr.Zero;
    vars.wramOffset = IntPtr.Zero;
    vars.hramOffset = IntPtr.Zero;
    
    vars.wramPtr = new MemoryWatcher<byte>(IntPtr.Zero);

    vars.watchers = new MemoryWatcherList();
    vars.splits = new List<Tuple<string, List<Tuple<string, uint>>>>();

    vars.stopwatch.Restart();
}

update
{
    if (vars.stopwatch.ElapsedMilliseconds > 1500)
    {
        vars.FindOffsets(game);

        if (vars.wramOffset != IntPtr.Zero && vars.hramOffset != IntPtr.Zero)
        {
            vars.watchers = vars.GetWatcherList(vars.wramOffset, vars.hramOffset);
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

    vars.wramPtr.Update(game);

    if (vars.wramPtr.Changed)
    {
        vars.FindOffsets(game);
        vars.watchers = vars.GetWatcherList(vars.wramOffset, vars.hramOffset);
    }

    vars.watchers.UpdateAll(game);
}

start
{
    return (vars.watchers["input"].Current & 0x09) != 0 && vars.watchers["fileSelectTiles"].Current == 0x96848DED && vars.watchers["state"].Current == 0x5B91;
}

reset
{
    return (vars.watchers["input"].Current & 0x01) != 0 && vars.watchers["resetTiles"].Current == 0x928498ED;
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