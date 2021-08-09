//
//  NSArray+ECMasAdditions.m
//  
//
//  Created by Daniel Hammond on 11/26/13.
//
//

#import "NSArray+ECMasAdditions.h"
#import "View+ECMasAdditions.h"

@implementation NSArray (ECMasAdditions)

- (NSArray *)ECMas_makeConstraints:(void(^)(ECMasConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (ECMas_VIEW *view in self) {
        NSAssert([view isKindOfClass:[ECMas_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view ECMas_makeConstraints:block]];
    }
    return constraints;
}

- (NSArray *)ECMas_updateConstraints:(void(^)(ECMasConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (ECMas_VIEW *view in self) {
        NSAssert([view isKindOfClass:[ECMas_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view ECMas_updateConstraints:block]];
    }
    return constraints;
}

- (NSArray *)ECMas_remakeConstraints:(void(^)(ECMasConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (ECMas_VIEW *view in self) {
        NSAssert([view isKindOfClass:[ECMas_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view ECMas_remakeConstraints:block]];
    }
    return constraints;
}

- (void)ECMas_distributeViewsAlongAxis:(ECMasAxisType)axisType withFixedSpacing:(CGFloat)fixedSpacing leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing {
    if (self.count < 2) {
        NSAssert(self.count>1,@"views to distribute need to bigger than one");
        return;
    }
    
    ECMas_VIEW *tempSuperView = [self ECMas_commonSuperviewOfViews];
    if (axisType == ECMasAxisTypeHorizontal) {
        ECMas_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            ECMas_VIEW *v = self[i];
            [v ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
                if (prev) {
                    make.width.equalTo(prev);
                    make.left.equalTo(prev.ECMas_right).offset(fixedSpacing);
                    if (i == self.count - 1) {//last one
                        make.right.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                }
                else {//first one
                    make.left.equalTo(tempSuperView).offset(leadSpacing);
                }
                
            }];
            prev = v;
        }
    }
    else {
        ECMas_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            ECMas_VIEW *v = self[i];
            [v ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
                if (prev) {
                    make.height.equalTo(prev);
                    make.top.equalTo(prev.ECMas_bottom).offset(fixedSpacing);
                    if (i == self.count - 1) {//last one
                        make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                    }                    
                }
                else {//first one
                    make.top.equalTo(tempSuperView).offset(leadSpacing);
                }
                
            }];
            prev = v;
        }
    }
}

- (void)ECMas_distributeViewsAlongAxis:(ECMasAxisType)axisType withFixedItemLength:(CGFloat)fixedItemLength leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing {
    if (self.count < 2) {
        NSAssert(self.count>1,@"views to distribute need to bigger than one");
        return;
    }
    
    ECMas_VIEW *tempSuperView = [self ECMas_commonSuperviewOfViews];
    if (axisType == ECMasAxisTypeHorizontal) {
        ECMas_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            ECMas_VIEW *v = self[i];
            [v ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
                make.width.equalTo(@(fixedItemLength));
                if (prev) {
                    if (i == self.count - 1) {//last one
                        make.right.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                    else {
                        CGFloat offset = (1-(i/((CGFloat)self.count-1)))*(fixedItemLength+leadSpacing)-i*tailSpacing/(((CGFloat)self.count-1));
                        make.right.equalTo(tempSuperView).multipliedBy(i/((CGFloat)self.count-1)).with.offset(offset);
                    }
                }
                else {//first one
                    make.left.equalTo(tempSuperView).offset(leadSpacing);
                }
            }];
            prev = v;
        }
    }
    else {
        ECMas_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            ECMas_VIEW *v = self[i];
            [v ECMas_makeConstraints:^(ECMasConstraintMaker *make) {
                make.height.equalTo(@(fixedItemLength));
                if (prev) {
                    if (i == self.count - 1) {//last one
                        make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                    else {
                        CGFloat offset = (1-(i/((CGFloat)self.count-1)))*(fixedItemLength+leadSpacing)-i*tailSpacing/(((CGFloat)self.count-1));
                        make.bottom.equalTo(tempSuperView).multipliedBy(i/((CGFloat)self.count-1)).with.offset(offset);
                    }
                }
                else {//first one
                    make.top.equalTo(tempSuperView).offset(leadSpacing);
                }
            }];
            prev = v;
        }
    }
}

- (ECMas_VIEW *)ECMas_commonSuperviewOfViews
{
    ECMas_VIEW *commonSuperview = nil;
    ECMas_VIEW *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[ECMas_VIEW class]]) {
            ECMas_VIEW *view = (ECMas_VIEW *)object;
            if (previousView) {
                commonSuperview = [view ECMas_closestCommonSuperview:commonSuperview];
            } else {
                commonSuperview = view;
            }
            previousView = view;
        }
    }
    NSAssert(commonSuperview, @"Can't constrain views that do not share a common superview. Make sure that all the views in this array have been added into the same view hierarchy.");
    return commonSuperview;
}

@end
