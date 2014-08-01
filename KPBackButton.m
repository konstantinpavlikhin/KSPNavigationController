//
//  KPBackButton.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 2/14/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import "KPBackButton.h"

#import "KPBackButtonCell.h"

@implementation KPBackButton

+ (Class)cellClass {
	return [KPBackButtonCell class];
}

+ (void) initialize
{
  [self setCellClass: [KPBackButtonCell class]];
}

+ (void) load
{
  [self setCellClass: [KPBackButtonCell class]];
}

- (void) awakeFromNib {
	[[self class] setCellClass:[KPBackButtonCell class]];
}

- (NSSize) intrinsicContentSize
{
  NSSize bzz = [super intrinsicContentSize];
  
  return NSMakeSize(bzz.width + 8.0, bzz.height);
}

@end
