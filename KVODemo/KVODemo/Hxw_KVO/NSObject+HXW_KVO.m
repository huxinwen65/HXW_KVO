//
//  NSObject+HXW_KVO.m
//  KVODemo
//
//  Created by BTI-HXW on 2019/5/16.
//  Copyright © 2019 BTI-HXW. All rights reserved.
//

#import "NSObject+HXW_KVO.h"
#import <objc/message.h>
#import "HXW_KVOModel.h"
const char* KVO_MODEL = "KVO_MODEL";
const char* KVO_OBSERVER_BLOCK = "KVO_OBSERVER_BLOCK";
#define KVO_CLASS_NAME  @"HXW_KVO_"
@interface NSObject()
/**
 观察数据
 */
@property (nonatomic, strong) NSMutableDictionary<NSString*,HXW_KVOModel*> *kvoModels;

@end

@implementation NSObject (HXW_KVO)
#pragma mark 添加观察者
- (void)hxw_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    ///添加子类，如果已经添加，则返回自己本身
    Class newSubClass = [self addSubClassForClass:[self class]];
    ///getter方法，保存就值（初始值）
    SEL getterS = NSSelectorFromString(keyPath);
    id oldValue = objc_msgSend(self, getterS);
    
    ///6、保存观察者携带的信息
    HXW_KVOModel* model = [self.kvoModels objectForKey:keyPath];
    if (!model) {///没有说明没有添加过keypath的监听，需要添加子类的keypath对应的setter方法
        ///4、获取setter方法，并添加到新类
        NSString* setMethodName = [NSString stringWithFormat:@"set%@:",[keyPath localizedCapitalizedString]];
        SEL setSelector = NSSelectorFromString(setMethodName);
        ///添加方法
        class_addMethod(newSubClass, setSelector, (IMP)setName, "v@:@");
        model = [HXW_KVOModel new];
        model.keyPath = keyPath;
        model.hxw_initialValue = oldValue;
    }
    NSString* orginClassName = NSStringFromClass([self class]);
    if (![orginClassName hasPrefix:KVO_CLASS_NAME]) {///父类不包含指定前缀，说明第一次添加监听，第一次创建子类，将isa指针指向子类
        ///5、改变isa指针x
        object_setClass(self, newSubClass);
    }
    model.hxw_oldValue = oldValue;
    model.context = (__bridge id _Nonnull)(context);
    NSString* observerClassName = [self getKeyNameStringForObject:observer];
    ///保存观察类型
    [model.observerOptions setObject:@(options) forKey:observerClassName];
    ///添加观察者，nsset
    if (![((__bridge NSString* _Nonnull)context) isEqualToString:@"block"] ) {
//        NSValue *value = [NSValue valueWithNonretainedObject:observer];
        [model.observers addObject:observer];
    }
    
    [self.kvoModels setObject:model forKey:keyPath];

}

