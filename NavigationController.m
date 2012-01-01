////////////////////////////////////////////////////////////////////////////////

#import "NavigationController.h"

#import "NavViewController.h"

#import "PathControl.h"

#import "GradientBox.h"

#import <QuartzCore/CoreAnimation.h>

@implementation NSView (NSImageFromNSView)

- (NSImage*) imageWithSubviews
{
  NSSize mySize = self.bounds.size;
  
  NSSize imgSize = NSMakeSize(mySize.width, mySize.height);
  
  NSBitmapImageRep* bir = [self bitmapImageRepForCachingDisplayInRect: [self bounds]];
  
  [bir setSize: imgSize];
  
  [self cacheDisplayInRect: [self bounds] toBitmapImageRep: bir];
  
  NSImage* image = [[[NSImage alloc] initWithSize: imgSize] autorelease];
  
  [image addRepresentation: bir];
  
  return image;
}

@end

#pragma mark -

@implementation NavigationController

@synthesize navigationBar;

@synthesize viewControllers;

@synthesize delegate;

@synthesize transitioning;

#define TRANSITION_DURATION 0.4

- (id) initWithRootViewController: (NavViewController*) rootViewController
{
  self = [self initWithNibName: @"NavigationController" bundle: nil];
  
  if(!self) return nil;
  
  [self loadView];
  
  //*** Настраиваем параметры представления GradientBox. ***********************
  [(GradientBox*)navigationBar setHasGradient: YES];
  
  [(GradientBox*)navigationBar setFillStartingColor: [NSColor colorWithDeviceWhite: 0.2 alpha: 1.0]];
  
  [(GradientBox*)navigationBar setFillEndingColor: [NSColor colorWithDeviceWhite: 0.05 alpha: 1.0]];
  
  [(GradientBox*)navigationBar setTopInsetAlpha: 0.1];
  
  [(GradientBox*)navigationBar setBottomInsetAlpha: 0.1];
  
  [(GradientBox*)navigationBar setHasBottomBorder: YES];
  
  [(GradientBox*)navigationBar setBottomBorderColor: [NSColor colorWithDeviceWhite: 0.05 alpha: 1.0]];
  
  
  viewControllers = [[NSMutableArray alloc] init];
  
  if(rootViewController) [self setViewControllers: [NSArray arrayWithObject: rootViewController]];
  
  //*** Анимация navigationBarItem и navigationToolbar. ************************
  CATransition* fadeTransition = [CATransition animation];
  
  [fadeTransition setType: kCATransitionFade];
  
  [fadeTransition setDuration: TRANSITION_DURATION];
  
  NSDictionary* animations = [NSDictionary dictionaryWithObject: fadeTransition forKey: @"subviews"];
  
  [navigationBar setAnimations: animations];
  
  [navigationToolbarHost setAnimations: animations];
  
  //*** Анимация смены navigationView. *****************************************
  pushTransition = [[CATransition animation] retain];
  
  [pushTransition setType: kCATransitionPush];
  
  [pushTransition setDuration: TRANSITION_DURATION];
  
  [pushTransition setDelegate: self];
  
  
  navigationViewTransitionHost = [[NSView alloc] initWithFrame: NSZeroRect];
  
  [navigationViewTransitionHost setAnimations: [NSDictionary dictionaryWithObject: pushTransition forKey: @"subviews"]];
  
  [navigationViewTransitionHost setWantsLayer: YES];
  
  [navigationViewTransitionHost setAutoresizingMask: NSViewMinYMargin | NSViewMaxYMargin | NSViewHeightSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewWidthSizable];
  
  
  imageView1 = [[NSImageView alloc] initWithFrame: NSZeroRect];
  
  [imageView1 setWantsLayer: YES];
  
  imageView2 = [[NSImageView alloc] initWithFrame: NSZeroRect];
  
  [imageView2 setWantsLayer: YES];
  
  //*** Биндинг pathControl'а. *************************************************
  NSDictionary* bindOptions = [NSDictionary dictionaryWithObject: NSNegateBooleanTransformerName forKey: NSValueTransformerNameBindingOption];
  
  [pathControl bind: @"enabled" toObject: self withKeyPath: @"transitioning" options: bindOptions];
  
  return self;
}

