//
//  ECMasConstraintMaker.h
//  ECMasonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "ECMasConstraint.h"
#import "ECMasUtilities.h"

typedef NS_OPTIONS(NSInteger, ECMasAttribute) {
    ECMasAttributeLeft = 1 << NSLayoutAttributeLeft,
    ECMasAttributeRight = 1 << NSLayoutAttributeRight,
    ECMasAttributeTop = 1 << NSLayoutAttributeTop,
    ECMasAttributeBottom = 1 << NSLayoutAttributeBottom,
    ECMasAttributeLeading = 1 << NSLayoutAttributeLeading,
    ECMasAttributeTrailing = 1 << NSLayoutAttributeTrailing,
    ECMasAttributeWidth = 1 << NSLayoutAttributeWidth,
    ECMasAttributeHeight = 1 << NSLayoutAttributeHeight,
    ECMasAttributeCenterX = 1 << NSLayoutAttributeCenterX,
    ECMasAttributeCenterY = 1 << NSLayoutAttributeCenterY,
    ECMasAttributeBaseline = 1 << NSLayoutAttributeBaseline,
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    ECMasAttributeFirstBaseline = 1 << NSLayoutAttributeFirstBaseline,
    ECMasAttributeLastBaseline = 1 << NSLayoutAttributeLastBaseline,
    
#endif
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
    
    ECMasAttributeLeftMargin = 1 << NSLayoutAttributeLeftMargin,
    ECMasAttributeRightMargin = 1 << NSLayoutAttributeRightMargin,
    ECMasAttributeTopMargin = 1 << NSLayoutAttributeTopMargin,
    ECMasAttributeBottomMargin = 1 << NSLayoutAttributeBottomMargin,
    ECMasAttributeLeadingMargin = 1 << NSLayoutAttributeLeadingMargin,
    ECMasAttributeTrailingMargin = 1 << NSLayoutAttributeTrailingMargin,
    ECMasAttributeCenterXWithinMargins = 1 << NSLayoutAttributeCenterXWithinMargins,
    ECMasAttributeCenterYWithinMargins = 1 << NSLayoutAttributeCenterYWithinMargins,

#endif
    
};

/**
 *  Provides factory methods for creating ECMasConstraints.
 *  Constraints are collected until they are ready to be installed
 *
 */
@interface ECMasConstraintMaker : NSObject

/**
 *	The following properties return a new ECMasViewConstraint
 *  with the first item set to the makers associated view and the appropriate ECMasViewAttribute
 */
@property (nonatomic, strong, readonly) ECMasConstraint *left;
@property (nonatomic, strong, readonly) ECMasConstraint *top;
@property (nonatomic, strong, readonly) ECMasConstraint *right;
@property (nonatomic, strong, readonly) ECMasConstraint *bottom;
@property (nonatomic, strong, readonly) ECMasConstraint *leading;
@property (nonatomic, strong, readonly) ECMasConstraint *trailing;
@property (nonatomic, strong, readonly) ECMasConstraint *width;
@property (nonatomic, strong, readonly) ECMasConstraint *height;
@property (nonatomic, strong, readonly) ECMasConstraint *centerX;
@property (nonatomic, strong, readonly) ECMasConstraint *centerY;
@property (nonatomic, strong, readonly) ECMasConstraint *baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) ECMasConstraint *firstBaseline;
@property (nonatomic, strong, readonly) ECMasConstraint *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) ECMasConstraint *leftMargin;
@property (nonatomic, strong, readonly) ECMasConstraint *rightMargin;
@property (nonatomic, strong, readonly) ECMasConstraint *topMargin;
@property (nonatomic, strong, readonly) ECMasConstraint *bottomMargin;
@property (nonatomic, strong, readonly) ECMasConstraint *leadingMargin;
@property (nonatomic, strong, readonly) ECMasConstraint *trailingMargin;
@property (nonatomic, strong, readonly) ECMasConstraint *centerXWithinMargins;
@property (nonatomic, strong, readonly) ECMasConstraint *centerYWithinMargins;

#endif

/**
 *  Returns a block which creates a new ECMasCompositeConstraint with the first item set
 *  to the makers associated view and children corresponding to the set bits in the
 *  ECMasAttribute parameter. Combine multiple attributes via binary-or.
 */
@property (nonatomic, strong, readonly) ECMasConstraint *(^attributes)(ECMasAttribute attrs);

/**
 *	Creates a ECMasCompositeConstraint with type ECMasCompositeConstraintTypeEdges
 *  which generates the appropriate ECMasViewConstraint children (top, left, bottom, right)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) ECMasConstraint *edges;

/**
 *	Creates a ECMasCompositeConstraint with type ECMasCompositeConstraintTypeSize
 *  which generates the appropriate ECMasViewConstraint children (width, height)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) ECMasConstraint *size;

/**
 *	Creates a ECMasCompositeConstraint with type ECMasCompositeConstraintTypeCenter
 *  which generates the appropriate ECMasViewConstraint children (centerX, centerY)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) ECMasConstraint *center;

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *  Whether or not to remove existing constraints prior to installing
 */
@property (nonatomic, assign) BOOL removeExisting;

/**
 *	initialises the maker with a default view
 *
 *	@param	view	any ECMasConstraint are created with this view as the first item
 *
 *	@return	a new ECMasConstraintMaker
 */
- (id)initWithView:(ECMas_VIEW *)view;

/**
 *	Calls install method on any ECMasConstraints which have been created by this maker
 *
 *	@return	an array of all the installed ECMasConstraints
 */
- (NSArray *)install;

- (ECMasConstraint * (^)(dispatch_block_t))group;

@end
