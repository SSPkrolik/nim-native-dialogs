# nim-native-dialogs
Native Operating System Dialogs implementation for Nim-lang via single API.

The library is:

 * GUI framework agnostic
 * Intended to support Win32/Cocoa/GTK/KDE windowing toolkits

## Usage
```nim
import native_dialogs

echo callDialogFileOpen("Open File")
echo callDialogFileSave("Save File")
echo callDialogFolderCreate("Create New Folder")
echo callDialogFolderSelect("Open Folder")
```
