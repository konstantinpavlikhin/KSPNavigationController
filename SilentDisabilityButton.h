//
//  SilentDisabilityButton.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 01.03.10.
//  Copyright 2010 Konstantin Pavlikhin. All rights reserved.
//

@interface SilentDisabilityButton : NSButton
{
  BOOL silentlyDisabled;
}

@property(readwrite, assign, getter = isSilentlyDisabled) BOOL silentlyDisabled;

@end

////////////////////////////////////////////////////////////////////////////////
