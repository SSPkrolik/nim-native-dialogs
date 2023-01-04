import private/common_types

export WindowToolkitKind


when defined(windows):
    import private/native_dialogs_windows
elif defined(macosx) and not defined(ios):
    import private/native_dialogs_macosx
elif defined(linux) and not defined(android) and not defined(emscripten):
    import private/native_dialogs_gtk
    #TODO: choose qt / gtk


proc getWindowToolkitKind*(): WindowToolkitKind = getWindowToolkitKindImpl()

proc callDialogFileOpen*(title: string): string = return callDialogFileOpenImpl(title)
proc callDialogFileSave*(title: string): string = return callDialogFileSaveImpl(title)
proc callDialogFolderCreate*(title: string): string = return callDialogFolderCreateImpl(title)
proc callDialogFolderSelect*(title: string): string = return callDialogFolderSelectImpl(title)


when isMainModule:
  echo "Your window toolkit is: ", getWindowToolkitKind()
  echo callDialogFileOpen("Open Simulation Results File")
  echo callDialogFileSave("Save Simulation Results File")
  echo callDialogFolderCreate("Create Folder For Simulation Results")
  echo callDialogFolderSelect("Select Folder For Simulation Results")
