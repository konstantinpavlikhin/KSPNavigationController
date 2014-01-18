#import "KPNavigationController+Private.h"

#import "KPNavigationControllerDelegate.h"

#import "KPNavViewController.h"

#import "HitTestView.h"

#import "NavigationView.h"

#import "KPBackButton.h"

#import "NSView+Screenshot.h"

#import <KPToolbox/NSObject+IfResponds.h>

#import <QuartzCore/CoreAnimation.h>

typedef NS_ENUM(NSUInteger, Side) { Backward, Forward };

#define RESIZE_DURATION (1.0 / 5.0)

#define TRANSITION_DURATION (1.0 / 3.0)

#define STANDART_SPACE 8.0

#define INVERT_SIDE(x) ((x == Backward)? Forward : Backward)

@implementation KPNavigationController
{
  NSMutableArray* _viewControllers;
}

+ (NSString*) nibFilename
{
  return @"KPNavigationController";
}

- (id) initWithRootViewController: (KPNavViewController*) rootViewController
{
  self = [self initWithNibName: [[self class] nibFilename] bundle: nil];
  
  if(!self) return nil;
  
  _viewControllers = [NSMutableArray new];
  
  if(rootViewController) [self setViewControllers: @[rootViewController] animated: NO];
  
  return self;
}

- (void) awakeFromNib
{
  [[self.navigationView.mainViewTransitionHost layer] setOpaque: YES];
  
  self.navigationViewPrototype = [NSKeyedUnarchiver unarchiveObjectWithData: [NSKeyedArchiver archivedDataWithRootObject: self.navigationView]];
  
  // * * *.
  
  CATransition* fadeTransition = [CATransition animation];
  
  [fadeTransition setType: kCATransitionFade];
  
  [fadeTransition setDuration: TRANSITION_DURATION];
  
  NSDictionary* animations = [NSDictionary dictionaryWithObject: fadeTransition forKey: @"subviews"];
  
  [self.navigationBar setAnimations: animations];
  
  [self.navigationToolbarHost setAnimations: animations];
}

- (NSButton*) newBackButtonWithTitle: (NSString*) string
{
  NSButton* b = [[KPBackButton alloc] initWithFrame: NSZeroRect];
  
  [b setBezelStyle: NSTexturedRoundedBezelStyle];
  
  if(!string) string = NSLocalizedStringFromTable(@"Back", @"KPNavigationViewController", nil);
  
  [b setTitle: string];
  
  [b setAction: @selector(backButtonPressed:)];
  
  return b;
}

- (IBAction) backButtonPressed: (id) sender
{
  [self popViewControllerAnimated: YES];
}

+ (NSArray*) constraintsForVerticalFixationOfView: (NSView*) view inNavigationBar: (NSView*) navigationBar
{
  NSLayoutConstraint* c1 = [NSLayoutConstraint constraintWithItem: view attribute: NSLayoutAttributeCenterY relatedBy: NSLayoutRelationEqual toItem: navigationBar attribute: NSLayoutAttributeCenterY multiplier: 1.0 constant: 0.0];
  
  // TODO: сделать тут растягивание навигационной плашки если суют слишком толстые кнопки.
  
  return @[c1];
}

#pragma mark - Back button & left view

// Константы для позиции вывода с экрана.
+ (NSArray*) constraintsForBackView: (NSView*) backView andLeftView: (NSView*) leftView inNavigationBar: (NSView*) navigationBar complementaryPositionSide: (Side) side
{
  NSMutableArray* allConstraints = [NSMutableArray new];
  
  // * * *.
  
  NSLayoutConstraint* c1 = [NSLayoutConstraint constraintWithItem: backView attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem: navigationBar attribute: NSLayoutAttributeLeading multiplier: 1.0 constant: STANDART_SPACE];
  
  c1.constant += ((side == Backward)? -1.0 : 1.0) * (navigationBar.bounds.size.width / 3.0);
  
  [allConstraints addObject: c1];
  
  // * * *.
  
  NSDictionary* views = NSDictionaryOfVariableBindings(backView, leftView);
  
  NSArray* c2 = [NSLayoutConstraint constraintsWithVisualFormat: @"[backView]-[leftView]" options: 0 metrics: nil views: views];
  
  [allConstraints addObjectsFromArray: c2];
  
  // * * *.
  
  [allConstraints addObjectsFromArray: [[self class] constraintsForVerticalFixationOfView: backView inNavigationBar: navigationBar]];
  
  [allConstraints addObjectsFromArray: [[self class] constraintsForVerticalFixationOfView: leftView inNavigationBar: navigationBar]];
  
  return allConstraints;
}

