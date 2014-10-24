//
//  KSPViewController.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 08.10.14.
//  Copyright (c) 2014 Konstantin Pavlikhin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// NSView —> KPViewController —> Любые другие NSView —> NSWindow —> NSWindowController —> Window Delegate —> NSDocument —> NSApp —> App Delegate —> NSDocumentController.

@interface KSPViewController : NSViewController

@property(readonly, strong, nonatomic) IBOutlet NSView* proposedFirstResponder;

@end
