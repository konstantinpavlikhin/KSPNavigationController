//
//  NSView+Screenshot.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 4/23/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import "NSView+Screenshot.h"

@implementation NSView (Screenshot)

- (NSImage*) imageWithSubviews
{
  NSSize mySize = self.bounds.size;
  
  NSSize imgSize = NSMakeSize(mySize.width, mySize.height);
  
  NSBitmapImageRep* bir = [self bitmapImageRepForCachingDisplayInRect: [self bounds]];
  
  [bir setSize: imgSize];
  
  [self cacheDisplayInRect: [self bounds] toBitmapImageRep: bir];
  
  NSImage* image = [[NSImage alloc] initWithSize: imgSize];
  
  [image addRepresentation: bir];
  
  return image;
}

@end
