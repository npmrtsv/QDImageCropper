//
//  QDImageCropperOverlay.h
//  QDImageCropper
//
//  Created by Nikolay on 13/04/14.
//
//

#import "IgnoringTouchesView.h"

@interface QDImageCropperOverlay : IgnoringTouchesView

- (void)setImageSize:(CGSize)size;
- (void)setSightFrame:(CGRect)frame;

- (void)setColor:(UIColor*)color;

@end
