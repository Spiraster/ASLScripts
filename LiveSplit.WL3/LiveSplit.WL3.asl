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
        var states = new Dictionary<int, int>
        {
            { 1744896, 0x566640 },  //BGB 1.5.8
            { 4702208, 0x81EBB8 },  //BGB 1.5.8 (x64)
            { 14569472, 0 },        //GSR r717
            { 5406720, 0 },         //BizHawk 2.3.3/2.4.0
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
                var target = new SigScanTarget(0, "05 00 00 00 ?? 00 00 00 00 ?? ?? 00 ?? 40 ?? 00 00 ?? ?? 00 00 00 00 00 ?? 00 00 00 00 00 00 00 00 00 00 00 ?? ?? ?? 00 ?? 00 00 00 00 00 ?? 00 ?? 00 00 00 00 00 00 00 ?? ?? ?? ?? ?? ?? 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F8 00 00 00");

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
                
                return true;
            }
        }

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