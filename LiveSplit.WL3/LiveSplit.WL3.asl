state("bgb") {}
state("bgb64") {}
state("gambatte") {}
state("gambatte_qt") {}
state("gambatte_qt_nonpsr") {}
state("gambatte_speedrun") {}
state("emuhawk") {}

startup
{
    refreshRate = 0.5;

    vars.TryFindOffsets = (Func<Process, int, long, bool>)((proc, memorySize, baseAddress) => 
    {
        long wramOffset = 0;
        string state = proc.ProcessName.ToLower();
        if (state.Contains("gambatte"))
        {
            IntPtr scanOffset = vars.SigScan(proc, 0, "20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 20 ?? ?? ?? 05 00 00");
            wramOffset = (long)scanOffset - 0x10;
        }
        else if (state == "emuhawk")
        {
            IntPtr scanOffset = vars.SigScan(proc, 0, "05 00 00 00 ?? 00 00 00 00 ?? ?? 00 ?? 40 ?? 00 00 ?? ?? 00 00 00 00 00 ?? 00 00 00 00 00 00 00 00 00 00 00 ?? ?? ?? 00 ?? 00 00 00 00 00 ?? 00 ?? 00 00 00 00 00 00 00 ?? ?? ?? ?? ?? ?? 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F8 00 00 00");
            wramOffset = (long)scanOffset - 0x40;
        }
        else if (state == "bgb")
        {
            IntPtr scanOffset = vars.SigScan(proc, 12, "6D 61 69 6E 6C 6F 6F 70 83 C4 F4 A1 ?? ?? ?? ??");
            wramOffset = new DeepPointer(scanOffset, 0, 0, 0x34).Deref<int>(proc) + 0x108;
        }
        else if (state == "bgb64")
        {
            IntPtr scanOffset = vars.SigScan(proc, 20, "48 83 EC 28 48 8B 05 ?? ?? ?? ?? 48 83 38 00 74 1A 48 8B 05 ?? ?? ?? ?? 48 8B 00 80 B8 ?? ?? ?? ?? 00 74 07");
            IntPtr baseOffset = scanOffset + proc.ReadValue<int>(scanOffset) + 4;
            wramOffset = new DeepPointer(baseOffset, 0, 0x44).Deref<int>(proc) + 0x190;
        }

        if (wramOffset > 0)
        {
            vars.watchers = vars.GetWatcherList((int)(wramOffset - baseAddress));
            print("[Autosplitter] WRAM Pointer: " + wramOffset.ToString("X8"));
            
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

    vars.GetWatcherList = (Func<int, MemoryWatcherList>)((wramOffset) =>
    {
        return new MemoryWatcherList
        {
            new MemoryWatcher<uint>(new DeepPointer(wramOffset, 0x9A)) { Name = "GameState" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x115A)) { Name = "RudyHP" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1DFF)) { Name = "ResetCheck" },
        };
    });
}

init
{
    vars.watchers = new MemoryWatcherList();

    if (!vars.TryFindOffsets(game, modules.First().ModuleMemorySize, (long)modules.First().BaseAddress))
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

exit
{
    refreshRate = 0.5;
}