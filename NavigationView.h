//
//  NavigationView.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 4/24/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NavigationView : NSView

@property(readwrite, strong) IBOutlet NSView* navigationBar;

@property(readwrite, strong) IBOutlet NSView* mainViewTransitionHost;

@property(readwrite, strong) IBOutlet NSView* navigationToolbarHost;

@end
