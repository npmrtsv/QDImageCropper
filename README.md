QDImageCropper
==============

<img src=http://cl.ly/image/2S2p1g3U472Z/Image%202014-04-13%20at%202.52.43%20am.png></img>

<h1>How to use</h1>

    QDImageCropper *cropper = [[QDImageCropper alloc] initWithImage:img
                                                       resultImageSize:CGSizeMake(100.0, 100.0)
                                                            completion:^(UIImage *image, CGRect rect, UIImage *croppedImage) {
                                                                //image — real image
                                                                //rect — real chosen image rect
                                                                //cropped image — cropped image (100x100)
                                                       }];
    UINavigationController *navContr = [[UINavigationController alloc] initWithRootViewController:cropper];
        
    [self presentViewController:navContr animated:YES completion:nil];
    
iOS 5.0+
    
<h1>Some customization</h1>

You can set X-axis frame offset and overlay color by editing properties in QDImageCropper.

<h1>Licence</h1>

QDImageCropper is available under the MIT license. See the LICENSE file for more info.
