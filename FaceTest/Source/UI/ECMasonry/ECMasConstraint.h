//
//  ECMasConstraint.h
//  ECMasonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "ECMasUtilities.h"

/**
 *	Enables Constraints to be created with chainable syntax
 *  Constraint can represent single NSLayoutConstraint (ECMasViewConstraint) 
 *  or a group of NSLayoutConstraints (ECMasComposisteConstraint)
 */
@interface ECMasConstraint : NSObject

// Chaining Support

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects ECMasConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (ECMasConstraint * (^)(ECMasEdgeInsets insets))insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects ECMasConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (ECMasConstraint * (^)(CGFloat inset))inset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects ECMasConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (ECMasConstraint * (^)(CGSize offset))sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects ECMasConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (ECMasConstraint * (^)(CGPoint offset))centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (ECMasConstraint * (^)(CGFloat offset))offset;

/**
 *  Modifies the NSLayoutConstraint constant based on a value type
 */
- (ECMasConstraint * (^)(NSValue *value))valueOffset;

/**
 *	Sets the NSLayoutConstraint multiplier property
 */
- (ECMasConstraint * (^)(CGFloat multiplier))multipliedBy;

/**
 *	Sets the NSLayoutConstraint multiplier to 1.0/dividedBy
 */
- (ECMasConstraint * (^)(CGFloat divider))dividedBy;

/**
 *	Sets the NSLayoutConstraint priority to a float or ECMasLayoutPriority
 */
- (ECMasConstraint * (^)(ECMasLayoutPriority priority))priority;

/**
 *	Sets the NSLayoutConstraint priority to ECMasLayoutPriorityLow
 */
- (ECMasConstraint * (^)(void))priorityLow;

/**
 *	Sets the NSLayoutConstraint priority to ECMasLayoutPriorityMedium
 */
- (ECMasConstraint * (^)(void))priorityMedium;

/**
 *	Sets the NSLayoutConstraint priority to ECMasLayoutPriorityHigh
 */
- (ECMasConstraint * (^)(void))priorityHigh;

/**
 *	Sets the constraint relation to NSLayoutRelationEqual
 *  returns a block which accepts one of the following:
 *    ECMasViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (ECMasConstraint * (^)(id attr))equalTo;

/**
 *	Sets the constraint relation to NSLayoutRelationGreaterThanOrEqual
 *  returns a block which accepts one of the following:
 *    ECMasViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (ECMasConstraint * (^)(id attr))greaterThanOrEqualTo;

/**
 *	Sets the constraint relation to NSLayoutRelationLessThanOrEqual
 *  returns a block which accepts one of the following:
 *    ECMasViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (ECMasConstraint * (^)(id attr))lessThanOrEqualTo;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (ECMasConstraint *)with;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (ECMasConstraint *)and;

/**
 *	Creates a new ECMasCompositeConstraint with the called attribute and reciever
 */
- (ECMasConstraint *)left;
- (ECMasConstraint *)top;
- (ECMasConstraint *)right;
- (ECMasConstraint *)bottom;
- (ECMasConstraint *)leading;
- (ECMasConstraint *)trailing;
- (ECMasConstraint *)width;
- (ECMasConstraint *)height;
- (ECMasConstraint *)centerX;
- (ECMasConstraint *)centerY;
- (ECMasConstraint *)baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (ECMasConstraint *)firstBaseline;
- (ECMasConstraint *)lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (ECMasConstraint *)leftMargin;
- (ECMasConstraint *)rightMargin;
- (ECMasConstraint *)topMargin;
- (ECMasConstraint *)bottomMargin;
- (ECMasConstraint *)leadingMargin;
- (ECMasConstraint *)trailingMargin;
- (ECMasConstraint *)centerXWithinMargins;
- (ECMasConstraint *)centerYWithinMargins;

#endif


/**
 *	Sets the constraint debug name
 */
- (ECMasConstraint * (^)(id key))key;

// NSLayoutConstraint constant Setters
// for use outside of ECMas_updateConstraints/ECMas_makeConstraints blocks

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects ECMasConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)setInsets:(ECMasEdgeInsets)insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects ECMasConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)setInset:(CGFloat)inset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects ECMasConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (void)setSizeOffset:(CGSize)sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects ECMasConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (void)setCenterOffset:(CGPoint)centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (void)setOffset:(CGFloat)offset;


// NSLayoutConstraint Installation support

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_OS_TV)
/**
 *  Whether or not to go through the animator proxy when modifying the constraint
 */
@property (nonatomic, copy, readonly) ECMasConstraint *animator;
#endif

/**
 *  Activates an NSLayoutConstraint if it's supported by an OS. 
 *  Invokes install otherwise.
 */
- (void)activate;

/**
 *  Deactivates previously installed/activated NSLayoutConstraint.
 */
- (void)deactivate;

/**
 *	Creates a NSLayoutConstraint and adds it to the appropriate view.
 */
- (void)install;

/**
 *	Removes previously installed NSLayoutConstraint
 */
- (void)uninstall;

@end


/**
 *  Convenience auto-boxing macros for ECMasConstraint methods.
 *
 *  Defining ECMas_SHORTHAND_GLOBALS will turn on auto-boxing for default syntax.
 *  A potential drawback of this is that the unprefixed macros will appear in global scope.
 */
#define ECMas_equalTo(...)                 equalTo(ECMasBoxValue((__VA_ARGS__)))
#define ECMas_greaterThanOrEqualTo(...)    greaterThanOrEqualTo(ECMasBoxValue((__VA_ARGS__)))
#define ECMas_lessThanOrEqualTo(...)       lessThanOrEqualTo(ECMasBoxValue((__VA_ARGS__)))

#define ECMas_offset(...)                  valueOffset(ECMasBoxValue((__VA_ARGS__)))


#ifdef ECMas_SHORTHAND_GLOBALS

#define equalTo(...)                     ECMas_equalTo(__VA_ARGS__)
#define greaterThanOrEqualTo(...)        ECMas_greaterThanOrEqualTo(__VA_ARGS__)
#define lessThanOrEqualTo(...)           ECMas_lessThanOrEqualTo(__VA_ARGS__)

#define offset(...)                      ECMas_offset(__VA_ARGS__)

#endif


@interface ECMasConstraint (AutoboxingSupport)

/**
 *  Aliases to corresponding relation methods (for shorthand macros)
 *  Also needed to aid autocompletion
 */
- (ECMasConstraint * (^)(id attr))ECMas_equalTo;
- (ECMasConstraint * (^)(id attr))ECMas_greaterThanOrEqualTo;
- (ECMasConstraint * (^)(id attr))ECMas_lessThanOrEqualTo;

/**
 *  A dummy method to aid autocompletion
 */
- (ECMasConstraint * (^)(id offset))ECMas_offset;

@end
