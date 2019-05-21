//
//  HXW_KVOModel.h
//  KVODemo
//
//  Created by BTI-HXW on 2019/5/17.
//  Copyright © 2019 BTI-HXW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXW_KVOModel : NSObject
/**
 观察属性
 */
@property (nonatomic, copy) NSString *keyPath;
/**
 观察内容方式，同一个观察者，多次添加，会被最后一次添加覆盖
 */
@property (nonatomic, strong) NSMutableDictionary<NSString* ,NSNumber*>* observerOptions;
/**
 block回调通知 同一个观察者，多次添加，block回调会被最后一次添加覆盖
 */
@property (nonatomic, strong) NSMutableDictionary *blocks;
/**
 context
 */
@property (nonatomic, strong) id context;
/**
 改变之前的值
 */
@property (nonatomic, strong) id hxw_oldValue;
/**
 最开始的值
 */
@property (nonatomic, strong) id hxw_initialValue;
/**
 观察者,对于同一个keypath，同一个观察者只需要添加一次,保证若引用
 */
@property (nonatomic, strong) NSHashTable *observers;
@end

NS_ASSUME_NONNULL_END
