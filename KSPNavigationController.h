#import "KSPViewController+Private.h"

@class KSPNavViewController;

@protocol KSPNavigationControllerDelegate;

@class KSPHitTestView;

@interface KSPNavigationController : KSPViewController

@property(readonly, strong) IBOutlet KSPHitTestView* navigationBar;

#pragma mark - Accessing the Delegate

@property(readwrite, weak) NSObject<KSPNavigationControllerDelegate>* delegate;

#pragma mark - Creating Navigation Controllers

- (instancetype) initWithNavigationBar: (NSView*) navigationBar rootViewController: (KSPNavViewController*) rootViewControllerOrNil NS_DESIGNATED_INITIALIZER;

- (instancetype) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (instancetype) initWithCoder: (NSCoder*) coder UNAVAILABLE_ATTRIBUTE;

#pragma mark - Accessing Items on the Navigation Stack

@property(readonly, strong) KSPNavViewController* topViewController;

- (KSPNavViewController*) topViewController;

#pragma mark - Pushing and Popping Stack Items

- (void) setViewControllers: (NSArray*) newViewControllers animated: (BOOL) animated;

- (void) pushViewController: (KSPNavViewController*) viewController animated: (BOOL) animated;

- (KSPNavViewController*) popViewControllerAnimated: (BOOL) animated;

- (NSArray*) popToRootViewControllerAnimated: (BOOL) animated;

- (NSArray*) popToViewController: (KSPNavViewController*) viewController animated: (BOOL) animated;

@end
