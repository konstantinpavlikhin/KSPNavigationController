
#import <KPFoundation/KPViewController.h>

@class NavigationController;

@interface NavViewController : KPViewController

@property(readwrite, assign) NavigationController* navigationController;

@property(readwrite, retain) NSString* navigationTitle;

@property(readwrite, retain) IBOutlet NSView* navigationBarItem;

@property(readwrite, retain) IBOutlet NSView* navigationToolbar;

- (void) traverseViewHierarchy: (NSView*) root andSetNSButtonCellsBackgroundColor: (NSColor*) backgroundColor;

- (void) viewWillAppear: (BOOL) animated;

- (void) viewDidAppear: (BOOL) animated;

- (void) viewWillDisappear: (BOOL) animated;

- (void) viewDidDisappear: (BOOL) animated;

@end
