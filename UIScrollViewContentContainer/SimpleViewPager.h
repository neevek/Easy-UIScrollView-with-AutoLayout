//
//  ViewPager.h
//  UIScrollViewContentContainer
//
//  Created by neevek on 7/30/15.
//  Copyright (c) 2015 neevek. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ViewPagerDelegate

@optional
-(NSUInteger)numberOfPage;
-(UIView *)pageViewForIndex:(NSUInteger)index;

@end

@interface SimpleViewPager : UIScrollView

-(void)addPageView:(UIView *)pageView;

@end
