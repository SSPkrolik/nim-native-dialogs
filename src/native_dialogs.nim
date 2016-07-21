## Nim cross-platform library that implements calling native desktop
## operating systems dialogs.
import os
import strutils

type
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
when defined(linux) and not defined(android) and not defined(emscripten):
  var windowToolkitKind: WindowToolkitKind

  # Checking for Linux system capabilities
  import glib
  import gtk3

  # Checking for Window Manager Type, and performing initialization if needed
  if os.getEnv("XDG_CURRENT_DESKTOP").toLower() in @["unity", "gnome"]:
    windowToolkitKind = WindowToolkitKind.GTK
    # Initializing GNOME-based environment
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
    var
      argc: cint = 0
      argv: cstringArray = nil
    discard init_check(argc, argv)
    echo "GTK initialized"

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
      result = $fileChooser.get_filename()
    of ResponseType.REJECT, ResponseTYPE.NO , ResponseType.CANCEL, ResponseType.CLOSE:
      result = nil
    else:
      result = nil

    dialog.destroy()
    while events_pending():
      discard main_iteration()

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

  ## Implementing Win32
  import windows

  type WindowsDialogAction {.pure.} = enum
    Open = 0
    Save

  proc callDialogFile(title: string, action: WindowsDialogAction, buttons: seq[DialogButtonInfo] = @[]): string =
    var
      fileInfo: LPOPENFILENAME = cast[LPOPENFILENAME](alloc0(sizeof(TOPENFILENAME)))
      buf: cstring = cast[cstring](alloc0(1024))

    fileInfo.lStructSize = sizeof(TOPENFILENAME).DWORD
    fileInfo.hWndOwner = 0
    fileInfo.flags = OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
    fileInfo.lpstrFile = buf
    fileInfo.nMaxFile = 1024
    fileInfo.lpstrFilter = "All\0*.*\0";
    fileInfo.lpstrFileTitle = title

    var res: int
    case action
    of WindowsDialogAction.Open:
      res = GetOpenFileName(fileInfo)
    of WindowsDialogAction.Save:
      res = GetSaveFileName(fileInfo)

    return if res == 0: nil else: $buf

  proc callDialogFileOpen*(title: string, buttons: seq[DialogButtonInfo] = @[]): string =
    return callDialogFile(title, WindowsDialogAction.Open, buttons)

  proc callDialogFileSave*(title: string, buttons: seq[DialogButtonInfo] = @[]): string =
    return callDialogFile(title, WindowsDialogAction.Save, buttons)

# ======== #
# OSX
# ======== #
elif defined(macosx) and not defined(ios):
    var windowToolkitKind = WindowToolkitKind.Darwin

    {.passL: "-framework AppKit".}

    type NSSavePanel {.importobjc: "NSSavePanel*", header: "<AppKit/AppKit.h>", incompleteStruct.} = object
    type NSOpenPanel {.importobjc: "NSOpenPanel*", header: "<AppKit/AppKit.h>", incompleteStruct.} = object

    proc newOpenPanel: NSOpenPanel {.importobjc: "NSOpenPanel openPanel", nodecl.}
    proc newSavePanel: NSSavePanel {.importobjc: "NSSavePanel savePanel", nodecl.}

    template wrapObjModalCode(body: untyped) =
      {.emit: """
      NSAutoreleasePool* pool = [NSAutoreleasePool new];
      NSWindow* keyWindow = [NSApp keyWindow];
      NSOpenGLContext* glCtx = [[NSOpenGLContext currentContext] retain];
      """.}
      body
      {.emit: """
      [pool drain];
      [glCtx makeCurrentContext];
      [glCtx release];
      [keyWindow makeKeyAndOrderFront: nil];
      """.}

    proc callDialogFileOpen*(title: string, buttons: seq[DialogButtonInfo] = @[]): string =
      wrapObjModalCode:
        let dialog = newOpenPanel()
        let ctitle : cstring = title
        var cres: cstring
        {.emit: """
        [`dialog` setCanChooseFiles:YES];
        `dialog`.title = [NSString stringWithUTF8String: `ctitle`];
        if ([`dialog` runModal] == NSOKButton && `dialog`.URLs.count > 0) {
          `cres` = [`dialog`.URLs objectAtIndex: 0].path.UTF8String;
        }
        """.}
        if not cres.isNil:
          result = $cres

    proc callDialogFileSave*(title: string, buttons: seq[DialogButtonInfo] = @[]): string =
      wrapObjModalCode:
        let dialog = newSavePanel()
        let ctitle : cstring = title
        var cres: cstring

        {.emit: """
        `dialog`.canCreateDirectories = YES;
        `dialog`.title = [NSString stringWithUTF8String: `ctitle`];
        if ([`dialog` runModal] == NSOKButton) {
          `cres` = `dialog`.URL.path.UTF8String;
        }
        """.}
        if not cres.isNil:
          result = $cres

else:
  {.error: "Unsupported platform".}

when isMainModule:
  echo "Your window toolkit is: ", windowToolkitKind
  echo callDialogFileOpen("Open Simulation Results File")
  echo callDialogFileSave("Save Simulation Results File")
  #echo callDialogFolderCreate("Create New Folder")
  #echo callDialogFolderSelect("Open Folder")
