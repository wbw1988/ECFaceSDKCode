//
//  ECMasConstraintMaker.m
//  ECMasonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "ECMasConstraintMaker.h"
#import "ECMasViewConstraint.h"
#import "ECMasCompositeConstraint.h"
#import "ECMasConstraint+Private.h"
#import "ECMasViewAttribute.h"
#import "View+ECMasAdditions.h"

@interface ECMasConstraintMaker () <ECMasConstraintDelegate>

@property (nonatomic, weak) ECMas_VIEW *view;
@property (nonatomic, strong) NSMutableArray *constraints;

@end

@implementation ECMasConstraintMaker

- (id)initWithView:(ECMas_VIEW *)view {
    self = [super init];
    if (!self) return nil;
    
    self.view = view;
    self.constraints = NSMutableArray.new;
    
    return self;
}

- (NSArray *)install {
    if (self.removeExisting) {
        NSArray *installedConstraints = [ECMasViewConstraint installedConstraintsForView:self.view];
        for (ECMasConstraint *constraint in installedConstraints) {
            [constraint uninstall];
        }
    }
    NSArray *constraints = self.constraints.copy;
    for (ECMasConstraint *constraint in constraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
    [self.constraints removeAllObjects];
    return constraints;
}

#pragma mark - ECMasConstraintDelegate

- (void)constraint:(ECMasConstraint *)constraint shouldBeReplacedWithConstraint:(ECMasConstraint *)replacementConstraint {
    NSUInteger index = [self.constraints indexOfObject:constraint];
    NSAssert(index != NSNotFound, @"Could not find constraint %@", constraint);
    [self.constraints replaceObjectAtIndex:index withObject:replacementConstraint];
}

- (ECMasConstraint *)constraint:(ECMasConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    ECMasViewAttribute *viewAttribute = [[ECMasViewAttribute alloc] initWithView:self.view layoutAttribute:layoutAttribute];
    ECMasViewConstraint *newConstraint = [[ECMasViewConstraint alloc] initWithFirstViewAttribute:viewAttribute];
    if ([constraint isKindOfClass:ECMasViewConstraint.class]) {
        //replace with composite constraint
        NSArray *children = @[constraint, newConstraint];
        ECMasCompositeConstraint *compositeConstraint = [[ECMasCompositeConstraint alloc] initWithChildren:children];
        compositeConstraint.delegate = self;
        [self constraint:constraint shouldBeReplacedWithConstraint:compositeConstraint];
        return compositeConstraint;
    }
    if (!constraint) {
        newConstraint.delegate = self;
        [self.constraints addObject:newConstraint];
    }
    return newConstraint;
}

- (ECMasConstraint *)addConstraintWithAttributes:(ECMasAttribute)attrs {
    __unused ECMasAttribute anyAttribute = (ECMasAttributeLeft | ECMasAttributeRight | ECMasAttributeTop | ECMasAttributeBottom | ECMasAttributeLeading
                                          | ECMasAttributeTrailing | ECMasAttributeWidth | ECMasAttributeHeight | ECMasAttributeCenterX
                                          | ECMasAttributeCenterY | ECMasAttributeBaseline
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
                                          | ECMasAttributeFirstBaseline | ECMasAttributeLastBaseline
#endif
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
                                          | ECMasAttributeLeftMargin | ECMasAttributeRightMargin | ECMasAttributeTopMargin | ECMasAttributeBottomMargin
                                          | ECMasAttributeLeadingMargin | ECMasAttributeTrailingMargin | ECMasAttributeCenterXWithinMargins
                                          | ECMasAttributeCenterYWithinMargins
#endif
                                          );
    
    NSAssert((attrs & anyAttribute) != 0, @"You didn't pass any attribute to make.attributes(...)");
    
    NSMutableArray *attributes = [NSMutableArray array];
    
    if (attrs & ECMasAttributeLeft) [attributes addObject:self.view.ECMas_left];
    if (attrs & ECMasAttributeRight) [attributes addObject:self.view.ECMas_right];
    if (attrs & ECMasAttributeTop) [attributes addObject:self.view.ECMas_top];
    if (attrs & ECMasAttributeBottom) [attributes addObject:self.view.ECMas_bottom];
    if (attrs & ECMasAttributeLeading) [attributes addObject:self.view.ECMas_leading];
    if (attrs & ECMasAttributeTrailing) [attributes addObject:self.view.ECMas_trailing];
    if (attrs & ECMasAttributeWidth) [attributes addObject:self.view.ECMas_width];
    if (attrs & ECMasAttributeHeight) [attributes addObject:self.view.ECMas_height];
    if (attrs & ECMasAttributeCenterX) [attributes addObject:self.view.ECMas_centerX];
    if (attrs & ECMasAttributeCenterY) [attributes addObject:self.view.ECMas_centerY];
    if (attrs & ECMasAttributeBaseline) [attributes addObject:self.view.ECMas_baseline];
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    if (attrs & ECMasAttributeFirstBaseline) [attributes addObject:self.view.ECMas_firstBaseline];
    if (attrs & ECMasAttributeLastBaseline) [attributes addObject:self.view.ECMas_lastBaseline];
    
#endif
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
    
    if (attrs & ECMasAttributeLeftMargin) [attributes addObject:self.view.ECMas_leftMargin];
    if (attrs & ECMasAttributeRightMargin) [attributes addObject:self.view.ECMas_rightMargin];
    if (attrs & ECMasAttributeTopMargin) [attributes addObject:self.view.ECMas_topMargin];
    if (attrs & ECMasAttributeBottomMargin) [attributes addObject:self.view.ECMas_bottomMargin];
    if (attrs & ECMasAttributeLeadingMargin) [attributes addObject:self.view.ECMas_leadingMargin];
    if (attrs & ECMasAttributeTrailingMargin) [attributes addObject:self.view.ECMas_trailingMargin];
    if (attrs & ECMasAttributeCenterXWithinMargins) [attributes addObject:self.view.ECMas_centerXWithinMargins];
    if (attrs & ECMasAttributeCenterYWithinMargins) [attributes addObject:self.view.ECMas_centerYWithinMargins];
    
#endif
    
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:attributes.count];
    
    for (ECMasViewAttribute *a in attributes) {
        [children addObject:[[ECMasViewConstraint alloc] initWithFirstViewAttribute:a]];
    }
    
    ECMasCompositeConstraint *constraint = [[ECMasCompositeConstraint alloc] initWithChildren:children];
    constraint.delegate = self;
    [self.constraints addObject:constraint];
    return constraint;
}

