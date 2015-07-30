//
//  UIScrollViewContentContainer.h
//  UIScrollViewContentContainer
//
//  Created by neevek on 7/24/15.
//  Copyright (c) 2015 neevek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollViewContentContainer : UIView

@property (nonatomic) UIEdgeInsets layoutInsets;
@property (nonatomic) CGFloat itemMargin;
@property (nonatomic) UILayoutConstraintAxis orientation;
@property (nonatomic) BOOL shouldRestrictSubviewsWithinBounds;
@property (nonatomic) BOOL centerItems;
@property (nonatomic) BOOL pagingEnabled;

@end
