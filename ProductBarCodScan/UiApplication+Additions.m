//
//  UiApplication+Additions.m
//  ProductBarCodScan
//
//  Created by Pawar, Santosh-CW on 4/6/15.
//  Copyright (c) 2015 Pawar, Santosh-CW. All rights reserved.
//

#import "UiApplication+Additions.h"

@implementation UIApplication (Additions)
+ (CGSize)currentSize {
    BOOL supportsiPad = NO;
    
    NSArray *deviceFamilySupport = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIDeviceFamily"];
    if (deviceFamilySupport) {
        for (NSString *family in deviceFamilySupport) {
            NSString *familyString = [NSString stringWithFormat:@"%@", family];
            
            if ([familyString isEqualToString:@"2"]) {
                supportsiPad = YES;
                break;
            }
        }
        
        if (supportsiPad == YES) {
            return [UIApplication sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
        } else {
            return [UIApplication sizeInOrientation:UIInterfaceOrientationPortrait];
        }
    } else {
        return [UIApplication sizeInOrientation:UIInterfaceOrientationPortrait];
    }
}

+ (CGSize)sizeInOrientation:(UIInterfaceOrientation)orientation {
    CGSize size = [UIScreen mainScreen].bounds.size;
//    CGFloat scale = [UIScreen mainScreen].scale;
    
    UIApplication *application = [UIApplication sharedApplication];
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        size = CGSizeMake(size.height, size.width);
    }
    
    if (application.statusBarHidden == NO) {
        size.height += MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    
    return size;
}

@end
