//
//  LMSideBarStyle.m
//  GPS Tracking app Development
//
//  Created by Ryo Song Zi on 08/15/17.
//  Copyright © 2017 Ryo Song Zi. All rights reserved.
//

#import "LMSideBarStyle.h"

@implementation LMSideBarStyle

- (void)setContentViewController:(UIViewController *)contentViewController
{
    // For subclass
}

- (void)showMenuViewController
{
    // For subclass
}

- (void)hideMenuViewController:(BOOL)animated
{
    // For subclass
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    // For subclass
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    // For subclass
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // For subclass
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // For subclass
}

@end
