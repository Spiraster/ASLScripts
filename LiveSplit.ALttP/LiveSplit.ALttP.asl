state("higan")
{
	ushort fileSelect : 0x515525;
	byte linkState : 0x515658;
	short mapTile : 0x515414;
	byte itemValue : 0x5155DC;
	byte world : 0x515DA8;
	byte yPos : 0x5162C9;
	byte endTrigger : 0x51571C;
}

state("snes9x", "1.53")
{
	ushort fileSelect : 0x2EFBA4, 0x221;
	byte linkState : 0x2EFBA4, 0x354;
	short mapTile : 0x2EFBA4, 0x110;
	byte itemValue : 0x2EFBA4, 0x2D8;
	byte world : 0x2EFBA4, 0xAA4;
	byte yPos : 0x2EFBA4, 0xFC5;
	byte endTrigger : 0x2EFBA4, 0x418;
}

state("snes9x-x64", "1.53")
{
	ushort fileSelect : 0x405EC8, 0x221;
	byte linkState : 0x405EC8, 0x354;
	short mapTile : 0x405EC8, 0x110;
	byte itemValue : 0x405EC8, 0x2D8;
	byte world : 0x405EC8, 0xAA4;
	byte yPos : 0x405EC8, 0xFC5;
	byte endTrigger : 0x405EC8, 0x418;
}

state("snes9x", "1.54.1")
{
	ushort fileSelect : 0x3410D4, 0x221;
	byte linkState : 0x3410D4, 0x354;
	short mapTile : 0x3410D4, 0x110;
	byte itemValue : 0x3410D4, 0x2D8;
	byte world : 0x3410D4, 0xAA4;
	byte yPos : 0x3410D4, 0xFC5;
	byte endTrigger : 0x3410D4, 0x418;
}

state("snes9x-x64", "1.54.1")
{
	ushort fileSelect : 0x4DAF18, 0x221;
	byte linkState : 0x4DAF18, 0x354;
	short mapTile : 0x4DAF18, 0x110;
	byte itemValue : 0x4DAF18, 0x2D8;
	byte world : 0x4DAF18, 0xAA4;
	byte yPos : 0x4DAF18, 0xFC5;
	byte endTrigger : 0x4DAF18, 0x418;
}

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
	//snes9x
	//1.53 x86: 5914624
	//1.53 x64: 6909952
	//1.54.1 x86: 6447104
	//1.54.1 x64: 7946240

	var memSize = modules.First().ModuleMemorySize;
	if (memSize == 6447104 || memSize == 7946240)
		version = "1.54.1";

  	vars.lastItem = 0;
}

update
{
	if (current.itemValue != old.itemValue && current.itemValue != 0)
		vars.lastItem = current.itemValue;
}

start
{
	return old.fileSelect == 0 && current.fileSelect == 0xFFFF;
}

reset
{
	return old.fileSelect == 0xFFFF && current.fileSelect != 0xFFFF;
}

split
{
	var swordUp = old.linkState != current.linkState && current.linkState == 0x24;

	var escape = settings["escape"] && old.yPos == 0x01 && current.yPos == 0x02 && current.world == 0x0A && current.mapTile == 0x36;
	var pendant = settings["pendants"] && swordUp && (vars.lastItem == 0x37 || vars.lastItem == 0x39 || vars.lastItem == 0x38);
	var crystal = settings["crystals"] && swordUp && vars.lastItem == 0x20;
	var masterSword = settings["masterSword"] && old.linkState != current.linkState && current.linkState == 0x17 && current.world == 0x01;
	var agahnim1 = settings["agahnim1"] && swordUp && current.mapTile == 0x60;
	var agahnim2 = settings["agahnim2"] && old.linkState == 0x1D && current.linkState == 0 && current.mapTile == 0x27;
	var end = settings["end"] && old.endTrigger == 0 && current.endTrigger == 0x01 && current.mapTile == 0;

	return escape || pendant || crystal || masterSword || agahnim1 || agahnim2 || end;
}