- (void) dealloc
{
  [viewControllers release];
  
  [pushTransition release];
  
  [navigationViewTransitionHost release];
  
  [imageView1 release];
  
  [imageView2 release];
  
  [pathControl unbind: @"enabled"];
  
  [super dealloc];
}

// Вставляет переданный контроллер в иерархию видов.
- (void) insertNavViewController: (NavViewController*) newController
{
  if(!newController) return;
  
  if([delegate respondsToSelector: @selector(navigationController:willShowViewController:animated:)])
  {
    [delegate navigationController: self willShowViewController: newController animated: NO];
  }
  
  //****************************************************************************
  
  NSView* newNavigationBarItem = [newController navigationBarItem];
  
  [newNavigationBarItem setFrame: [self frameForNavigationBarItem: newNavigationBarItem]];
  
  [navigationBar addSubview: newNavigationBarItem];
  
  //****************************************************************************
  
  NSView* newNavigationView = [newController view];
  
  [newNavigationView setFrame: [self frameForNavigationView]];
  
  [[self view] addSubview: newNavigationView];
  
  // ?
  [[[self windowController] window] makeFirstResponder: [newController theFirstResponder]];
  
  //****************************************************************************
  
  NSView* newNavigationToolbar = [newController navigationToolbar];
  
  [newNavigationToolbar setFrame: [self frameForNavigationToolbar]];
  
  [navigationToolbarHost addSubview: newNavigationToolbar];
}

- (void) removeCurrentNavViewController
{
  NavViewController* currentController = [self topViewController];
  
  [[currentController navigationBarItem] removeFromSuperviewWithoutNeedingDisplay];
  
  [[currentController view] removeFromSuperviewWithoutNeedingDisplay];
  
  [[currentController navigationToolbar] removeFromSuperviewWithoutNeedingDisplay];
}

// Снимает текущий контроллер из окна и вставляет в него новый.
- (void) replaceCurrentNavViewControllerWith: (NavViewController*) newController animated: (BOOL) animated slideTo: (Side) side
{
  if(!newController) return;
  
  if([delegate respondsToSelector: @selector(navigationController:willShowViewController:animated:)])
  {
    [delegate navigationController: self willShowViewController: newController animated: animated];
  }
  
  //****************************************************************************
  
  NavViewController* oldController = [self topViewController];
  
  //*** NavigationBarItem ******************************************************
  
  NSView* oldNavigationBarItem = [oldController navigationBarItem];
  NSView* newNavigationBarItem = [newController navigationBarItem];
  
  if(oldNavigationBarItem && newNavigationBarItem)
  {
    // Если navigationBarItem была и будет.
    [newNavigationBarItem setFrame: [self frameForNavigationBarItem: newNavigationBarItem]];
    
    [(animated ? [navigationBar animator] : navigationBar) replaceSubview: oldNavigationBarItem with: newNavigationBarItem];
  }
  else if(oldNavigationBarItem && !newNavigationBarItem)
  {
    // Если navigationBarItem была, но не будет.
    [(animated ? [oldNavigationBarItem animator] : oldNavigationBarItem) removeFromSuperview];
  }
  else if(!oldNavigationBarItem && newNavigationBarItem)
  {
    // Если navigationBarItem не было, но будет.
    [newNavigationBarItem setFrame: [self frameForNavigationBarItem: newNavigationBarItem]];
    
    [(animated ? [navigationBar animator] : navigationBar) addSubview: newNavigationBarItem];
  }
  
  //*** NavigationView *********************************************************
  
  NSView* oldNavigationView = [oldController view];
  NSView* newNavigationView = [newController view];
  
  [oldNavigationView removeFromSuperviewWithoutNeedingDisplay];
  
  [newNavigationView setFrame: [self frameForNavigationView]];
  
  if(animated)
  {
    subviewToAddAfterTransition = newNavigationView;
    
    [self animatedReplaceView: oldNavigationView with: newNavigationView slideTo: side];
  }
  else
  {
    [[self view] addSubview: newNavigationView];
    
    [[[self windowController] window] makeFirstResponder: [newController theFirstResponder]];
  }
  
  //*** NavigationToolbar ******************************************************
  
  NSView* newNavigationToolbar = [newController navigationToolbar];
  
  [newNavigationToolbar setFrame: [self frameForNavigationToolbar]];
  
  [(animated ? [navigationToolbarHost animator] : navigationToolbarHost) replaceSubview: [oldController navigationToolbar] with: newNavigationToolbar];
}

