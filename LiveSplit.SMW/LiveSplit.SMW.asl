state("higan"){}
state("snes9x"){}
state("snes9x-x64"){}

startup
{
	settings.Add("levels", true, "Normal Levels");
	settings.SetToolTip("levels", "Split on crossing goal tapes and activating keyholes");
	settings.Add("bosses", true, "Boss Levels");
	settings.SetToolTip("bosses", "Split on boss fanfare");
	settings.Add("switchPalaces", false, "Switch Palaces");
	settings.SetToolTip("switchPalaces", "Split on completing a switch palace");
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
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1ED2) { Name = "fileSelect" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x906) { Name = "fanfare" },
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x1434) { Name = "keyholeTimer" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f28) { Name = "yellowSwitch" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f27) { Name = "greenSwitch" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f29) { Name = "blueSwitch" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f2a) { Name = "redSwitch" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x13C6) { Name = "bossDefeat" },
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
	var bossExit = settings["bosses"] && vars.watchers["fanfare"].Old == 0 && vars.watchers["fanfare"].Current == 1 && vars.watchers["bossDefeat"].Current == 1;
	var bowserDefeated = settings["bosses"] && vars.watchers["peach"].Old == 0 && vars.watchers["peach"].Current == 1;

	return goalExit || keyExit || switchPalaceExit || bossExit || bowserDefeated;
}
