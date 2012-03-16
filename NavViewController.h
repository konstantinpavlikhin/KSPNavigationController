
@class NavigationController;

@interface NavViewController : ViewController
{
  NavigationController* navigationController;
  
  NSString* navigationTitle;
  
  IBOutlet NSView* navigationBarItem;
  
  IBOutlet NSView* navigationToolbar;
}

@property(readwrite, assign) NavigationController* navigationController;

@property(readwrite, retain) NSString* navigationTitle;

@property(readonly, retain) IBOutlet NSView* navigationBarItem;

@property(readonly, retain) IBOutlet NSView* navigationToolbar;

- (void) traverseViewHierarchy: (NSView*) root andSetNSButtonCellsBackgroundColor: (NSColor*) backgroundColor;

- (void) viewWillAppear: (BOOL) animated;

- (void) viewDidAppear: (BOOL) animated;

- (void) viewWillDisappear: (BOOL) animated;

- (void) viewDidDisappear: (BOOL) animated;

@end
