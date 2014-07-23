//
//  QDImageCropper.m
//  QDImageCropper
//
//  Created by Nikolay on 13/04/14.
//
//

#import "QDImageCropper.h"
#import "QDImageCropperOverlay.h"
#import "UIImage+QDResize.h"

@interface QDImageCropper ()<UIScrollViewDelegate>{
    CGRect sightFrame;
    void(^_completion)(UIImage *image, CGRect rect, UIImage *croppedImage);
}

@property (nonatomic, assign) CGFloat frameYOffset;

@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CGSize imageSize;
@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGFloat scale;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *imageContainer;
@property (strong, nonatomic) QDImageCropperOverlay *overlayView;

@property (strong, nonatomic) UIButton *bButton;
@property (strong, nonatomic) UIButton *cButton;

@end

@implementation QDImageCropper

- (instancetype)initWithImage:(UIImage *)image resultImageSize:(CGSize)imageSize completion:(void (^)(UIImage *, CGRect, UIImage *))completion{
    NSParameterAssert(completion && image);
    NSAssert(!CGSizeEqualToSize(imageSize, CGSizeZero), @"Set image size!");

    self = [super init];
    if (self) {
        [self.view setBackgroundColor:[UIColor whiteColor]];
        _imageSize = imageSize;
        _image = image;
        _completion = completion;
        _frameXOffset = 20.0;
        _overlayColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8];

        _imageView = [[UIImageView alloc] initWithImage:_image];

        _bButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 10.0, 50.0, 20.0)];
        [_bButton setTitle:@"Back" forState:UIControlStateNormal];

        _cButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 10.0, 50.0, 20.0)];
        [_cButton setTitle:@"Crop" forState:UIControlStateNormal];

    }
    return self;
}

- (void)setBackButton:(UIButton *)button {
    [_bButton removeFromSuperview];
    _bButton = button;
    [_bButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_bButton];
    [_bButton setFrame:CGRectMake(10.0, 15.0, _bButton.frame.size.width, _bButton.frame.size.height)];
}

- (void)setCropButton:(UIButton *)button {
    [_cButton removeFromSuperview];
    _cButton = button;
    [self.view addSubview:_cButton];
    [_cButton setFrame:CGRectMake(self.view.frame.size.width - 10.0 - _cButton.frame.size.width, 15.0, _cButton.frame.size.width, _cButton.frame.size.height)];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //NSAssert(self.navigationController, @"Cropper needs navigation controller");

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    [_scrollView setBackgroundColor:[UIColor blackColor]];
    [_scrollView setDelegate:self];
    [self.view addSubview:_scrollView];

    _imageContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    [_scrollView addSubview:_imageContainer];

    _overlayView = [[QDImageCropperOverlay alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_overlayView];

    [_overlayView setColor:_overlayColor];

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

    _frameYOffset = (_overlayView.frame.size.height - height)/2.0;

    sightFrame = CGRectMake(_frameXOffset,
            _frameYOffset,
            _overlayView.frame.size.width - 2*_frameXOffset,
            height);

    [_overlayView setSightFrame:sightFrame];

    double coef = (_image.size.width/_image.size.height>sightFrame.size.width/sightFrame.size.height)?_image.size.height/sightFrame.size.height:_image.size.width/sightFrame.size.width;

    CGRect frame = sightFrame;
    frame.size.height = _image.size.height/coef;
    frame.size.width = _image.size.width/coef;
    [_imageView setFrame:frame];

    [_imageContainer addSubview:_imageView];

    _scale = MIN(_image.size.width/_imageSize.width, _image.size.height/_imageSize.height);

    [_scrollView setMinimumZoomScale:1.0];
    [_scrollView setMaximumZoomScale:_scale];

    [_imageContainer setFrame:CGRectMake(0.0, 0.0, _imageView.frame.size.width+sightFrame.origin.x*2, _imageView.frame.size.height+sightFrame.origin.y*2)];

    [self setupContent];

    [self setBackButton:_bButton];
    [self setCropButton:_cButton];
}

- (void)setupContent {
    [_scrollView setContentSize:CGSizeMake(_imageContainer.frame.size.width - sightFrame.origin.x*2*(_scrollView.zoomScale-1.0), _imageContainer.frame.size.height - (sightFrame.origin.y*2)*(_scrollView.zoomScale-1.0))];

    CGRect frame = _imageContainer.frame;

    frame.origin.x = (_scrollView.contentSize.width - _imageContainer.frame.size.width)/2.0;
    frame.origin.y = (_scrollView.contentSize.height - _imageContainer.frame.size.height)/2.0;

    _imageContainer.frame = frame;
}

- (void)crop{
    float coef = (float) (_scrollView.zoomScale/_scale);

    CGRect result;
    result.origin.x = roundf((float) (_scrollView.contentOffset.x/(_scrollView.contentSize.width - _frameXOffset*2.0)*_image.size.width));
    result.origin.y = roundf((_scrollView.contentOffset.y)/(_scrollView.contentSize.height - _frameYOffset*2.0)*_image.size.height);
    result.size.width = roundf((_imageSize.width/coef));
    result.size.height = roundf(_imageSize.height/coef);

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
    [_cButton setEnabled:enabled];
    [_cButton setTintColor:enabled?[UIBarButtonItem appearance].tintColor:[UIColor blackColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
