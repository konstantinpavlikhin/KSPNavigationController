#import "KSPNavigationController+Private.h"

#import "KSPNavigationControllerDelegate.h"

#import "KSPNavViewController.h"

#import "KSPHitTestView.h"

#import "KSPNavigationView.h"

#import "NSView+Screenshot.h"

#import "KSPBackButton.h"

#import <KSPToolbox/NSObject+IfResponds.h>

#import <QuartzCore/CoreAnimation.h>

typedef NS_ENUM(NSUInteger, Side) { Backward, Forward };

#define RESIZE_DURATION (1.0 / 5.0)

#define STANDART_SPACE 8.0

#define INVERT_SIDE(x) ((x == Backward)? Forward : Backward)

@implementation KSPNavigationController
{
  NSMutableArray* _viewControllers;
}

- (instancetype) initWithNavigationBar: (NSView*) navigationBar rootViewController: (KSPNavViewController*) rootViewControllerOrNil
{
  NSParameterAssert(navigationBar);
  
  self = [super initWithNibName: @"KSPNavigationController" bundle: nil];
  
  if(!self) return nil;
  
  _transitionStyle = KSPNavigationControllerTransitionStyleLengthy;
  
  _transitionDuration = (1.0 / 2.0);
  
  KSPHitTestView* host = [[KSPHitTestView alloc] initWithFrame: NSZeroRect];
  
  host.translatesAutoresizingMaskIntoConstraints = NO;
  
  [navigationBar addSubview: host];
  
  [navigationBar addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[host]|" options: 0 metrics: nil views: @{@"host": host}]];
  
  [navigationBar addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[host]|" options: 0 metrics: nil views: @{@"host": host}]];
  
  _navigationBar = host;
  
  _viewControllers = [NSMutableArray new];
  
  if(rootViewControllerOrNil) [self setViewControllers: @[rootViewControllerOrNil] animated: NO];
  
  return self;
}

#pragma mark - Designated Initializers суперкласса

- (instancetype) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil
{
  NSAssert(NO, @"KPNavigationController можно инициализировать только с помощью -initWithNavigationBar:rootViewController:");
  
  return nil;
}

- (instancetype) initWithCoder: (NSCoder*) coder
{
  NSAssert(NO, @"KPNavigationController можно инициализировать только с помощью -initWithNavigationBar:rootViewController:");
  
  return nil;
}

#pragma mark -

- (void) awakeFromNib
{
  self.navigationView.navigationBar = self.navigationBar;
  
  [[self.navigationView.mainViewTransitionHost layer] setOpaque: YES];
  
  self.navigationViewPrototype = [NSKeyedUnarchiver unarchiveObjectWithData: [NSKeyedArchiver archivedDataWithRootObject: self.navigationView]];
  
  // * * *.
  
  CATransition* fadeTransition = [CATransition animation];
  
  [fadeTransition setType: kCATransitionFade];
  
  [fadeTransition setDuration: self.transitionDuration];
  
  NSDictionary* animations = @{@"subviews": fadeTransition};
  
  [self.navigationView.navigationBar setAnimations: animations];
  
  [self.navigationToolbarHost setAnimations: animations];
}

- (NSButton*) newBackButtonWithTitle: (NSString*) string
{
  NSButton* b = [[KSPBackButton alloc] initWithFrame: NSZeroRect];
  
  [b setBezelStyle: NSTexturedRoundedBezelStyle];
  
  if(!string) string = NSLocalizedStringFromTable(@"BackButton_Title", [self className], nil);
  
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

+ (void) removeBackView: (NSView*) backView andLeftView: (NSView*) leftView fromNavigationBar: (NSView*) navigationBar width: (CGFloat) width slideTo: (Side) side animated: (BOOL) animated
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
  
  // Принудительно фиксируем ширину левосторонней конструкции (backView + пробел + leftView).
  [navigationBar addConstraint: [NSLayoutConstraint constraintWithItem: backView attribute: NSLayoutAttributeLeft relatedBy: NSLayoutRelationEqual toItem: leftView attribute: NSLayoutAttributeRight multiplier: 1.0 constant: -width]];
  
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
  
  // Центральный вид стремится к середине, но, при необходимости, может быть расположен ассиметрично.
  c1.priority = 100.0;
  
  [allConstraints addObject: c1];
  
  [allConstraints addObjectsFromArray: [self constraintsForVerticalFixationOfView: centerView inNavigationBar: navigationBar]];
  
  return allConstraints;
}

+ (void) removeCenterView: (NSView*) centerView fromNavigationBar: (NSView*) navigationBar x: (CGFloat) x width: (CGFloat) width slideTo: (Side) side animated: (BOOL) animated
{
  // Мы не можем вычленить нужные константы, поэтому проще выкинуть вид совсем и добавить его снова с известными константами.
  [centerView removeFromSuperviewWithoutNeedingDisplay];
  
  [centerView setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [navigationBar addSubview: centerView];
  
  // Начальное условие.
  NSArray* startConstraints = [self constraintsForCenterView: centerView inNavigationBar: navigationBar];
  
  // Принудительно фиксируем левый край центральной плашки.
  id c = [NSLayoutConstraint constraintWithItem: centerView attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem: navigationBar attribute: NSLayoutAttributeLeading multiplier: 1.0 constant: x];
  
  startConstraints = [startConstraints arrayByAddingObject: c];
  
  // * * *.
  
  [navigationBar addConstraints: startConstraints];
  
  // Принудительно фиксируем ширину центральной плашки.
  NSDictionary* metrics = @{@"currentWidth": @(width)};
  
  NSDictionary* views = NSDictionaryOfVariableBindings(centerView);
  
  [navigationBar addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"[centerView(==currentWidth)]" options: 0 metrics: metrics views: views]];
  
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

+ (void) removeRightView: (NSView*) rightView fromNavigationBar: (NSView*) navigationBar width: (CGFloat) width animated: (BOOL) animated
{
  // Принудительно фиксируем ширину rightView.
  NSDictionary* metrics = @{@"currentWidth": @(width)};
  
  NSDictionary* views = NSDictionaryOfVariableBindings(rightView);
  
  [navigationBar addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"[rightView(==currentWidth)]" options: 0 metrics: metrics views: views]];
  
  // * * *.
  
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

+ (NSArray*) constraintsForMainView: (NSView*) mainView inNavigationView: (KSPNavigationView*) navigationView complementaryPositionSide: (Side) side transitionStyle: (KSPNavigationControllerTransitionStyle) transitionStyle
{
  NSMutableArray* allConstraints = [NSMutableArray new];
  
  // Переменные для биндингов форматной строки.
  NSView* navigationBar = navigationView.navigationBar;
  
  NSView* navigationToolbarHost = navigationView.navigationToolbarHost;
  
  NSDictionary* views = NSDictionaryOfVariableBindings(navigationView, navigationBar, mainView, navigationToolbarHost);
  
  if(side == Forward)
  {
    id c = [NSLayoutConstraint constraintsWithVisualFormat: @"H:[navigationView][mainView(==navigationView)]" options: 0 metrics: nil views: views];
    
    [allConstraints addObjectsFromArray: c];
  }
  else
  {
    id c = [NSLayoutConstraint constraintsWithVisualFormat: @"H:[mainView(==navigationView)]" options: 0 metrics: nil views: views];
    
    [allConstraints addObjectsFromArray: c];
    
    CGFloat m = (transitionStyle == KSPNavigationControllerTransitionStyleLengthy)? 1.0 : (1.0 / 3.0);
    
    id c2 = [NSLayoutConstraint constraintWithItem: mainView attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem: navigationView attribute: NSLayoutAttributeLeading multiplier: -m constant: 0.0];
    
    [allConstraints addObject: c2];
  }
  
  // * * *.
  
  NSArray* vertical = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[mainView][navigationToolbarHost]" options: 0 metrics: nil views: views];
  
  [allConstraints addObjectsFromArray: vertical];
  
  return allConstraints;
}

+ (NSArray*) constraintsForMainView: (NSView*) mainView inNavigationView: (KSPNavigationView*) navigationView
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
  
  NSArray* vertical = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[mainView][navigationToolbarHost]" options: 0 metrics: nil views: views2];
  
  [allConstraints addObjectsFromArray: vertical];
  
  return allConstraints;
}

+ (void) removeMainView: (NSView*) mainView fromNavigationView: (KSPNavigationView*) navigationView slideTo: (Side) side animated: (BOOL) animated transitionStyle: (KSPNavigationControllerTransitionStyle) transitionStyle
{
  // 1. Создать screenshot mainView.
  NSImageView* screenshot = [[NSImageView alloc] initWithFrame: NSZeroRect];
  
  [screenshot setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [screenshot setImage: [mainView ss_imageWithSubviews]];
  
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
  
  if(side == Forward)
  {
    id c = [NSLayoutConstraint constraintsWithVisualFormat: @"H:[mainViewTransitionHost][screenshot]" options: 0 metrics: nil views: views2];
    
    [finishConstraints addObjectsFromArray: c];
  }
  else
  {
    CGFloat divider = (transitionStyle == KSPNavigationControllerTransitionStyleLengthy)? 1.0 : 3.0;
    
    id c2 = [NSLayoutConstraint constraintWithItem: screenshot attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem: mainViewTransitionHost attribute: NSLayoutAttributeLeading multiplier: 1.0 constant: -(mainViewTransitionHost.frame.size.width / divider)];
    
    [finishConstraints addObject: c2];
  }
  
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

+ (void) insertMainView: (NSView*) mainView inNavigationView: (KSPNavigationView*) navigationView slideTo: (Side) side animated: (BOOL) animated transitionStyle: (KSPNavigationControllerTransitionStyle) transitionStyle
{
  // 1. Добавить mainView в navigationView.
  [mainView setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [navigationView addSubview: mainView positioned: NSWindowAbove relativeTo: navigationView.mainViewTransitionHost];
  
  [navigationView addConstraints: [self constraintsForMainView: mainView inNavigationView: navigationView]];
  
  [mainView layoutSubtreeIfNeeded];
  
  // 2. Создать screenshot mainView.
  NSImageView* screenshot = [[NSImageView alloc] initWithFrame: NSZeroRect];
  
  [screenshot setTranslatesAutoresizingMaskIntoConstraints: NO];
  
  [screenshot setImage: [mainView ss_imageWithSubviews]];
  
  [mainView removeFromSuperviewWithoutNeedingDisplay];
  
  // 3. Внедрить screenshot в mainViewTransitionHost на стартовую позицию.
  [navigationView.mainViewTransitionHost addSubview: screenshot positioned: side == Forward? NSWindowBelow : NSWindowAbove relativeTo: [[navigationView.mainViewTransitionHost subviews] lastObject]];
  
  NSMutableArray* startConstraints = [NSMutableArray array];
  
  NSView* mainViewTransitionHost = navigationView.mainViewTransitionHost;
  
  NSDictionary* views2 = NSDictionaryOfVariableBindings(screenshot, mainViewTransitionHost);
  
  if(side == Backward)
  {
    id c = [NSLayoutConstraint constraintsWithVisualFormat: @"H:[mainViewTransitionHost][screenshot]" options: 0 metrics: nil views: views2];
    
    [startConstraints addObjectsFromArray: c];
  }
  else
  {
    CGFloat divider = (transitionStyle == KSPNavigationControllerTransitionStyleLengthy)? 1.0 : 3.0;
    
    id c2 = [NSLayoutConstraint constraintWithItem: screenshot attribute: NSLayoutAttributeLeading relatedBy: NSLayoutRelationEqual toItem: mainViewTransitionHost attribute: NSLayoutAttributeLeading multiplier: 1.0 constant: -(mainViewTransitionHost.frame.size.width / divider)];
    
    [startConstraints addObject: c2];
  }
  
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

+ (void) removeViewController: (KSPNavViewController*) viewController fromNavigationView: (KSPNavigationView*) navigationView slideTo: (Side) side animated: (BOOL) animated transitionStyle: (KSPNavigationControllerTransitionStyle) transitionStyle
{
  /* Рассчитываем текущую ширину всех вьюшек на навигационной плашке. */
  
  // Запоминаем текущую ширину всей левосторонней конструкции (backView + пробел + leftView).
  const CGFloat backPlusLeftWidth = viewController.leftNavigationBarView.frame.origin.x + viewController.leftNavigationBarView.frame.size.width - viewController.backButton.frame.origin.x;
  
  // Запоминаем текущую ширину центральной плашки.
  const CGFloat centerWidth = viewController.centerNavigationBarView.frame.size.width;
  
  const CGFloat centerX = viewController.centerNavigationBarView.frame.origin.x;
  
  // Запоминаем текущую ширину rightView.
  const CGFloat rightWidth = viewController.rightNavigationBarView.frame.size.width;
  
  /* Back Navigation Bar Button & Left Navigation Bar View. */
  [self removeBackView: viewController.backButton andLeftView: viewController.leftNavigationBarView fromNavigationBar: navigationView.navigationBar width: backPlusLeftWidth slideTo: side animated: animated];
  
  /* Center Navigation Bar View. */
  [self removeCenterView: viewController.centerNavigationBarView fromNavigationBar: navigationView.navigationBar x: centerX width: centerWidth slideTo: side animated: animated];
  
  /* Right Navigation Bar View. */
  [self removeRightView: viewController.rightNavigationBarView fromNavigationBar: navigationView.navigationBar width: rightWidth animated: animated];
  
  /* Main View. */
  [self removeMainView: viewController.view fromNavigationView: navigationView slideTo: side animated: animated transitionStyle: transitionStyle];
  
  /* Navigation Toolbar. */
  [self removeNavigationToolbar: viewController.navigationToolbar];
}

+ (void) insertViewController: (KSPNavViewController*) viewController inNavigationView: (KSPNavigationView*) navigationView slideTo: (Side) side animated: (BOOL) animated transitionStyle: (KSPNavigationControllerTransitionStyle) transitionStyle
{
  /* Center Navigation Bar View. */
  [self insertCenterView: viewController.centerNavigationBarView inNavigationBar: navigationView.navigationBar slideTo: side animated: animated];
  
  /* Back Navigation Bar Button & Left Navigation Bar View. */
  [self insertBackView: viewController.backButton andLeftView: viewController.leftNavigationBarView utilizingCenterView: viewController.centerNavigationBarView inNavigationBar: navigationView.navigationBar slideTo: side animated: animated];
  
  /* Right Navigation Bar View. */
  [self insertRightView: viewController.rightNavigationBarView utilizingCenterView: viewController.centerNavigationBarView inNavigationBar: navigationView.navigationBar animated: animated];
  
  /* Main View. */
  [self insertMainView: viewController.view inNavigationView: navigationView slideTo: side animated: animated transitionStyle: transitionStyle];
  
  /* Navigation Toolbar. */
  [self insertNavigationToolbar: viewController.navigationToolbar inNavigationToolbarHost: navigationView.navigationToolbarHost];
}

// Снимает текущий контроллер из окна и вставляет в него новый.
- (void) replaceNavViewController: (KSPNavViewController*) oldControllerOrNil with: (KSPNavViewController*) newController animated: (BOOL) animated slideTo: (Side) side
{
  NSParameterAssert(newController);
  
  // Подгружаем вид контроллера навигации.
  if(!self.view) [self loadView];
  
  // Вид контроллера навигации перестает реагировать на клики.
  if(animated)
  {
    self.navigationBar.rejectHitTest = YES;
    
    ((KSPHitTestView*)self.view).rejectHitTest = YES;
  }
  
  // Размер окна с навигационным контроллером больше не может быть изменен.
  [self.windowController.window setStyleMask: [self.windowController.window styleMask] & ~NSResizableWindowMask];
  
  [[self.delegate ifResponds] navigationController: self willShowViewController: newController animated: animated];
  
  [oldControllerOrNil viewWillDisappear: animated];
  
  [newController viewWillAppear: animated];
  
  [newController view];
  
  // * * *.
  
  {{ /* Готовим кнопку «Назад» */
    NSButton* backButtonNew = nil;
    
    if([_viewControllers count] > 1)
    {
      NSString* title = ((KSPNavViewController*)_viewControllers[_viewControllers.count - 2]).title;
      
      backButtonNew = [self newBackButtonWithTitle: title];
    }
    else
    {
      backButtonNew = [[NSButton alloc] initWithFrame: NSZeroRect];
      
      NSDictionary* views = NSDictionaryOfVariableBindings(backButtonNew);
      
      [backButtonNew addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:[backButtonNew(==0@1000)]" options: 0 metrics: nil views: views]];
    }
    
    [backButtonNew setTarget: self];
    
    newController.backButton = backButtonNew;
  }}
  
  // * * *.
  
  // Анимация смены главного вида.
  [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* context)
  {
    [context setDuration: animated? self.transitionDuration : 0.0];
    
    [context setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
    
    if(oldControllerOrNil)
    {
      [[self class] removeViewController: oldControllerOrNil fromNavigationView: self.navigationView slideTo: side animated: animated transitionStyle: self.transitionStyle];
    }
    
    [[self class] insertViewController: newController inNavigationView: self.navigationView slideTo: side animated: animated transitionStyle: self.transitionStyle];
  }
  completionHandler: ^
  {
    [oldControllerOrNil viewDidDisappear: animated];
    
    [newController viewDidAppear: animated];
    
    [[self.delegate ifResponds] navigationController: self didShowViewController: newController animated: animated];
    
    // Окно снова можно ресайзить.
    [self.windowController.window setStyleMask: [self.windowController.window styleMask] | NSResizableWindowMask];
    
    // Навигационный вид снова реагирует на клики.
    ((KSPHitTestView*)self.view).rejectHitTest = NO;
    
    self.navigationBar.rejectHitTest = NO;
    
    // Ставим фокус на нужный контрол.
    [self.windowController.window makeFirstResponder: [self topViewController].proposedFirstResponder];
  }];
}

#pragma mark - Пользовательские функции

// Replaces the view controllers currently managed by the navigation controller with the specified items.
- (void) setViewControllers: (NSArray*) newViewControllers animated: (BOOL) animated
{
  NSParameterAssert(newViewControllers);
  
  NSAssert([newViewControllers count] > 0, @"Unable to set void view controllers array.");
  
  KSPNavViewController* current = [self topViewController];
  
  [_viewControllers removeAllObjects];
  
  [_viewControllers addObjectsFromArray: newViewControllers];
  
  [_viewControllers makeObjectsPerformSelector: @selector(setNavigationController:) withObject: self];
  
  self.topViewController = [_viewControllers lastObject];
  
  [self replaceNavViewController: current with: [newViewControllers lastObject] animated: animated slideTo: Backward];
}

// Pushes a view controller onto the receiver’s stack and updates the display.
- (void) pushViewController: (KSPNavViewController*) viewController animated: (BOOL) animated
{
  NSParameterAssert(viewController);
  
  NSAssert(![_viewControllers containsObject: viewController], @"View controller already on the stack.");
  
  KSPNavViewController* current = [self topViewController];
  
  [_viewControllers addObject: viewController];
  
  [viewController setNavigationController: self];
  
  self.topViewController = viewController;
  
  [self replaceNavViewController: current with: viewController animated: animated slideTo: Backward];
}

// Pops the top view controller from the navigation stack and updates the display.
- (KSPNavViewController*) popViewControllerAnimated: (BOOL) animated
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
- (NSArray*) popToViewController: (KSPNavViewController*) viewController animated: (BOOL) animated
{
  NSParameterAssert(viewController);
  
  NSAssert([_viewControllers containsObject: viewController], @"View controller not on the stack.");
  
  KSPNavViewController* current = [self topViewController];
  
  NSUInteger indexOfViewController = [_viewControllers indexOfObject: viewController];
  
  // Сохраняем катапультированные контроллеры.
  NSRange ejectedRange = NSMakeRange(indexOfViewController + 1, [_viewControllers count] - indexOfViewController - 1);
  
  NSArray* ejectedControllers = [_viewControllers subarrayWithRange: ejectedRange];
  
  [_viewControllers removeObjectsInRange: ejectedRange];
  
  self.topViewController = viewController;
  
  [self replaceNavViewController: current with: viewController animated: animated slideTo: Forward];
  
  return ejectedControllers;
}

@end
