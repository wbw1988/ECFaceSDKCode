//
//  ECMasViewConstraint.h
//  ECMasonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "ECMasViewAttribute.h"
#import "ECMasConstraint.h"
#import "ECMasLayoutConstraint.h"
#import "ECMasUtilities.h"

/**
 *  A single constraint.
 *  Contains the attributes neccessary for creating a NSLayoutConstraint and adding it to the appropriate view
 */
@interface ECMasViewConstraint : ECMasConstraint <NSCopying>

/**
 *	First item/view and first attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) ECMasViewAttribute *firstViewAttribute;

/**
 *	Second item/view and second attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) ECMasViewAttribute *secondViewAttribute;

/**
 *	initialises the ECMasViewConstraint with the first part of the equation
 *
 *	@param	firstViewAttribute	view.ECMas_left, view.ECMas_width etc.
 *
 *	@return	a new view constraint
 */
- (id)initWithFirstViewAttribute:(ECMasViewAttribute *)firstViewAttribute;

/**
 *  Returns all ECMasViewConstraints installed with this view as a first item.
 *
 *  @param  view  A view to retrieve constraints for.
 *
 *  @return An array of ECMasViewConstraints.
 */
+ (NSArray *)installedConstraintsForView:(ECMas_VIEW *)view;

@end