- (void) animatedReplaceView: (NSView*) oldView with: (NSView*) newView slideTo: (Side) side
{
  [self setTransitioning: YES];
  
  [imageView1 removeFromSuperviewWithoutNeedingDisplay];
  
  [imageView1 setImage: [oldView imageWithSubviews]];
  
  [imageView1 setFrameSize: [oldView frame].size];
  
  [imageView1 setFrameOrigin: NSZeroPoint];
  
  //******************************************************
  
  [imageView2 removeFromSuperviewWithoutNeedingDisplay];
  
  [imageView2 setImage: [newView imageWithSubviews]];
  
  [imageView2 setFrameSize: [newView frame].size];
  
  [imageView2 setFrameOrigin: NSZeroPoint];
  
  //******************************************************
  
  [navigationViewTransitionHost removeFromSuperviewWithoutNeedingDisplay];
  
  [[self view] addSubview: navigationViewTransitionHost];
  
  [navigationViewTransitionHost setFrame: [self frameForNavigationView]];
  
  [navigationViewTransitionHost addSubview: imageView1];
  
  [navigationViewTransitionHost display];
  
  //******************************************************
  
  [pushTransition setSubtype: (side == LeftSide) ? kCATransitionFromRight : kCATransitionFromLeft];
  
  [[navigationViewTransitionHost animator] replaceSubview: imageView1 with: imageView2];
}

- (void) animationDidStop: (CAAnimation*) theAnimation finished: (BOOL) finished
{
  if(finished)
  {
    [navigationViewTransitionHost removeFromSuperview];
    
    if(subviewToAddAfterTransition)
    {
      [[self view] addSubview: subviewToAddAfterTransition];
      
      subviewToAddAfterTransition = nil;
    }
    
    [self setTransitioning: NO];
    
    [[[self windowController] window] makeFirstResponder: [[self topViewController] theFirstResponder]];
  }
}

- (void) updatePathControl
{
  NSMutableArray* steps = [NSMutableArray array];
  
  for(NavViewController* controller in viewControllers) [steps addObject: [controller navigationTitle]];
  
  [pathControl setComponentsWithNames: steps];
}

- (void) pathControlClicked: (id) sender
{
  NavViewController* clickedController = [viewControllers objectAtIndex: [sender clickedComponentIndex]];
  
  if(clickedController != [self topViewController]) [self popToViewController: clickedController animated: YES];
}

#pragma mark - Определение фрэймов элементов

- (NSRect) frameForNavigationBarItem: (NSView*) navigationBarItem
{
  // Сюда заложим выходное значение.
  NSRect navigationBarItemFrame;
  
  // Узнаем размер этой фигни.
  navigationBarItemFrame.size = [navigationBarItem frame].size;
  
  // Какой размер navigationBar'а?
  NSSize navigationBarSize = [navigationBar frame].size;
  
  // Прикрепляем navigationBarItem к правому краю с отступом в 10.0.
  navigationBarItemFrame.origin.x = navigationBarSize.width - 10.0 - navigationBarItemFrame.size.width;
  
  // Центруем navigationBarItem по вертикали.
  navigationBarItemFrame.origin.y = floor((navigationBarSize.height - navigationBarItemFrame.size.height) / 2.0);
  
  return navigationBarItemFrame;
}

