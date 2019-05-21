//
//  HXW_KVOModel.m
//  KVODemo
//
//  Created by BTI-HXW on 2019/5/17.
//  Copyright © 2019 BTI-HXW. All rights reserved.
//

#import "HXW_KVOModel.h"

@implementation HXW_KVOModel
-(NSHashTable *)observers{
    if (!_observers) {
        _observers = [NSHashTable weakObjectsHashTable];
    }
    return _observers;
}
- (NSMutableDictionary<NSString *,NSNumber *> *)observerOptions{
    if (!_observerOptions) {
        _observerOptions = [NSMutableDictionary new];
    }
    return _observerOptions;
}
-(NSMutableDictionary *)blocks{
    if (!_blocks) {
        _blocks = [NSMutableDictionary new];
    }
    return _blocks;
}
@end
