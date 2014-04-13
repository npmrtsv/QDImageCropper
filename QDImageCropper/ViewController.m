//
//  ViewController.m
//  QDImageCropper
//
//  Created by Nikolay on 13/04/14.
//
//

#import "ViewController.h"
#import "QDImageCropper.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chooseImage:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *newPicker = [[UIImagePickerController alloc] init];
        newPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        newPicker.delegate = self;
        [self presentViewController:newPicker animated:YES completion:nil];
    }else
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Source type UIImagePickerControllerSourceTypeSavedPhotosAlbum is not available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        QDImageCropper *cropper = [[QDImageCropper alloc] initWithImage:img
                                                       resultImageSize:CGSizeMake(100.0, 100.0)
                                                            completion:^(UIImage *image, CGRect rect, UIImage *croppedImage) {
                                                                UIImageView *iv = [[UIImageView alloc] initWithImage:croppedImage];
                                                                [self.view addSubview:iv];
                                                       }];
        UINavigationController *navContr = [[UINavigationController alloc] initWithRootViewController:cropper];
        
        [self presentViewController:navContr animated:YES completion:nil];
    }];
}

@end
