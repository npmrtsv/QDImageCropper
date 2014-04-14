QDImageCropper
==============

<img src=http://cl.ly/image/2S2p1g3U472Z/Image%202014-04-13%20at%202.52.43%20am.png></img>

<h2>Installation</h2>

    pod 'QDImageCropper', '~> 0.0.3'

<h2>How to use</h2>

    QDImageCropper *cropper = [[QDImageCropper alloc] initWithImage:img
                                                       resultImageSize:CGSizeMake(100.0, 100.0)
                                                            completion:^(UIImage *image, CGRect rect, UIImage *croppedImage) {
                                                                //image — real image
                                                                //rect — real chosen image rect
                                                                //cropped image — cropped image (100x100)
                                                       }];
    UINavigationController *navContr = [[UINavigationController alloc] initWithRootViewController:cropper];
        
    [self presentViewController:navContr animated:YES completion:nil];
    
<h2>Info</h2>

You can set X-axis frame offset and overlay color by editing properties in QDImageCropper.
iOS 6.0

<h2>Licence</h2>

QDImageCropper is available under the MIT license. See the LICENSE file for more info.
