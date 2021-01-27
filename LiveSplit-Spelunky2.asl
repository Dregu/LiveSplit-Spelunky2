state("Spel2") {}

startup {
  settings.Add("st", true, "Starting");
  settings.Add("stlevel", true, "[any%] Start on first level", "st");
  settings.Add("stdoor", false, "[AS+T] Start on cave door", "st");

  settings.Add("sp", true, "Splitting");
  settings.Add("trans", true, "[any%] Split on any level transition screen", "sp");
  settings.Add("tiamat", true, "[any%] [AS+T] Split on end cutscene after Tiamat", "sp");
  settings.Add("hundun", true, "Split on end cutscene after Hundun", "sp");
  settings.Add("co", true, "Split on end cutscene after Cosmic Ocean", "sp");
  settings.Add("shortcut", false, "[AS+T] Split on completed shortcut tasks (\"Sure!\")", "sp");
  settings.Add("character", false, "[AC] Split on new character unlocked", "sp");
  settings.Add("characters", false, "Split on 20 characters unlocked", "sp");
  settings.Add("world", false, "Split on any world transition screen", "sp");

  settings.Add("rs", true, "Resetting (Data Management triggers only if there's something to reset)");
  settings.Add("rsrestart", true, "[any%] Reset on death/instant restart/in camp", "rs");
  settings.Add("rsdata", false, "[AS+T] [AC] Reset on \"Data Management\" reset", "rs");
  settings.Add("rsmenu", false, "Reset in main menu", "rs");
  settings.Add("rstitle", false, "Reset in title screen", "rs");
}

init {
  vars.reset = false;
  vars.state = new MemoryWatcherList();
  IntPtr ptr = IntPtr.Zero;
  IntPtr stateptr = IntPtr.Zero;
  foreach (var page in game.MemoryPages(true)) {
    var scanner = new SignatureScanner(game, page.BaseAddress, (int) page.RegionSize);
    IntPtr findptr = scanner.Scan(new SigScanTarget(0, 0x44, 0x52, 0x45, 0x47, 0x55, 0x41, 0x53, 0x4C)); // "DREGUASL" lol
    if (findptr != IntPtr.Zero) {
      ptr = findptr;
    }
  }
  foreach (var page in game.MemoryPages(false)) {
    var scanner = new SignatureScanner(game, page.BaseAddress, (int) page.RegionSize);
    IntPtr findptr = scanner.Scan(new SigScanTarget(-0x60, 0xDE, 0xC0, 0xED, 0xFE)); // 0xFEEDC0DE
    if (findptr != IntPtr.Zero) {
      stateptr = findptr;
    }
  }
  if (ptr == IntPtr.Zero) {
    throw new Exception("Could not find magic number for AutoSplitter!");
  }
  if (stateptr == IntPtr.Zero) {
    throw new Exception("Could not find magic number for State!");
  }
  print("AutoSplitter: "+ptr.ToString("x"));
  print("State: "+stateptr.ToString("x"));
  vars.state.Add(new MemoryWatcher<byte>(ptr+0x14) { Name = "screen" });
  vars.state.Add(new MemoryWatcher<int>(ptr+0x1c) { Name = "igt" });
  vars.state.Add(new MemoryWatcher<byte>(ptr+0x20) { Name = "world" });
  vars.state.Add(new MemoryWatcher<byte>(ptr+0x21) { Name = "level" });
  vars.state.Add(new MemoryWatcher<int>(ptr+0x28) { Name = "characters" });
  vars.state.Add(new MemoryWatcher<byte>(ptr+0x2c) { Name = "shortcuts" });
  vars.state.Add(new MemoryWatcher<int>(stateptr+0xa0c) { Name = "flags" });
}

update {
  vars.state.UpdateAll(game);
  timer.IsGameTimePaused = !vars.state["igt"].Changed;
  if(vars.state["screen"].Changed) print("Screen: "+vars.state["screen"].Old.ToString()+" -> "+vars.state["screen"].Current.ToString());
  if(vars.state["world"].Changed) print("World: "+vars.state["world"].Old.ToString()+" -> "+vars.state["world"].Current.ToString());
  if(vars.state["level"].Changed) print("Level: "+vars.state["level"].Old.ToString()+" -> "+vars.state["level"].Current.ToString());
  if(vars.state["characters"].Changed) print("Characters: "+vars.state["characters"].Old.ToString()+" -> "+vars.state["characters"].Current.ToString());
  if(vars.state["shortcuts"].Changed) print("Shortcuts: "+vars.state["shortcuts"].Old.ToString()+" -> "+vars.state["shortcuts"].Current.ToString());
  if(vars.state["flags"].Changed) print("Flags: "+vars.state["flags"].Old.ToString("X8")+" -> "+vars.state["flags"].Current.ToString("X8"));
}

start {
  if(vars.state["screen"].Current < 11) return false;
  if(vars.state["screen"].Current > 12) return false;
  if(settings["stlevel"] && vars.state["screen"].Current == 12 && vars.state["igt"].Current > 1) {
    print("Start: Level");
    return true;
  } else if(settings["stdoor"] && vars.state["screen"].Current == 11 && vars.state["flags"].Changed && (vars.state["flags"].Current & 0x100000) > 0) {
    print("Start: Door");
    return true;
  }
}

split {
  if(vars.state["screen"].Current == 14) return false;
  if(vars.state["screen"].Current < 12) return false;
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
  } else if(settings["shortcut"] && vars.state["shortcuts"].Changed) {
    print("Split: Shortcut unlocked");
    return true;
  } else if(settings["character"] && vars.state["characters"].Changed) {
    print("Split: Character unlocked");
    return true;
  } else if(settings["characters"] && vars.state["characters"].Changed && vars.state["characters"].Current == 20) {
    print("Split: All characters unlocked");
    return true;
  } else if(settings["world"] && vars.state["world"].Current > vars.state["world"].Old) {
    print("Split: World");
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
  if(settings["rsdata"] && 
    (vars.state["characters"].Current < vars.state["characters"].Old) ||
    (vars.state["shortcuts"].Current < vars.state["shortcuts"].Old)) {
    print("Reset: Data Management");
    return true;
  }
}

gameTime {
  return TimeSpan.FromSeconds(vars.state["igt"].Current/60.0);
}
