//
//  Person.h
//  KVODemo
//
//  Created by BTI-HXW on 2019/5/13.
//  Copyright © 2019 BTI-HXW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dog.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject{
    @public NSString* age;
}
/**
 
 */
@property (nonatomic, copy) NSString* name;
/**
 
 */
@property (nonatomic, strong) NSMutableArray *arr;
/**
 
 */
@property (nonatomic, strong) Dog *dog;
@end

NS_ASSUME_NONNULL_END
