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
	int memoryOffset = 0;
	while (memoryOffset == 0)
	{
		switch (modules.First().ModuleMemorySize)
		{
			case 5914624: //snes9x (1.53)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x6EFBA4);
				break;
			case 6909952: //snes9x (1.53-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x140405EC8);
				break;
			case 6447104: //snes9x (1.54.1)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x7410D4);
				break;
			case 7946240: //snes9x (1.54.1-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x1404DAF18);
				break;
			case 6602752: //snes9x (1.55)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x762874);
				break;
			case 8355840: //snes9x (1.55-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x1405BFDB8);
				break;
			case 12509184: //higan (v102)
				memoryOffset = 0x915304;
				break;
			case 13062144: //higan (v103)
				memoryOffset = 0x937324;
				break;
			case 15859712: //higan (v104)
				memoryOffset = 0x952144;
				break;
			case 16756736: //higan (v105tr1)
				memoryOffset = 0x94F144;
				break;
			case 16019456: //higan (v106)
				memoryOffset = 0x94D144;
				break;
			default:
				memoryOffset = 1;
				break;
		}
	}

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
