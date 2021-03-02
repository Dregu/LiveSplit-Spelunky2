state("Spel2") {}

startup {
  settings.Add("st", true, "Starting");
  settings.Add("stlevel", true, "Start on start of first level (uses IGT timing) [any%]", "st");
  settings.Add("stdoor", false, "Start on entering cave door (uses RTA timing) [AS+T, AC, AJE]", "st");

  settings.Add("sp", true, "Splitting");
  settings.Add("trans", true, "Split on any level transition screen [any%]", "sp");
  settings.Add("world", false, "Split on any world transition", "sp");
  settings.Add("tiamat", true, "Split on end cutscene after Tiamat [any%, AS+T]", "sp");
  settings.Add("hundun", true, "Split on end cutscene after Hundun [any%]", "sp");
  settings.Add("co", true, "Split on end cutscene after Cosmic Ocean [any%]", "sp");
  settings.Add("shortcut", false, "Split on completed shortcut tasks [AS+T]", "sp");
  settings.Add("character", false, "Split on new character unlocked [AC]", "sp");
  settings.Add("characters", false, "Split on 20 characters unlocked", "sp");
  settings.Add("journal", false, "Split on 100% journal unlocked [AJE]", "sp");

  settings.Add("rs", true, "Resetting");
  settings.Add("rsrestart", true, "Reset on death/instant restart/in camp [any%]", "rs");
  settings.Add("rsdata", false, "Reset on \"Data Management\" reset [AS+T, AC, AJE]", "rs");
  settings.Add("rsmenu", false, "Reset in main menu", "rs");
  settings.Add("rstitle", false, "Reset in title screen", "rs");

  settings.Add("tm", true, "Timing (Game Time returns the proper time based on your Start option)");
  settings.Add("tmforce", true, "Force current timing method to Game Time", "tm");

  settings.Add("ms", true, "Miscellaneous");
  settings.Add("tracker", false, "Send journal data to s2tracker [AC, AJE]", "ms");
}

init {
  vars.reset = false;
  vars.state = new MemoryWatcherList();
  IntPtr ptr = IntPtr.Zero;
  vars.saveptr = IntPtr.Zero;
  vars.checksum = 0;
  vars.lastsum = 0;
  vars.journal = new List<byte>();

  foreach (var page in game.MemoryPages(true)) {
    var scanner = new SignatureScanner(game, page.BaseAddress, (int) page.RegionSize);
    IntPtr findptr = scanner.Scan(new SigScanTarget(0, 0x44, 0x52, 0x45, 0x47, 0x55, 0x41, 0x53, 0x4C));
    //IntPtr saveptr = scanner.Scan(new SigScanTarget(16, 0, 0, 0, 0, 0, 0, 0, 0, 0xA3, 0x35, 0, 0, 0, 0, 0, 0));
    if (findptr != IntPtr.Zero) {
      ptr = findptr;
    }
    /*if (saveptr != IntPtr.Zero) {
      vars.saveptr = saveptr;
      vars.journal = game.ReadBytes((IntPtr)vars.saveptr, 210);
      print("Savedata: "+vars.saveptr.ToString("x"));
    }*/
  }
  if (ptr == IntPtr.Zero) {
    throw new Exception("Could not find magic number for AutoSplitter!");
  }
  print("AutoSplitter: "+ptr.ToString("x"));
  vars.state.Add(new MemoryWatcher<byte>(ptr+0x14) { Name = "screen" });
  vars.state.Add(new MemoryWatcher<byte>(ptr+0x1a) { Name = "pause" });
  vars.state.Add(new MemoryWatcher<int>(ptr+0x1c) { Name = "igt" });
  vars.state.Add(new MemoryWatcher<byte>(ptr+0x20) { Name = "world" });
  vars.state.Add(new MemoryWatcher<byte>(ptr+0x21) { Name = "level" });
  vars.state.Add(new MemoryWatcher<int>(ptr+0x28) { Name = "characters" });
  vars.state.Add(new MemoryWatcher<byte>(ptr+0x2c) { Name = "shortcuts" });
  vars.state.Add(new MemoryWatcher<int>(ptr+0x294) { Name = "door" });
  vars.state.Add(new MemoryWatcher<int>(ptr+0x298) { Name = "reset" });
  vars.state.Add(new MemoryWatcher<int>(ptr+0x29c) { Name = "reset_type" });

  Action initTracker = delegate() {
    foreach (var page in game.MemoryPages(true)) {
      var scanner = new SignatureScanner(game, page.BaseAddress, (int) page.RegionSize);
      IntPtr saveptr = scanner.Scan(new SigScanTarget(16, 0, 0, 0, 0, 0, 0, 0, 0, 0xA3, 0x35, 0, 0, 0, 0, 0, 0));
      if (saveptr != IntPtr.Zero) {
        vars.saveptr = saveptr;
        vars.journal = game.ReadBytes((IntPtr)vars.saveptr, 210);
        print("Savedata: "+vars.saveptr.ToString("x"));
      }
    }
  };
  vars.initTracker = initTracker;
  vars.initTracker();
}

