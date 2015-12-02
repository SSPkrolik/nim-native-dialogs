## Nim cross-platform library that implements calling native desktop
## operating systems dialogs.

import os
import strutils

type ErrorUnsupportedPlatform* = ref object of Exception
  ## OS is not supported by the library exception

type WindowToolkitKind* {.pure.} = enum  ## Kind of API to call dialogs via
  Win32 = 0
  Darwin
  GTK
  KDE

# ======= #
#  LINUX  #
# ======= #
when defined(linux):
  var windowToolkitKind: WindowToolkitKind

  # Checking for Linux system capabilities
  import gtk3

  # Checking for Window Manager Type, and performing initialization if needed
  if os.getEnv("XDG_CURRENT_DESKTOP").toLower() in @["unity", "gnome"]:
    windowToolkitKind = WindowToolkitKind.GTK
    # Initializing GNOME-based environment
    var
      argc: cint = 0
      argv: cstringArray = nil
    discard init_check(argc, argv)
  elif os.getEnv("GDMSESSION").toLower() in @["kde-plasma"]:
    # Initializing KDE-based environment
    windowToolkitKind = WindowToolkitKind.KDE

  proc callDialogFileOpen*(): seq[string] =
    ## Calls Linux-based OS open file dialog, and returns selected filename[s]
    result = @[]

  proc callDialogFileSave*(): string =
    ## Calls Linux-based OS save file dialog, and returns filename to save to
    result = nil

  proc callDialogFolderCreate*(): string =
    ## Call native Linux-based OS folder creation dialog, and returns folder name
    result = nil

  proc callDialogFolderOpen*(): string =
    ## Call native Linux-base OS folder opening dialog, and return folder name
    result = nil

# ======== #
# WINDOWS  #
# ======== #
elif defined(windows):
  var windowToolkitKind: WindowToolkitKind = WindowToolkitKind.Win32
  raise new(ErrorUnsupportedPlatform)

# ======== #
# OSX
# ======== #
elif defined(macos):
  var windowToolkitKind: WindowToolkitKind = WindowToolkitKind.Darwin
  raise new(ErrorUnsupportedPlatform)

else:
  raise new(ErrorUnsupportedPlatform)

when isMainModule:
  echo "Your window toolkit is: ", windowToolkitKind
