////////////////////////////////////////////////////////////////////////////////

#import "NavViewController.h"

#import "SilentDisabilityButton.h"

@implementation NavViewController

@synthesize navigationController;

@synthesize navigationTitle;

@synthesize navigationBarItem;

@synthesize navigationToolbar;

@synthesize theFirstResponder;

- (id) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil
{
  self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
  
  if(!self) return nil;
  
  [self loadView];
  
  [self bindSilentDisabilityButtons];
  
  [self traverseViewHierarchy: navigationToolbar andSetNSButtonCellsBackgroundColor: [NSColor windowBackgroundColor]];
  
  return self;
}

- (void) dealloc
{
  [self unbindSilentDisabilityButtons];
  
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

- (void) bindSilentDisabilityButtons
{
  [self traverseViewHierarchyAndBindSilentDisabilityButtons: [self navigationBarItem]];
  
  [self traverseViewHierarchyAndBindSilentDisabilityButtons: [self navigationToolbar]];
}

- (void) traverseViewHierarchyAndBindSilentDisabilityButtons: (NSView*) root
{
  if(!root) return;
  
  if([root isKindOfClass: [SilentDisabilityButton class]])
  {
    [(SilentDisabilityButton*)root bind: @"silentlyDisabled" toObject: self withKeyPath: @"navigationController.transitioning" options: nil];
  }
  else
  {
    NSArray* subviews = [root subviews];
    
    for(NSView* v in subviews) [self traverseViewHierarchyAndBindSilentDisabilityButtons: v];
  }
}

- (void) unbindSilentDisabilityButtons
{
  [self traverseViewHierarchyAndUnbindSilentDisabilityButtons: [self navigationBarItem]];
  
  [self traverseViewHierarchyAndUnbindSilentDisabilityButtons: [self navigationToolbar]];
}

- (void) traverseViewHierarchyAndUnbindSilentDisabilityButtons: (NSView*) root
{
  if(!root) return;
  
  if([root isKindOfClass: [SilentDisabilityButton class]])
  {
    [(SilentDisabilityButton*)root unbind: @"silentlyDisabled"];
  }
  else
  {
    NSArray* subviews = [root subviews];
    
    for(NSView* v in subviews) [self traverseViewHierarchyAndUnbindSilentDisabilityButtons: v];
  }
}

@end

////////////////////////////////////////////////////////////////////////////////
