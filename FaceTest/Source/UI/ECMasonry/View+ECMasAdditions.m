//
//  UIView+ECMasAdditions.m
//  ECMasonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "View+ECMASAdditions.h"
#import <objc/runtime.h>

@implementation ECMas_VIEW (ECMasAdditions)

- (NSArray *)ECMas_makeConstraints:(void(^)(ECMasConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    ECMasConstraintMaker *constraintMaker = [[ECMasConstraintMaker alloc] initWithView:self];
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)ECMas_updateConstraints:(void(^)(ECMasConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    ECMasConstraintMaker *constraintMaker = [[ECMasConstraintMaker alloc] initWithView:self];
    constraintMaker.updateExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)ECMas_remakeConstraints:(void(^)(ECMasConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    ECMasConstraintMaker *constraintMaker = [[ECMasConstraintMaker alloc] initWithView:self];
    constraintMaker.removeExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

#pragma mark - NSLayoutAttribute properties

- (ECMasViewAttribute *)ECMas_left {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
}

- (ECMasViewAttribute *)ECMas_top {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
}

- (ECMasViewAttribute *)ECMas_right {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
}

- (ECMasViewAttribute *)ECMas_bottom {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
}

- (ECMasViewAttribute *)ECMas_leading {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
}

- (ECMasViewAttribute *)ECMas_trailing {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
}

- (ECMasViewAttribute *)ECMas_width {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeWidth];
}

- (ECMasViewAttribute *)ECMas_height {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeHeight];
}

- (ECMasViewAttribute *)ECMas_centerX {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterX];
}

- (ECMasViewAttribute *)ECMas_centerY {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterY];
}

- (ECMasViewAttribute *)ECMas_baseline {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBaseline];
}

- (ECMasViewAttribute *(^)(NSLayoutAttribute))ECMas_attribute
{
    return ^(NSLayoutAttribute attr) {
        return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:attr];
    };
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (ECMasViewAttribute *)ECMas_firstBaseline {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeFirstBaseline];
}
- (ECMasViewAttribute *)ECMas_lastBaseline {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (ECMasViewAttribute *)ECMas_leftMargin {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeftMargin];
}

- (ECMasViewAttribute *)ECMas_rightMargin {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRightMargin];
}

- (ECMasViewAttribute *)ECMas_topMargin {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTopMargin];
}

- (ECMasViewAttribute *)ECMas_bottomMargin {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottomMargin];
}

- (ECMasViewAttribute *)ECMas_leadingMargin {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (ECMasViewAttribute *)ECMas_trailingMargin {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (ECMasViewAttribute *)ECMas_centerXWithinMargins {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (ECMasViewAttribute *)ECMas_centerYWithinMargins {
    return [[ECMasViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

- (ECMasViewAttribute *)ECMas_safeAreaLayoutGuide {
    return [[ECMasViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (ECMasViewAttribute *)ECMas_safeAreaLayoutGuideTop {
    return [[ECMasViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (ECMasViewAttribute *)ECMas_safeAreaLayoutGuideBottom {
    return [[ECMasViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (ECMasViewAttribute *)ECMas_safeAreaLayoutGuideLeft {
    return [[ECMasViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeLeft];
}
- (ECMasViewAttribute *)ECMas_safeAreaLayoutGuideRight {
    return [[ECMasViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeRight];
}

#endif

#pragma mark - associated properties

- (id)ECMas_key {
    return objc_getAssociatedObject(self, @selector(ECMas_key));
}

- (void)setECMas_key:(id)key {
    objc_setAssociatedObject(self, @selector(ECMas_key), key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - heirachy

- (instancetype)ECMas_closestCommonSuperview:(ECMas_VIEW *)view {
    ECMas_VIEW *closestCommonSuperview = nil;

    ECMas_VIEW *secondViewSuperview = view;
    while (!closestCommonSuperview && secondViewSuperview) {
        ECMas_VIEW *firstViewSuperview = self;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview;
}

@end
