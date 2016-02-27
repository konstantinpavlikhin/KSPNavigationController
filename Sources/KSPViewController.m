//
//  KSPViewController.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 08.10.14.
//  Copyright (c) 2016 Konstantin Pavlikhin. All rights reserved.
//

#import "KSPViewController+Private.h"

#import "KSPView.h"

@implementation KSPViewController

- (NSWindowController*) windowController
{
  return self.view.window.windowController;
}

#pragma mark - Cleanup

- (void) dealloc
{
  if(rint(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9)
  {
    // Nothing to do.
  }
  else
  {
    if([self viewWithoutInstantiationOnAccess] && [[self viewWithoutInstantiationOnAccess] isKindOfClass: [KSPView class]])
    {
      KSPView* const castedView = (KSPView*)[self viewWithoutInstantiationOnAccess];
      
      castedView.viewController = nil;
    }
  }
}

#pragma mark - NSViewController Overrides

- (void) setView: (NSView* const) newView
{
  if(rint(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9)
  {
    // Yosemite does the right thing out of the box.
    super.view = newView;
  }
  else
  {
    // 'view' property is declared as atomic.
    @synchronized(self)
    {
      if(newView != [self viewWithoutInstantiationOnAccess])
      {
        if([self viewWithoutInstantiationOnAccess] && [[self viewWithoutInstantiationOnAccess] isKindOfClass: [KSPView class]])
        {
          KSPView* const castedView = (KSPView*)[self viewWithoutInstantiationOnAccess];

          castedView.viewController = nil;
        }

        // * * *.

        super.view = newView;

        // * * *.

        if(newView && [newView isKindOfClass: [KSPView class]])
        {
          KSPView* const castedNewView = (KSPView*)newView;

          castedNewView.viewController = self;
        }
      }
    }
  }
}

#pragma mark - Private Methods

- (NSView*) viewWithoutInstantiationOnAccess
{
  // Private method selector "_view".
  NSArray* const letters = @[@"_", @"v", @"i", @"e", @"w"];
  
  return [self valueForKey: [letters componentsJoinedByString: @""]];
}

@end
