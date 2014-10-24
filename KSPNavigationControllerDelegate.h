//
//  KPNavigationControllerDelegate.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 2/12/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSPNavigationController, KSPNavViewController;

@protocol KSPNavigationControllerDelegate <NSObject>

@optional

/// Sent to the receiver just before the navigation controller displays a view controller’s view and navigation item properties.
- (void) navigationController: (KSPNavigationController*) navigationController willShowViewController: (KSPNavViewController*) viewController animated: (BOOL) animated;

/// Sent to the receiver just after the navigation controller displays a view controller’s view and navigation item properties.
- (void) navigationController: (KSPNavigationController*) navigationController didShowViewController: (KSPNavViewController*) viewController animated: (BOOL) animated;

@end
