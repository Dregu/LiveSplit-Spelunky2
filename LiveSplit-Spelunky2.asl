/*
 * Spelunky 2 autosplitter for LiveSplit by Dregu
 * Remember to set LiveSplit to Compare Against -> Game Time
 * and check the ASL settings for the right category options.
 */

state("Spel2")
{
  // unknown version
}

state("Spel2", "1.16.0")
{
  int counter : 0x21fe2f60, -192;
  byte screen : 0x21fe2f60, 0x10;
  byte loading : 0x21fe2f60, 0x14;
  byte trans : 0x21fe2f60, 0x28;
  byte fade : 0x21fe2f60, 0x2c;
  bool ingame : 0x21fe2f60, 0x30;
  bool playing : 0x21fe2f60, 0x31;
  byte pause : 0x21fe2f60, 0x32;
  int igt : 0x21fe2f60, 0x60;
  byte world : 0x21fe2f60, 0x65;
  byte level : 0x21fe2f60, 0x66;
  byte health : 0x21fe2f60, 0x1298, 0x8, 0x10f;
  byte bombs : 0x21fe2f60, 0x1298, 0x2c;
  byte ropes : 0x21fe2f60, 0x1298, 0x2d;
  byte12000 savedata : 0x21fe2f18, 0x18, 0, 0;
  // savedata indexes are -2 from https://github.com/spelunky-fyi/s2-data/blob/main/docs/save-format.md
}

startup
{
  settings.Add("st", true, "Starting");
  settings.Add("stlevel", true, "[any%] Start on first level", "st");
  settings.Add("stcamp", false, "[AS+T] Start on player selection", "st");

  settings.Add("sp", true, "Splitting");
  settings.Add("trans", true, "[any%] Split on any level transition screen", "sp");
  settings.Add("world", false, "Split on any world transition screen", "sp");
  settings.Add("tiamat", true, "[any%] [AS+T] Split on end cutscene after Tiamat", "sp");
  settings.Add("hundun", true, "Split on end cutscene after Hundun", "sp");
  settings.Add("co", true, "Split on end cutscene after Cosmic Ocean", "sp");
  settings.Add("shortcut", false, "[AS+T] Split on completed shortcut tasks", "sp");
  settings.Add("tutorial", false, "[AS+T] Split when entering the big door after tutorial", "sp");
  settings.Add("character", false, "Split on unlocking a new character", "sp");
  settings.Add("fade", false, "Split on walls are shifting/credits (this is broken)", "sp");
  settings.Add("level", false, "Split on new level start (this is stupid)", "sp");

  settings.Add("rs", true, "Resetting");
  settings.Add("rsrestart", true, "[any%] Reset on instant restart/in camp", "rs");
  settings.Add("rsmenu", true, "Reset in main menu", "rs");
  settings.Add("rstitle", true, "Reset in title screen", "rs");

  settings.Add("tm", true, "Timing method used by \"Game Time\" comparison (select exactly one)");
  settings.Add("ingame", true, "[any%] Ingame timer (pauses on level transitions, resets on camp)", "tm");
  settings.Add("loadless", false, "[AS+T] Loadless timer (uses real time minus levelgen time)", "tm");
  settings.Add("framecount", false, "Global frame counter (basically runs whenever you can interact with the game)", "tm");
  settings.Add("ingamesum", false, "Sum of ingame times (runs in game and in camp, persists across restarts, pauses in main menu and between levels)", "tm");
  settings.Add("realtime", false, "Real time (yes it just copies real time to game time)", "tm");

  settings.Add("misc", true, "Miscellaneous");
  settings.Add("pause", true, "Keep ingame timers running when paused instead of updating on level change (just a visual thing during levels, doesn't change the split times or total time)", "misc");
  settings.Add("webhook", false, "Enable webhook");
}


init
{
  switch (modules.First().ModuleMemorySize) {
    case 570781696: version = "1.16.0"; break;
    default:        version = ""; break;
  }
  print("Spelunky 2 size "+modules.First().ModuleMemorySize.ToString()+" is version "+version);
  vars.started = 0;
  vars.pausetime = 0;
  vars.paused = 0;
  vars.loadtime = 0.0;
  vars.loaded = 0.0;
  vars.totaltime = 0;
  vars.splitAt = 0;
  vars.shortcuts = 0;
}