#pragma mark 添加之类
- (Class)addSubClassForClass:(Class)class{
    ///1、获取类名
    NSString* orginClassName = NSStringFromClass(class);
    if ([orginClassName hasPrefix:KVO_CLASS_NAME]) {///说明添加过子类，且本身就是，r返回本身
        return class;
    }
    NSString* subKVOClassName = [NSString stringWithFormat:@"%@%@",KVO_CLASS_NAME,orginClassName];
    Class newSubClass = objc_getClass([subKVOClassName UTF8String]);
    ///2、防止多次新建子类并注册，再次保护
    if (!newSubClass) {
        ///3、不存在，第一次被观察,动态添加并注册新类
        newSubClass = objc_allocateClassPair([self class], [subKVOClassName UTF8String], 0);
        objc_registerClassPair(newSubClass);
    }
    return newSubClass;
}
#pragma mark 添加观察者 block形式回调通知
-(void)hxw_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options observerBlock:(ObserverBlock)block{
    [self hxw_addObserver:observer forKeyPath:keyPath options:options context:@"block"];
    NSString* keyName = [self getKeyNameStringForObject:observer];
    HXW_KVOModel* model = [self.kvoModels objectForKey:keyPath];
    [model.blocks setObject:block forKey:keyName];
    [self.kvoModels setObject:model forKey:keyPath];
}
#pragma mark 根据实例对象获取唯一key
- (NSString*) getKeyNameStringForObject:(NSObject*)object{
    NSString* observerClassName = NSStringFromClass([object class]);
    observerClassName = [NSString stringWithFormat:@"%@_%ld",observerClassName,object.hash];
    return observerClassName;
}
#pragma mark 添加的setter方法的imp
void setName(id self ,SEL _cmd, NSString* newName){
    //调用父类的setter方法
    Class subClass = [self class];
    NSMutableDictionary* observerDic = objc_getAssociatedObject(self, KVO_MODEL);
    ///调整isa指针
    object_setClass(self, class_getSuperclass(subClass));
    ///调用父类setter方法
    objc_msgSend(self, _cmd, newName);
    object_setClass(self, subClass);
    ///获取keyPath
    NSString * selString = NSStringFromSelector(_cmd);
    NSString* keyPath = [selString substringFromIndex:3];
    keyPath = [keyPath substringToIndex:keyPath.length - 1];
    keyPath = [keyPath stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[keyPath substringToIndex:1].lowercaseString];
    ///拿到相关参数
    HXW_KVOModel* model = observerDic[keyPath];
    NSArray* keys = model.blocks.allKeys;
    [model.blocks.allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ObserverBlock block = (ObserverBlock)obj;
        NSString* observerClassName = keys[idx];
        NSKeyValueObservingOptions option = [model.observerOptions objectForKey:observerClassName].integerValue;
        ///如果有block，则block回调，否则observeValueForKeyPath通知
        NSDictionary* change = [self getChangeByOption:option model:model newName:newName];
        if (block) {
            block(keyPath,change,self);
        }
    }];
    NSEnumerator* enumrator = [model.observers objectEnumerator];
    NSObject* obj = [enumrator nextObject];
    while (obj) {
        ///拿到对应监听的option，并拼装change
        NSString* observerClassName = [self getKeyNameStringForObject:obj];
        NSKeyValueObservingOptions option = [model.observerOptions objectForKey:observerClassName].integerValue;
        NSDictionary* change = [self getChangeByOption:option model:model newName:newName];
        ///发送通知
        objc_msgSend(obj, @selector(observeValueForKeyPath:ofObject:change:context:),keyPath,self,change,model.context);
        obj = [enumrator nextObject];
        
    }
    ///通知后，将最新的值赋值给就值，下次使用
     model.hxw_oldValue = newName;
    [observerDic setObject:model forKey:keyPath];
    objc_setAssociatedObject(self, KVO_MODEL, observerDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark 根据NSKeyValueObservingOptions组装change
- (NSDictionary*) getChangeByOption:(NSKeyValueObservingOptions)option model:(HXW_KVOModel*) model newName:(id)newName{
    
    NSMutableDictionary* change = [NSMutableDictionary new];
    switch (option) {
        case NSKeyValueObservingOptionInitial:
            [change setObject:model.hxw_initialValue forKey:@"initial"];
            break;
        case NSKeyValueObservingOptionNew:
            [change setObject:newName forKey:@"new"];
            break;
        case NSKeyValueObservingOptionOld:
            [change setObject:model.hxw_oldValue forKey:@"old"];
            break;
        case NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew:
            [change setObject:model.hxw_oldValue forKey:@"old"];
            [change setObject:newName forKey:@"new"];
            break;
            
        default:
            break;
    }
    return [change copy];
}

#pragma mark 属性关联 kvoModels
-(void)setKvoModels:(NSMutableDictionary<NSString*, HXW_KVOModel *> *)kvoModels{
    objc_setAssociatedObject(self, KVO_MODEL, kvoModels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSMutableDictionary<NSString* ,HXW_KVOModel*> *)kvoModels{
    NSMutableDictionary* arr = objc_getAssociatedObject(self, KVO_MODEL);
    if (!arr) {
        objc_setAssociatedObject(self, KVO_MODEL, [NSMutableDictionary new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, KVO_MODEL);
}
#pragma mark 移除掉通知
-(void)hxw_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    HXW_KVOModel* mode = [self.kvoModels objectForKey:keyPath];
    [mode.observers removeObject:observer];
    NSString* observerClassName = [self getKeyNameStringForObject:observer];
    [mode.observerOptions removeObjectForKey:observerClassName];
    [mode.blocks removeObjectForKey:observerClassName];
    ///当keypath对应的观察者为0，全部移除所有信息
    if (mode.observers.count == 0) {
        [self.kvoModels removeObjectForKey:keyPath];
    }
}
#pragma mark 移除所有观察者
-(void)hxw_removeAllObservers{
    [self.kvoModels removeAllObjects];
}
@end
