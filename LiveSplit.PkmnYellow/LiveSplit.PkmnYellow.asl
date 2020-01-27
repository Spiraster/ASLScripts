state("gambatte_qt") {}

startup
{
    //-------------------------------------------------------------//
    settings.Add("battles", true, "Battles");
    settings.Add("other", true, "Other");

    settings.CurrentDefaultParent = "battles";
    settings.Add("nidoran", true, "Viridian Forest House");
    settings.Add("silphGiovanni", true, "Silph Co. (Giovanni)");
    settings.Add("nuggetBridge", true, "Nugget Bridge (Rocket)");
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
    settings.Add("elite4_5b", true, "Champion (vape)", "elite4_5");

    settings.CurrentDefaultParent = "other";
    settings.Add("rival", false, "Leave Oak's Lab (after rival fight)");
    settings.Add("enterMtMoon", true, "Enter Mt. Moon");
    settings.Add("exitMtMoon", true, "Exit Mt. Moon");
    settings.Add("exitViridianForest", true, "Exit Viridian Forest");
    settings.Add("exitVictoryRoad", true, "Exit Victory Road");
    settings.Add("hm02", true, "Obtain HM02");
    settings.Add("flute", true, "Obtain Poké Flute");
    settings.Add("hof", true, "HoF Fade Out");
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
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0001)) { Name = "soundID" }, // OK
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0490)) { Name = "hofTile" }, // WIP
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0C26)) { Name = "cursorIndex" }, /// OK
            new MemoryWatcher<uint>(new DeepPointer(wramOffset, 0x0D40)) { Name = "hofPlayerShown" }, // OK
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x0FD7)) { Name = "enemyPkmn" }, // CFD8 -> CFD7
            new MemoryWatcher<uint>(new DeepPointer(wramOffset, 0x0FD9)) { Name = "enemyPkmnName" }, //CFDA -> CFD9
            new MemoryWatcher<uint>(new DeepPointer(wramOffset, 0x1049)) { Name = "opponentName" }, //D04A -> D049
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1162)) { Name = "partyCount" }, //D163 -> D162
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x1358)) { Name = "playerID" }, //D359 -> D358
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x135D)) { Name = "mapIndex" }, //D35E -> D35D
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x1360)) { Name = "playerPos" }, //D361 -> D360
            new MemoryWatcher<ushort>(new DeepPointer(wramOffset, 0x1FFD)) { Name = "stack" },

            new MemoryWatcher<byte>(hramOffset + 0x34) { Name = "input" }, // ?
            new MemoryWatcher<byte>(rBGP) { Name = "rBGP" }, // ?
        };
    });

    vars.GetSplitList = (Func<Dictionary<string, Dictionary<string, uint>>>)(() =>
    {
        return new Dictionary<string, Dictionary<string, uint>>
        {
            { "nidoran", new Dictionary<string, uint> { { "mapIndex", 0x32u }, { "playerPos", 0x032Bu } } },
            { "nuggetBridge", new Dictionary<string, uint> { { "opponentName", 0x8A828E91 }, { "mapIndex", 0x23u }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } },
            { "silphGiovanni", new Dictionary<string, uint> { { "opponentName", 0x958E8886 }, { "mapIndex", 0xEBu }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } },
            { "gym1", new Dictionary<string, uint> { { "opponentName", 0x828E9181 }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } },
            { "gym2", new Dictionary<string, uint> { { "opponentName", 0x9392888C }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } },
            { "gym3", new Dictionary<string, uint> { { "opponentName", 0x92E8938B }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } },
            { "gym4", new Dictionary<string, uint> { { "opponentName", 0x8A889184 }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } },
            { "gym5", new Dictionary<string, uint> { { "opponentName", 0x80868E8A }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } },
            { "gym6", new Dictionary<string, uint> { { "opponentName", 0x91818092 }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } },
            { "gym7", new Dictionary<string, uint> { { "opponentName", 0x88808B81 }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } },
            { "gym8", new Dictionary<string, uint> { { "opponentName", 0x958E8886 }, { "mapIndex", 0x2Du }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } },
            { "elite4_1", new Dictionary<string, uint> { { "opponentName", 0x84918E8B }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } }, //{ "mapIndex", 0xF5u }
            { "elite4_2", new Dictionary<string, uint> { { "opponentName", 0x8D949181 }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } }, //{ "mapIndex", 0xF6u }
            { "elite4_3", new Dictionary<string, uint> { { "opponentName", 0x93808680 }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } }, //{ "mapIndex", 0xF7u }
            { "elite4_4", new Dictionary<string, uint> { { "opponentName", 0x828D808B }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } }, //{ "mapIndex", 0x71u }
            { "elite4_5", new Dictionary<string, uint> { { "enemyPkmnName", 0x91808B85 }, { "mapIndex", 0x78u }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } },
            { "elite4_5b", new Dictionary<string, uint> { { "enemyPkmnName", 0x8E8F8095 }, { "mapIndex", 0x78u }, { "enemyPkmn", 0u }, { "stack", 0x0454u } } },

            { "rival", new Dictionary<string, uint> { { "mapIndex", 0u }, { "partyCount", 1u } } },
            { "enterMtMoon", new Dictionary<string, uint> { { "mapIndex", 0x3Bu }, { "playerPos", 0x0E23u } } },
            { "exitMtMoon", new Dictionary<string, uint> { { "mapIndex", 0x0Fu }, { "playerPos", 0x1805u } } },
            { "exitVictoryRoad", new Dictionary<string, uint> { { "mapIndex", 0x22u }, { "playerPos", 0x0E1Fu } } },
            { "exitViridianForest", new Dictionary<string, uint> { { "mapIndex", 0x2Fu}, { "playerPos", 0x0407u } } },
            { "hm02", new Dictionary<string, uint> { { "soundID", 0x94u }, { "mapIndex", 0xBCu } } },
            { "flute", new Dictionary<string, uint> { { "soundID", 0x94u }, { "mapIndex", 0x95u } } },
            { "hof", new Dictionary<string, uint> { { "mapIndex", 0x76u }, { "hofPlayerShown", 1u }, { "hofTile", 0x79u }, { "rBGP", 0u } } },
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

start
{
    return vars.watchers["cursorIndex"].Current == 0 && (vars.watchers["input"].Current & 0x1) == 1 && vars.watchers["playerID"].Current == 0 && vars.watchers["stack"].Current == 0x5C43;//0x5B91;
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
