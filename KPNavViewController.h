#import <KPFoundation/KPViewController.h>

@class KPNavigationController;

@interface KPNavViewController : KPViewController

@property(readwrite, weak) KPNavigationController* navigationController;

@property(readwrite, strong) NSString* navigationTitle;

@property(readwrite, strong) NSButton* backButton;

@property(readwrite, strong) IBOutlet NSView* leftNavigationBarView;

@property(readwrite, strong) IBOutlet NSView* centerNavigationBarView;

@property(readwrite, strong) IBOutlet NSView* rightNavigationBarView;

@property(readwrite, strong) IBOutlet NSView* navigationToolbar;

- (void) viewWillAppear: (BOOL) animated;

- (void) viewDidAppear: (BOOL) animated;

- (void) viewWillDisappear: (BOOL) animated;

- (void) viewDidDisappear: (BOOL) animated;

@end