// Константы для рабочей позиции вида.
+ (NSArray*) constraintsForBackView: (NSView*) backView andLeftView: (NSView*) leftView utilizingCenterView: (NSView*) centerView inNavigationBar: (NSView*) navigationBar
{
  NSMutableArray* allConstraints = [NSMutableArray new];
  
  // Фиксация левой стороны.
  NSLayoutConstraint* c1 = [NSLayoutConstraint constraintWithItem: backView attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem: navigationBar attribute: NSLayoutAttributeLeading multiplier: 1.0 constant: STANDART_SPACE];
  
  [allConstraints addObject: c1];
  
  // Фиксация видов между собой.
  NSDictionary* views = NSDictionaryOfVariableBindings(backView, leftView);
  
  NSArray* c2 = [NSLayoutConstraint constraintsWithVisualFormat: @"[backView]-[leftView]" options: 0 metrics: nil views: views];
  
  [allConstraints addObjectsFromArray: c2];
  
  // Фиксация правой стороны.
  if(centerView)
  {
    NSDictionary* views = NSDictionaryOfVariableBindings(leftView, centerView);
    
    NSArray* c3 = [NSLayoutConstraint constraintsWithVisualFormat: @"[leftView]-(>=20)-[centerView]" options: 0 metrics: nil views: views];
    
    [allConstraints addObjectsFromArray: c3];
  }
  
  // Вертикальная компонента.
  [allConstraints addObjectsFromArray: [[self class] constraintsForVerticalFixationOfView: backView inNavigationBar: navigationBar]];
  
  [allConstraints addObjectsFromArray: [[self class] constraintsForVerticalFixationOfView: leftView inNavigationBar: navigationBar]];
  
  return allConstraints;
}

+ (void) removeBackView: (NSView*) backView andLeftView: (NSView*) leftView fromNavigationBar: (NSView*) navigationBar slideTo: (Side) side animated: (BOOL) animated
{
  // Мы не можем вычленить нужные константы, поэтому проще выкинуть вид совсем и добавить его снова с известными константами.
  [@[backView, leftView] enumerateObjectsUsingBlock: ^(NSView* view, NSUInteger idx, BOOL* stop)
  {
    [view removeFromSuperviewWithoutNeedingDisplay];
    
    [view setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [navigationBar addSubview: view];
  }];
  
  // Начальное условие.
  NSArray* startConstraints = [[self class] constraintsForBackView: backView andLeftView: leftView utilizingCenterView: nil inNavigationBar: navigationBar];
  
  [navigationBar addConstraints: startConstraints];
  
  // Тут надо какой-то перерасчет.
  [navigationBar layoutSubtreeIfNeeded];
  
  // Выкидываем временную константу.
  [navigationBar removeConstraints: startConstraints];
  
  // Окончательное условие.
  NSArray* finishConstraints = [[self class] constraintsForBackView: backView andLeftView: leftView inNavigationBar: navigationBar complementaryPositionSide: side];
  
  [navigationBar addConstraints: finishConstraints];
  
  // Сама анимация.
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* context)
  {
    [context setAllowsImplicitAnimation: YES];
    
    [navigationBar layoutSubtreeIfNeeded];
    
    [@[backView, leftView] enumerateObjectsUsingBlock: ^(NSView* view, NSUInteger idx, BOOL* stop)
    {
      [view setAlphaValue: 0.0];
    }];
  }
  completionHandler: ^
  {
    [@[backView, leftView] enumerateObjectsUsingBlock: ^(NSView* view, NSUInteger idx, BOOL* stop)
    {
      [view removeFromSuperviewWithoutNeedingDisplay];
    }];
  }];
}

+ (void) insertBackView: (NSView*) backView andLeftView: (NSView*) leftView utilizingCenterView: (NSView*) centerView inNavigationBar: (NSView*) navigationBar slideTo: (Side) side animated: (BOOL) animated
{
  [@[backView, leftView] enumerateObjectsUsingBlock: ^(NSView* view, NSUInteger idx, BOOL* stop)
  {
    [view setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [navigationBar addSubview: view];
    
    [view setAlphaValue: 0.0];
  }];
  
  // Начальное условие.
  NSArray* startConstraints = [[self class] constraintsForBackView: backView andLeftView: leftView inNavigationBar: navigationBar complementaryPositionSide: INVERT_SIDE(side)];
  
  [navigationBar addConstraints: startConstraints];
  
  // Тут надо какой-то перерасчет.
  [navigationBar layoutSubtreeIfNeeded];
  
  // Выкидываем временную константу.
  [navigationBar removeConstraints: startConstraints];
  
  // Окончательное условие.
  NSArray* finishConstraints = [self constraintsForBackView: backView andLeftView: leftView utilizingCenterView: centerView inNavigationBar: navigationBar];
  
  [navigationBar addConstraints: finishConstraints];
  
  // Сама анимация.
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* context)
  {
    [context setAllowsImplicitAnimation: YES];
    
    [navigationBar layoutSubtreeIfNeeded];
    
    [@[backView, leftView] enumerateObjectsUsingBlock: ^(NSView* view, NSUInteger idx, BOOL* stop)
    {
      [view setAlphaValue: 1.0];
    }];
  }
  completionHandler: ^
  {
  }];
}

