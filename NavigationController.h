
#import <KPFoundation/KPViewController.h>

@class NavigationController, NavViewController;

@protocol NavigationControllerDelegate <NSObject>

@optional

- (void) navigationController: (NavigationController*) navigationController willShowViewController: (NavViewController*) viewController animated: (BOOL) animated;

- (void) navigationController: (NavigationController*) navigationController didShowViewController: (NavViewController*) viewController animated: (BOOL) animated;

@end

#pragma mark -

// TODO: переименовать все *ViewController на *NavViewController.

@interface NavigationController : KPViewController

// Кому это надо?
@property(readonly, retain) NSView* navigationBar;

@property(readonly, retain) NSMutableArray* viewControllers;

@property(readwrite, assign) id<NavigationControllerDelegate> delegate;

- (id) initWithRootViewController: (NavViewController*) rootViewController;

- (NavViewController*) topViewController;

- (void) setViewControllers: (NSMutableArray*) newViewControllers;

- (void) pushViewController: (NavViewController*) viewController animated: (BOOL) animated;

- (NavViewController*) popViewControllerAnimated: (BOOL) animated;

- (NSArray*) popToRootViewControllerAnimated: (BOOL) animated;

- (NSArray*) popToViewController: (NavViewController*) viewController animated: (BOOL) animated;

@end
