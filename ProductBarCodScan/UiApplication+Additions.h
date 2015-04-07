//
//  UiApplication+Additions.h
//  ProductBarCodScan
//
//  Created by Pawar, Santosh-CW on 4/6/15.
//  Copyright (c) 2015 Pawar, Santosh-CW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Additions)

+ (CGSize)currentSize;
+ (CGSize)sizeInOrientation:(UIInterfaceOrientation)orientation;

@end
