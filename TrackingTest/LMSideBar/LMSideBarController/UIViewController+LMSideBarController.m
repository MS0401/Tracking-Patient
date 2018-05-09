//
//  UIViewController+LMSideBarController.m
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 08/17/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

#import "UIViewController+LMSideBarController.h"

@implementation UIViewController (LMSideBarController)

- (LMSideBarController *)sideBarController
{
    UIViewController *iter = self.parentViewController;
    while (iter) {
        if ([iter isKindOfClass:[LMSideBarController class]]) {
            return (LMSideBarController *)iter;
        }
        else if (iter.parentViewController && iter.parentViewController != iter) {
            iter = iter.parentViewController;
        }
        else {
            iter = nil;
        }
    }
    return nil;
}

@end
