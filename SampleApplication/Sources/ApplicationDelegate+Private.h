//
//  ApplicationDelegate+Private.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 02/12/15.
//  Copyright © 2015 Konstantin Pavlikhin. All rights reserved.
//

#import "ApplicationDelegate.h"

#import "KSPNavigationControllerDelegate.h"

@interface ApplicationDelegate () <KSPNavigationControllerDelegate>

@property(readwrite, strong, nonatomic) IBOutlet NSWindow* window;

@property(readwrite, strong, nonatomic) IBOutlet NSView* navigationBarContainer;

@end
