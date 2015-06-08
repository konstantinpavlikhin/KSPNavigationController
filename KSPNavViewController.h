#import "KSPViewController+Private.h"

@class KSPNavigationController;

@interface KSPNavViewController : KSPViewController

@property(readwrite, weak, nonatomic) KSPNavigationController* navigationController;

@property(readwrite, strong, nonatomic) NSButton* backButton;

@property(readonly, strong, nonatomic) IBOutlet NSView* leftNavigationBarView;

@property(readonly, strong, nonatomic) IBOutlet NSView* centerNavigationBarView;

@property(readonly, strong, nonatomic) IBOutlet NSView* rightNavigationBarView;

@property(readonly, strong, nonatomic) IBOutlet NSView* navigationToolbar;

- (void) navigationViewWillAppear: (BOOL) animated;

- (void) navigationViewDidAppear: (BOOL) animated;

- (void) navigationViewWillDisappear: (BOOL) animated;

- (void) navigationViewDidDisappear: (BOOL) animated;

@end
