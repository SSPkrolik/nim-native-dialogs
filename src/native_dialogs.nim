## Nim cross-platform library that implements calling native desktop
## operating systems dialogs.

import os
import strutils

type
  ErrorUnsupportedPlatform* = ref object of Exception
  ## OS is not supported by the library exception

  WindowToolkitKind* {.pure.} = enum  ## Kind of API to call dialogs via
    Win32 = 0
    Darwin
    GTK
    KDE

  DialogButtonInfo* = tuple[title: string, responseType: int]
    ## Defines dialog button

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

  let
    dialogFileOpenDefaultButtons*: seq[DialogButtonInfo] = @[
      (title: "Cancel", responseType: ResponseType.CANCEL.int),
      (title: "Open", responseType: ResponseType.ACCEPT.int)
    ]

    dialogFileSaveDefaultButtons*: seq[DialogButtonInfo] = @[
      (title: "Cancel", responseType: ResponseType.CANCEL.int),
      (title: "Save", responseType: ResponseType.ACCEPT.int)
    ]

    dialogFolderCreateDefaultButtons*: seq[DialogButtonInfo] = @[
      (title: "Cancel", responseType: ResponseType.CANCEL.int),
      (title: "Create", responseType: ResponseType.ACCEPT.int)
    ]

    dialogFolderSelectDefaultButtons*: seq[DialogButtonInfo] = @[
      (title: "Cancel", responseType: ResponseType.CANCEL.int),
      (title: "Open", responseType: ResponseType.ACCEPT.int)
    ]

  proc callDialogFile(action: FileChooserAction, title: string, buttons: seq[DialogButtonInfo] = @[]): string =
    # Setup dialog
    var dialog = file_chooser_dialog_new(title.cstring, nil, action, nil)
    # Setup buttons
    for button in buttons:
      discard dialog.add_button(button.title.cstring, button.responseType.cint)

    # Run dialog
    var res = dialog.run()

    # Analyze call results
    case ResponseType(res):
    of ResponseType.ACCEPT, ResponseType.YES, ResponseType.APPLY:
      let fileChooser = cast[FileChooser](pointer(dialog))
      return $fileChooser.get_filename()
    of ResponseType.REJECT, ResponseTYPE.NO , ResponseType.CANCEL, ResponseType.CLOSE:
      return nil
    else:
      return nil

  proc callDialogFileOpen*(title: string, buttons: seq[DialogButtonInfo] = dialogFileOpenDefaultButtons): string =
    ## Calls Linux-based OS open file dialog, and returns selected filename[s]
    result = callDialogFile(FileChooserAction.OPEN, title, buttons)

  proc callDialogFileSave*(title: string): string =
    ## Calls Linux-based OS save file dialog, and returns filename to save to
    return callDialogFile(FileChooserAction.SAVE, title, dialogFileSaveDefaultButtons)

  proc callDialogFolderCreate*(title: string): string =
    ## Call native Linux-based OS folder creation dialog, and returns folder name
    return callDialogFile(FileChooserAction.CREATE_FOLDER, title, dialogFolderCreateDefaultButtons)

  proc callDialogFolderSelect*(title: string): string =
    ## Call native Linux-base OS folder opening dialog, and return folder name
    return callDialogFile(FileChooserAction.SELECT_FOLDER, title, dialogFolderSelectDefaultButtons)

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
  echo callDialogFileOpen("Open Simulation Results File")
  echo callDialogFileSave("Save Simulation Results File")
  echo callDialogFolderCreate("Create New Folder")
  echo callDialogFolderSelect("Open Folder")
