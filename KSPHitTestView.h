//
//  HitTestView.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 4/23/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KSPHitTestView : NSView

@property(readwrite, assign, nonatomic) BOOL rejectHitTest;

@end
