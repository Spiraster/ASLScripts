state("higan"){}
state("snes9x"){}
state("snes9x-x64"){}

startup
{
	settings.Add("escape", true, "Escape");
	settings.Add("pendants", true, "Pendants (sword up)");
	settings.Add("masterSword", false, "Master Sword");
	settings.Add("agahnim1", true, "Agahnim 1 (sword up)");
	settings.Add("crystals", true, "Crystals (sword up)");
	settings.Add("agahnim2", true, "Agahnim 2");
	settings.Add("end", true, "Enter Triforce Room");
}

init
{
	var states = new Dictionary<int, long>
	{
		{ 10330112, 0x789414 },   //snes9x 1.52-rr
		{ 7729152, 0x890EE4 },    //snes9x 1.54-rr
		{ 5914624, 0x6EFBA4 },    //snes9x 1.53
		{ 6909952, 0x140405EC8 }, //snes9x 1.53 (x64)
		{ 6447104, 0x7410D4 },    //snes9x 1.54/1.54.1
		{ 7946240, 0x1404DAF18 }, //snes9x 1.54/1.54.1 (x64)
		{ 6602752, 0x762874 },    //snes9x 1.55
		{ 8355840, 0x1405BFDB8 }, //snes9x 1.55 (x64)
		{ 6856704, 0x78528C },    //snes9x 1.56/1.56.2
		{ 9003008, 0x1405D8C68 }, //snes9x 1.56 (x64)
		{ 6848512, 0x7811B4 },    //snes9x 1.56.1
		{ 8945664, 0x1405C80A8 }, //snes9x 1.56.1 (x64)
		{ 9015296, 0x1405D9298 }, //snes9x 1.56.2 (x64)
		{ 6991872, 0x7A6EE4 },    //snes9x 1.57
		{ 9048064, 0x1405ACC58 }, //snes9x 1.57 (x64)
		{ 7000064, 0x7A7EE4 },    //snes9x 1.58
		{ 9060352, 0x1405AE848 }, //snes9x 1.58 (x64)
		{ 12509184, 0x915304 },   //higan v102
		{ 13062144, 0x937324 },   //higan v103
		{ 15859712, 0x952144 },   //higan v104
		{ 16756736, 0x94F144 },   //higan v105tr1
		{ 16019456, 0x94D144 },   //higan v106
	};

	long memoryOffset;
	if (states.TryGetValue(modules.First().ModuleMemorySize, out memoryOffset))
		if (memory.ProcessName.ToLower().Contains("snes9x"))
			memoryOffset = memory.ReadValue<int>((IntPtr)memoryOffset);

	vars.watchers = new MemoryWatcherList
	{
		new MemoryWatcher<ushort>((IntPtr)memoryOffset + 0x221) { Name = "fileSelect" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x354) { Name = "linkState" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x110) { Name = "mapTile" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x2D8) { Name = "itemValue" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0xAA4) { Name = "world" },
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0xFC4) { Name = "yPos" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x418) { Name = "end" },
	};

  	vars.lastItem = 0;
}

update
{
	vars.watchers.UpdateAll(game);

	if (vars.watchers["itemValue"].Changed && vars.watchers["itemValue"].Current != 0)
		vars.lastItem = vars.watchers["itemValue"].Current;
}

start
{
	return vars.watchers["fileSelect"].Old == 0 && vars.watchers["fileSelect"].Current == 0xFFFF;
}

reset
{
	return vars.watchers["fileSelect"].Old == 0xFFFF && vars.watchers["fileSelect"].Current != 0xFFFF;
}

split
{
	var swordUp = vars.watchers["linkState"].Changed && vars.watchers["linkState"].Current == 0x24;

	var escape = settings["escape"] && vars.watchers["yPos"].Current > vars.watchers["yPos"].Old && vars.watchers["yPos"].Current == 0x0218 && vars.watchers["mapTile"].Current == 0x36; //old.yPos == 0x01 && current.yPos == 0x02 && current.world == 0x0A && current.mapTile == 0x36;
	var pendant = settings["pendants"] && swordUp && vars.watchers["world"].Current == 0x0A && (vars.lastItem == 0x37 || vars.lastItem == 0x39 || vars.lastItem == 0x38);
	var crystal = settings["crystals"] && swordUp && vars.watchers["world"].Current == 0x0A && vars.lastItem == 0x20;
	var masterSword = settings["masterSword"] && vars.watchers["linkState"].Changed && vars.watchers["linkState"].Current == 0x17 && vars.watchers["world"].Current == 0x01;
	var agahnim1 = settings["agahnim1"] && swordUp && vars.watchers["mapTile"].Current == 0x60;
	var agahnim2 = settings["agahnim2"] && vars.watchers["linkState"].Old == 0x1D && vars.watchers["linkState"].Current == 0 && vars.watchers["mapTile"].Current == 0x27;
	var end = settings["end"] && vars.watchers["end"].Old == 0 && vars.watchers["end"].Current == 1 && vars.watchers["mapTile"].Current == 0;

	return escape || pendant || crystal || masterSword || agahnim1 || agahnim2 || end;
}
