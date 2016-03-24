# nim-native-dialogs

[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://github.com/yglukhov/nimble-tag)

Native Operating System Dialogs implementation for Nim-lang via single API.
The library is GUI framework agnostic and supports the next platforms:

 * GNU/Linux + GTK+3
 * OSX + Cocoa
 * Windows + Win32 API

Currently the next dialogs are implemented in a single-file mode:

 * Open File Dialog
 * Save File Dialog
 * Folder Creation Dialog
 * Folder Selection Dialog

## Installation

```bash
$ nimble install native_dialogs
```

## Usage
```nim
import native_dialogs

echo callDialogFileOpen("Open File")
echo callDialogFileSave("Save File")
echo callDialogFolderCreate("Create New Folder")
echo callDialogFolderSelect("Open Folder")
```
