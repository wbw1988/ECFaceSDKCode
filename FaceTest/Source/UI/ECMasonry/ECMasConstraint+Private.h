//
//  ECMasConstraint+Private.h
//  ECMasonry
//
//  Created by Nick Tymchenko on 29/04/14.
//  Copyright (c) 2014 cloudling. All rights reserved.
//

#import "ECMasConstraint.h"

@protocol ECMasConstraintDelegate;


@interface ECMasConstraint ()

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *	Usually ECMasConstraintMaker but could be a parent ECMasConstraint
 */
@property (nonatomic, weak) id<ECMasConstraintDelegate> delegate;

/**
 *  Based on a provided value type, is equal to calling:
 *  NSNumber - setOffset:
 *  NSValue with CGPoint - setPointOffset:
 *  NSValue with CGSize - setSizeOffset:
 *  NSValue with ECMasEdgeInsets - setInsets:
 */
- (void)setLayoutConstantWithValue:(NSValue *)value;

@end


@interface ECMasConstraint (Abstract)

/**
 *	Sets the constraint relation to given NSLayoutRelation
 *  returns a block which accepts one of the following:
 *    ECMasViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (ECMasConstraint * (^)(id, NSLayoutRelation))equalToWithRelation;

/**
 *	Override to set a custom chaining behaviour
 */
- (ECMasConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end


@protocol ECMasConstraintDelegate <NSObject>

/**
 *	Notifies the delegate when the constraint needs to be replaced with another constraint. For example
 *  A ECMasViewConstraint may turn into a ECMasCompositeConstraint when an array is passed to one of the equality blocks
 */
- (void)constraint:(ECMasConstraint *)constraint shouldBeReplacedWithConstraint:(ECMasConstraint *)replacementConstraint;

- (ECMasConstraint *)constraint:(ECMasConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end
