////////////////////////////////////////////////////////////////////////////////

#import "ViewController.h"

@class NavigationController;

@interface NavViewController : ViewController
{
  NavigationController* navigationController;
  
  NSString* navigationTitle;
  
  IBOutlet NSView* navigationBarItem;
  
  IBOutlet NSView* navigationToolbar;
  
  IBOutlet NSResponder* theFirstResponder;
}

@property(readwrite, assign) NavigationController* navigationController;

@property(readwrite, retain) NSString* navigationTitle;

@property(readonly) IBOutlet NSView* navigationBarItem;

@property(readonly) IBOutlet NSView* navigationToolbar;

@property(readonly) IBOutlet NSResponder* theFirstResponder;

- (void) traverseViewHierarchy: (NSView*) root andSetNSButtonCellsBackgroundColor: (NSColor*) backgroundColor;

// Биндит все SilentDisabilityButton'ы в подвидах к флагу navigationController.transitioning.
- (void) bindSilentDisabilityButtons;

- (void) traverseViewHierarchyAndBindSilentDisabilityButtons: (NSView*) root;

// Отсоединяет все SilentDisabilityButton'ы в подвидах от флага navigationController.transitioning.
- (void) unbindSilentDisabilityButtons;

- (void) traverseViewHierarchyAndUnbindSilentDisabilityButtons: (NSView*) root;

@end

////////////////////////////////////////////////////////////////////////////////
