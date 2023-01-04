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

    OpenFileNameA {.final, pure.} = object
        lStructSize: DWORD
        hwndOwner: HWND 
        hInstance: HINSTANCE
        lpstrFilter: LPCSTR
        lpstrCustomFilter: LPSTR
        nMaxCustFilter: DWORD
        nFilterIndex: DWORD
        lpstrFile: LPSTR
        nMaxFile: DWORD
        lpstrFileTitle: LPSTR
        nMaxFileTitle: DWORD
        lpstrInitialDir: LPCSTR
        lpstrTitle: LPCSTR
        flags: DWORD
        nFileOffset: WORD
        nFileExtension: WORD
        lpstrDefExt: LPCSTR
        lCustData: LPARAM
        lpfnHook: LPOFNHOOKPROC
        lpTemplateName: LPCSTR
        pvReserved: pointer
        dwReserved: DWORD
        flagsEx: DWORD


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


proc callDialogFolderCreateImpl*(title: string): string =
    return callDialogFileSaveImpl(title)


proc callDialogFolderSelectImpl*(title: string): string =
    return callDialogFileSaveImpl(title)