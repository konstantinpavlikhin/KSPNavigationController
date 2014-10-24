//
//  KPBackButtonCell.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 2/14/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import "KSPBackButtonCell.h"

static NSImage* arrowDisabled, *arrowNormal, *arrowHighlighted;

@implementation KSPBackButtonCell

+ (void) initialize
{
  arrowDisabled = [NSImage imageNamed: @"Arrow-disabled"];
  
  arrowNormal = [NSImage imageNamed: @"Arrow-normal"];
  
  arrowHighlighted = [NSImage imageNamed: @"Arrow-highlighted"];
}

- (void) drawBezelWithFrame: (NSRect) frame inView: (NSView*) controlView
{
  //[[NSColor redColor] setFill], NSRectFill(frame);
  
  NSRect r = NSMakeRect(0, 0, arrowNormal.size.width, arrowNormal.size.height);
  
  if(self.isEnabled)
  {
    if(self.isHighlighted)
    {
      [arrowHighlighted drawAtPoint: NSMakePoint(0, 1) fromRect: r operation: NSCompositeSourceOver fraction: 1.0];
    }
    else
    {
      [arrowNormal drawAtPoint: NSMakePoint(0, 1) fromRect: r operation: NSCompositeSourceOver fraction: 1.0];
    }
  }
  else
  {
    [arrowDisabled drawAtPoint: NSMakePoint(0, 1) fromRect: r operation: NSCompositeSourceOver fraction: 1.0];
  }
}

- (NSRect) titleRectForBounds: (NSRect) bounds
{
  NSRect supers = [super titleRectForBounds: bounds];
  
  return NSMakeRect(bounds.size.width - supers.size.width, supers.origin.y, supers.size.width, supers.size.height);
}

@end
