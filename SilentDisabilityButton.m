//
//  SilentDisabilityButton.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 01.03.10.
//  Copyright 2010 Konstantin Pavlikhin. All rights reserved.
//

#import "SilentDisabilityButton.h"

@implementation SilentDisabilityButton

@synthesize silentlyDisabled;

- (void) mouseDown: (NSEvent*) theEvent
{
  if([self isSilentlyDisabled]) return;
  
  [super mouseDown: theEvent];
}

- (void) mouseDragged: (NSEvent*) theEvent
{
  if([self isSilentlyDisabled]) return;
  
  [super mouseDragged: theEvent];
}

- (void) mouseUp: (NSEvent*) theEvent
{
  if([self isSilentlyDisabled]) return;
  
  [super mouseUp: theEvent];
}

- (void) setNilValueForKey: (NSString*) key
{
  if([key isEqualToString: @"silentlyDisabled"]) return;
  
  [super setNilValueForKey: key];
}

@end
