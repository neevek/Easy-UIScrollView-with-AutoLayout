//
//  UIScrollViewContentContainer.m
//
//  Created by neevek on 7/24/15.
//  Copyright (c) 2015 neevek. All rights reserved.
//

#import "UIScrollViewContentContainer.h"

@interface UIScrollViewContentContainer()
@property (nonatomic, weak) NSLayoutConstraint *widthConstraint;
@property (nonatomic, weak) NSLayoutConstraint *heightConstraint;
@end

@implementation UIScrollViewContentContainer

-(void)updateConstraints {
    if (self.subviews.count > 0) {
        if ([self.superview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *parent = (UIScrollView *)self.superview;
            if (parent.pagingEnabled) {
                self.pagingEnabled = YES;
            }
        }
        
        if (self.heightConstraint == nil) {
            self.heightConstraint = [self findConstraintForView:self layoutAttribute:NSLayoutAttributeHeight];
        }
        if (self.widthConstraint == nil) {
            self.widthConstraint = [self findConstraintForView:self layoutAttribute:NSLayoutAttributeWidth];
        }
        
        [self prepareForUpdateConstraints];
        
        if (self.orientation == UILayoutConstraintAxisHorizontal) {
            if (self.pagingEnabled) {
                [self expandSubviewsForPaging];
            } else if (self.shouldRestrictSubviewsWithinBounds) {
                [self restrictSubviewsHeightWithinBoundsIfNeeded];
            }
            
            [self growWidthIfNeeded];
            
        } else {
            if (self.pagingEnabled) {
                [self expandSubviewsForPaging];
            } else if (self.shouldRestrictSubviewsWithinBounds) {
                [self restrictSubviewsWidthWithinBoundsIfNeeded];
            }
            
            [self growHeightIfNeeded];
        }
        
        [self resetConstraints];
    }
    
    [super updateConstraints];
}

-(NSLayoutConstraint *)findConstraintForView:(UIView *)view layoutAttribute:(NSLayoutAttribute)layoutAttribute {
    for (NSLayoutConstraint *heightConstraint in view.constraints) {
        if (heightConstraint.firstItem == view && heightConstraint.firstAttribute == layoutAttribute) {
            return heightConstraint;
        }
    }
    
    return nil;
}

-(void)expandSubviewsForPaging {
    const NSUInteger count = self.subviews.count;
    for (int i = 0; i < count; ++i) {
        if (self.orientation == UILayoutConstraintAxisHorizontal) {
            [self expandWidthForSubview:self.subviews[i] atIndex:i];
        } else {
            [self expandHeightForSubview:self.subviews[i] atIndex:i];
        }
    }
}

-(void)expandWidthForSubview:(UIView *)subview atIndex:(int)index {
    NSLayoutConstraint *widthConstraint = [self findConstraintForView:subview layoutAttribute:NSLayoutAttributeWidth];
    if (widthConstraint) {
        widthConstraint.constant = [self adjustSubviewWidth:[UIScreen mainScreen].bounds.size.width atIndex:index];
    } else {
        widthConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:0
                                                      multiplier:1.0f
                                                        constant:[self adjustSubviewWidth:[UIScreen mainScreen].bounds.size.width atIndex:index]];
        [subview addConstraint:widthConstraint];
    }
    
    NSLayoutConstraint *heightConstraint = [self findConstraintForView:subview layoutAttribute:NSLayoutAttributeHeight];
    CGFloat height = self.heightConstraint.constant - self.layoutInsets.top - self.layoutInsets.bottom;
    if (heightConstraint) {
        heightConstraint.constant = height;
    } else {
        heightConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:0
                                                       multiplier:1.0f
                                                         constant:height];
        [subview addConstraint:heightConstraint];
    }
}

-(void)expandHeightForSubview:(UIView *)subview atIndex:(int)index {
    NSLayoutConstraint *heightConstraint = [self findConstraintForView:subview layoutAttribute:NSLayoutAttributeHeight];
    if (heightConstraint) {
        heightConstraint.constant = [self adjustSubviewHeight:self.heightConstraint.constant atIndex:index];
    } else {
        heightConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:0
                                                       multiplier:1.0f
                                                         constant:[self adjustSubviewHeight:self.heightConstraint.constant atIndex:index]];
        [subview addConstraint:heightConstraint];
    }
    
    NSLayoutConstraint *widthConstraint = [self findConstraintForView:subview layoutAttribute:NSLayoutAttributeWidth];
    CGFloat width = self.widthConstraint.constant - self.layoutInsets.left - self.layoutInsets.right;
    if (widthConstraint) {
        widthConstraint.constant = width;
    } else {
        widthConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:0
                                                       multiplier:1.0f
                                                         constant:width];
        [subview addConstraint:widthConstraint];
    }
}