- (NSRect) frameForNavigationView
{
  NSRect navigationViewFrame;
  
  CGFloat navigationToolbarHostHeight = [navigationToolbarHost frame].size.height;
  
  navigationViewFrame.origin.x = 0;
  
  navigationViewFrame.origin.y = navigationToolbarHostHeight;
  
  navigationViewFrame.size.width = [[self view] frame].size.width;
  
  navigationViewFrame.size.height = [navigationBar frame].origin.y - navigationToolbarHostHeight;
  
  return navigationViewFrame;
}

- (NSRect) frameForNavigationToolbar
{
  NSRect navigationToolbarFrame;
  
  navigationToolbarFrame.origin = NSZeroPoint;
  
  navigationToolbarFrame.size = [navigationToolbarHost frame].size;
  
  return navigationToolbarFrame;
}

#pragma mark Пользовательские функции

- (NavViewController*) topViewController
{
  return [viewControllers lastObject];
}

- (void) setViewControllers: (NSArray*) newViewControllers
{
  if(!newViewControllers) return;
  
  [self removeCurrentNavViewController];
  
  [viewControllers removeAllObjects];
  
  [viewControllers addObjectsFromArray: newViewControllers];
  
  [viewControllers makeObjectsPerformSelector: @selector(setNavigationController:) withObject: self];
  
  [self insertNavViewController: [self topViewController]];
  
  [self updatePathControl];
}

- (void) pushViewController: (NavViewController*) viewController animated: (BOOL) animated
{
  if(!viewController) return;
  
  [self replaceCurrentNavViewControllerWith: viewController animated: animated slideTo: LeftSide];
  
  [viewControllers addObject: viewController];
  
  [viewController setNavigationController: self];
  
  [self updatePathControl];
}

- (NavViewController*) popViewControllerAnimated: (BOOL) animated
{
  NSInteger controllerCount = [viewControllers count];
  
  // Если на стеке только корневой контроллер - ничего не делаем.
  if(controllerCount <= 1) return nil;
  
  NSArray* poppedControllers = [self popToViewController: [viewControllers objectAtIndex: controllerCount - 2] animated: animated];
  
  return [poppedControllers lastObject];
}

- (NSArray*) popToRootViewControllerAnimated: (BOOL) animated
{
  NSInteger controllerCount = [viewControllers count];
  
  // Если на стеке только корневой контроллер - ничего не делаем.
  if(controllerCount <= 1) return nil;
  
  return [self popToViewController: [viewControllers objectAtIndex: 0] animated: animated];
}

- (NSArray*) popToViewController: (NavViewController*) viewController animated: (BOOL) animated
{
  // Если нам передали чушь или такого контроллера вообще нету на стеке - тихо выходим.
  if(!viewController || ![viewControllers containsObject: viewController]) return nil;
  
  [self replaceCurrentNavViewControllerWith: viewController animated: animated slideTo: RightSide];
  
  NSUInteger indexOfViewController = [viewControllers indexOfObject: viewController];
  
  NSRange ejectedRange = NSMakeRange(indexOfViewController + 1, [viewControllers count] - indexOfViewController - 1);
  
  // Сохраняем катапультированные контроллеры.
  NSArray* ejectedControllers = [viewControllers subarrayWithRange: ejectedRange];
  
  [viewControllers removeObjectsInRange: ejectedRange];
  
  [self updatePathControl];
  
  // Информируем вызывавшего о том, кого мы выкинули.
  return ejectedControllers;
}

@end

////////////////////////////////////////////////////////////////////////////////
