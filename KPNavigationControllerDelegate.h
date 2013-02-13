//
//  KPNavigationControllerDelegate.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 2/12/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KPNavigationController, KPNavViewController;

@protocol KPNavigationControllerDelegate <NSObject>

@optional

/// Sent to the receiver just before the navigation controller displays a view controller’s view and navigation item properties.
- (void) navigationController: (KPNavigationController*) navigationController willShowViewController: (KPNavViewController*) viewController animated: (BOOL) animated;

/// Sent to the receiver just after the navigation controller displays a view controller’s view and navigation item properties.
- (void) navigationController: (KPNavigationController*) navigationController didShowViewController: (KPNavViewController*) viewController animated: (BOOL) animated;

@end
