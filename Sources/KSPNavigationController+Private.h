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

@property(readwrite, strong, nonatomic) IBOutlet KSPNavigationView* navigationView;

@property(readwrite, strong, nonatomic) KSPNavigationView* navigationViewPrototype;

@property(readwrite, strong, nonatomic) KSPHitTestView* navigationBar;

@property(readwrite, strong, nonatomic) IBOutlet NSView* navigationToolbarHost;

@property(readwrite, strong, nonatomic) IBOutlet NSLayoutConstraint* navigationToolbarHostHeight;

@property(readwrite, strong, nonatomic) KSPNavViewController* topViewController;

@end
