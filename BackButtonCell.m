//
//  BlackButtonCell.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 20.02.10.
//  Copyright 2010 Konstantin Pavlikhin. All rights reserved.
//

#import "BlackButtonCell.h"


static NSImage* buttonLeftN;

static NSImage* buttonFillN;

static NSImage* buttonRightN;

static NSImage* buttonLeftP;

static NSImage* buttonFillP;

static NSImage* buttonRightP;


@implementation BackButtonCell

+ (void) initialize
{
  NSBundle* bundle = [NSBundle mainBundle];
  
  buttonLeftN = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"backButton-N-left.png"]];
  
  buttonFillN = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"blackButton-N-middle.png"]];
  
  buttonRightN = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"blackButton-N-right.png"]];
  
  buttonLeftP = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"backButton-P-left.png"]];
  
  buttonFillP = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"backButton-P-middle.png"]];
  
  buttonRightP = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"backButton-P-right.png"]];
}

- (void) drawBezelWithFrame: (NSRect) cellFrame inView: (NSView*) controlView
{
  
  
  cellFrame.size.height = buttonFillN.size.height;
  
  if([self isHighlighted])
  {
    NSDrawThreePartImage(cellFrame, buttonLeftP, buttonFillP, buttonRightP, NO, NSCompositeSourceOver, 1, YES);
  }
  else
  {
    NSDrawThreePartImage(cellFrame, buttonLeftN, buttonFillN, buttonRightN, NO, NSCompositeSourceOver, 1, YES);
  }
}

- (NSRect) drawTitle: (NSAttributedString*) title withFrame: (NSRect) frame inView: (NSView*) controlView
{
  //frame.origin.y -= 4.0;
  [[NSColor blackColor] setFill];
  
  NSRectFill(frame);
  
  return [super drawTitle: title withFrame: frame inView: controlView];
}

- (NSDictionary*) _textAttributes
{
  NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
  
  [attributes addEntriesFromDictionary: [super _textAttributes]];
  
  [attributes setObject: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSRegularControlSize]] forKey: NSFontAttributeName];
  
  [attributes setObject: [NSColor colorWithCalibratedWhite: 0.9 alpha: 1.0] forKey: NSForegroundColorAttributeName];
  
  NSShadow* shadow = [NSShadow new];
  shadow.shadowOffset = NSMakeSize(0, 0);
  shadow.shadowBlurRadius = 1.5;
  shadow.shadowColor = [NSColor colorWithCalibratedWhite: 0.05 alpha: 1.0];
  [attributes setObject: shadow forKey: NSShadowAttributeName];
  
  return attributes;
}

- (NSControlSize) controlSize
{
  return NSRegularControlSize;
}

- (void) setControlSize: (NSControlSize) size
{
}

@end
