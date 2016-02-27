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

- (void) navigationController: (KSPNavigationController*) navigationController willShowViewController: (KSPNavViewController*) viewController animated: (BOOL) animated;

- (void) navigationController: (KSPNavigationController*) navigationController didShowViewController: (KSPNavViewController*) viewController animated: (BOOL) animated;

@end
