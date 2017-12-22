state("bgb") {}
state("gambatte") {}
state("gambatte_qt") {}

startup
{
    vars.stopwatch = new Stopwatch();

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
            case 1740800: //bgb (1.5.5/1.5.6)
                baseOffset = 0x566EDC;
                break;
            case 14290944: //gambatte-speedrun (r600)
            case 14180352: //gambatte-speedrun (r604/r614)
                baseOffset = int.MaxValue;
                break;
        }

        if (baseOffset == 0)
            vars.wramOffset = (IntPtr)1;
        else
        {
            vars.wramOffset = IntPtr.Zero;

            if (baseOffset == int.MaxValue) //gambatte
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
                    vars.wramPtr = new MemoryWatcher<int>(vars.ptrOffset - 0x20);
                }
            }
            else if (baseOffset != 0) //bgb
            {
                if (vars.ptrOffset == IntPtr.Zero)
                {
                    vars.ptrOffset = proc.ReadPointer(proc.ReadPointer((IntPtr)baseOffset) + 0x34);
                    vars.wramPtr = new MemoryWatcher<int>(vars.ptrOffset + 0xC0);
                }

                vars.wramOffset += 0xC000;
            }
            
            if (vars.ptrOffset != IntPtr.Zero)
            {
                vars.wramPtr.Update(proc);
                vars.wramOffset += vars.wramPtr.Current;
            }

            if (vars.wramOffset != IntPtr.Zero)
                print("[Autosplitter] WRAM: " + vars.wramOffset.ToString("X8"));
        }
    });

    vars.GetWatcherList = (Func<IntPtr, MemoryWatcherList>)((wramOffset) =>
    {   
        return new MemoryWatcherList
        {
            new MemoryWatcher<uint>(wramOffset + 0x9A) { Name = "GameState" },
            new MemoryWatcher<byte>(wramOffset + 0x115A) { Name = "RudyHP" },
            new MemoryWatcher<byte>(wramOffset + 0x1DFF) { Name = "ResetCheck" },
        };
    });
}

init
{    
    vars.ptrOffset = IntPtr.Zero;
    vars.wramOffset = IntPtr.Zero;

    vars.wramPtr = new MemoryWatcher<byte>(IntPtr.Zero);

    vars.watchers = new MemoryWatcherList();
    vars.splits = new List<Tuple<string, List<Tuple<string, int>>>>();

    vars.stopwatch.Restart();
}

update
{
    if (vars.stopwatch.ElapsedMilliseconds > 1500)
    {
        vars.FindOffsets(game, modules.First().ModuleMemorySize);

        if (vars.wramOffset != IntPtr.Zero)
        {
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

    vars.wramPtr.Update(game);

    if (vars.wramPtr.Changed)
    {
        vars.FindOffsets(game, modules.First().ModuleMemorySize);
        vars.watchers = vars.GetWatcherList(vars.wramOffset);
    }

    vars.watchers.UpdateAll(game);
}

start
{
    return vars.watchers["GameState"].Old == 0x030E00 && vars.watchers["GameState"].Current == 0x000100;
}

reset
{
    return vars.watchers["ResetCheck"].Current > 0;
}

split
{
    var levelClear = (vars.watchers["GameState"].Old == 0x000101 && (vars.watchers["GameState"].Current == 0x010101 || vars.watchers["GameState"].Current == 0x110101 || vars.watchers["GameState"].Current == 0x180401))
                  || (vars.watchers["GameState"].Old == 0x000701 && vars.watchers["GameState"].Current == 0x010701);

    var finalBoss = vars.watchers["RudyHP"].Old == 0x01 && vars.watchers["RudyHP"].Current == 0x00;

    return levelClear || finalBoss;
}