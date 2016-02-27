//
//  KSPView.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 20.05.15.
//  Copyright (c) 2016 Konstantin Pavlikhin. All rights reserved.
//

#import "KSPView.h"

#import "KSPViewController.h"

@implementation KSPView
{
  __weak KSPViewController* _viewController;
}

@synthesize viewController = _viewController;

#pragma mark - NSResponder Overrides

- (void) setNextResponder: (NSResponder* const) nextResponder
{
  if(rint(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9)
  {
    // Yosemite does the right thing out of the box.
    super.nextResponder = nextResponder;
  }
  else
  {
    if(_viewController)
    {
      _viewController.nextResponder = nextResponder;
    }
    else
    {
      super.nextResponder = nextResponder;
    }
  }
}

#pragma mark - Public Methods

- (void) setViewController: (KSPViewController* const) newViewControllerOrNil
{
  // Here we accept only nils and instances of a KSPViewController class.
  NSParameterAssert(!newViewControllerOrNil || [newViewControllerOrNil isKindOfClass: [KSPViewController class]]);

  // * * *.

  if(rint(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9)
  {
    _viewController = newViewControllerOrNil;
  }
  else
  {
    if(_viewController)
    {
      // If the current view already had a view controller...

      NSResponder* const currentViewControllersNextResponder = _viewController.nextResponder;

      _viewController.nextResponder = nil;

      _viewController = newViewControllerOrNil;

      if(newViewControllerOrNil)
      {
        super.nextResponder = newViewControllerOrNil;

        newViewControllerOrNil.nextResponder = currentViewControllersNextResponder;
      }
      else
      {
        super.nextResponder = currentViewControllersNextResponder;
      }
    }
    else
    {
      // If the current view had not a view controller...

      if(newViewControllerOrNil)
      {
        _viewController = newViewControllerOrNil;

        NSResponder* const currentViewsNextResponder = self.nextResponder;

        super.nextResponder = newViewControllerOrNil;

        newViewControllerOrNil.nextResponder = currentViewsNextResponder;
      }
    }
  }
}

@end