#pragma mark - Center view

// Константы для позиции вывода с экрана.
+ (NSArray*) constraintsForCenterView: (NSView*) centerView inNavigationBar: (NSView*) navigationBar complementaryPositionSide: (Side) side
{
  NSMutableArray* allConstraints = [NSMutableArray new];
  
  NSDictionary* views = NSDictionaryOfVariableBindings(navigationBar, centerView);
  
  NSString* format = (side == Backward)? @"[centerView][navigationBar]" : @"[navigationBar][centerView]";
  
  NSArray* c1 = [NSLayoutConstraint constraintsWithVisualFormat: format options: 0 metrics: nil views: views];
  
  [allConstraints addObjectsFromArray: c1];
  
  [allConstraints addObjectsFromArray: [[self class] constraintsForVerticalFixationOfView: centerView inNavigationBar: navigationBar]];
  
  return allConstraints;
}

// Константы для рабочей позиции вида.
+ (NSArray*) constraintsForCenterView: (NSView*) centerView inNavigationBar: (NSView*) navigationBar
{
  NSMutableArray* allConstraints = [NSMutableArray new];
  
  NSLayoutConstraint* c1 = [NSLayoutConstraint constraintWithItem: centerView attribute: NSLayoutAttributeCenterX relatedBy: NSLayoutRelationEqual toItem: navigationBar attribute: NSLayoutAttributeCenterX multiplier: 1.0 constant: 0.0];
  
  [allConstraints addObject: c1];
  
  [allConstraints addObjectsFromArray: [self constraintsForVerticalFixationOfView: centerView inNavigationBar: navigationBar]];
  
  return allConstraints;
}

+ (void) removeCenterView: (NSView*) centerView fromNavigationBar: (NSView*) navigationBar slideTo: (Side) side animated: (BOOL) animated
{
  // Мы не можем вычленить нужные константы, поэтому проще выкинуть вид совсем и добавить его снова с известными константами.
  [centerView removeFromSuperviewWithoutNeedingDisplay];
  
  [centerView setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [navigationBar addSubview: centerView];
  
  // Начальное условие.
  NSArray* startConstraints = [self constraintsForCenterView: centerView inNavigationBar: navigationBar];
  
  [navigationBar addConstraints: startConstraints];
  
  // Тут надо какой-то перерасчет.
  [navigationBar layoutSubtreeIfNeeded];
  
  // Выкидываем временную константу.
  [navigationBar removeConstraints: startConstraints];
  
  // Окончательное условие.
  NSArray* finishConstraints = [self constraintsForCenterView: centerView inNavigationBar: navigationBar complementaryPositionSide: side];
  
  [navigationBar addConstraints: finishConstraints];
  
  // Сама анимация.
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* context)
  {
    [context setAllowsImplicitAnimation: YES];
    
    [navigationBar layoutSubtreeIfNeeded];
    
    [centerView setAlphaValue: 0.0];
  }
  completionHandler: ^
  {
    [centerView removeFromSuperviewWithoutNeedingDisplay];
  }];
}

+ (void) insertCenterView: (NSView*) centerView inNavigationBar: (NSView*) navigationBar slideTo: (Side) side animated: (BOOL) animated
{
  [centerView setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [navigationBar addSubview: centerView];
  
  // Начальное условие.
  [centerView setAlphaValue: 0.0];
  
  NSArray* startConstraints = [self constraintsForCenterView: centerView inNavigationBar: navigationBar complementaryPositionSide: INVERT_SIDE(side)];
  
  [navigationBar addConstraints: startConstraints];
  
  // Тут надо какой-то перерасчет.
  [navigationBar layoutSubtreeIfNeeded];
  
  // Выкидываем временную константу.
  [navigationBar removeConstraints: startConstraints];
  
  // Окончательное условие.
  NSArray* finishConstraints = [self constraintsForCenterView: centerView inNavigationBar: navigationBar];
  
  [navigationBar addConstraints: finishConstraints];
  
  // Сама анимация.
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* context)
  {
    [context setAllowsImplicitAnimation: YES];
    
    [navigationBar layoutSubtreeIfNeeded];
    
    [centerView setAlphaValue: 1.0];
  }
  completionHandler: ^
  {
  }];
}

#pragma mark - Right view

