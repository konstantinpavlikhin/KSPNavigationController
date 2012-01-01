//
//  PathControl.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 18.02.10.
//  Copyright 2010 Konstantin Pavlikhin. All rights reserved.
//

@interface PathControl : NSControl
{
  id target;
  
  NSMutableArray* components;
  
  NSImage* separator;
  
  NSMutableDictionary* fontParams;
  
  NSMutableDictionary* pressedFontParams;
  
  NSUInteger pressedComponentIndex;
  
  BOOL drawHotState;
}

@property(readwrite, assign) id target;

// Устанавливает компоненты с передаваемыми именами.
- (void) setComponentsWithNames: (NSArray*) steps;

// Убирает все компоненты пути из контрола.
- (void) removeAllComponents;

// Добавляет компонент к концу пути.
- (void) addComponentWithName: (NSString*) step;

// Убирает последний компонент пути из контрола.
- (void) removeLastComponent;

// Возвращает индекс шага к которому мы вернулись.
- (NSUInteger) clickedComponentIndex;

////////////////////////////////////////////////////////////////////////////////

// Убирает все компоненты правее index.
- (void) popToComponentWithIndex: (NSUInteger) index;

- (void) mouseEvent: (NSEvent*) event;

@end

////////////////////////////////////////////////////////////////////////////////