-(CGFloat)adjustSubviewWidth:(CGFloat)width atIndex:(NSUInteger)index {
    const NSUInteger count = self.subviews.count;
    if (index == 0) {
        width -= self.layoutInsets.left;
        if (index + 1 == count) {
            width -= self.layoutInsets.right;
        } else {
            width -= (self.itemMargin / 2);
        }
    } else if (index > 0) {
        width -= (self.itemMargin / 2);
        
        if (index + 1 == count) {
            width -= self.layoutInsets.right;
        } else {
            width -= (self.itemMargin / 2);
        }
    }
    
    return width;
}

-(CGFloat)adjustSubviewHeight:(CGFloat)height atIndex:(NSUInteger)index {
    const NSUInteger count = self.subviews.count;
    if (index == 0) {
        height -= self.layoutInsets.top;
        if (index + 1 == count) {
            height -= self.layoutInsets.bottom;
        } else {
            height -= (self.itemMargin / 2);
        }
    } else if (index > 0) {
        height -= (self.itemMargin / 2);
        
        if (index + 1 == count) {
            height -= self.layoutInsets.bottom;
        } else {
            height -= (self.itemMargin / 2);
        }
    }
    
    return height;
}

-(void)restrictSubviewsHeightWithinBoundsIfNeeded {
    if (!self.shouldRestrictSubviewsWithinBounds || self.subviews.count == 0) {
        return;
    }
    
    CGFloat allowedMaxHeight = self.heightConstraint.constant - self.layoutInsets.top - self.layoutInsets.bottom;
    if (allowedMaxHeight <= 0) {
        return;
    }
    
    for (UIView *view in self.subviews) {
        // if the view implements the 'intrinsicContentSize' method, IB will generate
        // NSContentSizeLayoutConstraint for it so we will definitely find one
        NSLayoutConstraint *heightConstraint = [self findConstraintForView:view layoutAttribute:NSLayoutAttributeHeight];
        if (heightConstraint.constant <= allowedMaxHeight) {
            continue;
        }
        
        NSLayoutConstraint *widthConstraint = [self findConstraintForView:view layoutAttribute:NSLayoutAttributeWidth];
        widthConstraint.constant *= (allowedMaxHeight / heightConstraint.constant);
        
        heightConstraint.constant = allowedMaxHeight;
    }
}

-(void)restrictSubviewsWidthWithinBoundsIfNeeded {
    CGFloat allowedMaxWidth = self.widthConstraint.constant - self.layoutInsets.left - self.layoutInsets.right;
    if (allowedMaxWidth <= 0) {
        return;
    }
    
    for (UIView *view in self.subviews) {
        // if the view implements the 'intrinsicContentSize' method, IB will generate
        // NSContentSizeLayoutConstraint for it so we will definitely find one
        NSLayoutConstraint *widthConstraint = [self findConstraintForView:view layoutAttribute:NSLayoutAttributeWidth];
        if (widthConstraint.constant <= allowedMaxWidth) {
            continue;
        }
        
        NSLayoutConstraint *heightConstraint = [self findConstraintForView:view layoutAttribute:NSLayoutAttributeHeight];
        heightConstraint.constant *= (allowedMaxWidth / widthConstraint.constant);
        
        widthConstraint.constant = allowedMaxWidth;
    }
}

-(void)growWidthIfNeeded {
    CGFloat contentWidth = [self calculateContentWidth];
    if (contentWidth > self.widthConstraint.constant) {
        self.widthConstraint.constant = contentWidth;
    }
}

-(void)growHeightIfNeeded {
    CGFloat contentHeight = [self calculateContentHeight];
    if (contentHeight > self.heightConstraint.constant) {
        self.heightConstraint.constant = contentHeight;
    }
}

-(CGFloat)calculateContentWidth {
    CGFloat totalWidth = self.layoutInsets.left + self.layoutInsets.right;
    for (UIView *view in self.subviews) {
        NSLayoutConstraint *widthConstraint = [self findConstraintForView:view layoutAttribute:NSLayoutAttributeWidth];
        totalWidth += (widthConstraint.constant + self.itemMargin);
    }
    
    totalWidth -= self.itemMargin;  // minus the last one
    
    return totalWidth;
}

-(CGFloat)calculateContentHeight {
    CGFloat totalHeight = self.layoutInsets.top + self.layoutInsets.bottom;
    for (UIView *view in self.subviews) {
        NSLayoutConstraint *heightConstraint = [self findConstraintForView:view layoutAttribute:NSLayoutAttributeHeight];
        totalHeight += (heightConstraint.constant + self.itemMargin);
    }
    
    totalHeight -= self.itemMargin;  // minus the last one
    
    return totalHeight;
}

