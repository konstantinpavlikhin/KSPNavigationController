//
//  NSView+Screenshot.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 4/23/13.
//  Copyright (c) 2016 Konstantin Pavlikhin. All rights reserved.
//

#import "NSView+Screenshot.h"

@implementation NSView (Screenshot)

#pragma mark - Public Methods

- (NSImage*) ss_imageWithSubviews
{
  const NSSize mySize = self.bounds.size;
  
  const NSSize imgSize = NSMakeSize(mySize.width, mySize.height);
  
  NSBitmapImageRep* const bir = [self bitmapImageRepForCachingDisplayInRect: self.bounds];
  
  bir.size = imgSize;
  
  [self cacheDisplayInRect: self.bounds toBitmapImageRep: bir];
  
  NSImage* const image = [[NSImage alloc] initWithSize: imgSize];
  
  [image addRepresentation: bir];
  
  return image;
}

@end
