//
//  QDImageCropperOverlay.h
//  QDImageCropper
//
//  Created by Nikolay on 13/04/14.
//
//

#import "QDIgnoringTouchesView.h"

@interface QDImageCropperOverlay : QDIgnoringTouchesView

- (void)setImageSize:(CGSize)size;
- (void)setSightFrame:(CGRect)frame;

- (void)setColor:(UIColor*)color;

@end
