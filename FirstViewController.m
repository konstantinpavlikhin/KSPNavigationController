//
//  FirstViewController.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 02/12/15.
//  Copyright © 2015 Konstantin Pavlikhin. All rights reserved.
//

#import "FirstViewController+Private.h"

#import "SecondViewController.h"

#import "KSPNavigationController.h"

@implementation FirstViewController

#pragma mark - Interface Callbacks

- (IBAction) pushNextViewController: (id) sender
{
  SecondViewController* const secondViewController = [[SecondViewController alloc] initWithNibName: @"SecondView" bundle: nil];

  [self.navigationController pushViewController: secondViewController animated: YES];
}

@end
