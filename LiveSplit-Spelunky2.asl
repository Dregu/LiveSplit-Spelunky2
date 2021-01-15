/*
 * Spelunky 2 autosplitter for LiveSplit by Dregu
 * Remember to set LiveSplit to Compare Against -> Game Time
 * and check the ASL settings for the right category options.
 *
 * You can set the racehud webhook url where to push status updates to by running
 * setx LIVESPLIT_WEBHOOK_URL http://localhost:2222/Runnername/password
 */

state("Spel2")
{
  // unknown version
}

// 0x221A0DC8, 0x88, 0x58, 0x38, 0x3c8
state("Spel2", "1.19.7a")
{
  int counter : 0x221A0DC8, 0x88, 0x58, 0x38, 0x2f8;
  byte screen : 0x221A0DC8, 0x88, 0x58, 0x38, 0x3d8;
  byte loading : 0x221A0DC8, 0x88, 0x58, 0x38, 0x3dc;
  byte trans : 0x221A0DC8, 0x88, 0x58, 0x38, 0x3f0;
  bool ingame : 0x221A0DC8, 0x88, 0x58, 0x38, 0x3f8;
  bool playing : 0x221A0DC8, 0x88, 0x58, 0x38, 0x3f9;
  byte pause : 0x221A0DC8, 0x88, 0x58, 0x38, 0x3fa;
  int igt : 0x221A0DC8, 0x88, 0x58, 0x38, 0x428;
  byte world : 0x221A0DC8, 0x88, 0x58, 0x38, 0x42d;
  byte level : 0x221A0DC8, 0x88, 0x58, 0x38, 0x42e;
  byte door : 0x221A0DC8, 0x88, 0x58, 0x7300;
  byte12000 savedata : 0x22193748, 0, 0x48, 0;
}

// state = savedata+0xd680
state("Spel2", "1.19.8c")
{
  int counter : 0x221a1dc8, 0x88, 0x58, 0x38, 0x2f8;
  byte screen : 0x221a1dc8, 0x88, 0x58, 0x38, 0x3d8;
  byte loading : 0x221a1dc8, 0x88, 0x58, 0x38, 0x3dc;
  byte trans : 0x221a1dc8, 0x88, 0x58, 0x38, 0x3f0;
  bool ingame : 0x221a1dc8, 0x88, 0x58, 0x38, 0x3f8;
  bool playing : 0x221a1dc8, 0x88, 0x58, 0x38, 0x3f9;
  byte pause : 0x221a1dc8, 0x88, 0x58, 0x38, 0x3fa;
  int igt : 0x221a1dc8, 0x88, 0x58, 0x38, 0x428;
  byte world : 0x221a1dc8, 0x88, 0x58, 0x38, 0x42d;
  byte level : 0x221a1dc8, 0x88, 0x58, 0x38, 0x42e;
  byte door : 0x221a1dc8, 0x88, 0x58, 0x7300;
  byte12000 savedata : 0x22194748, 0x8, 0x48, 0;
}

state("Spel2", "1.20.0j")
{
  int counter : 0x221A3DC8, 0x3d0;
  byte screen : 0x221A3DC8, 0x4ac;
  byte loading : 0x221A3DC8, 0x4b4;
  byte trans : 0x221A3DC8, 0x4c8;
  bool ingame : 0x221A3DC8, 0x4d0;
  bool playing : 0x221A3DC8, 0x4d1;
  byte pause : 0x221A3DC8, 0x4d2;
  int igt : 0x221A3DC8, 0x500;
  byte world : 0x221A3DC8, 0x505;
  byte level : 0x221A3DC8, 0x506;
  byte door : 0x22188F60, 0x38, 0x38, 0x73b0;
  byte12000 savedata : 0x22196778, 0x8, 0x48, 0;
}

