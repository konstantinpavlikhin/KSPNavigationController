//
//  HitTestView.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 4/23/13.
//  Copyright (c) 2016 Konstantin Pavlikhin. All rights reserved.
//

#import "KSPHitTestView.h"

@implementation KSPHitTestView

#pragma mark - NSView Overrides

- (NSView*) hitTest: (NSPoint) aPoint
{
  if(self.rejectHitTest) return nil;
  
  return [super hitTest: aPoint];
}

@end
