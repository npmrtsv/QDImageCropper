//
//  QDImageCropper.h
//  QDImageCropper
//
//  Created by Nikolay on 13/04/14.
//
//

#import <UIKit/UIKit.h>

@interface QDImageCropper : UINavigationController

@property (nonatomic, assign) CGFloat frameXOffset;
@property (nonatomic, strong) UIColor *overlayColor;

- (instancetype)initWithImage:(UIImage*)image resultImageSize:(CGSize)imageSize completion:(void(^)(UIImage *image, CGRect rect, UIImage *croppedImage))completion;
- (void)setBackButton:(UIButton *)button;
- (void)setCropButton:(UIButton *)button;

@end
