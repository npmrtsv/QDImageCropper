//
//  QDIgnoringTouchesView.m
//  QDImageCropper
//
//  Created by Nikolay on 13/04/14.
//
//

#import "QDIgnoringTouchesView.h"

@implementation QDIgnoringTouchesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self)
        return nil;
    else
        return hitView;
}

@end
