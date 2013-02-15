//
//  KPBlackButtonCell.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 2/14/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import "KPBlackButtonCell.h"

NSImage* _disabled_left, *_disabled_center, *_disabled_right;

NSImage* _normal_left, *_normal_center, *_normal_right;

NSImage* _highlighted_left, *_highlighted_center, *_highlighted_right;

@implementation KPBlackButtonCell

+ (void) initialize
{
  _disabled_left = [NSImage imageNamed: @"black-button-disabled-left"];
  _disabled_center = [NSImage imageNamed: @"black-button-disabled-center"];
  _disabled_right = [NSImage imageNamed: @"black-button-disabled-right"];
  
  _normal_left = [NSImage imageNamed: @"black-button-normal-left"];
  _normal_center = [NSImage imageNamed: @"black-button-normal-center"];
  _normal_right = [NSImage imageNamed: @"black-button-normal-right"];
  
  _highlighted_left = [NSImage imageNamed: @"black-button-highlighted-left"];
  _highlighted_center = [NSImage imageNamed: @"black-button-highlighted-center"];
  _highlighted_right = [NSImage imageNamed: @"black-button-highlighted-right"];
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
  if(self.isEnabled)
  {
    if(self.isHighlighted)
    {
      NSDrawThreePartImage(frame, _highlighted_left, _highlighted_center, _highlighted_right, NO, NSCompositeSourceOver, 1.0, YES);
    }
    else
    {
      NSDrawThreePartImage(frame, _normal_left, _normal_center, _normal_right, NO, NSCompositeSourceOver, 1.0, YES);
    }
  }
  else
  {
    NSDrawThreePartImage(frame, _disabled_left, _disabled_center, _disabled_right, NO, NSCompositeSourceOver, 1.0, YES);
  }
}

- (NSRect)drawTitle: (NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
  NSColor* color;
  
  NSShadow* shadow = [NSShadow new];
  [shadow setShadowOffset: NSMakeSize(0, 1.0)];
  [shadow setShadowBlurRadius: 0.0];
  
  if(self.isEnabled)
  {
    if(self.isHighlighted)
    {
      color = [NSColor colorWithCalibratedRed: 247.0 / 255.0 green: 247.0 / 255.0 blue: 247.0 / 255.0 alpha: 1.0];
      
      [shadow setShadowColor: [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 1.0]];
    }
    else
    {
      color = [NSColor colorWithCalibratedRed: 247.0 / 255.0 green: 247.0 / 255.0 blue: 247.0 / 255.0 alpha: 1.0];
      
      [shadow setShadowColor: [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 0.58]];
    }
  }
  else
  {
    color = [NSColor colorWithCalibratedRed: 175.0 / 255.0 green: 175.0 / 255.0 blue: 175.0 / 255.0 alpha: 1.0];
    
    [shadow setShadowColor: [NSColor colorWithCalibratedRed: 84.0 / 255.0 green: 84.0 / 255.0 blue: 84.0 / 255.0 alpha: 1.0]];
  }
  
  NSMutableAttributedString *attrString = [title mutableCopy];
  
  [attrString beginEditing];
  
  [attrString addAttribute:NSForegroundColorAttributeName value: color range: NSMakeRange(0, [[self title] length])];
  
  [attrString addAttribute:NSShadowAttributeName value: shadow range: NSMakeRange(0, [[self title] length])];
  
  [attrString addAttribute: NSFontAttributeName value: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSRegularControlSize]] range:NSMakeRange(0, [[self title] length])];
  
  [attrString endEditing];
  
  NSRect r = [super drawTitle:attrString withFrame:frame inView:controlView];
  
  return r;
}

/*
- (NSSize)ce1llSize
{
  return NSMakeSize(100, 13.0);
}

- (NSRect)dra1wingRectForBounds:(NSRect)theRect
{
  return NSMakeRect(0, 0, 25, 13.0);
}

- (NSSize)ce1llSizeForBounds:(NSRect)aRect
{
  NSLog(@"IT: %@", NSStringFromRect(aRect));
  return NSMakeSize(200, 13.0);
}
*/

@end
