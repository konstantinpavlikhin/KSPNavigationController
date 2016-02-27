//
//  NavigationView.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 4/24/13.
//  Copyright (c) 2016 Konstantin Pavlikhin. All rights reserved.
//

#import "KSPNavigationView.h"

@implementation KSPNavigationView

#pragma mark - NSCoding Protocol Implementation

- (instancetype) initWithCoder: (NSCoder*) aDecoder
{
  self = [super initWithCoder: aDecoder];
  
  if(!self) return nil;

  // * * *.

  _navigationBar = [aDecoder decodeObjectOfClass: [NSView class] forKey: @"NavigationBar"];

  _navigationToolbarHost = [aDecoder decodeObjectOfClass: [NSView class] forKey: @"NavigationToolbarHost"];

  // * * *.

  return self;
}

- (void) encodeWithCoder: (NSCoder*) aCoder
{
  [super encodeWithCoder: aCoder];

  // * * *.

  [aCoder encodeObject: self.navigationBar forKey: @"NavigationBar"];

  [aCoder encodeObject: self.navigationToolbarHost forKey: @"NavigationToolbarHost"];
}

@end
