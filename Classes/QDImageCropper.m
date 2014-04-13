//
//  QDImageCropper.m
//  QDImageCropper
//
//  Created by Nikolay on 13/04/14.
//
//

#import "QDImageCropper.h"
#import "QDImageCropperOverlay.h"
#import "UIImage+Resize.h"

@interface QDImageCropper ()<UIScrollViewDelegate>{
    CGFloat navBarHeight;
    CGRect sightFrame;
    void(^_completion)(UIImage *image, CGRect rect, UIImage *croppedImage);
}

@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CGSize imageSize;
@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGFloat scale;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (strong, nonatomic) QDImageCropperOverlay *overlayView;

@end

@implementation QDImageCropper

- (instancetype)initWithImage:(UIImage *)image resultImageSize:(CGSize)imageSize completion:(void (^)(UIImage *, CGRect, UIImage *))completion{
    NSParameterAssert(completion && image);
    NSAssert(!CGSizeEqualToSize(imageSize, CGSizeZero), @"Set image size!");
    
    self = [super init];
    if (self) {
        _imageSize = imageSize;
        _image = image;
        _completion = completion;
        _frameXOffset = 20.0;
        _overlayColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8];
        
        _imageView = [[UIImageView alloc] initWithImage:_image];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSAssert(self.navigationController, @"Cropper needs navigation controller");
    
    _overlayView = [[QDImageCropperOverlay alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_overlayView];
    
    [_overlayView setColor:_overlayColor];
    
    navBarHeight = 44.0 + ([UIApplication sharedApplication].statusBarHidden?0.0:20.0);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Crop", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(crop)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(back)];
    
    [self setCropButtonEnabled:NO];
    
    [self.view addSubview:_overlayView];
    
    float height = (_overlayView.frame.size.width - 2*_frameXOffset)*_imageSize.height/_imageSize.width;
    
    sightFrame = CGRectMake(_frameXOffset,
                            (_overlayView.frame.size.height - height)/2.0,
                            _overlayView.frame.size.width - 2*_frameXOffset,
                            height);
    
    [_overlayView setSightFrame:sightFrame];
    
    double coef = (_image.size.width/_image.size.height>sightFrame.size.width/sightFrame.size.height)?_image.size.height/sightFrame.size.height:_image.size.width/sightFrame.size.width;
    
    CGRect frame = sightFrame;
    frame.origin.y-=navBarHeight;
    frame.size.height = _image.size.height/coef;
    frame.size.width = _image.size.width/coef;
    [_imageView setFrame:frame];
    
    [_imageContainer addSubview:_imageView];
    
    _scale = MIN(_image.size.width/_imageSize.width, _image.size.height/_imageSize.height);
    
    [_scrollView setMinimumZoomScale:1.0];
    [_scrollView setMaximumZoomScale:_scale];
    
    [_imageContainer setFrame:CGRectMake(0.0, 0.0, _imageView.frame.size.width+sightFrame.origin.x*2, _imageView.frame.size.height+sightFrame.origin.y*2 - navBarHeight)];
    
    [self setupContent];
}

- (void)setupContent {
    [_scrollView setContentSize:CGSizeMake(_imageContainer.frame.size.width - sightFrame.origin.x*2*(_scrollView.zoomScale-1.0), _imageContainer.frame.size.height - (sightFrame.origin.y*2 - navBarHeight)*(_scrollView.zoomScale-1.0))];
    
    CGRect frame = _imageContainer.frame;
    
    frame.origin.x = (_scrollView.contentSize.width - _imageContainer.frame.size.width)/2.0;
    frame.origin.y = (_scrollView.contentSize.height - _imageContainer.frame.size.height + navBarHeight*(_scrollView.zoomScale-1.0))/2.0;
    
    _imageContainer.frame = frame;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setupCenter) object:nil];
    [self performSelector:@selector(setupCenter) withObject:nil afterDelay:0.2];
}

- (void)setupCenter{
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-self.view.frame.size.width)/2.0, (_scrollView.contentSize.height-self.view.frame.size.height+navBarHeight)/2.0)];
}

- (void)crop{
    float coef = _scrollView.zoomScale;
    
    CGRect result;
    result.origin.x = roundf(_scrollView.contentOffset.x*_image.size.width/_imageView.frame.size.width/coef);
    result.origin.y = roundf((_scrollView.contentOffset.y+navBarHeight)*_image.size.height/_imageView.frame.size.height/coef);
    result.size.width = roundf(_image.size.width/coef);
    result.size.height = roundf(_image.size.width/coef*_imageSize.height/_imageSize.width);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([_image CGImage], result);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    
    croppedImage = [croppedImage resizeImage:_imageSize];
    
    _completion(_image, result, croppedImage);
    
    [self back];
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ScrollView

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageContainer;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self setCropButtonEnabled:NO];
    [self setupContent];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:nil];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.1];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setCropButtonEnabled:YES];
}

- (void)setCropButtonEnabled:(BOOL)enabled{
    [self.navigationItem.rightBarButtonItem setEnabled:enabled];
    [self.navigationItem.rightBarButtonItem setTintColor:enabled?[UIBarButtonItem appearance].tintColor:[UIColor blackColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
