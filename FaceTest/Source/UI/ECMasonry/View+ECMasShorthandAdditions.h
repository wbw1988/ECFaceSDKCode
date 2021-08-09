//
//  UIView+ECMasShorthandAdditions.h
//  ECMasonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "View+ECMasAdditions.h"

#ifdef ECMas_SHORTHAND

/**
 *	Shorthand view additions without the 'ECMas_' prefixes,
 *  only enabled if ECMas_SHORTHAND is defined
 */
@interface ECMas_VIEW (ECMasShorthandAdditions)

@property (nonatomic, strong, readonly) ECMasViewAttribute *left;
@property (nonatomic, strong, readonly) ECMasViewAttribute *top;
@property (nonatomic, strong, readonly) ECMasViewAttribute *right;
@property (nonatomic, strong, readonly) ECMasViewAttribute *bottom;
@property (nonatomic, strong, readonly) ECMasViewAttribute *leading;
@property (nonatomic, strong, readonly) ECMasViewAttribute *trailing;
@property (nonatomic, strong, readonly) ECMasViewAttribute *width;
@property (nonatomic, strong, readonly) ECMasViewAttribute *height;
@property (nonatomic, strong, readonly) ECMasViewAttribute *centerX;
@property (nonatomic, strong, readonly) ECMasViewAttribute *centerY;
@property (nonatomic, strong, readonly) ECMasViewAttribute *baseline;
@property (nonatomic, strong, readonly) ECMasViewAttribute *(^attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) ECMasViewAttribute *firstBaseline;
@property (nonatomic, strong, readonly) ECMasViewAttribute *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) ECMasViewAttribute *leftMargin;
@property (nonatomic, strong, readonly) ECMasViewAttribute *rightMargin;
@property (nonatomic, strong, readonly) ECMasViewAttribute *topMargin;
@property (nonatomic, strong, readonly) ECMasViewAttribute *bottomMargin;
@property (nonatomic, strong, readonly) ECMasViewAttribute *leadingMargin;
@property (nonatomic, strong, readonly) ECMasViewAttribute *trailingMargin;
@property (nonatomic, strong, readonly) ECMasViewAttribute *centerXWithinMargins;
@property (nonatomic, strong, readonly) ECMasViewAttribute *centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) ECMasViewAttribute *safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) ECMasViewAttribute *safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) ECMasViewAttribute *safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) ECMasViewAttribute *safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

- (NSArray *)makeConstraints:(void(^)(ECMasConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(ECMasConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(ECMasConstraintMaker *make))block;

@end

#define ECMas_ATTR_FORWARD(attr)  \
- (ECMasViewAttribute *)attr {    \
    return [self ECMas_##attr];   \
}

@implementation ECMas_VIEW (ECMasShorthandAdditions)

ECMas_ATTR_FORWARD(top);
ECMas_ATTR_FORWARD(left);
ECMas_ATTR_FORWARD(bottom);
ECMas_ATTR_FORWARD(right);
ECMas_ATTR_FORWARD(leading);
ECMas_ATTR_FORWARD(trailing);
ECMas_ATTR_FORWARD(width);
ECMas_ATTR_FORWARD(height);
ECMas_ATTR_FORWARD(centerX);
ECMas_ATTR_FORWARD(centerY);
ECMas_ATTR_FORWARD(baseline);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

ECMas_ATTR_FORWARD(firstBaseline);
ECMas_ATTR_FORWARD(lastBaseline);

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

ECMas_ATTR_FORWARD(leftMargin);
ECMas_ATTR_FORWARD(rightMargin);
ECMas_ATTR_FORWARD(topMargin);
ECMas_ATTR_FORWARD(bottomMargin);
ECMas_ATTR_FORWARD(leadingMargin);
ECMas_ATTR_FORWARD(trailingMargin);
ECMas_ATTR_FORWARD(centerXWithinMargins);
ECMas_ATTR_FORWARD(centerYWithinMargins);

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

ECMas_ATTR_FORWARD(safeAreaLayoutGuideTop);
ECMas_ATTR_FORWARD(safeAreaLayoutGuideBottom);
ECMas_ATTR_FORWARD(safeAreaLayoutGuideLeft);
ECMas_ATTR_FORWARD(safeAreaLayoutGuideRight);

#endif

- (ECMasViewAttribute *(^)(NSLayoutAttribute))attribute {
    return [self ECMas_attribute];
}

- (NSArray *)makeConstraints:(void(NS_NOESCAPE ^)(ECMasConstraintMaker *))block {
    return [self ECMas_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(NS_NOESCAPE ^)(ECMasConstraintMaker *))block {
    return [self ECMas_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(NS_NOESCAPE ^)(ECMasConstraintMaker *))block {
    return [self ECMas_remakeConstraints:block];
}

@end

#endif