-(void)prepareForUpdateConstraints {
    if (self.subviews.count == 0) {
        return;
    }
    
    NSArray *constraints = self.constraints;
    for (int i = 0; i < constraints.count; ++i) {
        NSLayoutConstraint *constraint = constraints[i];
        // if it is constraint for my subview
        if (constraint.firstItem != self || constraint.secondItem != nil) {
            // if we should change the dimension constraints for this subview in [self updateConstraints],
            // or the constraint is not width/height constraint
            if (self.shouldRestrictSubviewsWithinBounds || (constraint.firstAttribute != NSLayoutAttributeWidth && constraint.firstAttribute != NSLayoutAttributeHeight)) {
                [self removeConstraint:constraint];
            }
        }
    }
}

-(void)resetConstraints {
    if (self.subviews.count == 0) {
        return;
    }
    
    NSArray *constraints = self.constraints;
    for (int i = 0; i < constraints.count; ++i) {
        NSLayoutConstraint *constraint = constraints[i];
        // if it is constraint for my subview
        if (constraint.firstItem != self || constraint.secondItem != nil) {
            // if we should change the dimension constraints for this subview in [self updateConstraints],
            // or the constraint is not width/height constraint
            if (self.shouldRestrictSubviewsWithinBounds || (constraint.firstAttribute != NSLayoutAttributeWidth && constraint.firstAttribute != NSLayoutAttributeHeight)) {
                [self removeConstraint:constraint];
            }
        }
    }
    
    UIView *prev = nil;
    UIView *next = nil;
    for (int i = 0; i < self.subviews.count; ++i) {
        UIView *current = self.subviews[i];
        
        if (i + 1 < self.subviews.count) {
            next = self.subviews[i + 1];
        } else {
            next = nil;
        }
        
        NSDictionary *viewDict;
        NSString *vfl;
        
        if (prev == nil && next == nil) {
            NSString *format =self.orientation == UILayoutConstraintAxisHorizontal ? @"H:|-%g-[current]-(>=%g)-|" : @"V:|-%g-[current]-(>=%g)-|";
            vfl = [NSString stringWithFormat:format, self.layoutInsets.left, self.layoutInsets.right];
            viewDict = NSDictionaryOfVariableBindings(current);
            
        } else if (prev == nil) {
            NSString *format =self.orientation == UILayoutConstraintAxisHorizontal ? @"H:|-%g-[current]" : @"V:|-%g-[current]";
            vfl = [NSString stringWithFormat:format, self.layoutInsets.left];
            viewDict = NSDictionaryOfVariableBindings(current);
            
        } else if (next == nil) {
            NSString *format =self.orientation == UILayoutConstraintAxisHorizontal ? @"H:[prev]-%g-[current]-(>=%g)-|" : @"V:[prev]-%g-[current]-(>=%g)-|";
            vfl = [NSString stringWithFormat:format, self.itemMargin, self.layoutInsets.right];
            viewDict = NSDictionaryOfVariableBindings(current, prev);
            
        } else {
            NSString *format =self.orientation == UILayoutConstraintAxisHorizontal ? @"H:[prev]-%g-[current]-%g-[next]" : @"V:[prev]-%g-[current]-%g-[next]";
            vfl = [NSString stringWithFormat:format, self.itemMargin, self.itemMargin];
            viewDict = NSDictionaryOfVariableBindings(current, prev, next);
        }
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:nil views:viewDict]];
        
        if (self.centerItems) {
            NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:current
                                                                                attribute:self.orientation == UILayoutConstraintAxisHorizontal ? NSLayoutAttributeCenterY : NSLayoutAttributeCenterX
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:self.orientation == UILayoutConstraintAxisHorizontal ? NSLayoutAttributeCenterY : NSLayoutAttributeCenterX
                                                                               multiplier:1.0
                                                                                 constant:0];
            [self addConstraint:centerConstraint];
            
        } else {
            NSString *format =self.orientation == UILayoutConstraintAxisHorizontal ? @"V:|-%g-[current]-(>=%g)-|" : @"H:|-%g-[current]-(>=%g)-|";
            vfl = [NSString stringWithFormat:format, self.layoutInsets.top, self.layoutInsets.bottom];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:nil views:viewDict]];
        }
        
        
        
        prev = current;
    }
}

-(CGSize)sizeThatFits:(CGSize)size {
    if (self.orientation == UILayoutConstraintAxisHorizontal) {
        size.width = [self calculateContentWidth];
        
        if (size.width != self.widthConstraint.constant) {
            // update the constraint
            self.widthConstraint.constant = size.width;
        }
        
    } else {
        size.height = [self calculateContentHeight];
        
        if (size.height != self.heightConstraint.constant) {
            // update the constraint
            self.heightConstraint.constant = size.height;
        }
    }
    
    return size;
}

-(CGSize)intrinsicContentSize {
    return CGSizeMake(self.widthConstraint.constant, self.heightConstraint.constant);
}

@end