#pragma mark - standard Attributes

- (ECMasConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    return [self constraint:nil addConstraintWithLayoutAttribute:layoutAttribute];
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

- (ECMasConstraint *(^)(ECMasAttribute))attributes {
    return ^(ECMasAttribute attrs){
        return [self addConstraintWithAttributes:attrs];
    };
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


#pragma mark - composite Attributes

- (ECMasConstraint *)edges {
    return [self addConstraintWithAttributes:ECMasAttributeTop | ECMasAttributeLeft | ECMasAttributeRight | ECMasAttributeBottom];
}

- (ECMasConstraint *)size {
    return [self addConstraintWithAttributes:ECMasAttributeWidth | ECMasAttributeHeight];
}

- (ECMasConstraint *)center {
    return [self addConstraintWithAttributes:ECMasAttributeCenterX | ECMasAttributeCenterY];
}

#pragma mark - grouping

- (ECMasConstraint *(^)(dispatch_block_t group))group {
    return ^id(dispatch_block_t group) {
        NSInteger previousCount = self.constraints.count;
        group();

        NSArray *children = [self.constraints subarrayWithRange:NSMakeRange(previousCount, self.constraints.count - previousCount)];
        ECMasCompositeConstraint *constraint = [[ECMasCompositeConstraint alloc] initWithChildren:children];
        constraint.delegate = self;
        return constraint;
    };
}

@end
