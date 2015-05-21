//
//  KSPView.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 20.05.15.
//  Copyright (c) 2015 Konstantin Pavlikhin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KSPViewController;

@interface KSPView : NSView

@property(readwrite, weak, nonatomic) KSPViewController* viewController;

@end