startup
{
  settings.Add("st", true, "Starting");
  settings.Add("stlevel", true, "[any%] Start on first level", "st");
  settings.Add("stdoor", false, "[AS+T] Start on door (note: use the appropriate timing method too)", "st");

  settings.Add("sp", true, "Splitting");
  settings.Add("trans", true, "[any%] Split on any level transition screen", "sp");
  settings.Add("shortcut", false, "[AS+T] Split on completed shortcut tasks (\"Sure!\")", "sp");
  settings.Add("tiamat", true, "[any%] [AS+T] Split on end cutscene after Tiamat", "sp");
  settings.Add("hundun", true, "Split on end cutscene after Hundun", "sp");
  settings.Add("co", true, "Split on end cutscene after Cosmic Ocean", "sp");
  settings.Add("world", false, "Split on any world transition screen", "sp");
  settings.Add("character", false, "[AC] Split on new character unlocked", "sp");
  settings.Add("characters", false, "Split on 20 characters unlocked", "sp");

  settings.Add("rs", true, "Resetting (Data Management options trigger only if there's something to reset)");
  settings.Add("rsrestart", true, "[any%] Reset on death/instant restart/in camp", "rs");
  settings.Add("rsshortcut", false, "[AS+T] Reset on \"Reset Shortcuts\"", "rs");
  settings.Add("rscharacter", false, "[AC] Reset on \"Reset Unlocked Characters\"", "rs");
  settings.Add("rsmenu", false, "Reset in main menu", "rs");
  settings.Add("rstitle", false, "Reset in title screen", "rs");

  settings.Add("tm", true, "Timing method used by \"Game Time\" comparison (select exactly one)");
  settings.Add("ingame", true, "[any%] Ingame timer (pauses on level transitions, resets on camp)", "tm");
  settings.Add("astime", false, "[AS+T] RTA timer for door start (1.19.7a+, adds 0.63s to RT)", "tm");
  settings.Add("realtime", false, "Real time (yes it just copies real time to game time)", "tm");

  settings.Add("misc", true, "Miscellaneous");
  settings.Add("pause", true, "Keep ingame timers running when paused instead of updating on level change (just a visual thing during levels, doesn't change the split times or total time)", "misc");
  settings.Add("webhook", false, "Enable experimental webhook thing", "misc");

  vars.getCharacters = (Func<int, int, int, int>)((a, b, c) => {
    int count = 0;
    while (a > 0) {
        count += a & 1;
        a >>= 1;
    }
    while (b > 0) {
        count += b & 1;
        b >>= 1;
    }
    while (c > 0) {
        count += c & 1;
        c >>= 1;
    }
    vars.characters = count;
    return count;
  });
}

