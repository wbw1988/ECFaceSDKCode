//
//  UIViewController+ECMasAdditions.h
//  ECMasonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "ECMasUtilities.h"
#import "ECMasConstraintMaker.h"
#import "ECMasViewAttribute.h"

#ifdef ECMas_VIEW_CONTROLLER

@interface ECMas_VIEW_CONTROLLER (ECMasAdditions)

/**
 *	following properties return a new ECMasViewAttribute with appropriate UILayoutGuide and NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_topLayoutGuide;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_bottomLayoutGuide;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_topLayoutGuideTop;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_topLayoutGuideBottom;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_bottomLayoutGuideTop;
@property (nonatomic, strong, readonly) ECMasViewAttribute *ECMas_bottomLayoutGuideBottom;


@end

#endif
