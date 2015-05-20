//
//  KSPViewController.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 08.10.14.
//  Copyright (c) 2014 Konstantin Pavlikhin. All rights reserved.
//

#import "KSPViewController+Private.h"

#import "KSPView.h"

@implementation KSPViewController

- (NSWindowController*) windowController
{
  return self.view.window.windowController;
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
      if(newView != self.view)
      {
        if(self.view && [self.view isKindOfClass: [KSPView class]])
        {
          KSPView* const castedView = (KSPView*)self.view;

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

@end
