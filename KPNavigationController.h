#import <KPToolbox/KPViewController.h>

@class KPNavViewController;

@protocol KPNavigationControllerDelegate;

@interface KPNavigationController : KPViewController

@property(readonly, strong) IBOutlet NSView* navigationBar;

#pragma mark - Accessing the Delegate

@property(readwrite, weak) NSObject<KPNavigationControllerDelegate>* delegate;

#pragma mark - Creating Navigation Controllers

/// Initializes and returns a newly created navigation controller.
- (instancetype) initWithRootViewController: (KPNavViewController*) rootViewController;

#pragma mark - Accessing Items on the Navigation Stack

- (KPNavViewController*) topViewController;

#pragma mark - Pushing and Popping Stack Items

- (void) setViewControllers: (NSArray*) newViewControllers animated: (BOOL) animated;

- (void) pushViewController: (KPNavViewController*) viewController animated: (BOOL) animated;

- (KPNavViewController*) popViewControllerAnimated: (BOOL) animated;

- (NSArray*) popToRootViewControllerAnimated: (BOOL) animated;

- (NSArray*) popToViewController: (KPNavViewController*) viewController animated: (BOOL) animated;

@end
