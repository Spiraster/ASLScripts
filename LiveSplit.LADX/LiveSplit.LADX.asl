state("bgb") {}
state("gambatte") {}
state("gambatte_qt") {}

startup
{
    //-------------------------------------------------------------//
    settings.Add("entrances", true, "Dungeon Entrances");
    settings.Add("instruments", true, "Dungeon Ends (Instruments)");
    settings.Add("items", true, "Items");
    settings.Add("misc", true, "Miscellaneous");

    settings.CurrentDefaultParent = "entrances";
    settings.Add("d1Enter", true, "Tail Cave (D1)");
    settings.Add("d2Enter", true, "Bottle Grotto (D2)");
    settings.Add("d3Enter", true, "Key Cavern (D3)");
    settings.Add("d4Enter", true, "Angler's Tunnel (D4)");
    settings.Add("d5Enter", true, "Catfish's Maw (D5)");
    settings.Add("d6Enter", true, "Face Shrine (D6)");
    settings.Add("d7Enter", true, "Eagle's Tower (D7)");
    settings.Add("d8Enter", true, "Turtle Rock (D8)");
    settings.Add("d0Enter", false, "Color Dungeon (D0)");

    settings.CurrentDefaultParent = "instruments";
    settings.Add("d1End", true, "Full Moon Cello (D1)");
    settings.Add("d2End", true, "Conch Horn (D2)");
    settings.Add("d3End", true, "Sea Lily's Bell (D3)");
    settings.Add("d4End", true, "Surf Harp (D4)");
    settings.Add("d5End", true, "Wind Marimba (D5)");
    settings.Add("d6End", true, "Coral Triangle (D6)");
    settings.Add("d7End", true, "Organ of Evening Calm (D7)");
    settings.Add("d8End", true, "Thunder Drum (D8)");
    settings.Add("d0End", false, "Tunic Upgrade (D0)");
    settings.Add("eggStairs", true, "Wind Fish's Egg (stairs)");

    settings.CurrentDefaultParent = "items";
    settings.Add("tailKey", false, "Tail Key");
    settings.Add("slimeKey", false, "Slime Key");
    settings.Add("anglerKey", false, "Angler Key");
    settings.Add("faceKey", false, "Face Key");
    settings.Add("birdKey", false, "Bird Key");
    settings.Add("feather", false, "Feather");
    settings.Add("bracelet", false, "Bracelet (L1)");
    settings.Add("boots", false, "Boots");
    settings.Add("ocarina", false, "Ocarina");
    settings.Add("flippers", false, "Flippers");
    settings.Add("hookshot", false, "Hookshot");
    settings.Add("l2Shield", false, "Shield (L2)");
    settings.Add("magicRod", false, "Magic Rod");
    settings.Add("magnifyingLens", false, "Magnifying Lens");
    settings.Add("boomerang", false, "Boomerang");
    settings.Add("l1Sword", false, "Sword (L1)");
    settings.Add("l2Sword", false, "Sword (L2)");
    settings.Add("yoshi", false, "Yoshi Doll");

    settings.CurrentDefaultParent = "misc";
    settings.Add("house", false, "Leave starting house");
    settings.Add("woods", false, "Leaving the Mysterious Woods");
    settings.Add("shop", false, "Shoplifting");
    settings.Add("marin", false, "Marin");
    settings.Add("walrus", false, "Walrus");
    settings.Add("d8Exit", false, "Exit D8 to Mountaintop");
    settings.Add("song1", false, "Song #1 (Ballad of the Wind Fish)");
    settings.Add("song2", false, "Song #2 (Manbo's Mambo)");
    settings.Add("song3", false, "Song #3 (Frog's Song of Soul)");
    settings.Add("creditsWarp", false, "Credits Warp (ACE)");
    //-------------------------------------------------------------//

    vars.stopwatch = new Stopwatch();

    vars.TryFindOffsets = (Func<Process, int, bool>)((proc, memorySize) => 
    {
        var states = new Dictionary<int, int>
        {
            { 1691648, 0x55BC7C }, //BGB 1.5.1
            { 1699840, 0x55DCA0 }, //BGB 1.5.2
            { 1736704, 0x564EBC }, //BGB 1.5.3/1.5.4
            { 1740800, 0x566EDC }, //BGB 1.5.5/1.5.6
            { 14290944, 0 }, //GSR r600
            { 14180352, 0 }, //GSR r604/614
        };

        int baseOffset;
        if (states.TryGetValue(memorySize, out baseOffset))
        {
            vars.romOffset = IntPtr.Zero;
            vars.wramOffset = IntPtr.Zero;

            var state = proc.ProcessName.ToLower();
            if (state.Contains("gambatte"))
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
                    vars.romPtr = new MemoryWatcher<int>(vars.ptrOffset - 0x28);
                    vars.wramPtr = new MemoryWatcher<int>(vars.ptrOffset - 0x20);
                }
            }
            else if (state == "bgb")
            {
                if (vars.ptrOffset == IntPtr.Zero)
                {
                    vars.ptrOffset = proc.ReadPointer(proc.ReadPointer((IntPtr)baseOffset) + 0x34);
                    vars.romPtr = new MemoryWatcher<int>(vars.ptrOffset + 0x10);
                    vars.wramPtr = new MemoryWatcher<int>(vars.ptrOffset + 0xC0);
                }

                vars.wramOffset += 0xC000;                
            }

            vars.romPtr.Update(proc);         
            vars.wramPtr.Update(proc);
            vars.romOffset += vars.romPtr.Current;   
            vars.wramOffset += vars.wramPtr.Current;
            if (vars.romOffset != IntPtr.Zero && vars.wramOffset != IntPtr.Zero)
            {
                vars.version = proc.ReadValue<byte>((IntPtr)vars.romOffset + 0x143);
                vars.watchers = vars.GetWatcherList();
                vars.stopwatch.Reset();
                
                print("[Autosplitter] ROM: " + vars.romOffset.ToString("X8"));
                print("[Autosplitter] WRAM: " + vars.wramOffset.ToString("X8"));
                if (vars.version == 0x00)
                    print("[Autosplitter] LA");
                else if (vars.version == 0x80)
                    print("[Autosplitter] LADX");

                return true;
            }
            else
                vars.stopwatch.Restart();
        }
        else
            vars.stopwatch.Reset();

        return false;
    });

    vars.Current = (Func<string, int, bool>)((name, value) => 
    {
        return vars.watchers[name].Current == value;
    });

    vars.Changed = (Func<string, int, bool>)((name, value) => 
    {
        return vars.watchers[name].Changed && vars.watchers[name].Current == value;
    });

    vars.Bit = (Func<int, int, bool>)((value, bit) =>
    {
        return ((value >> bit) & 1) == 1;
    });

    vars.Instrument = (Func<int, bool>)((index) => 
    {
        var flags = vars.watchers["dungeonFlags"].Current;
        var dungeon = BitConverter.GetBytes(flags)[index];
        return vars.Bit(dungeon, 1);
    });

    vars.GetWatcherList = (Func<MemoryWatcherList>)(() =>
    {
        var wram = (IntPtr)vars.wramOffset;
        return new MemoryWatcherList
        {
            new MemoryWatcher<byte>(wram + 0x03B0) { Name = "objectState" },
            new MemoryWatcher<long>(wram + 0x1B65) { Name = "dungeonFlags" },
            new MemoryWatcher<byte>(wram + 0x1B54) { Name = "overworldScreen" },
            new MemoryWatcher<byte>(wram + 0x1BAE) { Name = "submapScreen" },
            new MemoryWatcher<byte>(wram + 0x1B60) { Name = "submapIndex" },
            new MemoryWatcher<byte>(wram + 0x13CA) { Name = "music" },
            new MemoryWatcher<byte>(wram + 0x13C8) { Name = "sound" },
            new MemoryWatcher<byte>(wram + 0x1B11) { Name = "tailKey" },
            new MemoryWatcher<byte>(wram + 0x191D) { Name = "featherRoom" },
            new MemoryWatcher<byte>(wram + 0x1920) { Name = "braceletRoom" },
            new MemoryWatcher<byte>(wram + 0x1946) { Name = "bootsRoom" },
            new MemoryWatcher<byte>(wram + 0x1ABE) { Name = "ocarinaRoom" },
            new MemoryWatcher<byte>(wram + 0x1B0C) { Name = "flippers" },
            new MemoryWatcher<byte>(wram + 0x1B44) { Name = "shieldLevel" },
            new MemoryWatcher<byte>(wram + 0x1A37) { Name = "magicRodRoom" },
            new MemoryWatcher<byte>(wram + 0x1B0E) { Name = "tradingItem" },
            new MemoryWatcher<byte>(wram + 0x1B6E) { Name = "shopThefts" },
            new MemoryWatcher<byte>(wram + 0x1B73) { Name = "marin" },

            new MemoryWatcher<byte>(wram + 0xEFF) { Name = "resetCheck" },
            new MemoryWatcher<short>(wram + 0x1B95) { Name = "gameState" },
        };
    });

    vars.GetSplitList = (Func<Dictionary<string, bool>>)(() =>
    {
        var splits = new Dictionary<string, bool>
        {
            { "d1Enter", vars.Current("submapScreen", 0x3B) && vars.Current("overworldScreen", 0xD3) },
            { "d2Enter", vars.Current("submapIndex", 0x01) && vars.Current("submapScreen", 0x3A) },
            { "d3Enter", vars.Current("submapIndex", 0x02) && vars.Current("submapScreen", 0x39) },
            { "d4Enter", vars.Current("submapIndex", 0x03) && vars.Current("submapScreen", 0x3B) },
            { "d5Enter", vars.Current("submapIndex", 0x04) && vars.Current("submapScreen", 0x3F) },
            { "d6Enter", vars.Current("submapIndex", 0x05) && vars.Current("submapScreen", 0x3B) },
            { "d7Enter", vars.Current("submapIndex", 0x06) && vars.Current("submapScreen", 0x39) },
            { "d8Enter", vars.Current("submapIndex", 0x07) && vars.Current("submapScreen", 0x3B) },
            { "d0Enter", vars.Current("submapIndex", 0xFF) && vars.Current("submapScreen", 0x3A) },
            { "d0End", vars.Current("sound", 0x01) && vars.Current("music", 0x0C) && vars.Current("overworldScreen", 0x77) },
            { "eggStairs", vars.Current("gameState", 0x0201) },
            
            { "tailKey", vars.Changed("tailKey", 0x01) && vars.Current("overworldScreen", 0x41) },
            { "slimeKey", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0xC6) },
            { "anglerKey", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0xCE) },
            { "faceKey", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0xAC) },
            { "birdKey", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0x0A) },
            { "feather", vars.Changed("featherRoom", 0x98) && vars.Current("submapScreen", 0x20) },
            { "bracelet", vars.Changed("braceletRoom", 0x91) && vars.Current("submapIndex", 0x01) },
            { "boots", vars.Changed("bootsRoom", 0x9B) && vars.Current("submapIndex", 0x02) },
            { "ocarina", vars.Changed("ocarinaRoom", 0x90) && vars.Current("submapIndex", 0x13) },
            { "flippers", vars.Changed("flippers", 0x01) && vars.Current("submapIndex", 0x03) },
            { "hookshot", vars.Current("music", 0x10) && vars.Current("submapIndex", 0x04) },
            { "l2Shield", vars.Changed("shieldLevel", 0x02) && vars.Current("submapIndex", 0x06) },
            { "magicRod", vars.Changed("magicRodRoom", 0x98) && vars.Current("submapIndex", 0x07) },
            { "magnifyingLens", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0xE9) },
            { "boomerang", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0xF4) },
            { "l1Sword", vars.Current("music", 0x0F) && vars.Current("overworldScreen", 0xF2) },
            { "l2Sword", vars.Current("music", 0x0F) && vars.Current("overworldScreen", 0x8A) },
            { "yoshi", vars.Changed("tradingItem", 0x01) && vars.Current("overworldScreen", 0xB3) },

            { "house", vars.Current("overworldScreen", 0xA2) },
            { "woods", vars.Current("overworldScreen", 0x90) && vars.Current("tailKey", 0x01) },
            { "shop", vars.Changed("shopThefts", 0x02) && vars.Current("overworldScreen", 0x93) },
            { "marin", vars.Changed("marin", 0x01) && vars.Current("overworldScreen", 0xF5) },
            { "walrus", vars.Current("objectState", 0x05) && vars.Current("overworldScreen", 0xFD) },
            { "d8Exit", vars.Current("submapScreen", 0x12) && vars.Current("overworldScreen", 0x00) },
            { "song1", vars.Current("music", 0x10) && (vars.Current("overworldScreen", 0xDC) || vars.Current("overworldScreen", 0x92)) },
            { "song2", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0x2A) },
            { "song3", vars.Current("music", 0x10) && vars.Current("overworldScreen", 0xD4) },
            { "creditsWarp", vars.Current("gameState", 0x0301) },
        };

        if (vars.version == 0) //LA
        {
            splits.Add("d1End", vars.Current("music", 0x05) && vars.Instrument(0));
            splits.Add("d2End", vars.Current("music", 0x05) && vars.Instrument(1));
            splits.Add("d3End", vars.Current("music", 0x05) && vars.Instrument(2));
            splits.Add("d4End", vars.Current("music", 0x05) && vars.Instrument(3));
            splits.Add("d5End", vars.Current("music", 0x05) && vars.Instrument(4));
            splits.Add("d6End", vars.Current("music", 0x05) && vars.Instrument(5));
            splits.Add("d7End", vars.Current("music", 0x06) && vars.Instrument(6));
            splits.Add("d8End", vars.Current("music", 0x06) && vars.Instrument(7));
        }
        else if (vars.version == 0x80) //LADX
        {
            splits.Add("d1End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x00));
            splits.Add("d2End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x01));
            splits.Add("d3End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x02));
            splits.Add("d4End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x03));
            splits.Add("d5End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x04));
            splits.Add("d6End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x05));
            splits.Add("d7End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x06));
            splits.Add("d8End", vars.Current("music", 0x0B) && vars.Current("submapIndex", 0x07));
        }

        return splits;
    });
}

init
{
    vars.ptrOffset = IntPtr.Zero;
    vars.romPtr = new MemoryWatcher<byte>(IntPtr.Zero);
    vars.wramPtr = new MemoryWatcher<byte>(IntPtr.Zero);
    vars.romOffset = IntPtr.Zero;
    vars.wramOffset = IntPtr.Zero;

    vars.version = 0xFF;
    vars.watchers = new MemoryWatcherList();
    vars.pastSplits = new HashSet<string>();

    vars.stopwatch.Restart();
}

update
{
    if (timer.CurrentPhase == TimerPhase.NotRunning && vars.pastSplits.Count > 0)
        vars.pastSplits.Clear();

	if (vars.stopwatch.ElapsedMilliseconds > 1500)
	{
        if (!vars.TryFindOffsets(game, modules.First().ModuleMemorySize))
            return false;
	}
    else if (vars.watchers.Count == 0)
        return false;

    vars.romPtr.Update(game);
    vars.wramPtr.Update(game);
    if (vars.romPtr.Changed || vars.wramPtr.Changed)
        vars.TryFindOffsets(game, modules.First().ModuleMemorySize);
    
    vars.watchers.UpdateAll(game);
}

start
{
    return vars.watchers["gameState"].Current == 0x0902;
}

reset
{
    return vars.watchers["resetCheck"].Current > 0;
}

split
{
    var splits = vars.GetSplitList();

    foreach (var split in splits)
    {
        if (settings[split.Key] && split.Value && !vars.pastSplits.Contains(split.Key))
        {
            vars.pastSplits.Add(split.Key);
            print("[Autosplitter] Split: " + split.Key);
            return true;
        }
    }
}