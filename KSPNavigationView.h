//
//  NavigationView.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 4/24/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KSPHitTestView;

@interface KSPNavigationView : NSView

@property(readwrite, strong, nonatomic) IBOutlet KSPHitTestView* navigationBar;

@property(readwrite, strong, nonatomic) IBOutlet NSView* mainViewTransitionHost;

@property(readwrite, strong, nonatomic) IBOutlet NSView* navigationToolbarHost;

@end
