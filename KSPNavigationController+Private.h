//
//  KPNavigationController_Private.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 4/23/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import "KSPNavigationController.h"

@class KSPNavigationView;

@interface KSPNavigationController ()

@property(readwrite, strong) IBOutlet KSPNavigationView* navigationView;

@property(readwrite, strong) KSPNavigationView* navigationViewPrototype;

@property(readwrite, strong) KSPHitTestView* navigationBar;

@property(readwrite, strong) IBOutlet NSView* navigationToolbarHost;

@property(readwrite, strong) KSPNavViewController* topViewController;

@end
