#import "KSPViewController+Private.h"

// * * *.

typedef NS_ENUM(NSUInteger, KSPNavigationControllerTransitionStyle)
{
  KSPNavigationControllerTransitionStyleLengthy,
  
  KSPNavigationControllerTransitionStyleShort
};

// * * *.

@class KSPHitTestView;

@class KSPNavViewController;

@protocol KSPNavigationControllerDelegate;

// * * *.

@interface KSPNavigationController : KSPViewController

@property(readonly, strong, nonatomic) IBOutlet KSPHitTestView* navigationBar;

/// KSPNavigationControllerTransitionStyleLengthy by default.
@property(readwrite, assign, nonatomic) KSPNavigationControllerTransitionStyle transitionStyle;

/// 1/2 of a second by default.
@property(readwrite, assign, nonatomic) CFTimeInterval transitionDuration;

/// 24 points by default.
@property(readonly, strong, nonatomic) IBOutlet NSLayoutConstraint* navigationToolbarHostHeight;

#pragma mark - Accessing the Delegate

@property(readwrite, weak, nonatomic) id<KSPNavigationControllerDelegate> delegate;

#pragma mark - Creating Navigation Controllers

- (instancetype) initWithNavigationBar: (NSView*) navigationBar rootViewController: (KSPNavViewController*) rootViewControllerOrNil NS_DESIGNATED_INITIALIZER;

- (instancetype) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (instancetype) initWithCoder: (NSCoder*) coder UNAVAILABLE_ATTRIBUTE;

#pragma mark - Accessing Items on the Navigation Stack

@property(readonly, strong, nonatomic) KSPNavViewController* topViewController;

#pragma mark - Pushing and Popping Stack Items

- (void) setViewControllers: (NSArray*) newViewControllers animated: (BOOL) animated;

- (void) pushViewController: (KSPNavViewController*) viewController animated: (BOOL) animated;

- (KSPNavViewController*) popViewControllerAnimated: (BOOL) animated;

- (NSArray*) popToRootViewControllerAnimated: (BOOL) animated;

- (NSArray*) popToViewController: (KSPNavViewController*) viewController animated: (BOOL) animated;

@end
