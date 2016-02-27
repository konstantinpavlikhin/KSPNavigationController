//
//  KSPNavViewController+Private.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 08.06.15.
//  Copyright (c) 2015 Konstantin Pavlikhin. All rights reserved.
//

#import "KSPNavViewController.h"

@interface KSPNavViewController ()

@property(readwrite, strong, nonatomic) IBOutlet NSView* leftNavigationBarView;

@property(readwrite, strong, nonatomic) IBOutlet NSView* centerNavigationBarView;

@property(readwrite, strong, nonatomic) IBOutlet NSView* rightNavigationBarView;

@property(readwrite, strong, nonatomic) IBOutlet NSView* navigationToolbar;

@end
