//
//  ViewPager.m
//  UIScrollViewContentContainer
//
//  Created by neevek on 7/30/15.
//  Copyright (c) 2015 neevek. All rights reserved.
//

#import "SimpleViewPager.h"

@implementation SimpleViewPager

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

-(void)_init {
    self.pagingEnabled = YES;
}



@end