start
{
  if(version == "") {
    return;
  }
  if(current.screen <= 3) {
    return;
  }
  if ((settings["stlevel"] && current.playing && current.igt > 1 && old.igt == 1)
  || (settings["stcamp"] && current.ingame && !old.ingame && current.pause == 0 && vars.started == 0)) {
    print("Starting timer");
    vars.paused = 0;
    vars.pausetime = 0;
    vars.loadtime = 0.0;
    vars.loaded = 0.0;
    vars.totaltime = 0;
    vars.splitAt = 0;
    vars.shortcuts = 0;
    vars.started = current.counter;
    return true;
  }
}

split
{
  if(version == "") {
    return;
  }
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
  } else if(settings["shortcut"] && current.savedata[0xe9] != old.savedata[0xe9] && current.savedata[0xe9] > 1) {
    print("Splitting because completed shortcut task");
    return true;
  } else if(settings["tutorial"] && current.savedata[0xe8] != old.savedata[0xe8] && current.savedata[0xe8] == 3) {
    print("Splitting after tutorial");
    return true;
  } else if(settings["character"] && (current.savedata[0xe4] != old.savedata[0xe4] || current.savedata[0xe5] != old.savedata[0xe5] || current.savedata[0xe6] != old.savedata[0xe6])) {
    print("Splitting because character unlocked");
    return true;
  }
}

reset
{
  if(version == "") {
    return;
  }
  if ((settings["rstitle"] && current.screen == 3 && old.screen != 3)
    || (settings["rsrestart"] && current.igt <= 1)
    || (settings["rsmenu"] && !current.ingame && !current.playing && current.pause == 0)) {
    print("Resetting timer");
    vars.paused = 0;
    vars.pausetime = 0;
    vars.loadtime = 0.0;
    vars.loaded = 0.0;
    vars.totaltime = 0;
    vars.splitAt = 0;
    vars.started = 0;
    vars.shortcuts = 0;
    return true;
  }
}

