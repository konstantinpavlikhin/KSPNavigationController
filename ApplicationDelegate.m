//
//  ApplicationDelegate.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 02/12/15.
//  Copyright © 2015 Konstantin Pavlikhin. All rights reserved.
//

#import "ApplicationDelegate+Private.h"

#import "KSPNavigationController.h"

@implementation ApplicationDelegate
{
  KSPNavigationController* _navigationController;
}

- (void) awakeFromNib
{
  [super awakeFromNib];

  // * * *.

  {{
    _navigationController = [[KSPNavigationController alloc] initWithNavigationBar: self.navigationBarContainer rootViewController: nil];

    _navigationController.delegate = self;

    _navigationController.view.translatesAutoresizingMaskIntoConstraints = NO;

    [self.window.contentView addSubview: _navigationController.view];

    NSDictionary* const views = @{@"NavigationBarContainer": self.navigationBarContainer,

                                  @"NavigationControllerView": _navigationController.view};

    [self.window.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[NavigationControllerView]|" options: 0 metrics: nil views: views]];

    [self.window.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[NavigationBarContainer][NavigationControllerView]|" options: 0 metrics: nil views: views]];
  }}
}

- (void) applicationDidFinishLaunching: (NSNotification*) aNotification
{
}

#pragma mark - KSPNavigationControllerDelegate Protocol Implementation

@end
