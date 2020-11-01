/* Spelunky 2 autosplitter for LiveSplit by Dregu

   Most things should work now!
   Remember to set LiveSplit to Compare Against -> Game Time
   and check the ASL settings for the right category options. */

state("Spel2")
{
	// unknown version
}

state("Spel2", "1.14.0")
{
	byte screen : 0x21FCFEF0, 0x10;
	byte trans : 0x21FCFEF0, 0x28;
	byte fade : 0x21FCFEF0, 0x2c;
	bool ingame : 0x21FCFEF0, 0x30;
	bool playing : 0x21FCFEF0, 0x31;
	byte pause : 0x21FCFEF0, 0x32;
	int counter : 0x21FCFEF0, -192;
	int igt : 0x21FCFEF0, 0x60;
	byte world : 0x21FCFEF0, 0x65;
	byte level : 0x21FCFEF0, 0x66;
}

state("Spel2", "1.12.1e")
{
	byte screen : 0x21FB3EF0, 0x10;
	byte trans : 0x21FB3EF0, 0x28;
	byte fade : 0x21FB3EF0, 0x2c;
	bool ingame : 0x21FB3EF0, 0x30;
	bool playing : 0x21FB3EF0, 0x31;
	byte pause : 0x21FB3EF0, 0x32;
	int counter : 0x21FB3EF0, -192;
	int igt : 0x21FB3EF0, 0x60;
	byte world : 0x21FB3EF0, 0x65;
	byte level : 0x21FB3EF0, 0x66;
}

startup
{
	settings.Add("st", true, "Starting");
	settings.Add("stlevel", true, "[any%] Start on first level", "st");
	settings.Add("stcamp", false, "[AS+T] Start on player selection (use with loadless)", "st");

	settings.Add("sp", true, "Splitting");
	settings.Add("trans", true, "[any%] Split between levels", "sp");
	settings.Add("world", false, "Split on any world transition screen", "sp");
	settings.Add("tiamat", false, "[any%] [AS+T] Split on end cutscene after Tiamat", "sp");
	settings.Add("hundun", false, "Split on end cutscene after Hundun", "sp");
	settings.Add("co", false, "Split on end cutscene after Cosmic Ocean", "sp");
	settings.Add("shortcut", false, "[AS+T] Split on Terra encounters (doesn't actually check if you did the thing)", "sp");
	settings.Add("tutorial", false, "[AS+T] Split after completing the tutorial", "sp");
	settings.Add("fade", false, "Split on walls are shifting/credits (this is broken)", "sp");
	settings.Add("level", false, "Split on new level start (this is stupid)", "sp");

	settings.Add("rs", true, "Resetting");
	settings.Add("rsrestart", true, "[any%] Reset on instant restart/return to camp", "rs");
	settings.Add("rsmenu", true, "Reset on main menu", "rs");
	settings.Add("rstitle", true, "Reset on title screen", "rs");

	settings.Add("tm", true, "Timing");
	settings.Add("pause", true, "Keep timer running when paused instead of updating on level change", "tm");
	settings.Add("loadless", false, "[AS+T] Loadless mode (uses global frame counter instead of gametime)", "tm");
}

init
{
	switch (modules.First().ModuleMemorySize) {
		case 570585088: version = "1.12.1e"; break;
		case 570699776: version = "1.14.0"; break;
		default:        version = ""; break;
	}
	print("Spelunky 2 size "+modules.First().ModuleMemorySize.ToString()+" is version "+version);
	vars.started = 0;
	vars.pausetime = 0;
	vars.paused = 0;
	vars.splitAt = 0;
	vars.shortcuts = 0;
	vars.tutorial = 0;
}

start
{
	if(current.screen <= 3) {
		return;
	}
	if ((settings["stlevel"] && current.playing && current.igt > 1 && old.igt == 1)
	|| (settings["stcamp"] && current.ingame && !old.ingame && current.pause == 0 && vars.started == 0)) {
		print("Starting timer");
		vars.paused = 0;
		vars.pausetime = 0;
		vars.splitAt = 0;
		vars.shortcuts = 0;
		vars.tutorial = 0;
		vars.started = current.counter;
		return true;
	}
}

