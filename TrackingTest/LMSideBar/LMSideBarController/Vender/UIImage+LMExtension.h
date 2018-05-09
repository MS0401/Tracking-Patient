//
//  UIImage+LMExtension.h
//
//  Created by Ryo Song Zi on 08/12/2017.
//  Copyright (c) 2017 Ryo Song Zi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Accelerate/Accelerate.h>

@interface UIImage (LMExtension)

/**
 Screen shot from view.
 */
+ (UIImage *)imageFromView:(UIView *)theView withSize:(CGSize)size;

/**
 Blur image
 */
- (UIImage *)blurredImageWithRadius:(CGFloat)radius
                         iterations:(NSUInteger)iterations
                          tintColor:(UIColor *)tintColor;

@end
