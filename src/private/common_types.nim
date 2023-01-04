type
    WindowToolkitKind* {.pure.} = enum
        Win32 = 0
        Darwin
        Gtk
        Qt

    DialogButtonInfo* = tuple[title: string, responseType: int]
