//
//  NSArray+ECMasShorthandAdditions.h
//  ECMasonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "NSArray+ECMasAdditions.h"

#ifdef ECMas_SHORTHAND

/**
 *	Shorthand array additions without the 'ECMas_' prefixes,
 *  only enabled if ECMas_SHORTHAND is defined
 */
@interface NSArray (ECMasShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(ECMasConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(ECMasConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(ECMasConstraintMaker *make))block;

@end

@implementation NSArray (ECMasShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(ECMasConstraintMaker *))block {
    return [self ECMas_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(^)(ECMasConstraintMaker *))block {
    return [self ECMas_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(^)(ECMasConstraintMaker *))block {
    return [self ECMas_remakeConstraints:block];
}

@end

#endif
