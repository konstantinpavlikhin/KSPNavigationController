//
//  NavigationView.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 4/24/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import "KSPNavigationView.h"

@implementation KSPNavigationView

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder: aDecoder];
  
  if(!self) return nil;
  
  _navigationBar = [aDecoder decodeObjectOfClass: [NSView class] forKey: @"NavigationBar"];
  
  _mainViewTransitionHost = [aDecoder decodeObjectOfClass: [NSView class] forKey: @"MainViewTransitionHost"];
  
  _navigationToolbarHost = [aDecoder decodeObjectOfClass: [NSView class] forKey: @"NavigationToolbarHost"];
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [super encodeWithCoder: aCoder];
  
  [aCoder encodeObject: self.navigationBar forKey: @"NavigationBar"];
  
  [aCoder encodeObject: self.mainViewTransitionHost forKey: @"MainViewTransitionHost"];
  
  [aCoder encodeObject: self.navigationToolbarHost forKey: @"NavigationToolbarHost"];
}

@end
