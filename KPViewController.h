////////////////////////////////////////////////////////////////////////////////
//  
//  KPViewController.h
//  
//  KPToolbox
//  
//  Created by Konstantin Pavlikhin on unknown.
//  
////////////////////////////////////////////////////////////////////////////////

#import <AppKit/AppKit.h>

// NSView —> KPViewController —> Любые другие NSView —> NSWindow —> NSWindowController —> Window Delegate —> NSDocument —> NSApp —> App Delegate —> NSDocumentController.

@interface KPViewController : NSViewController

// Каждый конкретный экземпляр NSWindowController'а должен задать это проперти во время инициализации KPViewController'а.
@property(readwrite, assign) NSWindowController* windowController;

// Это свойство указывает на элемент интерфейса, предпочтительный для назначения first responder'ом.
@property(readonly, assign) IBOutlet NSResponder* proposedFirstResponder;

@end
