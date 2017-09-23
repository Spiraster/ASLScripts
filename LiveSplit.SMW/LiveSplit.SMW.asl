state("higan")
{
	byte fileSelect : 0x5171D6;
	byte fanfare : 0x515C0A;
	byte keyholeTimer : 0x516738;
	byte peach : 0x516C11;
}

state("snes9x", "1.53")
{
	byte fileSelect : 0x2EFBA4, 0x1ED2;
	byte fanfare : 0x2EFBA4, 0x906;
	byte keyholeTimer : 0x2EFBA4, 0x1434;
	byte peach : 0x2EFBA4, 0x190D;
}

state("snes9x-x64", "1.53")
{
	byte fileSelect : 0x405EC8, 0x1ED2;
	byte fanfare : 0x405EC8, 0x906;
	byte keyholeTimer : 0x405EC8, 0x1434;
	byte peach : 0x405EC8, 0x190D;
}

state("snes9x", "1.54.1")
{
	byte fileSelect : 0x3410D4, 0x1ED2;
	byte fanfare : 0x3410D4, 0x906;
	byte keyholeTimer : 0x3410D4, 0x1434;
	byte peach : 0x3410D4, 0x190D;
}

state("snes9x-x64", "1.54.1")
{
	byte fileSelect : 0x4DAF18, 0x1ED2;
	byte fanfare : 0x4DAF18, 0x906;
	byte keyholeTimer : 0x4DAF18, 0x1434;
	byte peach : 0x4DAF18, 0x190D;
}

startup
{
	settings.Add("levels", true, "Normal Levels");
	settings.SetToolTip("levels", "Split on crossing goal tapes and activating keyholes");
	settings.Add("bosses", true, "Boss Levels");
	settings.SetToolTip("bosses", "Split on boss fanfare");
}

init
{
	var memSize = modules.First().ModuleMemorySize;
	if (memSize == 6447104 || memSize == 7946240)
		version = "1.54.1";
}

start
{
	return old.fileSelect == 0 && current.fileSelect == 1;
}

reset
{
	return old.fileSelect == 1 && current.fileSelect != 1;
}

split
{
	var goalExit = settings["levels"] && old.fanfare == 0 && current.fanfare == 1;
	var keyExit = settings["levels"] && old.keyholeTimer == 0 && current.keyholeTimer > 0;
	var bossExit = settings["bosses"] && old.fanfare == 0 && current.fanfare == 1;
	var bowserDefeated = settings["bosses"] && old.peach == 0 && current.peach == 1;


	return goalExit || keyExit || bossExit || bowserDefeated;
}