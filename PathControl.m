//
//  PathControl.m
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 18.02.10.
//  Copyright 2010 Konstantin Pavlikhin. All rights reserved.
//

#import "PathControl.h"

@implementation PathControl

@synthesize target;

- (id) initWithFrame: (NSRect) frameRect
{
  self = [super initWithFrame: frameRect];
  
  if(!self) return nil;
  
  components = [[NSMutableArray alloc] init];
  
  separator = [NSImage imageNamed: @"PathControlSeparator.png"];
  
  //////////////////////////////////////////////////////////////////////////////
  
  fontParams = [[NSMutableDictionary alloc] init];
  
  [fontParams setObject: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSRegularControlSize]] forKey: NSFontAttributeName];
  
  [fontParams setObject: [NSColor whiteColor] forKey: NSForegroundColorAttributeName];
  
  //////////////////////////////////////////////////////////////////////////////
  
  pressedFontParams = [[NSMutableDictionary alloc] init];
  
  [pressedFontParams addEntriesFromDictionary: fontParams];
  
  NSShadow* shadow = [[[NSShadow alloc] init] autorelease];
  
  [shadow setShadowOffset: NSMakeSize(0.0, 0.0)];
  
  [shadow setShadowColor: [NSColor lightGrayColor]];
  
  [shadow setShadowBlurRadius: 8.0];
  
  [pressedFontParams setObject: shadow forKey: NSShadowAttributeName];
  
  return self;
}

- (void) dealloc
{
  [components release];
  
  [separator release];
  
  [fontParams release];
  
  [pressedFontParams release];
  
  [super dealloc];
}

- (void) setComponentsWithNames: (NSArray*) steps
{
  [components removeAllObjects];
  
  [components addObjectsFromArray: steps];
  
  [self setNeedsDisplay: YES];
}

- (void) removeAllComponents
{
  [components removeAllObjects];
  
  [self setNeedsDisplay: YES];
}

- (void) addComponentWithName: (NSString*) step
{
  [components addObject: step];
  
  [self setNeedsDisplay: YES];
}

- (void) removeLastComponent
{
  [components removeLastObject];
  
  [self setNeedsDisplay: YES];
}

- (NSUInteger) clickedComponentIndex
{
  return [components count] - 1;
}

- (void) popToComponentWithIndex: (NSUInteger) index
{
  [components removeObjectsInRange: NSMakeRange(index + 1, [components count] - (index + 1))];
  
  [self setNeedsDisplay: YES];
  
  [target performSelector: @selector(pathControlClicked:) withObject: self];
}

- (void) drawRect: (NSRect) dirtyRect
{
  double cursor = 0.0;
  
  NSInteger counter = 0;
  
  for(NSString* component in components)
  {
    // Если мы рисуем "нажатый" компонент и курсор по прежнему в его пределах...
    NSMutableDictionary* params = ((counter++ == pressedComponentIndex) && drawHotState) ? pressedFontParams : fontParams;
    
    [component drawAtPoint: NSMakePoint(cursor, 8.0) withAttributes: params];
    
    // У последнего шага стрелку мы не рисуем.
    //if(counter >= ([components count] - 1)) return;
    
    cursor += round([component sizeWithAttributes: params].width);
    
    [separator drawAtPoint: NSMakePoint(cursor, 0.0) fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0];
    
    cursor += round([separator size].width);
  }
}

- (void) mouseDown: (NSEvent*) theEvent
{
  [self mouseEvent: theEvent];
}

- (void) mouseDragged: (NSEvent*) theEvent
{
  [self mouseEvent: theEvent];
}

- (void) mouseUp: (NSEvent*) theEvent
{
  [self mouseEvent: theEvent];
}

- (void) mouseEvent: (NSEvent*) event
{
  if(![self isEnabled]) return;
  
  NSPoint mousePoint = [self convertPoint: [event locationInWindow] fromView: nil];
  
  NSRect componentRect;
  
  componentRect.origin = NSZeroPoint;
  
  componentRect.size.height = 30;
  
  NSUInteger counter = 0;
  
  for(NSString* component in components)
  {
    componentRect.size.width = [component sizeWithAttributes: fontParams].width;
    
    if(NSPointInRect(mousePoint, componentRect))
    {
      if([event type] == NSLeftMouseDown)
      {
        pressedComponentIndex = counter;
        
        drawHotState = YES;
        
        [self setNeedsDisplay: YES];
        
        return;
      }
      
      if([event type] == NSLeftMouseDragged)
      {
        if(counter == pressedComponentIndex)
        {
          drawHotState = YES;
          
          [self setNeedsDisplay: YES];
          
          return;
        }
      }
      
      if([event type] == NSLeftMouseUp)
      {
        if(counter == pressedComponentIndex)
        {
          drawHotState = NO;
          
          [self popToComponentWithIndex: counter];
        }
        
        return;
      }
    }
    
    componentRect.origin.x += componentRect.size.width + [separator size].width;
    
    counter++;
  }
  
  if([event type] == NSLeftMouseDragged)
  {
    drawHotState = NO;
    
    [self setNeedsDisplay: YES];
  }
}

@end

////////////////////////////////////////////////////////////////////////////////
