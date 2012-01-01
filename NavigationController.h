////////////////////////////////////////////////////////////////////////////////

#import "ViewController.h"

@interface NSView (NSImageFromNSView)

- (NSImage*) imageWithSubviews;

@end

#pragma mark -

@class NavigationController, NavViewController;

@protocol NavigationControllerDelegate <NSObject>

@optional

- (void) navigationController: (NavigationController*) navigationController willShowViewController: (NavViewController*) viewController animated: (BOOL) animated;

@end

#pragma mark -

// TODO: переименовать все *ViewController на *NavViewController.

typedef enum _Side { LeftSide, RightSide } Side;

@class CATransition;

@class PathControl;

@interface NavigationController : ViewController
{
  IBOutlet NSView* navigationBar;
  
  IBOutlet PathControl* pathControl;
  
  IBOutlet NSView* navigationToolbarHost;
  
  NSMutableArray* viewControllers;
  
  //**************************************
  
  CATransition* pushTransition;
  
  NSView* navigationViewTransitionHost;
  
  NSView* subviewToAddAfterTransition;
  
  NSImageView* imageView1;
  
  NSImageView* imageView2;
  
  id<NavigationControllerDelegate> delegate;
  
  BOOL transitioning;
}

@property(readonly) NSView* navigationBar;

@property(readonly) NSMutableArray* viewControllers;

@property(readwrite, assign) id<NavigationControllerDelegate> delegate;

@property(readwrite, assign, getter = isTransitioning) BOOL transitioning;

- (id) initWithRootViewController: (NavViewController*) rootViewController;

// Вставляет виды newController'а в виды NavigationController'а.
- (void) insertNavViewController: (NavViewController*) newController;

// Вынимает виды текущего NavViewController'а из видов NavigationController'а.
- (void) removeCurrentNavViewController;

// Заменяет виды текущего NavViewController'а на виды newController'а.
- (void) replaceCurrentNavViewControllerWith: (NavViewController*) newController animated: (BOOL) animated slideTo: (Side) side;

- (void) animatedReplaceView: (NSView*) oldView with: (NSView*) newView slideTo: (Side) side;

- (void) animationDidStop: (CAAnimation*) theAnimation finished: (BOOL) flag;

- (void) updatePathControl;

- (void) pathControlClicked: (id) sender;

#pragma mark Определение фрэймов элементов

- (NSRect) frameForNavigationBarItem: (NSView*) navigationBarItem;

- (NSRect) frameForNavigationView;

- (NSRect) frameForNavigationToolbar;

#pragma mark Пользовательские функции

- (NavViewController*) topViewController;

- (void) setViewControllers: (NSArray*) newViewControllers;

- (void) pushViewController: (NavViewController*) viewController animated: (BOOL) animated;

- (NavViewController*) popViewControllerAnimated: (BOOL) animated;

- (NSArray*) popToRootViewControllerAnimated: (BOOL) animated;

- (NSArray*) popToViewController: (NavViewController*) viewController animated: (BOOL) animated;

@end

////////////////////////////////////////////////////////////////////////////////
