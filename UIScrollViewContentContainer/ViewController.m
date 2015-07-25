//
//  ViewController.m
//  UIScrollViewContentContainer
//
//  Created by neevek on 7/25/15.
//  Copyright (c) 2015 neevek. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollViewContentContainer.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollViewContentContainer *scrollViewContentContainer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollViewContentContainer.orientation = UILayoutConstraintAxisHorizontal;
    self.scrollViewContentContainer.layoutInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    self.scrollViewContentContainer.itemMargin = 20;
    self.scrollViewContentContainer.shouldRestrictSubviewsWithinBounds = YES;
    self.scrollViewContentContainer.centerItems = YES;

    NSMutableArray *toBeDeleted = [[NSMutableArray alloc] init];
        for (int i = 0; i < 10; ++i) {
            UIView *v = [self createImageView];
            [self.scrollViewContentContainer addSubview:v];
    
            if (i % 2 == 0) {
                [toBeDeleted addObject:v];
            }
        }
        // we don't need to call 'invalidateIntrinsicContentSize' at this point
        // since we are in viewDidLoad(before constrains of contentView are applied for the first time)
        // [self.scrollViewContentContainer invalidateIntrinsicContentSize];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *v in toBeDeleted) {
            [v removeFromSuperview];
        }
        
        // this method MUST be called if the subviews of contentView are removed or
        // views are added the contentView
        [self.scrollViewContentContainer invalidateIntrinsicContentSize];
        // this method is optional, call it if you want your content to be exactly the
        // fill contentView
        [self.scrollViewContentContainer sizeToFit];
    });

}

-(UIImageView *)createImageView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dog"]];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    return imageView;
}


@end
