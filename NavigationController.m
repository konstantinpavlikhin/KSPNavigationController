
#import "NavigationController.h"

#import "NavViewController.h"

#import <QuartzCore/CoreAnimation.h>

#import <KPFoundation/GradientBox.h>

@interface NSView (NSImageFromNSView)

- (NSImage*) imageWithSubviews;

@end

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

enum Side { LeftSide, RightSide };

@interface NavigationController ()

@property(readwrite, retain) IBOutlet NSView* navigationBar;

@property(readwrite, retain) IBOutlet NSButton* backButton;

@property(readwrite, retain) IBOutlet NSTextField* titleField;

@property(readwrite, retain) IBOutlet NSView* navigationToolbarHost;

- (IBAction) backButtonPressed: (id) sender;

@end

@implementation NavigationController
{
  NSMutableArray* viewControllers;
  
  CATransition* pushTransition;
  
  NSView* navigationViewTransitionHost;
  
  NSImageView* imageView1;
  
  NSImageView* imageView2;
}

@synthesize viewControllers;

#define TRANSITION_DURATION 0.25

- (id) initWithRootViewController: (NavViewController*) rootViewController
{
  self = [self initWithNibName: @"NavigationController" bundle: nil];
  
  if(!self) return nil;
  
  [self loadView];
  
  //*** Настраиваем параметры представления GradientBox. ***********************
  [(GradientBox*)self.navigationBar setHasGradient: YES];
  
  [(GradientBox*)self.navigationBar setFillStartingColor: [NSColor colorWithCalibratedWhite: 0.18 alpha: 1.0]]; // 0.2 iPhoto
  
  [(GradientBox*)self.navigationBar setFillEndingColor: [NSColor colorWithCalibratedWhite: 0.09 alpha: 1.0]]; // 0.15 iPhoto
  
  //[(GradientBox*)navigationBar setTopInsetAlpha: 0.15];
  
  [(GradientBox*)self.navigationBar setBottomInsetAlpha: 0.03];
  
  [(GradientBox*)self.navigationBar setHasBottomBorder: YES];
  
  [(GradientBox*)self.navigationBar setBottomBorderColor: [NSColor colorWithCalibratedWhite: 0.07 alpha: 1.0]];
  
  {
    [self.backButton setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [self.navigationBar addSubview: self.backButton];
    
    NSView* title = self.titleField;
    
    NSDictionary* dict = NSDictionaryOfVariableBindings(_backButton, title);
    
    [self.navigationBar addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-10-[_backButton]-(>=10)-[title]" options: 0 metrics: nil views: dict]];
    
    [self.navigationBar addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-7-[_backButton]" options: 0 metrics: nil views: dict]];
  }
  
  viewControllers = [NSMutableArray new];
  
  if(rootViewController)
  {
    [self setViewControllers: [NSArray arrayWithObject: rootViewController]];
  }
  
  //*** Анимация navigationBarItem и navigationToolbar. ************************
  CATransition* fadeTransition = [CATransition animation];
  
  [fadeTransition setType: kCATransitionFade];
  
  [fadeTransition setDuration: TRANSITION_DURATION];
  
  NSDictionary* animations = [NSDictionary dictionaryWithObject: fadeTransition forKey: @"subviews"];
  
  [self.navigationBar setAnimations: animations];
  
  [self.navigationToolbarHost setAnimations: animations];
  
  //*** Анимация смены navigationView. *****************************************
  pushTransition = [[CATransition animation] retain];
  
  [pushTransition setType: kCATransitionPush];
  
  [pushTransition setDuration: TRANSITION_DURATION];
  
  
  navigationViewTransitionHost = [[NSView alloc] initWithFrame: NSZeroRect];
  
  [navigationViewTransitionHost setAnimations: [NSDictionary dictionaryWithObject: pushTransition forKey: @"subviews"]];
  
  [navigationViewTransitionHost setWantsLayer: YES];
  
  [navigationViewTransitionHost setIdentifier: @"navigationViewTransitionHost"];
  
  
  imageView1 = [[NSImageView alloc] initWithFrame: NSZeroRect];
  
  [imageView1 setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [imageView1 setWantsLayer: YES];
  
  [imageView1 setIdentifier: @"imageView1"];
  
  
  imageView2 = [[NSImageView alloc] initWithFrame: NSZeroRect];
  
  [imageView2 setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [imageView2 setWantsLayer: YES];
  
  [imageView2 setIdentifier: @"imageView2"];
  
  return self;
}

- (void) dealloc
{
  [viewControllers release], viewControllers = nil;
  
  [pushTransition release], pushTransition = nil;
  
  [navigationViewTransitionHost release], navigationViewTransitionHost = nil;
  
  [imageView1 release], imageView1 = nil;
  
  [imageView2 release], imageView2 = nil;
  
  [super dealloc];
}

/*!
 * Вставляет вид v на место основного вида навигационного контроллера.
 */
- (void) insertNavigationViewWithAppropriateConstraints: (NSView*) v
{
  [v setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [self.view addSubview: v];
  
  NSDictionary* views = NSDictionaryOfVariableBindings(_navigationBar, v, _navigationToolbarHost);
  
  [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[v]|" options: 0 metrics: nil views: views]];
  
  [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[_navigationBar][v][_navigationToolbarHost]" options: 0 metrics: nil views: views]];
  
  {
    //[v setNeedsLayout: YES];
    
    //[self.view setNeedsDisplayInRect: v.frame];
    
    //[v setNeedsDisplay: YES];
  }
}

// Вставляет переданный контроллер в иерархию видов.
- (void) insertNavViewController: (NavViewController*) newController
{
  if(!newController) return;
  
  if([self.delegate respondsToSelector: @selector(navigationController:willShowViewController:animated:)])
  {
    [self.delegate navigationController: self willShowViewController: newController animated: NO];
  }
  
  //*********************
  
  NSView* newNavigationBarItem = [newController navigationBarItem];
  
  if(newNavigationBarItem)
  {
    [self.navigationBar addSubview: newNavigationBarItem];
    
    [newNavigationBarItem setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    NSView* title = self.titleField;
    
    NSDictionary* views = NSDictionaryOfVariableBindings(title, newNavigationBarItem);
    
    [self.navigationBar addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:[title]-(>=10)-[newNavigationBarItem]-(10)-|" options: 0 metrics: nil views: views]];
    
    [self.navigationBar addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-4-[newNavigationBarItem]" options: 0 metrics: nil views: views]];
  }

  //****************************************************************************
  
  [self insertNavigationViewWithAppropriateConstraints: [newController view]];
  
  // ?
  [[self.windowController window] makeFirstResponder: newController.proposedFirstResponder];
  
  //****************************************************************************
  
  NSView* newNavigationToolbar = [newController navigationToolbar];
  
  [newNavigationToolbar setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  //[newNavigationToolbar setFrame: [self frameForNavigationToolbar]];
  
  [self.navigationToolbarHost addSubview: newNavigationToolbar];
  
  NSDictionary* views = NSDictionaryOfVariableBindings(newNavigationToolbar);
  
  [self.navigationToolbarHost addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[newNavigationToolbar]|" options: 0 metrics: nil views: views]];
  
  [self.navigationToolbarHost addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[newNavigationToolbar]|" options: 0 metrics: nil views: views]];
}

// Вынимает виды текущего NavViewController'а из видов NavigationController'а.
- (void) removeCurrentNavViewController
{
  NavViewController* currentController = [self topViewController];
  
  [[currentController navigationBarItem] removeFromSuperviewWithoutNeedingDisplay];
  
  [[currentController view] removeFromSuperviewWithoutNeedingDisplay];
  
  [[currentController navigationToolbar] removeFromSuperviewWithoutNeedingDisplay];
}

// Снимает текущий контроллер из окна и вставляет в него новый.
- (void) replaceCurrentNavViewControllerWith: (NavViewController*) newController animated: (BOOL) animated slideTo: (enum Side) side
{
  if(!newController) return;
  
  if([self.delegate respondsToSelector: @selector(navigationController:willShowViewController:animated:)])
  {
    [self.delegate navigationController: self willShowViewController: newController animated: animated];
  }
  
  //****************************************************************************
  
  NavViewController* oldController = [self topViewController];
  
  [oldController viewWillDisappear: animated];
  
  [newController viewWillAppear: animated];
  
  //*** NavigationBarItem ******************************************************
  
  NSView* oldNavigationBarItem = [oldController navigationBarItem];
  NSView* newNavigationBarItem = [newController navigationBarItem];
  
  if(oldNavigationBarItem && newNavigationBarItem)
  {
    // Если navigationBarItem была и будет.
    //[newNavigationBarItem setFrame: [self frameForNavigationBarItem: newNavigationBarItem]];
    
    [(animated? [self.navigationBar animator] : self.navigationBar) replaceSubview: oldNavigationBarItem with: newNavigationBarItem];
  }
  else if(oldNavigationBarItem && !newNavigationBarItem)
  {
    // Если navigationBarItem была, но не будет.
    [(animated? [oldNavigationBarItem animator] : oldNavigationBarItem) removeFromSuperview];
  }
  else if(!oldNavigationBarItem && newNavigationBarItem)
  {
    // Если navigationBarItem не было, но будет.
    //[newNavigationBarItem setFrame: [self frameForNavigationBarItem: newNavigationBarItem]];
    
    [(animated? [self.navigationBar animator] : self.navigationBar) addSubview: newNavigationBarItem];
  }
  
  if(newNavigationBarItem)
  {
    [newNavigationBarItem setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    NSView* title = self.titleField;
    
    NSDictionary* dict = NSDictionaryOfVariableBindings(title, newNavigationBarItem);
  
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:[title]-(>=10)-[newNavigationBarItem]-10-|" options: 0 metrics: nil views: dict]];
  
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-4-[newNavigationBarItem]" options: 0 metrics: nil views: dict]];
    
    //[self.windowController.window visualizeConstraints: [newNavigationBarItem constraints]];
  }
  
  //*** NavigationView *********************************************************
  
  NSView* oldNavigationView = [oldController view];
  NSView* newNavigationView = [newController view];
  
  if(animated)
  {
    [self animatedReplaceView: oldNavigationView with: newNavigationView slideTo: side hackyParam: newController hackyParam2: oldController];
  }
  else
  {
    [[self view] addSubview: newNavigationView];
    
    [newNavigationView setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    NSDictionary* dict = NSDictionaryOfVariableBindings(newNavigationView);
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[newNavigationView]|" options: 0 metrics: nil views: dict]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[newNavigationView]|" options: 0 metrics: nil views: dict]];
    
    [[[self windowController] window] makeFirstResponder: newController.proposedFirstResponder];
    
    if([self.delegate respondsToSelector: @selector(navigationController:didShowViewController:animated:)])
    {
      [self.delegate navigationController: self didShowViewController: newController animated: NO];
    }
    
    [oldController viewDidDisappear: animated];
    
    [newController viewDidAppear: animated];
  }
  
  //*** NavigationToolbar ******************************************************
  
  NSView* newNavigationToolbar = newController.navigationToolbar;
  
  //[newNavigationToolbar setFrame: [self frameForNavigationToolbar]];
  
  [(animated? [self.navigationToolbarHost animator] : self.navigationToolbarHost) replaceSubview: [oldController navigationToolbar] with: newNavigationToolbar];
  
  [newNavigationToolbar setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  NSDictionary* dict = NSDictionaryOfVariableBindings(newNavigationToolbar);
  
  [self.navigationToolbarHost addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[newNavigationToolbar]|" options: 0 metrics: nil views: dict]];
  
  [self.navigationToolbarHost addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[newNavigationToolbar]|" options: 0 metrics: nil views: dict]];
}

// Что будет, если во время анимации сдвига изменить размер окна?
- (void) animatedReplaceView: (NSView*) oldView with: (NSView*) newView slideTo: (enum Side) side hackyParam: (NavViewController*) newController hackyParam2: (NavViewController*) oldController
{
  // Сохраняем изображение текущего вида в картинку.
  imageView1.image = [oldView imageWithSubviews];
  
  //[[imageView1.image TIFFRepresentation] writeToFile: @"/Users/konstantin/Desktop/view1.tiff" atomically: YES];
  
  // Выкидываем текущий навигационный вид.
  [oldView removeFromSuperviewWithoutNeedingDisplay];
  
  // Добавляем временный вид для анимирования смены основных видов навигационных контроллеров.
  [self insertNavigationViewWithAppropriateConstraints: navigationViewTransitionHost];
  
  // Подцепляем вид с картинкой старого навигационного вида к временому хосту.
  [navigationViewTransitionHost addSubview: imageView1];
  
  // Растягиваем вид с картинкой на всю площадь хоста.
  {
    NSDictionary* dict = NSDictionaryOfVariableBindings(imageView1);
    
    [navigationViewTransitionHost addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[imageView1]|" options: 0 metrics: nil views: dict]];
    
    [navigationViewTransitionHost addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[imageView1]|" options: 0 metrics: nil views: dict]];
  }
  
  // Освежаем вид хоста.
  [navigationViewTransitionHost display], [imageView1 display];
  
  // Выравниваем фрейм нового навигационного вида со фреймом старого вида.
  newView.frame = NSMakeRect(0, 0, oldView.frame.size.width, oldView.frame.size.height);
  
  // Фотографируем новый вид.
  imageView2.image = [newView imageWithSubviews];
  
  // Выравниваем фрейм нового скриншота со фреймом сменяемого вида. Надо ли?
  
  // Изменяем направление сдвига в зависимости от параметра.
  [pushTransition setSubtype: (side == LeftSide) ? kCATransitionFromRight : kCATransitionFromLeft];
  
  NSWindowController* wndCtrlr = self.windowController;
  
  id del = self.delegate;
  
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* context)
  {
    //NSLog(@"navigationHost: %@", NSStringFromRect(navigationViewTransitionHost.frame));
    
    //NSLog(@"imageView1: %@", NSStringFromRect(imageView1.frame));
    
    //NSLog(@"imageView2: %@", NSStringFromRect(imageView2.frame));
    
    // Анимируем смену скриншотов.
    [[navigationViewTransitionHost animator] replaceSubview: imageView1 with: imageView2];
  }
  completionHandler: ^
  {
    [imageView2 removeFromSuperview];
    
    // Хост анимации сделал свое дело — убираем его из иерархии видов.
    [navigationViewTransitionHost removeFromSuperview];
    
    // Добавляем новый навигационный вид и растягиваем его на всю площадь с помощью constraints.
    [self insertNavigationViewWithAppropriateConstraints: newView];
    
    // Ставим фокус на нужный контрол.
    [[wndCtrlr window] makeFirstResponder: [self topViewController].proposedFirstResponder];
    
    if([del respondsToSelector: @selector(navigationController:didShowViewController:animated:)])
    {
      // Даем отмашку, что смена контроллеров была закончена.
      [del navigationController: self didShowViewController: (NavViewController*)newController animated: YES];
    }
    
    [oldController viewDidDisappear: YES];
    
    [newController viewDidAppear: YES];
    //NSLog(@"Push animation completion handler done.");
  }];
}

- (void) updatePathControl
{
  self.titleField.stringValue = [[viewControllers lastObject] navigationTitle];
  
  if([viewControllers count] > 1)
  {
    [self.backButton setHidden: NO];
    
    self.backButton.title = [NSString stringWithFormat: @"  %@", [[viewControllers objectAtIndex: [viewControllers count] - 2] navigationTitle]];
  }
  else
  {
    [self.backButton setHidden: YES];
  }
  
  return;
  
  NSMutableArray* steps = [NSMutableArray array];
  
  for(NavViewController* controller in viewControllers) [steps addObject: [controller navigationTitle]];
  
  //[pathControl setComponentsWithNames: steps];
}

/*
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
*/

- (NSRect) frameForNavigationView
{
  NSRect navigationViewFrame;
  
  CGFloat navigationToolbarHostHeight = [self.navigationToolbarHost frame].size.height;
  
  navigationViewFrame.origin.x = 0;
  
  navigationViewFrame.origin.y = navigationToolbarHostHeight;
  
  navigationViewFrame.size.width = [[self view] frame].size.width;
  
  navigationViewFrame.size.height = [self.navigationBar frame].origin.y - navigationToolbarHostHeight;
  
  return navigationViewFrame;
}

/*
- (NSRect) frameForNavigationToolbar
{
  NSRect navigationToolbarFrame;
  
  navigationToolbarFrame.origin = NSZeroPoint;
  
  navigationToolbarFrame.size = [navigationToolbarHost frame].size;
  
  return navigationToolbarFrame;
}
*/

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

- (IBAction) backButtonPressed:(id)sender
{
  [self popViewControllerAnimated: YES];
}

@end
