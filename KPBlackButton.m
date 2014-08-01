//
//  KPBlackButton.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 2/14/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import "KPBlackButton.h"

#import "KPBlackButtonCell.h"

@implementation KPBlackButton

+ (void)load
{
  [self setCellClass: [KPBlackButtonCell class]];
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    {
      [self invalidateIntrinsicContentSize];
      
      //[self setFrame: NSMakeRect(0, 0, 10, 10)];
    }
  }
  return self;
}


- (NSSize) intrinsicContentSize
{
  NSSize bzz = [super intrinsicContentSize];
  
  return NSMakeSize(bzz.width, 22.0);
}

- (NSEdgeInsets) alignmentRectInsets
{
  // 1px из 23px общей высоты — это тень.
  return NSEdgeInsetsMake(0.0, 0.0, 1.0, 0.0);
}

/*
- (void) drawRect:(NSRect)dirtyRect
{
  [[NSColor cyanColor] setFill];
  
  NSRectFill(self.bounds);
}
*/

@end
