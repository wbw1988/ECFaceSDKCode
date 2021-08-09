//
//  UIView+ECMasAdditions.h
//  ECMasonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "ECMasUtilities.h"
#import "ECMasConstraintMaker.h"
#import "ECMasViewAttribute.h"

/**
 *	Provides constraint maker block
 *  and convience methods for creating ECMasViewAttribute which are view + NSLayoutAttribute pairs
 */
@interface ECMas_VIEW (ECMasAdditions)

/**
 *	following properties return a new ECMasViewAttribute with current view and appropriate NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_left;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_top;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_right;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_bottom;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_leading;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_trailing;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_width;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_height;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_centerX;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_centerY;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_baseline;
@property (nonatomic, strong, readonly) ECMasViewAttribute *(^ECMas_attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_firstBaseline;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_leftMargin;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_rightMargin;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_topMargin;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_bottomMargin;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_leadingMargin;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_trailingMargin;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_centerXWithinMargins;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_safeAreaLayoutGuide API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

/**
 *	a key to associate with this view
 */
@property (nonatomic, strong) id ECMas_key;

/**
 *	Finds the closest common superview between this view and another view
 *
 *	@param	view	other view
 *
 *	@return	returns nil if common superview could not be found
 */
- (instancetype)ECMas_closestCommonSuperview:(ECMas_VIEW *)view;

/**
 *  Creates a ECMasConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created ECMasConstraints
 */
- (NSArray *)ECMas_makeConstraints:(void(NS_NOESCAPE ^)(ECMasConstraintMaker *make))block;

/**
 *  Creates a ECMasConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  If an existing constraint exists then it will be updated instead.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated ECMasConstraints
 */
- (NSArray *)ECMas_updateConstraints:(void(NS_NOESCAPE ^)(ECMasConstraintMaker *make))block;

/**
 *  Creates a ECMasConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  All constraints previously installed for the view will be removed.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated ECMasConstraints
 */
- (NSArray *)ECMas_remakeConstraints:(void(NS_NOESCAPE ^)(ECMasConstraintMaker *make))block;

@end
