//
//  NavigationBar.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 2/14/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import "NavigationBar.h"

@implementation NavigationBar
{
  NSImage* _background;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
  _background = [NSImage imageNamed: @"navigationBar"];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  NSDrawThreePartImage(self.bounds, nil, _background, nil, NO, NSCompositeSourceOver, 1.0, NO);
}

@end
