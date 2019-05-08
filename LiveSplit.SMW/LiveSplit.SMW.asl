state("higan") {}
state("snes9x") {}
state("snes9x-x64") {}
state("emuhawk") {}

startup
{
    settings.Add("levels", true, "Normal Levels");
    settings.SetToolTip("levels", "Split on crossing goal tapes and activating keyholes");
    settings.Add("bosses", true, "Boss Levels");
    settings.SetToolTip("bosses", "Split on boss fanfare");
    settings.Add("switchPalaces", false, "Switch Palaces");
    settings.SetToolTip("switchPalaces", "Split on completing a switch palace");
    settings.Add("levelDoorPipe", false, "Level Room Transitions");
    settings.SetToolTip("levelDoorPipe", "Split on door and pipe transitions within standard levels and switch palaces");
    settings.Add("castleDoorPipe", false, "Castle/GH Room Transitions");
    settings.SetToolTip("castleDoorPipe", "Split on door and pipe transitions within ghost houses and castles");
    settings.Add("bowserPhase", false, "Bowser Phase Transition");
    settings.SetToolTip("bowserPhase", "Split on the transition between Bowser's phases (not tested on Cloud runs)");
}

init
{
    var states = new Dictionary<int, long>
    {
        { 10330112, 0x789414 },     //snes9x 1.52-rr
        { 7729152, 0x890EE4 },      //snes9x 1.54-rr
        { 5914624, 0x6EFBA4 },      //snes9x 1.53
        { 6909952, 0x140405EC8 },   //snes9x 1.53 (x64)
        { 6447104, 0x7410D4 },      //snes9x 1.54/1.54.1
        { 7946240, 0x1404DAF18 },   //snes9x 1.54/1.54.1 (x64)
        { 6602752, 0x762874 },      //snes9x 1.55
        { 8355840, 0x1405BFDB8 },   //snes9x 1.55 (x64)
        { 6856704, 0x78528C },      //snes9x 1.56/1.56.2
        { 9003008, 0x1405D8C68 },   //snes9x 1.56 (x64)
        { 6848512, 0x7811B4 },      //snes9x 1.56.1
        { 8945664, 0x1405C80A8 },   //snes9x 1.56.1 (x64)
        { 9015296, 0x1405D9298 },   //snes9x 1.56.2 (x64)
        { 6991872, 0x7A6EE4 },      //snes9x 1.57
        { 9048064, 0x1405ACC58 },   //snes9x 1.57 (x64)
        { 7000064, 0x7A7EE4 },      //snes9x 1.58
        { 9060352, 0x1405AE848 },   //snes9x 1.58 (x64)
        { 8953856, 0x975A54 },      //snes9x 1.59.2
        { 12537856, 0x1408D86F8 },  //snes9x 1.59.2 (x64)
        { 9027584, 0x94DB54 },      //snes9x 1.60
        { 12836864, 0x1408D8BE8 },  //snes9x 1.60 (x64)
        { 12509184, 0x915304 },     //higan v102
        { 13062144, 0x937324 },     //higan v103
        { 15859712, 0x952144 },     //higan v104
        { 16756736, 0x94F144 },     //higan v105tr1
        { 16019456, 0x94D144 },     //higan v106
        { 10096640, 0x72BECC },     //bsnes v107
        { 10338304, 0x762F2C },     //bsnes v107.1
        { 47230976, 0x765F2C },     //bsnes v107.2/107.3
        { 7061504, 0x36F11500240 }, //BizHawk 2.3
        { 7249920, 0x36F11500240 }, //BizHawk 2.3.1
    };

    long memoryOffset;
    if (states.TryGetValue(modules.First().ModuleMemorySize, out memoryOffset))
        if (memory.ProcessName.ToLower().Contains("snes9x"))
            memoryOffset = memory.ReadValue<int>((IntPtr)memoryOffset);

    if (memoryOffset == 0)
        throw new Exception("Memory not yet initialized.");

    vars.watchers = new MemoryWatcherList
    {
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1ED2) { Name = "fileSelect" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x906) { Name = "fanfare" },
        new MemoryWatcher<short>((IntPtr)memoryOffset + 0x1434) { Name = "keyholeTimer" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f28) { Name = "yellowSwitch" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f27) { Name = "greenSwitch" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f29) { Name = "blueSwitch" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f2a) { Name = "redSwitch" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x141A) { Name = "roomCounter" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1B9B) { Name = "yoshiBanned" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x13C6) { Name = "bossDefeat" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1429) { Name = "bowserPalette" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x190D) { Name = "peach" },
    };
}

update
{
    vars.watchers.UpdateAll(game);
}

start
{
    return vars.watchers["fileSelect"].Old == 0 && vars.watchers["fileSelect"].Current == 1;
}

reset
{
    return vars.watchers["fileSelect"].Old != 0 && vars.watchers["fileSelect"].Current == 0;
}

split
{
    var goalExit = settings["levels"] && vars.watchers["fanfare"].Old == 0 && vars.watchers["fanfare"].Current == 1 && vars.watchers["bossDefeat"].Current == 0;
    var keyExit = settings["levels"] && vars.watchers["keyholeTimer"].Old == 0 && vars.watchers["keyholeTimer"].Current == 0x0030;
    
    var yellowPalace = settings["switchPalaces"] && vars.watchers["yellowSwitch"].Old == 0 && vars.watchers["yellowSwitch"].Current == 1;
    var greenPalace = settings["switchPalaces"] && vars.watchers["greenSwitch"].Old == 0 && vars.watchers["greenSwitch"].Current == 1;
    var bluePalace = settings["switchPalaces"] && vars.watchers["blueSwitch"].Old == 0 && vars.watchers["blueSwitch"].Current == 1;
    var redPalace = settings["switchPalaces"] && vars.watchers["redSwitch"].Old == 0 && vars.watchers["redSwitch"].Current == 1;
    var switchPalaceExit = yellowPalace || greenPalace || bluePalace || redPalace;

    var levelDoorPipe = settings["levelDoorPipe"] && (vars.watchers["roomCounter"].Old + 1) == vars.watchers["roomCounter"].Current && vars.watchers["yoshiBanned"].Current == 0;
    var castleDoorPipe = settings["castleDoorPipe"] && (vars.watchers["roomCounter"].Old + 1) == vars.watchers["roomCounter"].Current && vars.watchers["yoshiBanned"].Current == 1;
    
    var bossExit = settings["bosses"] && vars.watchers["fanfare"].Old == 0 && vars.watchers["fanfare"].Current == 1 && vars.watchers["bossDefeat"].Current == 1;
    var bowserPhase = settings["bowserPhase"] && vars.watchers["bowserPalette"].Old == 4 && vars.watchers["bowserPalette"].Current == 7;
    var bowserDefeated = settings["bosses"] && vars.watchers["peach"].Old == 0 && vars.watchers["peach"].Current == 1;

    return goalExit || keyExit || switchPalaceExit || levelDoorPipe || castleDoorPipe || bossExit || bowserPhase || bowserDefeated;
}