split
{
	if(current.screen <= 3) {
		return;
	}
	if(vars.splitAt > 0 && current.counter >= vars.splitAt && current.igt > 10) {
		print("Splitting after level transition delay");
		vars.splitAt = 0;
		return true;
	} else if(settings["level"] && current.level != old.level) {
		print("Splitting because new level ("+old.level+"->"+current.level+")");
		return true;
	} else if(settings["world"] && current.world != old.world && current.world > 1) {
		print("Splitting because new world ("+old.world+"->"+current.world+")");
		return true;
	} else if(settings["fade"] && (current.fade == 40 && old.fade != 40)) {
		print("Splitting after fade");
		return true;
	} else if(settings["shortcut"] && current.trans == 18 && old.trans != 18 && current.screen == 13) {
		if(vars.shortcuts < 3 && current.world == 2 && current.level == 4) {
			vars.shortcuts++;
			print("Splitting at 1-4 shortcut");
			return true;
		} else if(vars.shortcuts >= 3 && vars.shortcuts < 6 && current.world == 4 && current.level == 1) {
			vars.shortcuts++;
			print("Splitting at 3-1 shortcut");
			return true;
		} else if(vars.shortcuts >= 6 && vars.shortcuts < 9 && current.world == 5 && current.level == 4) {
			vars.shortcuts++;
			print("Splitting at 5-1 shortcut");
			return true;
		}
	} else if(settings["tutorial"] && vars.tutorial == 0 && current.screen == 12) {
		print("Splitting after tutorial");
		vars.tutorial = 1;
		return true;
	}
}

reset
{
	if ((settings["rstitle"] && current.screen == 3 && old.screen != 3)
		|| (settings["rsrestart"] && current.igt <= 1)
		|| (settings["rsmenu"] && !current.ingame && !current.playing && current.pause == 0)) {
		print("Resetting timer");
		vars.paused = 0;
		vars.pausetime = 0;
		vars.splitAt = 0;
		vars.started = 0;
		vars.shortcuts = 0;
		vars.tutorial = 0;
		return true;
	}
}

update
{
	if(current.pause == 1 && old.pause == 0) {
		timer.IsGameTimePaused = true;
		vars.paused = current.counter;
		print("Paused");
	} else if(current.pause == 0 && old.pause == 1) {
		timer.IsGameTimePaused = false;
		vars.pausetime += current.counter-vars.paused;
		vars.paused = 0;
		print("Unpaused");
	}
	if(settings["trans"] && current.trans == 18 && old.trans != 18 && current.screen == 13) {
		print("Setting delayed split after level transition at "+(current.counter+1).ToString());
		vars.paused = 0;
		vars.pausetime = 0;
		vars.splitAt = current.counter+1;
	} else if(settings["tiamat"] && current.trans == 18 && old.trans != 18 && current.world == 6 && current.level == 4) {
		print("Setting delayed split after Tiamat at "+(current.counter+1).ToString());
		vars.paused = 0;
		vars.pausetime = 0;
		vars.splitAt = current.counter+1;
	} else if(settings["hundun"] && current.trans == 18 && old.trans != 18 && current.world == 7 && current.level == 4) {
		print("Setting delayed split after Hundun at "+(current.counter+1).ToString());
		vars.paused = 0;
		vars.pausetime = 0;
		vars.splitAt = current.counter+1;
	} else if(settings["co"] && current.trans == 18 && old.trans != 18 && current.level == 98) {
		print("Setting delayed split after CO at "+(current.counter+1).ToString());
		vars.paused = 0;
		vars.pausetime = 0;
		vars.splitAt = current.counter+1;
	}
	if ((settings["rstitle"] && current.screen == 3 && old.screen != 3)
		|| (settings["rsmenu"] && !current.ingame && !current.playing && current.pause == 0)) {
		print("Clearing state because of reset condition");
		vars.paused = 0;
		vars.pausetime = 0;
		vars.splitAt = 0;
		vars.started = 0;
		vars.shortcuts = 0;
		vars.tutorial = 0;
	}
}

isLoading
{
	return current.pause > 1;
}

gameTime
{
	if(!settings["loadless"] && current.igt == old.igt) {
		timer.IsGameTimePaused = true;
	} else {
		timer.IsGameTimePaused = false;
	}
	if(!settings["loadless"]) {
		if(settings["pause"]) {
			if(current.pause == 1) {
				return TimeSpan.FromSeconds((current.igt+vars.pausetime+current.counter-vars.paused)/60.0);
			} else {
				return TimeSpan.FromSeconds((current.igt+vars.pausetime)/60.0);
			}
		} else {
			return TimeSpan.FromSeconds((current.igt)/60.0);
		}
	} else {
		return TimeSpan.FromSeconds((current.counter-vars.started)/60.0);
	}
}