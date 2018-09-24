state("bgb") {}
state("bgb64") {}
state("gambatte") {}
state("gambatte_qt") {}
state("gambatte_qt_nonpsr") {}
state("emuhawk") {}

startup
{
    vars.stopwatch = new Stopwatch();

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
            new MemoryWatcher<uint>(new DeepPointer(wramOffset, 0x9A)) { Name = "GameState" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x115A)) { Name = "RudyHP" },
            new MemoryWatcher<byte>(new DeepPointer(wramOffset, 0x1DFF)) { Name = "ResetCheck" },
        };
    });
}

init
{
    vars.watchers = new MemoryWatcherList();

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