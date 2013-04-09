
#import "KPNavigationController.h"

#import "KPNavigationControllerDelegate.h"

#import "KPNavViewController.h"

#import <QuartzCore/CoreAnimation.h>

#import <KPFoundation/NSObject+IfResponds.h>

#import "KPBackButton.h"

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
  
  NSImage* image = [[NSImage alloc] initWithSize: imgSize];
  
  [image addRepresentation: bir];
  
  return image;
}

@end

#pragma mark -

enum Side { Backwards, RightSide };

@interface KPNavigationController ()

@property(readwrite, retain) IBOutlet NSView* navigationBar;

@property(readwrite, retain) IBOutlet KPBackButton* backButton;

@property(readwrite, retain) IBOutlet NSTextField* titleField;

@property(readwrite, retain) IBOutlet NSView* navigationToolbarHost;

@end

@implementation KPNavigationController
{
  NSMutableArray* viewControllers;
  
  CATransition* pushTransition;
  
  NSView* navigationViewTransitionHost;
  
  NSImageView* imageView1;
  
  NSImageView* imageView2;
  
  NSButton* _backButtonOld, *_backButtonNew;
}

@synthesize viewControllers;

//#define TRANSITION_DURATION 0.25
#define TRANSITION_DURATION (1.0 / 3.0) * 1.0

