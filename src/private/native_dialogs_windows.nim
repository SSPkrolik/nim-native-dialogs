import common_types

type
    BOOL = int32
    WORD = uint16
    DWORD = uint32
    HANDLE = pointer
    HWND = HANDLE
    HINSTANCE = HANDLE
    LPCSTR = cstring
    LPSTR = cstring
    LPARAM = ByteAddress
    WPARAM = ByteAddress
    WINUINT = uint32
    LPOFNHOOKPROC = proc (para1: HWND, para2: WINUINT, para3: WPARAM, para4: LPARAM): WINUINT {.stdcall.}
    LPEDITMENU = pointer

    OpenFileNameA {.final, pure.} = object  # 152
        lStructSize: DWORD        # 4
        hwndOwner: HWND           # 8 12 
        hInstance: HINSTANCE      # 8 20
        lpstrFilter: LPCSTR       # 8 28
        lpstrCustomFilter: LPSTR  # 8 36
        nMaxCustFilter: DWORD     # 4 40
        nFilterIndex: DWORD       # 4 44
        lpstrFile: LPSTR          # 8 52
        nMaxFile: DWORD           # 4 56
        lpstrFileTitle: LPSTR     # 8 64
        nMaxFileTitle: DWORD      # 4 68
        lpstrInitialDir: LPCSTR   # 8 76
        lpstrTitle: LPCSTR        # 8 84
        flags: DWORD              # 4 88
        nFileOffset: WORD         # 2 90
        nFileExtension: WORD      # 2 92
        lpstrDefExt: LPCSTR       # 8 100
        lCustData: LPARAM         # 8 108
        lpfnHook: LPOFNHOOKPROC   # 8 116
        lpTemplateName: LPCSTR    # 8 124
        pvReserved: pointer       # 8 148
        dwReserved: DWORD         # 4 152
        flagsEx: DWORD            # 4 156


const
    OFN_FILEMUSTEXIST: DWORD = 0x00001000
    OFN_PATHMUSTEXIST: DWORD = 0x00000800

const
    TRUE: BOOL = 1


proc GetOpenFileNameA(unnamedParam1: ptr OpenFileNameA): BOOL {.cdecl, stdcall, importc, dynlib: "Comdlg32.dll".}
proc GetSaveFileNameA(unnamedParam1: ptr OpenFileNameA): BOOL {.cdecl, stdcall, importc, dynlib: "Comdlg32.dll".}
proc CommDlgExtendedError(): DWORD {.cdecl, used, importc, stdcall, dynlib: "Comdlg32.dll".}


proc getWindowToolkitKindImpl*(): WindowToolkitKind =
    return WindowToolkitKind.Windows


proc callDialogFileSaveImpl*(title: string): string =
    var
        fileInfo: ptr OpenFileNameA = cast[ptr OpenFileNameA](alloc0(sizeof(OpenFileNameA)))
        buf: cstring = cast[cstring](alloc0(1024))

    fileInfo.lStructSize = sizeof(OpenFileNameA).DWORD
    fileInfo.hWndOwner = cast[HWND](0)
    fileInfo.flags = OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
    fileInfo.lpstrFile = buf
    fileInfo.nMaxFile = 1024
    fileInfo.lpstrFilter = "All\0*.*\0";
    fileInfo.lpstrFileTitle = title

    let res = GetSaveFileNameA(fileInfo)

    return if res == TRUE : $buf else: ""


proc callDialogFileOpenImpl*(title: string): string =
    var
        fileInfo: ptr OpenFileNameA = cast[ptr OpenFileNameA](alloc0(sizeof(OpenFileNameA)))
        buf: cstring = cast[cstring](alloc0(1024))

    fileInfo.lStructSize = sizeof(OpenFileNameA).DWORD
    fileInfo.hWndOwner = cast[HWND](0)
    fileInfo.flags = OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
    fileInfo.lpstrFile = buf
    fileInfo.nMaxFile = 1024
    fileInfo.lpstrFilter = "All\0*.*\0";
    fileInfo.lpstrFileTitle = title

    let res = GetOpenFileNameA(fileInfo)

    return if res == TRUE: $buf else: ""
