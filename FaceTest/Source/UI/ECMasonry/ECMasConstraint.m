//
//  ECMasConstraint.m
//  ECMasonry
//
//  Created by Nick Tymchenko on 1/20/14.
//

#import "ECMasConstraint.h"
#import "ECMasConstraint+Private.h"

#define ECMasMethodNotImplemented() \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
                                 userInfo:nil]

@implementation ECMasConstraint

#pragma mark - Init

- (id)init {
	NSAssert(![self isMemberOfClass:[ECMasConstraint class]], @"ECMasConstraint is an abstract class, you should not instantiate it directly.");
	return [super init];
}

#pragma mark - NSLayoutRelation proxies

- (ECMasConstraint * (^)(id))equalTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationEqual);
    };
}

- (ECMasConstraint * (^)(id))ECMas_equalTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationEqual);
    };
}

- (ECMasConstraint * (^)(id))greaterThanOrEqualTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationGreaterThanOrEqual);
    };
}

- (ECMasConstraint * (^)(id))ECMas_greaterThanOrEqualTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationGreaterThanOrEqual);
    };
}

- (ECMasConstraint * (^)(id))lessThanOrEqualTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationLessThanOrEqual);
    };
}

- (ECMasConstraint * (^)(id))ECMas_lessThanOrEqualTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationLessThanOrEqual);
    };
}

#pragma mark - ECMasLayoutPriority proxies

- (ECMasConstraint * (^)(void))priorityLow {
    return ^id{
        self.priority(ECMasLayoutPriorityDefaultLow);
        return self;
    };
}

- (ECMasConstraint * (^)(void))priorityMedium {
    return ^id{
        self.priority(ECMasLayoutPriorityDefaultMedium);
        return self;
    };
}

- (ECMasConstraint * (^)(void))priorityHigh {
    return ^id{
        self.priority(ECMasLayoutPriorityDefaultHigh);
        return self;
    };
}

#pragma mark - NSLayoutConstraint constant proxies

- (ECMasConstraint * (^)(ECMasEdgeInsets))insets {
    return ^id(ECMasEdgeInsets insets){
        self.insets = insets;
        return self;
    };
}

- (ECMasConstraint * (^)(CGFloat))inset {
    return ^id(CGFloat inset){
        self.inset = inset;
        return self;
    };
}

- (ECMasConstraint * (^)(CGSize))sizeOffset {
    return ^id(CGSize offset) {
        self.sizeOffset = offset;
        return self;
    };
}

- (ECMasConstraint * (^)(CGPoint))centerOffset {
    return ^id(CGPoint offset) {
        self.centerOffset = offset;
        return self;
    };
}

- (ECMasConstraint * (^)(CGFloat))offset {
    return ^id(CGFloat offset){
        self.offset = offset;
        return self;
    };
}

- (ECMasConstraint * (^)(NSValue *value))valueOffset {
    return ^id(NSValue *offset) {
        NSAssert([offset isKindOfClass:NSValue.class], @"expected an NSValue offset, got: %@", offset);
        [self setLayoutConstantWithValue:offset];
        return self;
    };
}

- (ECMasConstraint * (^)(id offset))ECMas_offset {
    // Will never be called due to macro
    return nil;
}

#pragma mark - NSLayoutConstraint constant setter

- (void)setLayoutConstantWithValue:(NSValue *)value {
    if ([value isKindOfClass:NSNumber.class]) {
        self.offset = [(NSNumber *)value doubleValue];
    } else if (strcmp(value.objCType, @encode(CGPoint)) == 0) {
        CGPoint point;
        [value getValue:&point];
        self.centerOffset = point;
    } else if (strcmp(value.objCType, @encode(CGSize)) == 0) {
        CGSize size;
        [value getValue:&size];
        self.sizeOffset = size;
    } else if (strcmp(value.objCType, @encode(ECMasEdgeInsets)) == 0) {
        ECMasEdgeInsets insets;
        [value getValue:&insets];
        self.insets = insets;
    } else {
        NSAssert(NO, @"attempting to set layout constant with unsupported value: %@", value);
    }
}

#pragma mark - Semantic properties

- (ECMasConstraint *)with {
    return self;
}

- (ECMasConstraint *)and {
    return self;
}

#pragma mark - Chaining

- (ECMasConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute __unused)layoutAttribute {
    ECMasMethodNotImplemented();
}

- (ECMasConstraint *)left {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeft];
}

- (ECMasConstraint *)top {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTop];
}

- (ECMasConstraint *)right {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRight];
}

- (ECMasConstraint *)bottom {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottom];
}

- (ECMasConstraint *)leading {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeading];
}

- (ECMasConstraint *)trailing {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailing];
}

- (ECMasConstraint *)width {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeWidth];
}

- (ECMasConstraint *)height {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeHeight];
}

- (ECMasConstraint *)centerX {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterX];
}

- (ECMasConstraint *)centerY {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterY];
}

- (ECMasConstraint *)baseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBaseline];
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (ECMasConstraint *)firstBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeFirstBaseline];
}
- (ECMasConstraint *)lastBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (ECMasConstraint *)leftMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeftMargin];
}

- (ECMasConstraint *)rightMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRightMargin];
}

- (ECMasConstraint *)topMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTopMargin];
}

- (ECMasConstraint *)bottomMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottomMargin];
}

- (ECMasConstraint *)leadingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (ECMasConstraint *)trailingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (ECMasConstraint *)centerXWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (ECMasConstraint *)centerYWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#pragma mark - Abstract

- (ECMasConstraint * (^)(CGFloat multiplier))multipliedBy { ECMasMethodNotImplemented(); }

- (ECMasConstraint * (^)(CGFloat divider))dividedBy { ECMasMethodNotImplemented(); }

- (ECMasConstraint * (^)(ECMasLayoutPriority priority))priority { ECMasMethodNotImplemented(); }

- (ECMasConstraint * (^)(id, NSLayoutRelation))equalToWithRelation { ECMasMethodNotImplemented(); }

- (ECMasConstraint * (^)(id key))key { ECMasMethodNotImplemented(); }

- (void)setInsets:(ECMasEdgeInsets __unused)insets { ECMasMethodNotImplemented(); }

- (void)setInset:(CGFloat __unused)inset { ECMasMethodNotImplemented(); }

- (void)setSizeOffset:(CGSize __unused)sizeOffset { ECMasMethodNotImplemented(); }

- (void)setCenterOffset:(CGPoint __unused)centerOffset { ECMasMethodNotImplemented(); }

- (void)setOffset:(CGFloat __unused)offset { ECMasMethodNotImplemented(); }

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_OS_TV)

- (ECMasConstraint *)animator { ECMasMethodNotImplemented(); }

#endif

- (void)activate { ECMasMethodNotImplemented(); }

- (void)deactivate { ECMasMethodNotImplemented(); }

- (void)install { ECMasMethodNotImplemented(); }

- (void)uninstall { ECMasMethodNotImplemented(); }

@end
