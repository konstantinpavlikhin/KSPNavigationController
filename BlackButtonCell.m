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


@implementation BlackButtonCell

+ (void) initialize
{
  NSBundle* bundle = [NSBundle mainBundle];
  
  buttonLeftN = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"BlackButtonLeftNormal.png"]];
  
  buttonFillN = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"BlackButtonFillNormal.png"]];
  
  buttonRightN = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"BlackButtonRightNormal.png"]];
  
  buttonLeftP = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"BlackButtonLeftPressed.png"]];
  
  buttonFillP = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"BlackButtonFillPressed.png"]];
  
  buttonRightP = [[NSImage alloc] initWithContentsOfFile: [bundle pathForImageResource: @"BlackButtonRightPressed.png"]];
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
  frame.origin.y -= 1.0;
  
  return [super drawTitle: title withFrame: frame inView: controlView];
}

- (NSDictionary*) _textAttributes
{
  NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
  
  [attributes addEntriesFromDictionary: [super _textAttributes]];
  
  [attributes setObject: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSRegularControlSize]] forKey: NSFontAttributeName];
  
  [attributes setObject: [NSColor whiteColor] forKey: NSForegroundColorAttributeName];
  
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

////////////////////////////////////////////////////////////////////////////////