update
{
  if(version == "") {
    return;
  }
  if(current.pause == 1 && old.pause == 0) {
    timer.IsGameTimePaused = true;
    vars.paused = current.counter;
    print("Paused");
  } else if(current.pause == 0 && old.pause == 1) {
    timer.IsGameTimePaused = false;
    vars.pausetime += current.counter-vars.paused;
    vars.paused = 0;
    print("Unpaused");
  } else if(current.loading == 2 && old.loading != 2) {
    timer.IsGameTimePaused = true;
    vars.loaded = Environment.TickCount;
    print("Loading");
  } else if(current.loading != 2 && old.loading == 2) {
    timer.IsGameTimePaused = false;
    vars.loadtime += Environment.TickCount-vars.loaded;
    double delta = Environment.TickCount-vars.loaded;
    vars.loaded = 0;
    print("Finished loading, it took "+delta/1000.0+"s");
  }
  if(current.trans == 18 && old.trans != 18) {
    print("Clearing pausetimer on level transition");
    vars.paused = 0;
    vars.pausetime = 0;
  }
  if(current.igt < old.igt) {
    vars.totaltime += old.igt;
  }
  if(settings["trans"] && current.trans == 18 && old.trans != 18 && current.screen == 13) {
    print("Setting delayed split after level transition at "+(current.counter+1).ToString());
    vars.splitAt = current.counter+1;
  } else if(settings["tiamat"] && current.trans == 18 && old.trans != 18 && current.world == 6 && current.level == 4) {
    print("Setting delayed split after Tiamat at "+(current.counter+1).ToString());
    vars.splitAt = current.counter+1;
  } else if(settings["hundun"] && current.trans == 18 && old.trans != 18 && current.world == 7 && current.level == 4) {
    print("Setting delayed split after Hundun at "+(current.counter+1).ToString());
    vars.splitAt = current.counter+1;
  } else if(settings["co"] && current.trans == 18 && old.trans != 18 && current.level == 98) {
    print("Setting delayed split after CO at "+(current.counter+1).ToString());
    vars.splitAt = current.counter+1;
  }
  /*if(settings["world"] && current.world != old.world && current.world > 1) {
    print("Setting delayed split because new world ("+old.world+"->"+current.world+") at "+(current.counter+1).ToString());
    vars.splitAt = current.counter+1;
  }*/
  if ((settings["rstitle"] && current.screen == 3 && old.screen != 3)
    || (settings["rsmenu"] && current.screen == 4 && old.screen != 4)) {
    print("Clearing state because of reset condition");
    vars.paused = 0;
    vars.pausetime = 0;
    vars.loadtime = 0;
    vars.loaded = 0;
    vars.splitAt = 0;
    vars.started = 0;
    vars.shortcuts = 0;
  }
  // debug
  if(current.screen != old.screen || current.trans != old.trans || current.ingame != old.ingame || current.playing != old.playing || current.pause != old.pause || current.world != old.world || current.level != old.level || current.savedata[0xe8] != old.savedata[0xe8] || current.savedata[0xe2] != old.savedata[0xe2] || current.savedata[0xe9] != old.savedata[0xe9] || current.bombs != old.bombs || current.ropes != old.ropes || current.health != old.health) {
    print("frame: "+current.counter+" igt: "+current.igt+" screen: "+current.screen+" trans: "+current.trans+" ingame: "+current.ingame+" playing: "+current.playing+" pause: "+current.pause+" world: "+current.world+" level: "+current.level+" shortcut: "+current.savedata[0xe9]+" progress: "+current.savedata[0xe8]+" load time: "+vars.loadtime/1000.0);
    if(settings["webhook"]) {
      var post = "user="+Environment.GetEnvironmentVariable("username")
        +"&char="+current.savedata[0x2a78].ToString()
        +"&health="+current.health.ToString()
        +"&bombs="+current.bombs.ToString()
        +"&ropes="+current.ropes.ToString()
        +"&level[]="+(current.screen >= 12?current.world.ToString():0)
        +"&level[]="+(current.screen >= 12?current.level.ToString():0)
        +"&record[]="+(current.savedata[0x4ac].ToString())
        +"&record[]="+(current.savedata[0x4ad].ToString())
        +"&shortcuts="+(current.savedata[0xe9] > 1?current.savedata[0xe9]-1:0).ToString()
        +"&tries="+System.BitConverter.ToInt32(current.savedata, 0x48c).ToString()
        +"&deaths="+System.BitConverter.ToInt32(current.savedata, 0x490).ToString()
        +"&wins[]="+System.BitConverter.ToInt32(current.savedata, 0x494).ToString()
        +"&wins[]="+System.BitConverter.ToInt32(current.savedata, 0x498).ToString()
        +"&wins[]="+System.BitConverter.ToInt32(current.savedata, 0x49c).ToString();
      byte[] bytes = Encoding.ASCII.GetBytes(post);
      System.Net.WebRequest req = System.Net.WebRequest.Create("http://127.0.0.1:2222/");
      req.Method = "POST";
      req.ContentType = "application/x-www-form-urlencoded";
      Stream dataStream = req.GetRequestStream();
      dataStream.Write(bytes, 0, bytes.Length);
      dataStream.Close();
      System.Net.WebResponse res = req.GetResponse();
      print(((System.Net.HttpWebResponse)res).StatusDescription);
    }
  }
}

/*isLoading
{
  return current.loading == 2;
}*/

gameTime
{
  if(version == "") {
    return;
  }
  if((settings["ingame"] || settings["ingamesum"]) && current.igt == old.igt) {
    timer.IsGameTimePaused = true;
  } else {
    timer.IsGameTimePaused = false;
  }
  if(settings["ingame"]) {
    if(settings["pause"]) {
      if(current.pause == 1) {
        return TimeSpan.FromSeconds((current.igt+vars.pausetime+current.counter-vars.paused)/60.0);
      } else {
        return TimeSpan.FromSeconds((current.igt+vars.pausetime)/60.0);
      }
    } else {
      return TimeSpan.FromSeconds((current.igt)/60.0);
    }
  } else if(settings["framecount"]) {
    return TimeSpan.FromSeconds((current.counter-vars.started)/60.0);
  } else if(settings["loadless"]) {
    return TimeSpan.FromMilliseconds(timer.CurrentTime.RealTime.Value.TotalMilliseconds-vars.loadtime);
  } else if(settings["ingamesum"]) {
    if(settings["pause"]) {
      if(current.pause == 1) {
        return TimeSpan.FromSeconds((current.igt+vars.totaltime+vars.pausetime+current.counter-vars.paused)/60.0);
      } else {
        return TimeSpan.FromSeconds((current.igt+vars.totaltime+vars.pausetime)/60.0);
      }
    } else {
      return TimeSpan.FromSeconds((current.igt+vars.totaltime)/60.0);
    }
  } else if(settings["realtime"]) {
    return timer.CurrentTime.RealTime;
  }
}
