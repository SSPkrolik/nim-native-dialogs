type
    WindowToolkitKind* {.pure.} = enum
        Windows = 0
        Macosx
        Gtk
        Qt

    DialogButtonInfo* = tuple[title: string, responseType: int]
