//
//  HitTestView.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 4/23/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import "HitTestView.h"

@implementation HitTestView

- (NSView*) hitTest: (NSPoint) aPoint
{
  if(self.rejectHitTest) return nil;
  
  return [super hitTest: aPoint];
}

@end
