
#import "NavViewController.h"

@implementation NavViewController

@synthesize navigationController;

@synthesize navigationTitle;

@synthesize navigationBarItem;

@synthesize navigationToolbar;

- (id) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil
{
  self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
  
  if(!self) return nil;
  
  [self loadView];
  
  [self traverseViewHierarchy: navigationToolbar andSetNSButtonCellsBackgroundColor: [NSColor windowBackgroundColor]];
  
  return self;
}

- (void) dealloc
{
  [navigationTitle release]; navigationTitle = nil;
  
  [super dealloc];
}

- (void) traverseViewHierarchy: (NSView*) root andSetNSButtonCellsBackgroundColor: (NSColor*) backgroundColor
{
  if(!root || !backgroundColor) return;
  
  NSArray* subviews = [root subviews];
  
  for(NSView* one in subviews)
  {
    if([one isKindOfClass: [NSButton class]] && ![(NSButton*)one isBordered])
    {
      [[(NSButton*)one cell] setBackgroundColor: backgroundColor];
    }
    else
    {
      [self traverseViewHierarchy: one andSetNSButtonCellsBackgroundColor: backgroundColor];
    }
  }
}

- (void) viewWillAppear: (BOOL) animated
{
}

- (void) viewDidAppear: (BOOL) animated
{
}

- (void) viewWillDisappear: (BOOL) animated
{
}

- (void) viewDidDisappear: (BOOL) animated
{
}

@end
