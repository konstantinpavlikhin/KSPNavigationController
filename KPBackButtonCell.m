//
//  KPBackButtonCell.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 2/14/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import "KPBackButtonCell.h"

static NSImage* _disabled_left, *_disabled_center, *_disabled_right;

static NSImage* _normal_left, *_normal_center, *_normal_right;

static NSImage* _highlighted_left, *_highlighted_center, *_highlighted_right;

@implementation KPBackButtonCell

+ (void) initialize
{
  _disabled_left = [NSImage imageNamed: @"back-button-disabled-left"];
  _disabled_center = [NSImage imageNamed: @"black-button-disabled-center"];
  _disabled_right = [NSImage imageNamed: @"black-button-disabled-right"];
  
  _normal_left = [NSImage imageNamed: @"back-button-normal-left"];
  _normal_center = [NSImage imageNamed: @"black-button-normal-center"];
  _normal_right = [NSImage imageNamed: @"black-button-normal-right"];
  
  _highlighted_left = [NSImage imageNamed: @"back-button-highlighted-left"];
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

#pragma mark - NSButtonCell Overrides

/*
- (void)drawImage: (NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView
{
  
}
*/


#pragma mark - NSCell Overrides

- (NSRect) titleRectForBounds:(NSRect)theRect
{
  return NSOffsetRect(theRect, 3.0, -1.0);
}




/*
 - (NSSize)cellSizeForBounds:(NSRect)aRect
 {
 return NSMakeSize(aRect.size.width, 10.0);
 }


- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
}

- (NSRect)titleRectForBounds:(NSRect)theRect
{
}

- (NSRect)imageRectForBounds:(NSRect)theRect
{
}

- (NSRect)drawingRectForBounds:(NSRect)theRect
{
}

// To support constraint-based layout, when the content of a custom cell changes in such a way that the return value of this method would change, it needs to notify its control of the change via invalidateIntrinsicContentSizeForCell:.


- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView
{
}
*/

@end
