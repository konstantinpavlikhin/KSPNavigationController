//
//  KSPViewController.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 08.10.14.
//  Copyright (c) 2014 Konstantin Pavlikhin. All rights reserved.
//

#import "KSPViewController+Private.h"

static NSString* const NextResponder = @"nextResponder";

static void* NextResponderKVOContext;

@implementation KSPViewController

- (NSWindowController*) windowController
{
  return self.view.window.windowController;
}

#pragma mark - Responder Chain Patching

+ (BOOL) runningOnPreYosemite
{
  return (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_9);
}

- (void) loadView
{
  [super loadView];
  
  if([[self class] runningOnPreYosemite] && [self respondsToSelector: @selector(viewDidLoad)])
  {
    [self viewDidLoad];
  }
}

- (void) setView: (NSView*) view
{
  [super setView: view];
  
  if([[self class] runningOnPreYosemite])
  {
    // Подписываемся на обновления свойства nextResponder своего вида.
    [self.view addObserver: self forKeyPath: NextResponder options: NSKeyValueObservingOptionInitial context: &NextResponderKVOContext];
  }
}

- (void) observeValueForKeyPath: (NSString*) keyPath ofObject: (id) object change: (NSDictionary*) change context: (void*) context
{
  // Если это то, чего мы ждем...
  if([keyPath isEqualToString: NextResponder] && object == self.view && context == &NextResponderKVOContext)
  {
    // Избегаем бесконечной рекурсии...
    if(self.view.nextResponder != self) [self patchResponderChain];
  }
}

- (void) patchResponderChain
{
  // Ставим после себя существующий next responder нашего вида.
  self.nextResponder = self.view.nextResponder;
  
  // Ставим себя next responder'ом нашего вида.
  self.view.nextResponder = self;
}

- (void) dealloc
{
  if([[self class] runningOnPreYosemite])
  {
    // Отписываемся от нотификаций.
    [self.view removeObserver: self forKeyPath: NextResponder context: &NextResponderKVOContext];
  }
}

@end