+ (NSArray*) constraintsForRightView: (NSView*) rightView utilizingCenterView: (NSView*) centerView inNavigationBar: (NSView*) navigationBar
{
  NSMutableArray* allConstraints = [NSMutableArray new];
  
  // Фиксация левой стороны.
  NSLayoutConstraint* c1 = [NSLayoutConstraint constraintWithItem: rightView attribute: NSLayoutAttributeTrailing relatedBy: NSLayoutRelationEqual toItem: navigationBar attribute: NSLayoutAttributeTrailing multiplier: 1.0 constant: -STANDART_SPACE];
  
  [allConstraints addObject: c1];
  
  // Фиксация правой стороны.
  if(centerView)
  {
    NSDictionary* views = NSDictionaryOfVariableBindings(centerView, rightView);
    
    NSArray* c2 = [NSLayoutConstraint constraintsWithVisualFormat: @"[centerView]-(>=20)-[rightView]" options: 0 metrics: nil views: views];
    
    [allConstraints addObjectsFromArray: c2];
  }
  
  // Вертикальная компонента.
  [allConstraints addObjectsFromArray: [[self class] constraintsForVerticalFixationOfView: rightView inNavigationBar: navigationBar]];
  
  return allConstraints;
}

+ (void) removeRightView: (NSView*) rightView fromNavigationBar: (NSView*) navigationBar animated: (BOOL) animated
{
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* context)
  {
    [context setAllowsImplicitAnimation: YES];
    
    [rightView setAlphaValue: 0.0];
  }
  completionHandler: ^
  {
    [rightView removeFromSuperviewWithoutNeedingDisplay];
  }];
}

+ (void) insertRightView: (NSView*) rightView utilizingCenterView: (NSView*) centerView inNavigationBar: (NSView*) navigationBar animated: (BOOL) animated
{
  [rightView setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [navigationBar addSubview: rightView];
  
  // Окончательное условие.
  [rightView setAlphaValue: 0.0];
  
  NSArray* constraints = [[self class] constraintsForRightView: rightView utilizingCenterView: centerView inNavigationBar: navigationBar];
  
  [navigationBar addConstraints: constraints];
  
  [navigationBar layoutSubtreeIfNeeded];
  
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* context)
  {
    [context setAllowsImplicitAnimation: YES];
    
    [rightView setAlphaValue: 1.0];
  }
  completionHandler: ^
  {
  }];
}

#pragma mark - Main view

+ (NSArray*) constraintsForMainView: (NSView*) mainView inNavigationView: (NavigationView*) navigationView complementaryPositionSide: (Side) side
{
  NSMutableArray* allConstraints = [NSMutableArray new];
  
  // Переменные для биндингов форматной строки.
  NSView* navigationBar = navigationView.navigationBar;
  
  NSView* navigationToolbarHost = navigationView.navigationToolbarHost;
  
  NSDictionary* views = NSDictionaryOfVariableBindings(navigationView, navigationBar, mainView, navigationToolbarHost);
  
  NSString* format = (side == Forward)? @"H:[navigationView][mainView(==navigationView)]" : @"H:[mainView(==navigationView)][navigationView]";
  
  NSArray* horizontal = [NSLayoutConstraint constraintsWithVisualFormat: format options: 0 metrics: nil views: views];
  
  [allConstraints addObjectsFromArray: horizontal];
  
  // * * *.
  
  NSArray* vertical = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[navigationBar][mainView][navigationToolbarHost]" options: 0 metrics: nil views: views];
  
  [allConstraints addObjectsFromArray: vertical];
  
  return allConstraints;
}

+ (NSArray*) constraintsForMainView: (NSView*) mainView inNavigationView: (NavigationView*) navigationView
{
  NSMutableArray* allConstraints = [NSMutableArray new];
  
  // * * *.
  
  NSDictionary* views1 = NSDictionaryOfVariableBindings(mainView);
  
  NSArray* horizontal = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[mainView]|" options: 0 metrics: nil views: views1];
  
  [allConstraints addObjectsFromArray: horizontal];
  
  // * * *.
  
  // Переменные для биндингов форматной строки.
  NSView* navigationBar = navigationView.navigationBar;
  
  NSView* navigationToolbarHost = navigationView.navigationToolbarHost;
  
  NSDictionary* views2 = NSDictionaryOfVariableBindings(navigationBar, mainView, navigationToolbarHost);
  
  NSArray* vertical = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[navigationBar][mainView][navigationToolbarHost]" options: 0 metrics: nil views: views2];
  
  [allConstraints addObjectsFromArray: vertical];
  
  return allConstraints;
}

