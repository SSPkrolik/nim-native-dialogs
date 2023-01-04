import common_types

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


proc getWindowToolkitKindImpl*(): WindowToolkitKind =
    return WindowToolkitKind.Macosx


proc callDialogFileOpenImpl*(title: string): string =
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

proc callDialogFileSaveImpl*(title: string): string =
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


proc callDialogFolderCreateImpl*(title: string): string =
    return callDialogFileSaveImpl(title)


proc callDialogFolderSelectImpl*(title: string): string =
    return callDialogFileSaveImpl(title)