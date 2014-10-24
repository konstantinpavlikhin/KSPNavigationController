////////////////////////////////////////////////////////////////////////////////
//  
//  KPViewController.m
//  
//  KPToolbox
//  
//  Created by Konstantin Pavlikhin on unknown.
//  
////////////////////////////////////////////////////////////////////////////////

#import "KPViewController.h"

NSString* const nextResponder = @"nextResponder";

static void* NextResponderKVOContext;

@interface KPViewController ()

// Задавать это свойство надо из IB.
@property(readwrite, assign) IBOutlet NSResponder* proposedFirstResponder;

@end

@implementation KPViewController

+ (BOOL) runningOnPreYosemite
{
  NSOperatingSystemVersion currentSystemVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
  
  return (currentSystemVersion.majorVersion <= 10) && (currentSystemVersion.minorVersion < 10);
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
    [self.view addObserver: self forKeyPath: nextResponder options: NSKeyValueObservingOptionInitial context: &NextResponderKVOContext];
  }
}

- (void) observeValueForKeyPath: (NSString*) keyPath ofObject: (id) object change: (NSDictionary*) change context: (void*) context
{
  // Если это то, чего мы ждем...
  if([keyPath isEqualToString: nextResponder] && object == self.view && context == &NextResponderKVOContext)
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
    [self.view removeObserver: self forKeyPath: nextResponder context: &NextResponderKVOContext];
  }
}

@end