+ (void) removeMainView: (NSView*) mainView fromNavigationView: (NavigationView*) navigationView slideTo: (Side) side animated: (BOOL) animated
{
  // 1. Создать screenshot mainView.
  NSImageView* screenshot = [[NSImageView alloc] initWithFrame: NSZeroRect];
  
  [screenshot setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [screenshot setImage: [mainView imageWithSubviews]];
  
  // 2. Выкинуть mainView.
  [mainView removeFromSuperview];
  
  // 3. Внедрить screenshot в mainViewTransitionHost на стартовую позицию.
  [navigationView.mainViewTransitionHost addSubview: screenshot];
  
  NSMutableArray* startConstraints = [NSMutableArray array];
  
  NSDictionary* views = NSDictionaryOfVariableBindings(screenshot);
  
  [startConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[screenshot]|" options: 0 metrics: nil views: views]];
  
  [startConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[screenshot]|" options: 0 metrics: nil views: views]];
  
  [navigationView.mainViewTransitionHost addConstraints: startConstraints];
  
  // Тут надо какой-то перерасчет.
  [navigationView.mainViewTransitionHost layoutSubtreeIfNeeded];
  
  // Выкидываем временную константу.
  [navigationView.mainViewTransitionHost removeConstraints: startConstraints];
  
  // Окончательное условие.
  NSMutableArray* finishConstraints = [NSMutableArray array];
  
  NSView* mainViewTransitionHost = navigationView.mainViewTransitionHost;
  
  NSDictionary* views2 = NSDictionaryOfVariableBindings(screenshot, mainViewTransitionHost);
  
  NSString* format = (side == Backward)? @"H:[screenshot][mainViewTransitionHost]" : @"H:[mainViewTransitionHost][screenshot]";
  
  [finishConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: format options: 0 metrics: nil views: views2]];
  
  [finishConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[screenshot]" options: 0 metrics: nil views: views2]];
  
  [navigationView.mainViewTransitionHost addConstraints: finishConstraints];
  
  // Сама анимация.
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* context)
  {
    [context setAllowsImplicitAnimation: YES];
    
    [navigationView.mainViewTransitionHost layoutSubtreeIfNeeded];
  }
  completionHandler: ^
  {
    [screenshot removeFromSuperviewWithoutNeedingDisplay];
  }];
}

+ (void) insertMainView: (NSView*) mainView inNavigationView: (NavigationView*) navigationView slideTo: (Side) side animated: (BOOL) animated
{
  // 1. Добавить mainView в navigationView.
  [mainView setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [navigationView addSubview: mainView positioned: NSWindowAbove relativeTo: navigationView.mainViewTransitionHost];
  
  [navigationView addConstraints: [self constraintsForMainView: mainView inNavigationView: navigationView]];
  
  [mainView layoutSubtreeIfNeeded];
  
  // 2. Создать screenshot mainView.
  NSImageView* screenshot = [[NSImageView alloc] initWithFrame: NSZeroRect];
  
  [screenshot setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [screenshot setImage: [mainView imageWithSubviews]];
  
  [mainView removeFromSuperviewWithoutNeedingDisplay];
  
  // 3. Внедрить screenshot в mainViewTransitionHost на стартовую позицию.
  [navigationView.mainViewTransitionHost addSubview: screenshot];
  
  NSMutableArray* startConstraints = [NSMutableArray array];
  
  NSView* mainViewTransitionHost = navigationView.mainViewTransitionHost;
  
  NSDictionary* views2 = NSDictionaryOfVariableBindings(screenshot, mainViewTransitionHost);
  
  NSString* format = (side == Forward)? @"H:[screenshot][mainViewTransitionHost]" : @"H:[mainViewTransitionHost][screenshot]";
  
  [startConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: format options: 0 metrics: nil views: views2]];
  
  [startConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[screenshot]" options: 0 metrics: nil views: views2]];
  
  [navigationView.mainViewTransitionHost addConstraints: startConstraints];
  
  // Тут надо какой-то перерасчет.
  [navigationView.mainViewTransitionHost layoutSubtreeIfNeeded];
  
  // Выкидываем временную константу.
  [navigationView.mainViewTransitionHost removeConstraints: startConstraints];
  
  // Окончательное условие.
  NSMutableArray* finishConstraints = [NSMutableArray array];
  
  NSDictionary* views3 = NSDictionaryOfVariableBindings(screenshot);
  
  [finishConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[screenshot]|" options: 0 metrics: nil views: views3]];
  
  [finishConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[screenshot]|" options: 0 metrics: nil views: views3]];
  
  [navigationView.mainViewTransitionHost addConstraints: finishConstraints];
  
  // Сама анимация.
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* context)
  {
    [context setAllowsImplicitAnimation: YES];
    
    [navigationView.mainViewTransitionHost layoutSubtreeIfNeeded];
  }
  completionHandler: ^
  {
    [screenshot removeFromSuperviewWithoutNeedingDisplay];
    
    [navigationView addSubview: mainView positioned: NSWindowAbove relativeTo: navigationView.mainViewTransitionHost];
    
    [navigationView addConstraints: [self constraintsForMainView: mainView inNavigationView: navigationView]];
  }];
}

#pragma mark - Navigation toolbar

+ (NSArray*) constraintsForNavigationToolbar: (NSView*) navigationToolbar
{
  NSMutableArray* allConstraints = [NSMutableArray array];
  
  NSDictionary* dict = NSDictionaryOfVariableBindings(navigationToolbar);
  
  [allConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[navigationToolbar]|" options: 0 metrics: nil views: dict]];
  
  [allConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[navigationToolbar]|" options: 0 metrics: nil views: dict]];
  
  return allConstraints;
}

+ (void) removeNavigationToolbar: (NSView*) navigationToolbar
{
  [navigationToolbar removeFromSuperview];
}

+ (void) insertNavigationToolbar: (NSView*) navigationToolbar inNavigationToolbarHost: (NSView*) navigationToolbarHost
{
  [navigationToolbar setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [navigationToolbarHost addSubview: navigationToolbar];
  
  [navigationToolbarHost addConstraints: [self constraintsForNavigationToolbar: navigationToolbar]];
}

#pragma mark - Ядровой метод

+ (void) removeViewController: (KPNavViewController*) viewController fromNavigationView: (NavigationView*) navigationView slideTo: (Side) side animated: (BOOL) animated
{
  /* Back Navigation Bar Button & Left Navigation Bar View. */
  [self removeBackView: viewController.backButton andLeftView: viewController.leftNavigationBarView fromNavigationBar: navigationView.navigationBar slideTo: side animated: animated];
  
  /* Center Navigation Bar View. */
  [self removeCenterView: viewController.centerNavigationBarView fromNavigationBar: navigationView.navigationBar slideTo: side animated: animated];
  
  /* Right Navigation Bar View. */
  [self removeRightView: viewController.rightNavigationBarView fromNavigationBar: navigationView.navigationBar animated: animated];
  
  /* Main View. */
  [self removeMainView: viewController.view fromNavigationView: navigationView slideTo: side animated: animated];
  
  /* Navigation Toolbar. */
  [self removeNavigationToolbar: viewController.navigationToolbar];
}

+ (void) insertViewController: (KPNavViewController*) viewController inNavigationView: (NavigationView*) navigationView slideTo: (Side) side animated: (BOOL) animated
{
  /* Center Navigation Bar View. */
  [self insertCenterView: viewController.centerNavigationBarView inNavigationBar: navigationView.navigationBar slideTo: side animated: animated];
  
  /* Back Navigation Bar Button & Left Navigation Bar View. */
  [self insertBackView: viewController.backButton andLeftView: viewController.leftNavigationBarView utilizingCenterView: viewController.centerNavigationBarView inNavigationBar: navigationView.navigationBar slideTo: side animated: animated];
  
  /* Right Navigation Bar View. */
  [self insertRightView: viewController.rightNavigationBarView utilizingCenterView: viewController.centerNavigationBarView inNavigationBar: navigationView.navigationBar animated: animated];
  
  /* Main View. */
  [self insertMainView: viewController.view inNavigationView: navigationView slideTo: side animated: animated];
  
  /* Navigation Toolbar. */
  [self insertNavigationToolbar: viewController.navigationToolbar inNavigationToolbarHost: navigationView.navigationToolbarHost];
}

#define COPY_VIEW(x) [NSKeyedUnarchiver unarchiveObjectWithData: [NSKeyedArchiver archivedDataWithRootObject: x]]

+ (void) insertCopyOfViewController: (KPNavViewController*) viewController inNavigationView: (NavigationView*) navigationView slideTo: (Side) side animated: (BOOL) animated
{
  /* Center Navigation Bar View. */
  NSView* asd = COPY_VIEW(viewController.centerNavigationBarView);
  
  [self insertCenterView: asd inNavigationBar: navigationView.navigationBar slideTo: side animated: animated];
  
  /* Back Navigation Bar Button & Left Navigation Bar View. */
  [self insertBackView: COPY_VIEW(viewController.backButton) andLeftView: COPY_VIEW(viewController.leftNavigationBarView) utilizingCenterView: asd inNavigationBar: navigationView.navigationBar slideTo: side animated: animated];
  
  /* Right Navigation Bar View. */
  [self insertRightView: COPY_VIEW(viewController.rightNavigationBarView) utilizingCenterView: asd inNavigationBar: navigationView.navigationBar animated: animated];
  
  /* Main View. */
  [self insertMainView: COPY_VIEW(viewController.view) inNavigationView: navigationView slideTo: side animated: animated];
  
  /* Navigation Toolbar. */
  [self insertNavigationToolbar: COPY_VIEW(viewController.navigationToolbar) inNavigationToolbarHost: navigationView.navigationToolbarHost];
}

// Возвращает размер, удовлетворяющий обоим контроллерам, максимально близкий к size.
+ (NSSize) mutuallySatisfyingNavigationViewFrameSizeForOldViewController: (KPNavViewController*) oldControllerOrNil newViewController: (KPNavViewController*) newController closeTo: (NSSize) size utilizingNavigationViewPrototype: (NavigationView*) navigationViewPrototype
{
  // Текущий вид.
  NavigationView* navigationView1 = [NSKeyedUnarchiver unarchiveObjectWithData: [NSKeyedArchiver archivedDataWithRootObject: navigationViewPrototype]];
  
  [navigationView1 setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  if(oldControllerOrNil)
  {
    [self insertCopyOfViewController: oldControllerOrNil inNavigationView: navigationView1 slideTo: Backward animated: NO];
  }
  
  // * * *.
  
  // Новый вид.
  NSParameterAssert(newController);
  
  NavigationView* navigationView2 = [NSKeyedUnarchiver unarchiveObjectWithData: [NSKeyedArchiver archivedDataWithRootObject: navigationViewPrototype]];
  
  [navigationView2 setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [self insertCopyOfViewController: newController inNavigationView: navigationView2 slideTo: Backward animated: NO];
  
  // Контейнер.
  NSView* container = [[NSView alloc] initWithFrame: NSZeroRect];
  
  [container setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [container addSubview: navigationView1];
  
  [container addSubview: navigationView2];
  
  // * * *.
  
  // Накладываем вид «один на другой».
  NSDictionary* views = NSDictionaryOfVariableBindings(navigationView1, navigationView2);
  
  [container addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[navigationView1]|" options: 0 metrics: nil views: views]];
  
  [container addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[navigationView1]|" options: 0 metrics: nil views: views]];
  
  [container addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[navigationView2]|" options: 0 metrics: nil views: views]];
  
  [container addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[navigationView2]|" options: 0 metrics: nil views: views]];
  
  // Внедряем желаемый размер.
  NSDictionary* metrics = @{@"width": @(size.width), @"height": @(size.height)};
  
  NSDictionary* view = NSDictionaryOfVariableBindings(container);
  
  [container addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:[container(==width@700)]" options: 0 metrics: metrics views: view]];
  
  [container addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[container(==height@700)]" options: 0 metrics: metrics views: view]];
  
  //***
  
  [container layoutSubtreeIfNeeded];
  
  //***
  
  return container.frame.size;
}

// Снимает текущий контроллер из окна и вставляет в него новый.
- (void) replaceNavViewController: (KPNavViewController*) oldControllerOrNil with: (KPNavViewController*) newController animated: (BOOL) animated slideTo: (Side) side
{
  NSParameterAssert(newController);
  
  // Подгружаем вид контроллера навигации.
  if(!self.view) [self loadView];
  
  // Вид контроллера навигации перестает реагировать на клики.
  if(animated) ((HitTestView*)self.view).rejectHitTest = YES;
  
  // Размер окна с навигационным контроллером больше не может быть изменен.
  [self.windowController.window setStyleMask: [self.windowController.window styleMask] & ~NSResizableWindowMask];
  
  [[self.delegate ifResponds] navigationController: self willShowViewController: newController animated: animated];
  
  [oldControllerOrNil viewWillDisappear: animated];
  
  [newController viewWillAppear: animated];
  
  [newController view];
  
  // * * *.
  
  {{ /* Готовим кнопку «Назад» */
    NSButton* _backButtonNew = nil;
    
    if([_viewControllers count] > 1)
    {
      NSString* title = [_viewControllers[[_viewControllers count] - 2] navigationTitle];
      
      _backButtonNew = [self newBackButtonWithTitle: title];
    }
    else
    {
      _backButtonNew = [[NSButton alloc] initWithFrame: NSZeroRect];
      
      NSDictionary* views = NSDictionaryOfVariableBindings(_backButtonNew);
      
      [_backButtonNew addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:[_backButtonNew(==0@1000)]" options: 0 metrics: nil views: views]];
    }
    
    [_backButtonNew setTarget: self];
    
    newController.backButton = _backButtonNew;
  }}
  
  // * * *.
  
  // Рассчитываем размеры навигационных видов.
  NSSize currentNavigationViewSize = self.navigationView.frame.size;
  
  NSSize mutuallySatisfyingSize = NSZeroSize;
  
  NSLayoutConstraint *w, *h;
  
  BOOL shouldResizeNavigationView = NO;
  
  if(oldControllerOrNil)
  {
    mutuallySatisfyingSize = [[self class] mutuallySatisfyingNavigationViewFrameSizeForOldViewController: oldControllerOrNil newViewController: newController closeTo: currentNavigationViewSize utilizingNavigationViewPrototype: self.navigationViewPrototype];
    
    if(!NSEqualSizes(currentNavigationViewSize, mutuallySatisfyingSize))
    {
      shouldResizeNavigationView = YES;
      
      w = [NSLayoutConstraint constraintWithItem: self.navigationView attribute: NSLayoutAttributeWidth relatedBy: NSLayoutRelationEqual toItem: nil attribute: NSLayoutAttributeNotAnAttribute multiplier: 1.0 constant: currentNavigationViewSize.width];
      
      [self.navigationView addConstraint: w];
      
      h = [NSLayoutConstraint constraintWithItem: self.navigationView attribute: NSLayoutAttributeHeight relatedBy: NSLayoutRelationEqual toItem: nil attribute: NSLayoutAttributeNotAnAttribute multiplier: 1.0 constant: currentNavigationViewSize.height];
      
      [self.navigationView addConstraint: h];
    }
  }
  
  // Анимация изменения размеров навигационного вида.
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* context)
  {
    if(shouldResizeNavigationView)
    {
      // Анимируем временные константы.
      context.duration = animated? RESIZE_DURATION : 0.0;
      
      [[w animator] setConstant: mutuallySatisfyingSize.width];
      
      [[h animator] setConstant: mutuallySatisfyingSize.height];
    }
  }
  completionHandler: ^
  {
    // Выкидываем временные константы.
    if(shouldResizeNavigationView)
    {
      [self.navigationView removeConstraint: w];
      
      [self.navigationView removeConstraint: h];
    }
    
    // Анимация смены главного вида.
    [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* context)
    {
      [context setDuration: animated? TRANSITION_DURATION : 0.0];
      
      [context setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
      
      if(oldControllerOrNil)
      {
        [[self class] removeViewController: oldControllerOrNil fromNavigationView: self.navigationView slideTo: side animated: animated];
      }
      
      [[self class] insertViewController: newController inNavigationView: self.navigationView slideTo: side animated: animated];
    }
    completionHandler: ^
    {
      [oldControllerOrNil viewDidDisappear: animated];
      
      [newController viewDidAppear: animated];
      
      [[self.delegate ifResponds] navigationController: self didShowViewController: newController animated: animated];
      
      // Окно снова можно ресайзить.
      [self.windowController.window setStyleMask:[self.windowController.window styleMask] | NSResizableWindowMask];
      
      // Навигационный вид снова реагирует на клики.
      ((HitTestView*)self.view).rejectHitTest = NO;
      
      // Ставим фокус на нужный контрол.
      [self.windowController.window makeFirstResponder: [self topViewController].proposedFirstResponder];
    }];
  }];
}

#pragma mark - Пользовательские функции

- (KPNavViewController*) topViewController
{
  return [_viewControllers lastObject];
}

// Replaces the view controllers currently managed by the navigation controller with the specified items.
- (void) setViewControllers: (NSArray*) newViewControllers animated: (BOOL) animated
{
  NSParameterAssert(newViewControllers);
  
  NSAssert([newViewControllers count] > 0, @"Unable to set void view controllers array.");
  
  KPNavViewController* current = [self topViewController];
  
  [_viewControllers removeAllObjects];
  
  [_viewControllers addObjectsFromArray: newViewControllers];
  
  [_viewControllers makeObjectsPerformSelector: @selector(setNavigationController:) withObject: self];
  
  [self replaceNavViewController: current with: [newViewControllers lastObject] animated: animated slideTo: Backward];
}

// Pushes a view controller onto the receiver’s stack and updates the display.
- (void) pushViewController: (KPNavViewController*) viewController animated: (BOOL) animated
{
  NSParameterAssert(viewController);
  
  NSAssert(![_viewControllers containsObject: viewController], @"View controller already on the stack.");
  
  KPNavViewController* current = [self topViewController];
  
  [_viewControllers addObject: viewController];
  
  // TODO: Делать это в обозревателе свойства _viewControllers.
  [viewController setNavigationController: self];
  
  [self replaceNavViewController: current with: viewController animated: animated slideTo: Backward];
}

// Pops the top view controller from the navigation stack and updates the display.
- (KPNavViewController*) popViewControllerAnimated: (BOOL) animated
{
  NSInteger controllersCount = [_viewControllers count];
  
  // Если на стеке только корневой контроллер - ничего не делаем.
  if(controllersCount < 2) return nil;
  
  NSArray* poppedControllers = [self popToViewController: _viewControllers[controllersCount - 2] animated: animated];
  
  return [poppedControllers lastObject];
}

// Pops all the view controllers on the stack except the root view controller and updates the display.
- (NSArray*) popToRootViewControllerAnimated: (BOOL) animated
{
  // Если на стеке только корневой контроллер - ничего не делаем.
  if([_viewControllers count] < 2) return nil;
  
  return [self popToViewController: _viewControllers[0] animated: animated];
}

// Pops view controllers until the specified view controller is at the top of the navigation stack.
- (NSArray*) popToViewController: (KPNavViewController*) viewController animated: (BOOL) animated
{
  NSParameterAssert(viewController);
  
  NSAssert([_viewControllers containsObject: viewController], @"View controller not on the stack.");
  
  KPNavViewController* current = [self topViewController];
  
  NSUInteger indexOfViewController = [_viewControllers indexOfObject: viewController];
  
  // Сохраняем катапультированные контроллеры.
  NSRange ejectedRange = NSMakeRange(indexOfViewController + 1, [_viewControllers count] - indexOfViewController - 1);
  
  NSArray* ejectedControllers = [_viewControllers subarrayWithRange: ejectedRange];
  
  [_viewControllers removeObjectsInRange: ejectedRange];
  
  [self replaceNavViewController: current with: viewController animated: animated slideTo: Forward];
  
  return ejectedControllers;
}

@end
