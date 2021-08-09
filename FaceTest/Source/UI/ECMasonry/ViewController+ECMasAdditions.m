//
//  UIViewController+ECMasAdditions.m
//  ECMasonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "ViewController+ECMasAdditions.h"

#ifdef ECMas_VIEW_CONTROLLER

@implementation ECMas_VIEW_CONTROLLER (ECMasAdditions)

- (ECMasViewAttribute *)ECMas_topLayoutGuide {
    return [[ECMasViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (ECMasViewAttribute *)ECMas_topLayoutGuideTop {
    return [[ECMasViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (ECMasViewAttribute *)ECMas_topLayoutGuideBottom {
    return [[ECMasViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (ECMasViewAttribute *)ECMas_bottomLayoutGuide {
    return [[ECMasViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (ECMasViewAttribute *)ECMas_bottomLayoutGuideTop {
    return [[ECMasViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (ECMasViewAttribute *)ECMas_bottomLayoutGuideBottom {
    return [[ECMasViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}



@end

#endif
