//
//  KPNavigationController_Private.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 4/23/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import "KPNavigationController.h"

@class NavigationView;

@interface KPNavigationController ()

@property(readwrite, strong) IBOutlet NavigationView* navigationView;

@property(readwrite, strong) NavigationView* navigationViewPrototype;

@property(readwrite, strong) IBOutlet NSView* navigationBar;

@property(readwrite, strong) IBOutlet NSView* navigationToolbarHost;

@end