init
{
  switch (modules.First().ModuleMemorySize) {
    case 572555264: version = "1.19.7a"; break;
    case 572559360: version = "1.19.8c"; break;
    case 572567552: version = "1.20.0j"; break;
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
  vars.webhookUrl = Environment.GetEnvironmentVariable("LIVESPLIT_WEBHOOK_URL", EnvironmentVariableTarget.User);
  vars.webhookAt = 0;
  vars.world = 0;
  vars.pace = "";
  vars.levelsleft = 0;
  vars.levelstarted = 0.0;
  vars.characters = 0;
}

start
{
  if(version == "") {
    return;
  }
  if(current.screen <= 3) {
    return;
  }
  if ((settings["stlevel"] && current.playing && current.igt > 1 && old.igt == 1 && current.screen == 12)
  || (settings["stdoor"] && ((current.screen == 11 && current.door == 1 && old.door == 0) || (current.screen == 12 && old.screen == 11)))) {
    print("Starting timer");
    vars.paused = 0;
    vars.pausetime = 0;
    vars.loadtime = 0.0;
    vars.loaded = 0.0;
    vars.totaltime = 0;
    vars.splitAt = 0;
    vars.started = current.counter;
    vars.webhookUrl = Environment.GetEnvironmentVariable("LIVESPLIT_WEBHOOK_URL", EnvironmentVariableTarget.User);
    vars.webhookAt = 0;
    vars.world = 0;
    vars.pace = "";
    vars.levelsleft = 0;
    vars.levelstarted = 0.0;
    if(settings["webhook"] && vars.webhookUrl != null) {
      vars.webhookAt = current.counter+10;
    }
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
  vars.getCharacters(current.savedata[0xe4], current.savedata[0xe5], current.savedata[0xe6]);
  if(vars.splitAt > 0 && current.counter >= vars.splitAt && current.igt > 10 && current.screen != 14) {
    print("Splitting after level transition delay");
    vars.splitAt = 0;
    return true;
  } else if(settings["world"] && current.world != old.world && current.world > 1) {
    print("Splitting because new world ("+old.world+"->"+current.world+")");
    return true;
  } else if(settings["shortcut"] && current.savedata[0xe9] != old.savedata[0xe9] && current.savedata[0xe9] > 1) {
    print("Splitting because completed shortcut task");
    return true;
  } else if(settings["character"] && (current.savedata[0xe4] > old.savedata[0xe4] || current.savedata[0xe5] > old.savedata[0xe5] || current.savedata[0xe6] > old.savedata[0xe6])) {
    print("Splitting because character unlocked");
    return true;
  } else if(settings["characters"] && (current.savedata[0xe4] > old.savedata[0xe4] || current.savedata[0xe5] > old.savedata[0xe5] || current.savedata[0xe6] > old.savedata[0xe6]) && vars.characters == 20) {
    print("Splitting because all characters unlocked");
    return true;
  }
}

reset
{
  if(version == "") {
    return;
  }
  vars.getCharacters(current.savedata[0xe4], current.savedata[0xe5], current.savedata[0xe6]);
  if ((settings["rstitle"] && current.screen == 3 && old.screen != 3)
    || (settings["rsrestart"] && current.igt <= 1)
    || (settings["rsmenu"] && !current.ingame && !current.playing && current.pause == 0)
    || (settings["rsshortcut"] && current.savedata[0xe9] < old.savedata[0xe9])
    || (settings["rscharacter"] && (current.savedata[0xe4] < old.savedata[0xe4] || current.savedata[0xe5] < old.savedata[0xe5] || current.savedata[0xe6] < old.savedata[0xe6]) && vars.characters == 4)) {
    print("Resetting timer");
    vars.paused = 0;
    vars.pausetime = 0;
    vars.loadtime = 0.0;
    vars.loaded = 0.0;
    vars.totaltime = 0;
    vars.splitAt = 0;
    vars.started = 0;
    vars.webhookAt = 0;
    vars.world = 0;
    vars.pace = "";
    vars.levelsleft = 0;
    vars.levelstarted = 0.0;
    if(settings["webhook"] && vars.webhookUrl != null) {
      vars.webhookAt = current.counter+10;
    }
    return true;
  }
}

update
{
  if(version == "") {
    return;
  }
  vars.getCharacters(current.savedata[0xe4], current.savedata[0xe5], current.savedata[0xe6]);
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
  if(current.screen == 13 && old.screen != 13) {
    print("Clearing pausetimer on level transition");
    vars.paused = 0;
    vars.pausetime = 0;
    if(timer.CurrentTime.GameTime.HasValue) {
      vars.levelstarted = timer.CurrentTime.GameTime.Value.TotalSeconds;
    }
  }
  if(current.igt < old.igt) {
    vars.totaltime += old.igt;
  }
  if(settings["trans"] && current.screen == 13 && old.screen != 13) {
    print("Setting delayed split after level transition at "+(current.counter+1).ToString());
    vars.splitAt = current.counter+1;
  } else if(settings["tiamat"] && current.world == 6 && current.level == 4 && current.screen == 16 && old.screen != 16) {
    print("Setting delayed split after Tiamat at "+(current.counter+1).ToString());
    vars.splitAt = current.counter+1;
  } else if(settings["hundun"] && current.world == 7 && current.level == 4 && current.screen == 16 && old.screen != 16) {
    print("Setting delayed split after Hundun at "+(current.counter+1).ToString());
    vars.splitAt = current.counter+1;
  } else if(settings["co"] && current.world == 7 && current.level == 99 && current.screen == 19 && old.screen != 19) {
    print("Setting delayed split after CO at "+(current.counter+1).ToString());
    vars.splitAt = current.counter+1;
  }
  if ((settings["rstitle"] && current.screen == 3 && old.screen != 3)
    || (settings["rsrestart"] && current.igt <= 1)
    || (settings["rsmenu"] && !current.ingame && !current.playing && current.pause == 0)
    || (settings["rsshortcut"] && current.savedata[0xe9] < old.savedata[0xe9])
    || (settings["rscharacter"] && (current.savedata[0xe4] < old.savedata[0xe4] || current.savedata[0xe5] < old.savedata[0xe5] || current.savedata[0xe6] < old.savedata[0xe6]) && vars.characters == 4)) {
    vars.paused = 0;
    vars.pausetime = 0;
    vars.loadtime = 0;
    vars.loaded = 0;
    vars.splitAt = 0;
    vars.started = 0;
    vars.webhookAt = 0;
    vars.world = 0;
    vars.pace = "";
    vars.levelsleft = 0;
    vars.levelstarted = 0.0;
    vars.leveltimeleft = "";
  }
  if(current.screen == 12) {
    vars.world = current.world;
  }

  // stupid level pace calculation
  vars.levelsleft = 0;
  string levellist = "";
  int tw = 1;
  int tl = 1;
  int w = vars.world;
  int l = current.level;
  if(settings["tiamat"]) {
    tw = 6; tl = 4;
  } else if(settings["hundun"]) {
    tw = 7; tl = 4;
  } else if(settings["co"]) {
    tw = 7; tl = 98;
  }
  while(w < tw || (w >= tw && l <= tl)) {
    if(w == 3 && l > 1) {
      w++;
      l = 1;
    } else if(w == 5 && l > 1) {
      w++;
      l = 1;
    } else if(w < 7 && l > 4) {
      w++;
      l = 1;
    } else if(l > 99) {
      break;
    }
    levellist = levellist+", "+w.ToString()+"-"+l.ToString();
    l++;
    vars.levelsleft++;
  }
  if(current.screen == 13 || (current.screen == 12 && !current.playing)) {
    vars.levelsleft -= 1;
  }
  if(vars.levelsleft <= 0) {
    vars.levelsleft = 1;
  }
  double pb = (timer.Run[timer.Run.Count-1].PersonalBestSplitTime.GameTime.HasValue ? (timer.Run[timer.Run.Count-1].PersonalBestSplitTime.GameTime.Value).TotalSeconds : 0);
  if(timer.CurrentTime.GameTime.HasValue) {
    double timeleft = pb - vars.levelstarted;
    double timeleftaverage = pb / vars.levelsleft;
    TimeSpan average = TimeSpan.FromSeconds(timeleftaverage);
    TimeSpan left = TimeSpan.FromSeconds(timeleftaverage-(timer.CurrentTime.GameTime.Value.TotalSeconds-vars.levelstarted));
    if(average.Hours > 0) {
      vars.pace = (left < TimeSpan.FromSeconds(0)?"+":"-")+string.Format("{0:D1}:{1:D2}:{2:D2} / {3:D1}:{4:D2}:{5:D2}", Math.Abs(left.Hours), Math.Abs(left.Minutes), Math.Abs(left.Seconds), average.Hours, average.Minutes, average.Seconds);
    } else {
      vars.pace = (left < TimeSpan.FromSeconds(0)?"+":"-")+string.Format("{0:D1}:{1:D2} / {2:D1}:{3:D2}", Math.Abs(left.Minutes), Math.Abs(left.Seconds), average.Minutes, average.Seconds);
    }
  }

  // debug
  if(current.screen != old.screen || current.trans != old.trans || current.ingame != old.ingame || current.playing != old.playing || current.pause != old.pause || current.world != old.world || current.level != old.level || current.savedata[0xe8] != old.savedata[0xe8] || current.savedata[0xe2] != old.savedata[0xe2] || current.savedata[0xe9] != old.savedata[0xe9] || current.savedata[0xe4] != old.savedata[0xe4] || current.savedata[0xe5] != old.savedata[0xe5] || current.savedata[0xe6] != old.savedata[0xe6]) {
    print("frame: "+current.counter+" igt: "+current.igt+" screen: "+current.screen+" trans: "+current.trans+" ingame: "+current.ingame+" playing: "+current.playing+" pause: "+current.pause+" world: "+current.world+" level: "+current.level+" shortcut: "+current.savedata[0xe9]+" progress: "+current.savedata[0xe8]+" character: "+vars.characters+" load time: "+vars.loadtime/1000.0);
    vars.webhookUrl = Environment.GetEnvironmentVariable("LIVESPLIT_WEBHOOK_URL", EnvironmentVariableTarget.User);
    if(settings["webhook"] && vars.webhookUrl != null) {
        vars.webhookAt = current.counter+10;
    }
    print(levellist);
  }
  if(vars.webhookAt > 0 && current.counter >= vars.webhookAt) {
    vars.webhookAt = 0;
    print("Using webhook: "+vars.webhookUrl);
    var post = "char="+current.savedata[0x2a78].ToString()
      +"&health=4"
      +"&bombs=4"
      +"&ropes=4"
      +"&level[]="+(current.screen >= 12?vars.world.ToString():0)
      +"&level[]="+(current.screen >= 12?current.level.ToString():0)
      +"&record[]="+(current.savedata[0x4ac].ToString())
      +"&record[]="+(current.savedata[0x4ad].ToString())
      +"&shortcuts="+(current.savedata[0xe9] > 1?current.savedata[0xe9]-1:0).ToString()
      +"&characters="+vars.characters.ToString()
      +"&tries="+System.BitConverter.ToInt32(current.savedata, 0x48c).ToString()
      +"&deaths="+System.BitConverter.ToInt32(current.savedata, 0x490).ToString()
      +"&wins[]="+System.BitConverter.ToInt32(current.savedata, 0x494).ToString()
      +"&wins[]="+System.BitConverter.ToInt32(current.savedata, 0x498).ToString()
      +"&wins[]="+System.BitConverter.ToInt32(current.savedata, 0x49c).ToString()
      +"&igt="+(current.igt/60.0).ToString(System.Globalization.CultureInfo.InvariantCulture)
      +"&gt="+timer.CurrentTime.GameTime.Value.TotalSeconds.ToString(System.Globalization.CultureInfo.InvariantCulture)
      +"&bigt="+(System.BitConverter.ToInt32(current.savedata, 0x2894)/60.0).ToString(System.Globalization.CultureInfo.InvariantCulture)
      +"&phase="+timer.CurrentPhase
      +"&splitindex="+timer.CurrentSplitIndex
      +"&splits="+timer.Run.Count
      +"&splittime="+(timer.CurrentSplitIndex < timer.Run.Count && timer.CurrentSplitIndex >= 0 && timer.Run[timer.CurrentSplitIndex].PersonalBestSplitTime.GameTime.HasValue ? (timer.Run[timer.CurrentSplitIndex].PersonalBestSplitTime.GameTime.Value).TotalSeconds : 0).ToString(System.Globalization.CultureInfo.InvariantCulture)
      +"&pb="+(timer.Run[timer.Run.Count-1].PersonalBestSplitTime.GameTime.HasValue ? (timer.Run[timer.Run.Count-1].PersonalBestSplitTime.GameTime.Value).TotalSeconds : 0).ToString(System.Globalization.CultureInfo.InvariantCulture)
      +"&levelsleft="+vars.levelsleft
      +"&pace="+vars.pace;
    byte[] bytes = Encoding.ASCII.GetBytes(post);
    System.Net.WebRequest req = System.Net.WebRequest.Create(vars.webhookUrl);
    req.Method = "POST";
    req.ContentType = "application/x-www-form-urlencoded";
    Stream dataStream = req.GetRequestStream();
    dataStream.Write(bytes, 0, bytes.Length);
    dataStream.Close();
    print("Posting "+vars.webhookUrl+"?"+post);
    System.Net.WebResponse res = req.GetResponse();
    print(((System.Net.HttpWebResponse)res).StatusDescription);
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
  //if((settings["ingame"] || settings["ingamesum"]) && current.igt == old.igt) {
  if(settings["ingame"] && current.igt == old.igt) {
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
  } /*else if(settings["framecount"]) {
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
  } */else if(settings["realtime"]) {
    return timer.CurrentTime.RealTime;
  } else if(settings["astime"]) {
    return timer.CurrentTime.RealTime+TimeSpan.FromSeconds(0.63);
  }
}
