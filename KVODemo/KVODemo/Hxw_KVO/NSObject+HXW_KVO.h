//
//  NSObject+HXW_KVO.h
//  KVODemo
//
//  Created by BTI-HXW on 2019/5/16.
//  Copyright © 2019 BTI-HXW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ObserverBlock)(NSString* keyPath,NSDictionary* change,id obj);

@interface NSObject (HXW_KVO)
///添加观察者
- (void)hxw_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
///block形式回调通知
- (void)hxw_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options observerBlock:(ObserverBlock)block;
///移除观察者
-(void)hxw_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
///移除所有观察者
-(void)hxw_removeAllObservers;
@end

NS_ASSUME_NONNULL_END
