//
//  ApplicationDelegate+Private.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 02/12/15.
//  Copyright © 2016 Konstantin Pavlikhin. All rights reserved.
//

#import "ApplicationDelegate.h"

@import KSPNavigationController.KSPNavigationControllerDelegate;

@interface ApplicationDelegate () <KSPNavigationControllerDelegate>

@property(readwrite, strong, nonatomic) IBOutlet NSWindow* window;

@property(readwrite, strong, nonatomic) IBOutlet NSView* navigationBarContainer;

@end
