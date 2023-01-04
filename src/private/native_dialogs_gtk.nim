import common_types

import gtk2

nim_init()


const
    dialogFileOpenDefaultButtons*: seq[DialogButtonInfo] = @[
      (title: "Cancel", responseType: RESPONSE_CANCEL.int),
      (title: "Open", responseType: RESPONSE_ACCEPT.int)
    ]

    dialogFileSaveDefaultButtons*: seq[DialogButtonInfo] = @[
      (title: "Cancel", responseType: RESPONSE_CANCEL.int),
      (title: "Save", responseType: RESPONSE_ACCEPT.int)
    ]

    dialogFolderCreateDefaultButtons*: seq[DialogButtonInfo] = @[
      (title: "Cancel", responseType: RESPONSE_CANCEL.int),
      (title: "Create", responseType: RESPONSE_ACCEPT.int)
    ]

    dialogFolderSelectDefaultButtons*: seq[DialogButtonInfo] = @[
      (title: "Cancel", responseType: RESPONSE_CANCEL.int),
      (title: "Open", responseType: RESPONSE_ACCEPT.int)
    ]


proc callDialogFile(action: TFileChooserAction, title: string, buttons: seq[DialogButtonInfo] = @[]): string =
    # Setup dialog
    var dialog = file_chooser_dialog_new(title.cstring, nil, action, nil)
    # Setup buttons
    for button in buttons:
        discard dialog.add_button(button.title.cstring, button.responseType.cint)

    # Run dialog
    var res = dialog.run()

    # Analyze call results
    case res:
    of RESPONSE_ACCEPT, RESPONSE_YES, RESPONSE_APPLY:
        let fileChooser = cast[PFileChooser](pointer(dialog))
        result = $fileChooser.get_filename()
    of RESPONSE_REJECT, RESPONSE_NO, RESPONSE_CANCEL, RESPONSE_CLOSE:
        result = ""
    else:
        result = ""

    dialog.destroy()
    while events_pending() > 0:
        discard main_iteration()


proc getWindowToolkitKindImpl*(): WindowToolkitKind = 
    return WindowToolkitKind.Gtk

proc callDialogFileOpenImpl*(title: string, buttons: seq[DialogButtonInfo] = dialogFileOpenDefaultButtons): string =
    result = callDialogFile(TFileChooserAction.FILE_CHOOSER_ACTION_OPEN, title, buttons)

proc callDialogFileSaveImpl*(title: string): string =
    return callDialogFile(TFileChooserAction.FILE_CHOOSER_ACTION_SAVE, title, dialogFileSaveDefaultButtons)

proc callDialogFolderCreateImpl*(title: string): string =
    return callDialogFile(TFileChooserAction.FILE_CHOOSER_ACTION_CREATE_FOLDER, title, dialogFolderCreateDefaultButtons)

proc callDialogFolderSelectImpl*(title: string): string =
    return callDialogFile(TFileChooserAction.FILE_CHOOSER_ACTION_SELECT_FOLDER, title, dialogFolderSelectDefaultButtons)
