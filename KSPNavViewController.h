#import "KSPViewController+Private.h"

@class KSPNavigationController;

@interface KSPNavViewController : KSPViewController

@property(readwrite, weak) KSPNavigationController* navigationController;

@property(readwrite, strong) NSButton* backButton;

@property(readwrite, strong) IBOutlet NSView* leftNavigationBarView;

@property(readwrite, strong) IBOutlet NSView* centerNavigationBarView;

@property(readwrite, strong) IBOutlet NSView* rightNavigationBarView;

@property(readwrite, strong) IBOutlet NSView* navigationToolbar;

- (void) navigationViewWillAppear: (BOOL) animated;

- (void) navigationViewDidAppear: (BOOL) animated;

- (void) navigationViewWillDisappear: (BOOL) animated;

- (void) navigationViewDidDisappear: (BOOL) animated;

@end
