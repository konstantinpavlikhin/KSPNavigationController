//
//  KPBackButton.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 2/14/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import "KSPBackButton.h"

#import "KSPBackButtonCell.h"

@implementation KSPBackButton

+ (Class) cellClass
{
	return [KSPBackButtonCell class];
}

+ (void) initialize
{
  [self setCellClass: [KSPBackButtonCell class]];
}

+ (void) load
{
  [self setCellClass: [KSPBackButtonCell class]];
}

- (void) awakeFromNib
{
	[[self class] setCellClass:[KSPBackButtonCell class]];
}

- (NSSize) intrinsicContentSize
{
  NSSize bzz = [super intrinsicContentSize];
  
  return NSMakeSize(bzz.width + 4.0, bzz.height);
}

@end