- (id) initWithRootViewController: (KPNavViewController*) rootViewController
{
  self = [self initWithNibName: @"KPNavigationController" bundle: nil];
  
  if(!self) return nil;
  
  [self loadView];
  
  viewControllers = [NSMutableArray new];
  
  if(rootViewController)
  {
    [self setViewControllers: @[rootViewController]];
  }
  
  //*** Анимация navigationBarItem и navigationToolbar. ************************
  CATransition* fadeTransition = [CATransition animation];
  
  [fadeTransition setType: kCATransitionFade];
  
  [fadeTransition setDuration: TRANSITION_DURATION];
  
  NSDictionary* animations = [NSDictionary dictionaryWithObject: fadeTransition forKey: @"subviews"];
  
  [self.navigationBar setAnimations: animations];
  
  [self.navigationToolbarHost setAnimations: animations];
  
  //*** Анимация смены navigationView. *****************************************
  pushTransition = [CATransition animation];
  
  [pushTransition setType: kCATransitionPush];
  
  [pushTransition setDuration: TRANSITION_DURATION];
  
  [pushTransition setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
  
  
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
}

- (NSButton*) newBackButtonWithTitle: (NSString*) string
{
  NSButton* b = [[KPBackButton alloc] initWithFrame: NSZeroRect];

  //[b setButtonType: NSTexturedRoundedBezelStyle];
  
  [b setBezelStyle: NSTexturedRoundedBezelStyle];
  
  if(!string) string = NSLocalizedString(@"Back", nil);
  
  [b setTitle: string];
  
  [b setAction: @selector(backButtonPressed:)];
  
  return b;
}

- (NSArray*) constraintsForVerticalFixationOfNavigationBarView: (NSView*) view
{
  NSLayoutConstraint* c1 = [NSLayoutConstraint constraintWithItem: view
                                                        attribute: NSLayoutAttributeCenterY
                                                        relatedBy: NSLayoutRelationEqual
                                                           toItem: self.navigationBar
                                                        attribute: NSLayoutAttributeCenterY
                                                       multiplier: 1
                                                         constant: 0];
  
  // TODO: сделать тут растягивание навигационной плашки если суют слишком толстые кнопки.
  
  //NSLayoutConstraint* c2 = [NSLayoutConstraint constraintWithItem: view attribute: NSLayoutAttributeTop relatedBy: NSLayoutRelationLessThanOrEqual toItem: self.navigationBar attribute: NSLayoutAttributeTop multiplier: 1 constant: -20];
  
  //NSLayoutConstraint* c3 = [NSLayoutConstraint constraintWithItem: view attribute: NSLayoutAttributeBottom relatedBy: NSLayoutRelationGreaterThanOrEqual toItem: self.navigationBar attribute: NSLayoutAttributeBottom multiplier: 1 constant: 2];
  
  return @[c1];//, c2, c3];
}

#pragma mark - Back Button & Left View

#define STANDART_SPACE 8.0

- (NSArray*) constraintsForBackView: (NSView*) backView andLeftView: (NSView*) leftView complementaryPositionSide: (enum Side) side
{
  NSMutableArray* allConstraints = [NSMutableArray new];
  
  NSDictionary* views = NSDictionaryOfVariableBindings(_navigationBar, backView, leftView);
  
  NSLayoutConstraint* c1 = [NSLayoutConstraint constraintWithItem: backView attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem: self.navigationBar attribute: NSLayoutAttributeLeading multiplier: 1 constant: STANDART_SPACE];
  
  c1.constant += ((side == Backwards)? -1 : 1) * self.navigationBar.bounds.size.width / 3.0;
  
  [allConstraints addObject: c1];
  
  NSArray* c2 = [NSLayoutConstraint constraintsWithVisualFormat: @"[backView]-[leftView]" options: 0 metrics: nil views: views];
  
  [allConstraints addObjectsFromArray: c2];
  
  // Вертикальная компонента.
  [allConstraints addObjectsFromArray: [self constraintsForVerticalFixationOfNavigationBarView: backView]];
  
  [allConstraints addObjectsFromArray: [self constraintsForVerticalFixationOfNavigationBarView: leftView]];
  
  return allConstraints;
}

- (NSArray*) constraintsForBackView: (NSView*) backView andLeftView: (NSView*) leftView utilizingCenterView: (NSView*) centerView flag: (BOOL) flag;
{
  NSMutableArray* allConstraints = [NSMutableArray new];
  
  // Фиксация левой стороны.
  NSLayoutConstraint* c1 = [NSLayoutConstraint constraintWithItem: backView attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem: self.navigationBar attribute: NSLayoutAttributeLeading multiplier: 1 constant: STANDART_SPACE];
  
  [allConstraints addObject: c1];
  
  // Фиксация правой стороны.
  NSDictionary* views = NSDictionaryOfVariableBindings(backView, leftView, centerView);
  
  if(flag)
  {
    NSArray* c2 = [NSLayoutConstraint constraintsWithVisualFormat: @"[leftView]-(>=20)-[centerView]" options: 0 metrics: nil views: views];
    
    [allConstraints addObjectsFromArray: c2];
  }
  
  // Фиксация видов между собой.
  NSArray* c3 = [NSLayoutConstraint constraintsWithVisualFormat: @"[backView]-[leftView]" options: 0 metrics: nil views: views];
  
  [allConstraints addObjectsFromArray: c3];
  
  // Вертикальная компонента.
  [allConstraints addObjectsFromArray: [self constraintsForVerticalFixationOfNavigationBarView: backView]];
  
  [allConstraints addObjectsFromArray: [self constraintsForVerticalFixationOfNavigationBarView: leftView]];
  
  return allConstraints;
}

- (void) removeBackView: (NSView*) backView leftView: (NSView*) leftView utilizingCenterView: (NSView*) centerView slideTo: (enum Side) side animated: (BOOL) animated
{
  // Мы не можем вычленить нужные constraints, поэтмоу проще выкинуть вид совсем и добавить его снова с известными константами.
  [backView removeFromSuperviewWithoutNeedingDisplay], [leftView removeFromSuperviewWithoutNeedingDisplay];
  
  [backView setTranslatesAutoresizingMaskIntoConstraints: NO], [leftView setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [self.navigationBar addSubview: backView], [self.navigationBar addSubview: leftView];
  
  // Начальное условие.
  NSArray* constraints = [self constraintsForBackView: backView andLeftView: leftView utilizingCenterView: centerView flag: NO];
  
  [self.navigationBar addConstraints: constraints];
  
  // тут надо какой-то перерасчет.
  [self.navigationBar layoutSubtreeIfNeeded];
  
  // выкидываем временную константу.
  [self.navigationBar removeConstraints: constraints];
  
  // Окончательное условие.
  NSArray* complementaryConstraints = [self constraintsForBackView: backView andLeftView: leftView complementaryPositionSide: (side == Backwards)? Backwards : RightSide];
  
  [self.navigationBar addConstraints: complementaryConstraints];
  
  // Сама анимация.
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
   {
     [context setDuration: animated? TRANSITION_DURATION : 0];
     
     [context setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
     
     [context setAllowsImplicitAnimation: YES];
     
     [self.navigationBar layoutSubtreeIfNeeded];
     
     [backView setAlphaValue: 0.0], [leftView setAlphaValue: 0.0];
   }
    completionHandler: ^
   {
     [backView removeFromSuperviewWithoutNeedingDisplay], [leftView removeFromSuperviewWithoutNeedingDisplay];
   }];
}

- (void) addBackView: (NSView*) backView leftView: (NSView*) leftView utilizingCenterView: (NSView*) centerView slideTo: (enum Side) side animated: (BOOL) animated
{
  [backView setTranslatesAutoresizingMaskIntoConstraints: NO], [leftView setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [self.navigationBar addSubview: backView], [self.navigationBar addSubview: leftView];
  
  // Начальное условие.
  [backView setAlphaValue: 0.0], [leftView setAlphaValue: 0.0];
  
  NSArray* complementaryConstraints = [self constraintsForBackView: backView andLeftView: leftView complementaryPositionSide: side == Backwards? RightSide : Backwards];
  
  [self.navigationBar addConstraints: complementaryConstraints];
  
  // тут надо какой-то перерасчет.
  [self.navigationBar layoutSubtreeIfNeeded];
  
  // выкидываем временную константу.
  [self.navigationBar removeConstraints: complementaryConstraints];
  
  // Окончательное условие.
  [self.navigationBar addConstraints: [self constraintsForBackView: backView andLeftView: leftView utilizingCenterView: centerView flag: YES]];
  
  // Сама анимация.
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
   {
     [context setDuration: animated? TRANSITION_DURATION : 0];
     
     [context setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
     
     [context setAllowsImplicitAnimation: YES];
     
     [self.navigationBar layoutSubtreeIfNeeded];
     
     [backView setAlphaValue: 1.0], [leftView setAlphaValue: 1.0];
   }
   completionHandler: ^
   {
     
   }];
}

#pragma mark - Center View

- (NSArray*) constraintsForCenterView: (NSView*) centerView complementaryPositionSide: (enum Side) side
{
  NSMutableArray* allConstraints = [NSMutableArray new];
  
  NSDictionary* views = NSDictionaryOfVariableBindings(_navigationBar, centerView);
  
  NSString* format = (side == Backwards)? @"[centerView][_navigationBar]" : @"[_navigationBar][centerView]";
  
  NSArray* c1 = [NSLayoutConstraint constraintsWithVisualFormat: format options: 0 metrics: nil views: views];
  
  [allConstraints addObjectsFromArray: c1];
  
  [allConstraints addObjectsFromArray: [self constraintsForVerticalFixationOfNavigationBarView: centerView]];
  
  return allConstraints;
}

- (NSArray*) constraintsForCenterView: (NSView*) centerView
{
  NSMutableArray* allConstraints = [NSMutableArray new];
  
  NSLayoutConstraint* c1 = [NSLayoutConstraint constraintWithItem: centerView attribute: NSLayoutAttributeCenterX relatedBy: NSLayoutRelationEqual toItem: self.navigationBar attribute: NSLayoutAttributeCenterX multiplier: 1 constant: 0];
  
  [allConstraints addObject: c1];
  
  [allConstraints addObjectsFromArray: [self constraintsForVerticalFixationOfNavigationBarView: centerView]];
  
  return allConstraints;
}

- (void) removeView: (NSView*) centerView fromCenterNavigationBarViewSlideTo: (enum Side) side animated: (BOOL) animated
{
  // Мы не можем вычленить нужные constraints, поэтмоу проще выкинуть вид совсем и добавить его снова с известными константами.
  [centerView removeFromSuperviewWithoutNeedingDisplay];
  
  [centerView setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [self.navigationBar addSubview: centerView];
  
  // Начальное условие.
  NSArray* constraints = [self constraintsForCenterView: centerView];
  
  [self.navigationBar addConstraints: constraints];
  
  // тут надо какой-то перерасчет.
  [self.navigationBar layoutSubtreeIfNeeded];
  
  // выкидываем временную константу.
  [self.navigationBar removeConstraints: constraints];
  
  // Окончательное условие.
  NSArray* complementaryConstraints = [self constraintsForCenterView: centerView complementaryPositionSide: (side == Backwards)? Backwards : RightSide];
  
  [self.navigationBar addConstraints: complementaryConstraints];
  
  // Сама анимация.
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
   {
     [context setDuration: animated? TRANSITION_DURATION : 0];
     
     [context setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
     
     [context setAllowsImplicitAnimation: YES];
     
     [self.navigationBar layoutSubtreeIfNeeded];
     
     [centerView setAlphaValue: 0.0];
   }
    completionHandler: ^
   {
     [centerView removeFromSuperviewWithoutNeedingDisplay];
   }];
}

- (void) addView: (NSView*) centerView toCenterNavigationBarViewSlideTo: (enum Side) side animated: (BOOL) animated
{
  [centerView setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [self.navigationBar addSubview: centerView];
  
  // Начальное условие.
  [centerView setAlphaValue: 0.0];
  
  NSArray* complementaryConstraints = [self constraintsForCenterView: centerView complementaryPositionSide: (side == Backwards)? RightSide : Backwards];
  
  [self.navigationBar addConstraints: complementaryConstraints];
  
  // тут надо какой-то перерасчет.
  [self.navigationBar layoutSubtreeIfNeeded];
  
  // выкидываем временную константу.
  [self.navigationBar removeConstraints: complementaryConstraints];
  
  // Окончательное условие.
  [self.navigationBar addConstraints: [self constraintsForCenterView: centerView]];
  
  // Сама анимация.
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
   {
     [context setDuration: animated? TRANSITION_DURATION : 0];
     
     [context setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
     
     [context setAllowsImplicitAnimation: YES];
     
     [self.navigationBar layoutSubtreeIfNeeded];
     
     [centerView setAlphaValue: 1.0];
   }
   completionHandler: ^
   {
     
   }];
}

#pragma mark - Right View

- (NSArray*) constraintsForRightView: (NSView*) rightView utilizingCenterView: (NSView*) centerView flag: (BOOL) flag
{
  NSMutableArray* allConstraints = [NSMutableArray new];
  
  // Фиксация левой стороны.
  NSLayoutConstraint* c1 = [NSLayoutConstraint constraintWithItem: rightView attribute: NSLayoutAttributeTrailing relatedBy: NSLayoutRelationEqual toItem: self.navigationBar attribute: NSLayoutAttributeTrailing multiplier: 1 constant: -STANDART_SPACE];
  
  [allConstraints addObject: c1];
  
  // Фиксация правой стороны.
  NSDictionary* views = NSDictionaryOfVariableBindings(centerView, rightView);
  
  if(flag)
  {
    NSArray* c2 = [NSLayoutConstraint constraintsWithVisualFormat: @"[centerView]-(>=20)-[rightView]" options: 0 metrics: nil views: views];
    
    [allConstraints addObjectsFromArray: c2];
  }
  
  // Вертикальная компонента.
  [allConstraints addObjectsFromArray: [self constraintsForVerticalFixationOfNavigationBarView: rightView]];
  
  return allConstraints;
}

- (void) removeView: (NSView*) rightView fromRightNavigationBarViewUtilizingCenterView: (NSView*) centerView animated: (BOOL) animated
{
  // Мы не можем вычленить нужные constraints, поэтмоу проще выкинуть вид совсем и добавить его снова с известными константами.
  [rightView removeFromSuperviewWithoutNeedingDisplay];
  
  [rightView setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [self.navigationBar addSubview: rightView];
  
  // Начальное условие.
  NSArray* constraints = [self constraintsForRightView: rightView utilizingCenterView: centerView flag: NO];
  
  [self.navigationBar addConstraints: constraints];
  
  // тут надо какой-то перерасчет.
  [self.navigationBar layoutSubtreeIfNeeded];
  
  // выкидываем временную константу.
  //[self.navigationBar removeConstraints: constraints];
  
  // Сама анимация.
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
   {
     [context setDuration: animated? TRANSITION_DURATION : 0];
     
     [context setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear]];
     
     [context setAllowsImplicitAnimation: YES];
     
     [rightView setAlphaValue: 0.0];
   }
   completionHandler: ^
   {
     [rightView removeFromSuperviewWithoutNeedingDisplay];
   }];
}

- (void) addView: (NSView*) rightView toRightNavigationBarViewUtilizingCenterView: (NSView*) centerView animated: (BOOL) animated
{
  [rightView setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [self.navigationBar addSubview: rightView];
  
  // Окончательное условие.
  [rightView setAlphaValue: 0.0];
  
  NSArray* constraints = [self constraintsForRightView: rightView utilizingCenterView: centerView flag: YES];
  
  [self.navigationBar addConstraints: constraints];
  
  // тут надо какой-то перерасчет.
  [self.navigationBar layoutSubtreeIfNeeded];
  
  // Сама анимация.
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
   {
     [context setDuration: animated? TRANSITION_DURATION : 0];
     
     [context setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear]];
     
     [context setAllowsImplicitAnimation: YES];
     
     [rightView setAlphaValue: 1.0];
   }
  completionHandler: ^
   {
     
   }];
}

#pragma mark Ядровой метод

// Снимает текущий контроллер из окна и вставляет в него новый.
- (void) replaceNavViewController: (KPNavViewController*) oldControllerOrNil with: (KPNavViewController*) newControllerOrNil animated: (BOOL) animated slideTo: (enum Side) side
{
  [newControllerOrNil view];
  
  if(newControllerOrNil)
  {
    [[self.delegate ifResponds] navigationController: self willShowViewController: newControllerOrNil animated: animated];
  }
  
  //****************************************************************************
  
  //KPNavViewController* oldControllerOrNil = [self topViewController];
  
  [oldControllerOrNil viewWillDisappear: animated];
  
  [newControllerOrNil viewWillAppear: animated];
  
  //*** Center Navigation Bar View ******************************************************
  
  if(oldControllerOrNil)
  {
    [self removeView: oldControllerOrNil.centerNavigationBarView fromCenterNavigationBarViewSlideTo: side animated: animated];
  }
  
  if(newControllerOrNil)
  {
    [self addView: newControllerOrNil.centerNavigationBarView toCenterNavigationBarViewSlideTo: side animated: animated];
  }
  
  //*** Back Navigation Bar button & Left Navigation Bar View ******************************************************
  
  if(oldControllerOrNil)
  {
    _backButtonOld = _backButtonNew;
    
    [self removeBackView: _backButtonOld leftView: oldControllerOrNil.leftNavigationBarView utilizingCenterView: oldControllerOrNil.centerNavigationBarView slideTo: side animated: animated];
  }
  
  if(newControllerOrNil)
  {
    if([self.viewControllers count] > 1)
    {
      _backButtonNew = [self newBackButtonWithTitle: [self.viewControllers[[self.viewControllers count] - 2] navigationTitle]];
    }
    else
    {
      _backButtonNew = [[NSButton alloc] initWithFrame: NSZeroRect];
      
      NSDictionary* views = NSDictionaryOfVariableBindings(_backButtonNew);
      
      [_backButtonNew addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:[_backButtonNew(0)]" options: 0 metrics: nil views: views]];
    }
    
    [_backButtonNew setTarget: self];
    
    [self addBackView: _backButtonNew leftView: newControllerOrNil.leftNavigationBarView utilizingCenterView: newControllerOrNil.centerNavigationBarView slideTo: side animated:animated];
  }
  
  //*** Right Navigation Bar View ******************************************************
  
  if(oldControllerOrNil)
  {
    [self removeView: oldControllerOrNil.rightNavigationBarView fromRightNavigationBarViewUtilizingCenterView: oldControllerOrNil.centerNavigationBarView animated: animated];
  }
  
  if(newControllerOrNil)
  {
    [self addView: newControllerOrNil.rightNavigationBarView toRightNavigationBarViewUtilizingCenterView: newControllerOrNil.centerNavigationBarView animated: animated];
  }
  
  //*** NavigationView *********************************************************
  
  NSView* oldNavigationView = [oldControllerOrNil view];
  NSView* newNavigationView = [newControllerOrNil view];
  
  if(animated && oldNavigationView && newNavigationView)
  {
    [self animatedReplaceView: oldNavigationView with: newNavigationView slideTo: side hackyParam: newControllerOrNil hackyParam2: oldControllerOrNil];
  }
  else
  {
    [oldNavigationView removeFromSuperview];
    
    if(newNavigationView)
    {
      [self insertNavigationViewWithAppropriateConstraints: newNavigationView];
    }
    
    [[[self windowController] window] makeFirstResponder: newControllerOrNil.proposedFirstResponder];
    
    if([self.delegate respondsToSelector: @selector(navigationController:didShowViewController:animated:)] && newControllerOrNil)
    {
      [self.delegate navigationController: self didShowViewController: newControllerOrNil animated: NO];
    }
    
    [oldControllerOrNil viewDidDisappear: animated];
    
    [newControllerOrNil viewDidAppear: animated];
  }
  
  //*** NavigationToolbar ******************************************************

  NSView* newNavigationToolbar = newControllerOrNil.navigationToolbar;
  
  if(newNavigationToolbar)
  {
    [(animated? [self.navigationToolbarHost animator] : self.navigationToolbarHost) replaceSubview: [oldControllerOrNil navigationToolbar] with: newNavigationToolbar];
    
    if(![oldControllerOrNil navigationToolbar]) [self.navigationToolbarHost addSubview: newNavigationToolbar];
    
    [newNavigationToolbar setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    NSDictionary* dict = NSDictionaryOfVariableBindings(newNavigationToolbar);
    
    [self.navigationToolbarHost addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[newNavigationToolbar]|" options: 0 metrics: nil views: dict]];
    
    [self.navigationToolbarHost addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[newNavigationToolbar]|" options: 0 metrics: nil views: dict]];
  }
}

#pragma mark Замена основного вида

// Что будет, если во время анимации сдвига изменить размер окна?
- (void) animatedReplaceView: (NSView*) oldView with: (NSView*) newView slideTo: (enum Side) side hackyParam: (KPNavViewController*) newController hackyParam2: (KPNavViewController*) oldController
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
  [pushTransition setSubtype: (side == Backwards) ? kCATransitionFromRight : kCATransitionFromLeft];
  
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
      [del navigationController: self didShowViewController: (KPNavViewController*)newController animated: YES];
    }
    
    [oldController viewDidDisappear: YES];
    
    [newController viewDidAppear: YES];
    //NSLog(@"Push animation completion handler done.");
  }];
}

#pragma mark Пользовательские функции

- (KPNavViewController*) topViewController
{
  return [viewControllers lastObject];
}

- (void) setViewControllers: (NSArray*) newViewControllers
{
  NSParameterAssert(newViewControllers);
  
  KPNavViewController* current = [self topViewController];
  
  [viewControllers removeAllObjects];
  
  [viewControllers addObjectsFromArray: newViewControllers];
  
  [viewControllers makeObjectsPerformSelector: @selector(setNavigationController:) withObject: self];
  
  [self replaceNavViewController: current with: [newViewControllers lastObject] animated: NO slideTo: Backwards];
}

- (void) pushViewController: (KPNavViewController*) viewController animated: (BOOL) animated
{
  NSParameterAssert(viewController);
  
  KPNavViewController* current = [self topViewController];
  
  [viewControllers addObject: viewController];
  
  [viewController setNavigationController: self];
  
  [self replaceNavViewController: current with: viewController animated: animated slideTo: Backwards];
}

- (KPNavViewController*) popViewControllerAnimated: (BOOL) animated
{
  NSInteger controllerCount = [viewControllers count];
  
  // Если на стеке только корневой контроллер - ничего не делаем.
  if(controllerCount < 2) return nil;
  
  NSArray* poppedControllers = [self popToViewController: [viewControllers objectAtIndex: controllerCount - 2] animated: animated];
  
  return [poppedControllers lastObject];
}

- (NSArray*) popToRootViewControllerAnimated: (BOOL) animated
{
  // Если на стеке только корневой контроллер - ничего не делаем.
  if([viewControllers count] < 2) return nil;
  
  return [self popToViewController: [viewControllers objectAtIndex: 0] animated: animated];
}

- (NSArray*) popToViewController: (KPNavViewController*) viewController animated: (BOOL) animated
{
  // Если нам передали чушь или такого контроллера вообще нету на стеке...
  NSParameterAssert(viewController || [viewControllers containsObject: viewController]);
  
  KPNavViewController* current = [self topViewController];
  
  NSUInteger indexOfViewController = [viewControllers indexOfObject: viewController];
  
  // Сохраняем катапультированные контроллеры.
  NSRange ejectedRange = NSMakeRange(indexOfViewController + 1, [viewControllers count] - indexOfViewController - 1);
  
  NSArray* ejectedControllers = [viewControllers subarrayWithRange: ejectedRange];
  
  [viewControllers removeObjectsInRange: ejectedRange];
  
  [self replaceNavViewController: current with: viewController animated: animated slideTo: RightSide];
  
  return ejectedControllers;
}

- (IBAction) backButtonPressed: (id) sender
{
  [self popViewControllerAnimated: YES];
}

@end
