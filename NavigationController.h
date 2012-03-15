
@interface NSView (NSImageFromNSView)

- (NSImage*) imageWithSubviews;

@end

#pragma mark -

@class NavigationController, NavViewController;

@protocol NavigationControllerDelegate <NSObject>

@optional

- (void) navigationController: (NavigationController*) navigationController willShowViewController: (NavViewController*) viewController animated: (BOOL) animated;

- (void) navigationController: (NavigationController*) navigationController didShowViewController: (NavViewController*) viewController animated: (BOOL) animated;

@end

#pragma mark -

// TODO: переименовать все *ViewController на *NavViewController.

typedef enum _Side { LeftSide, RightSide } Side;

@class CATransition;

@class PathControl;

@interface NavigationController : ViewController
{
  IBOutlet NSView* navigationBar;
  
  IBOutlet NSView* navigationToolbarHost;
  
  NSMutableArray* viewControllers;
  
  //**************************************
  
  CATransition* pushTransition;
  
  NSView* navigationViewTransitionHost;
  
  NSMutableArray* tempConstraints;
  
  IBOutlet NSImageView* imageView1;
  
  IBOutlet NSImageView* imageView2;
  
  id<NavigationControllerDelegate> delegate;
}

@property(readwrite, retain) IBOutlet NSButton* backButton;
@property(readwrite, retain) IBOutlet NSTextField* titleField;

@property(readwrite, retain) NSView* navigationViewTransitionHost;

@property(readonly) NSView* navigationBar;

@property(readonly) NSMutableArray* viewControllers;

@property(readwrite, assign) id<NavigationControllerDelegate> delegate;

- (id) initWithRootViewController: (NavViewController*) rootViewController;

// Вставляет виды newController'а в виды NavigationController'а.
- (void) insertNavViewController: (NavViewController*) newController;

// Вынимает виды текущего NavViewController'а из видов NavigationController'а.
- (void) removeCurrentNavViewController;

// Заменяет виды текущего NavViewController'а на виды newController'а.
- (void) replaceCurrentNavViewControllerWith: (NavViewController*) newController animated: (BOOL) animated slideTo: (Side) side;

- (void) animatedReplaceView: (NSView*) oldView with: (NSView*) newView slideTo: (Side) side hackyParam: (NavViewController*) newController hackyParam2: (NavViewController*) oldController;

- (void) updatePathControl;

/*
#pragma mark Определение фрэймов элементов

- (NSRect) frameForNavigationBarItem: (NSView*) navigationBarItem;
*/

- (NSRect) frameForNavigationView;

/*
- (NSRect) frameForNavigationToolbar;
*/

#pragma mark Пользовательские функции

- (NavViewController*) topViewController;

- (void) setViewControllers: (NSMutableArray*) newViewControllers;

- (void) pushViewController: (NavViewController*) viewController animated: (BOOL) animated;

- (NavViewController*) popViewControllerAnimated: (BOOL) animated;

- (NSArray*) popToRootViewControllerAnimated: (BOOL) animated;

- (NSArray*) popToViewController: (NavViewController*) viewController animated: (BOOL) animated;

- (IBAction) backButtonPressed:(id)sender;

@end
