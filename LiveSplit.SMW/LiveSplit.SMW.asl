state("higan"){}
state("snes9x"){}
state("snes9x-x64"){}

startup
{
	settings.Add("levels", true, "Normal Levels");
	settings.SetToolTip("levels", "Split on crossing goal tapes and activating keyholes");
	settings.Add("bosses", true, "Boss Levels");
	settings.SetToolTip("bosses", "Split on boss fanfare");
}

init
{
	int memoryOffset = 0;
	while (memoryOffset == 0)
	{
		switch (modules.First().ModuleMemorySize)
		{
			case 5914624: //snes9x (1.53_x86)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x6EFBA4);
				break;
			case 6909952: //snes9x (1.53_x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x140405EC8);
				break;
			case 6447104: //snes9x (1.54.1_x86)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x7410D4);
				break;
			case 7946240: //snes9x (1.54.1_x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x1404DAF18);
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
			default:
				memoryOffset = 1;
				break;
		}
	}

	vars.watchers = new MemoryWatcherList
	{
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1ED2) { Name = "fileSelect" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x906) { Name = "fanfare" },
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x1434) { Name = "keyholeTimer" },
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
	var goalExit = settings["levels"] && vars.watchers["fanfare"].Old == 0 && vars.watchers["fanfare"].Current == 1;
	var keyExit = settings["levels"] && vars.watchers["keyholeTimer"].Old == 0 && vars.watchers["keyholeTimer"].Current == 0x0030;
	var bossExit = settings["bosses"] && vars.watchers["fanfare"].Old == 0 && vars.watchers["fanfare"].Current == 1;
	var bowserDefeated = settings["bosses"] && vars.watchers["peach"].Old == 0 && vars.watchers["peach"].Current == 1;

	return goalExit || keyExit || bossExit || bowserDefeated;
}