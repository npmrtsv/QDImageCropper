//
//  QDImageCropperOverlay.m
//  QDImageCropper
//
//  Created by Nikolay on 13/04/14.
//
//

#import "QDImageCropperOverlay.h"
#import "UIImage+Color.h"
#import <QuartzCore/QuartzCore.h>

@interface QDImageCropperOverlay()

@property (strong, nonatomic) IgnoringTouchesView *sightView;
@property (strong, nonatomic) UIColor *color;

@end

@implementation QDImageCropperOverlay

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _sightView = [[IgnoringTouchesView alloc] initWithFrame:frame];
        [self addSubview:_sightView];
        _sightView.layer.borderWidth = 1;
        _sightView.layer.borderColor = [UIColor whiteColor].CGColor;
        
        _color = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8];
    }
    return self;
}

- (void)setImageSize:(CGSize)size{
    CGRect frame = _sightView.frame;
    frame.size.height = self.frame.size.width*size.height/size.width;
    frame.origin.y = (self.frame.size.height - frame.size.height)/2.0;
    _sightView.frame = frame;
    [self refresh];
}

- (void)setSightFrame:(CGRect)frame{
    _sightView.frame = frame;
    [self refresh];
}

- (void)setColor:(UIColor *)color{
    _color = color;
    [self refresh];
}

- (void)refresh{
    UIImage *image = [UIImage imageWithColor:_color width:self.frame.size.width height:self.frame.size.height];
    
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:imageRect];
    CGContextClearRect(context, _sightView.frame);
    UIImage *bck = UIGraphicsGetImageFromCurrentImageContext();
    [self setBackgroundColor:[UIColor colorWithPatternImage:bck]];
    UIGraphicsEndImageContext();
}

@end
