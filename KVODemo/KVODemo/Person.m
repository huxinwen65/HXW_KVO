//
//  Person.m
//  KVODemo
//
//  Created by BTI-HXW on 2019/5/13.
//  Copyright © 2019 BTI-HXW. All rights reserved.
//

#import "Person.h"

@implementation Person
///属性关联（监听属性与其他的对象属性相关）
+(NSSet<NSString *> *)keyPathsForValuesAffectingDog{
    NSSet*set = [NSSet setWithObjects:@"_dog.name", nil];
    return set;
}

///关闭自动通知
+(BOOL)automaticallyNotifiesObserversOfName{
    return NO;
}
///手动通知
-(void)setName:(NSString *)name{
    [self willChangeValueForKey:@"name"];
    _name = name;
    [self didChangeValueForKey:@"name"];
}
@end
