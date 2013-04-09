
#import <KPFoundation/KPViewController.h>

@class KPNavViewController;

@protocol KPNavigationControllerDelegate;

@interface KPNavigationController : KPViewController

@property(readonly, retain) IBOutlet NSView* navigationBar;

#pragma mark - Creating Navigation Controllers

/// Initializes and returns a newly created navigation controller.
- (instancetype) initWithRootViewController: (KPNavViewController*) rootViewController;

#pragma mark - Accessing Items on the Navigation Stack

/// The view controller at the top of the navigation stack. (read-only)
- (KPNavViewController*) topViewController;

/// The view controllers currently on the navigation stack.
/// The root view controller is at index 0 in the array, the back view controller is at index n-2, and the top controller is at index n-1, where n is the number of items in the array.
/// Assigning a new array of view controllers to this property is equivalent to calling the setViewControllers:animated: method with the animated parameter set to NO.
@property(nonatomic, copy) NSArray *viewControllers;

/// Replaces the view controllers currently managed by the navigation controller with the specified items.
/// You can use this method to update or replace the current view controller stack without pushing or popping each controller explicitly. In addition, this method lets you update the set of controllers without animating the changes, which might be appropriate at launch time when you want to return the navigation controller to a previous state.
/// If animations are enabled, this method decides which type of transition to perform based on whether the last item in the items array is already in the navigation stack. If the view controller is currently in the stack, but is not the topmost item, this method uses a pop transition; if it is the topmost item, no transition is performed. If the view controller is not on the stack, this method uses a push transition. Only one transition is performed, but when that transition finishes, the entire contents of the stack are replaced with the new view controllers. For example, if controllers A, B, and C are on the stack and you set controllers D, A, and B, this method uses a pop transition and the resulting stack contains the controllers D, A, and B.
//- (void) setViewControllers: (NSMutableArray*) newViewControllers animated: (BOOL) animated;

#pragma mark - Pushing and Popping Stack Items

/// Pushes a view controller onto the receiver’s stack and updates the display.
/// The object in the viewController parameter becomes the top view controller on the navigation stack. Pushing a view controller results in the display of the view it manages. How that view is displayed is determined by the animated parameter. If the animated parameter is YES, the view is animated into position; otherwise, the view is simply displayed in place. The view is automatically resized to fit between the navigation bar and toolbar (if present) before it is displayed.
/// In addition to displaying the view associated with the new view controller at the top of the stack, this method also updates the navigation bar and tool bar accordingly. In iOS 3.0 and later, the contents of the built-in navigation toolbar are updated to reflect the toolbar items of the new view controller. For information on how the navigation bar is updated, see “Updating the Navigation Bar.”
- (void) pushViewController: (KPNavViewController*) viewController animated: (BOOL) animated;

/// Pops the top view controller from the navigation stack and updates the display.
/// This method removes the top view controller from the stack and makes the new top of the stack the active view controller. If the view controller at the top of the stack is the root view controller, this method does nothing. In other words, you cannot pop the last item on the stack.
/// In addition to displaying the view associated with the new view controller at the top of the stack, this method also updates the navigation bar and tool bar accordingly. In iOS 3.0 and later, the contents of the built-in navigation toolbar are updated to reflect the toolbar items of the new view controller. For information on how the navigation bar is updated, see “Updating the Navigation Bar.”
- (KPNavViewController*) popViewControllerAnimated: (BOOL) animated;

/// Pops all the view controllers on the stack except the root view controller and updates the display.
/// The root view controller becomes the top view controller. For information on how the navigation bar is updated, see “Updating the Navigation Bar.”
- (NSArray*) popToRootViewControllerAnimated: (BOOL) animated;

/// Pops view controllers until the specified view controller is at the top of the navigation stack.
/// For information on how the navigation bar is updated, see “Updating the Navigation Bar.”
- (NSArray*) popToViewController: (KPNavViewController*) viewController animated: (BOOL) animated;

#pragma mark - Accessing the Delegate

/// The receiver’s delegate or nil if it doesn’t have a delegate.
@property(readwrite, assign) NSObject<KPNavigationControllerDelegate>* delegate;

@end