update {
  if(settings["tmforce"] && timer.CurrentTimingMethod != TimingMethod.GameTime) timer.CurrentTimingMethod = TimingMethod.GameTime;
  vars.state.UpdateAll(game);
  timer.IsGameTimePaused = !vars.state["igt"].Changed;
  if(vars.state["screen"].Changed) print("Screen: "+vars.state["screen"].Old.ToString()+" -> "+vars.state["screen"].Current.ToString());
  if(vars.state["world"].Changed) print("World: "+vars.state["world"].Old.ToString()+" -> "+vars.state["world"].Current.ToString());
  if(vars.state["level"].Changed) print("Level: "+vars.state["level"].Old.ToString()+" -> "+vars.state["level"].Current.ToString());
  if(vars.state["characters"].Changed) print("Characters: "+vars.state["characters"].Old.ToString()+" -> "+vars.state["characters"].Current.ToString());
  if(vars.state["shortcuts"].Changed) print("Shortcuts: "+vars.state["shortcuts"].Old.ToString()+" -> "+vars.state["shortcuts"].Current.ToString());
  if(vars.state["door"].Changed) print("Door frame: "+vars.state["door"].Old.ToString()+" -> "+vars.state["door"].Current.ToString());
  if(vars.state["reset"].Changed) print("Reset frame: "+vars.state["reset"].Old.ToString()+" -> "+vars.state["reset"].Current.ToString());
  if(vars.state["reset_type"].Changed) print("Reset type: "+vars.state["reset_type"].Old.ToString()+" -> "+vars.state["reset_type"].Current.ToString());

  if (settings["tracker"] || settings["journal"]) {
    if (vars.saveptr == IntPtr.Zero) {
      vars.initTracker();
    }
    vars.journal = game.ReadBytes((IntPtr)vars.saveptr, 210);
    int sum = 0;
    Array.ForEach((System.Byte[])vars.journal, i => sum += i);
    if (sum != vars.checksum) {
      print("Journal: "+vars.checksum.ToString()+" -> "+sum.ToString()+" / 210");
      vars.checksum = sum;
      var post = "journal="+string.Join(",", vars.journal);
      byte[] bytes = Encoding.ASCII.GetBytes(post);
      System.Net.WebRequest req = System.Net.WebRequest.Create("http://localhost:27122/");
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

start {
  if(vars.state["screen"].Current < 11) return false;
  if(vars.state["screen"].Current > 12) return false;
  if(settings["stlevel"] && vars.state["screen"].Current == 12 && vars.state["igt"].Current > 1) {
    print("Start: Level");
    return true;
  } else if(settings["stdoor"] && vars.state["screen"].Current == 11 && vars.state["door"].Changed) {
    print("Start: Door");
    return true;
  }
}

split {
  if(vars.state["screen"].Current == 14) return false;
  if(vars.state["screen"].Current < 12) return false;
  int sum = 0;
  Array.ForEach((System.Byte[])vars.journal, i => sum += i);
  if(settings["trans"] && vars.state["screen"].Changed && vars.state["screen"].Current == 13) {
    print("Split: Level transition");
    return true;
  } else if(settings["tiamat"] && vars.state["world"].Current == 6 && vars.state["screen"].Changed && vars.state["screen"].Current == 16) {
    print("Split: Tiamat ending");
    return true;
  } else if(settings["hundun"] && vars.state["world"].Current == 7 && vars.state["screen"].Changed && vars.state["screen"].Current == 16) {
    print("Split: Hundun ending");
    return true;
  } else if(settings["co"] && vars.state["screen"].Changed && vars.state["screen"].Current == 19) {
    print("Split: CO ending");
    return true;
  } else if(settings["shortcut"] && vars.state["shortcuts"].Changed && vars.state["shortcuts"].Current > 1) {
    print("Split: Shortcut unlocked");
    return true;
  } else if(settings["character"] && vars.state["characters"].Changed) {
    print("Split: Character unlocked");
    return true;
  } else if(settings["characters"] && vars.state["characters"].Changed && vars.state["characters"].Current == 20) {
    print("Split: All characters unlocked");
    return true;
  } else if(settings["world"] && vars.state["world"].Changed) {
    print("Split: World");
    return true;
  } else if(settings["journal"] && sum == 210 && vars.lastsum != sum) {
    print("Split: Journal");
    vars.lastsum = sum;
    return true;
  }
}

reset {
  if(settings["rsrestart"] && vars.state["igt"].Changed && vars.state["igt"].Current <= 1) {
    print("Reset: Restart");
    return true;
  }
  if(settings["rstitle"] && vars.state["screen"].Changed && vars.state["screen"].Current == 3) {
    print("Reset: Title");
    return true;
  }
  if(settings["rsmenu"] && vars.state["screen"].Changed && vars.state["screen"].Current < 11) {
    print("Reset: Menu");
    return true;
  }
  if(settings["rsdata"] && vars.state["screen"].Current == 5 && vars.state["reset"].Changed) {
    print("Reset: Data Management");
    return true;
  }
}

gameTime {
  if(settings["stlevel"]) {
    return TimeSpan.FromSeconds(vars.state["igt"].Current/60.0);
  } else if(settings["stdoor"]) {
    return timer.CurrentTime.RealTime;
  }
}
