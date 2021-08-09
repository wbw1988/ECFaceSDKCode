//
//  ECMasCompositeConstraint.h
//  ECMasonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "ECMasConstraint.h"
#import "ECMasUtilities.h"

/**
 *	A group of ECMasConstraint objects
 */
@interface ECMasCompositeConstraint : ECMasConstraint

/**
 *	Creates a composite with a predefined array of children
 *
 *	@param	children	child ECMasConstraints
 *
 *	@return	a composite constraint
 */
- (id)initWithChildren:(NSArray *)children;

@end
