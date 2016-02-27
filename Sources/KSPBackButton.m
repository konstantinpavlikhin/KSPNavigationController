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

#pragma mark - NSObject Overrides

+ (void) load
{
  [self setCellClass: [KSPBackButtonCell class]];
}

+ (void) initialize
{
  [self setCellClass: [KSPBackButtonCell class]];
}

#pragma mark - NSControl Overrides

+ (Class) cellClass
{
	return [KSPBackButtonCell class];
}

#pragma mark - NSView Overrides

- (NSSize) intrinsicContentSize
{
  NSSize bzz = [super intrinsicContentSize];

  return NSMakeSize(bzz.width + 4.0, bzz.height);
}

#pragma mark -

- (void) awakeFromNib
{
  [super awakeFromNib];

  // * * *.

	[[self class] setCellClass:[KSPBackButtonCell class]];
}

@end
