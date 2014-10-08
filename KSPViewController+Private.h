//
//  KSPViewController+Private.h
//  KSPNavigationController
//
//  Created by Konstantin Pavlikhin on 08.10.14.
//  Copyright (c) 2014 Konstantin Pavlikhin. All rights reserved.
//

#import "KSPViewController.h"

@interface KSPViewController ()

// Actually, this property should be weak, but we may need to point to the NSTextView which doesn't support weak references.
@property(readwrite, strong, nonatomic) IBOutlet NSView* proposedFirstResponder;

@end
