#import <KSPToolbox/KPViewController.h>

@class KPNavViewController;

@protocol KPNavigationControllerDelegate;

@class HitTestView;

@interface KPNavigationController : KPViewController

@property(readonly, strong) IBOutlet HitTestView* navigationBar;

#pragma mark - Accessing the Delegate

@property(readwrite, weak) NSObject<KPNavigationControllerDelegate>* delegate;

#pragma mark - Creating Navigation Controllers

- (instancetype) initWithNavigationBar: (NSView*) navigationBar rootViewController: (KPNavViewController*) rootViewControllerOrNil NS_DESIGNATED_INITIALIZER;

- (instancetype) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (instancetype) initWithCoder: (NSCoder*) coder UNAVAILABLE_ATTRIBUTE;

#pragma mark - Accessing Items on the Navigation Stack

@property(readonly, strong) KPNavViewController* topViewController;

- (KPNavViewController*) topViewController;

#pragma mark - Pushing and Popping Stack Items

- (void) setViewControllers: (NSArray*) newViewControllers animated: (BOOL) animated;

- (void) pushViewController: (KPNavViewController*) viewController animated: (BOOL) animated;

- (KPNavViewController*) popViewControllerAnimated: (BOOL) animated;

- (NSArray*) popToRootViewControllerAnimated: (BOOL) animated;

- (NSArray*) popToViewController: (KPNavViewController*) viewController animated: (BOOL) animated;

@end
