//
//  NSView+Screenshot.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 4/23/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Screenshot)

@property(readonly, copy, nonatomic) NSImage* ss_imageWithSubviews;

@end
