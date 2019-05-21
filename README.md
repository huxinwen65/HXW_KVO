# HXW_KVO
自定义KVO
导入Hxw_KVO文件，
1、block方式调用：
__weak typeof(self) weakSelf = self;
    [self.p hxw_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld observerBlock:^(NSString * _Nonnull keyPath, NSDictionary * _Nonnull change, id  _Nonnull observer) {
        NSLog(@"keyPath:%@,change:%@,class:%@",keyPath,change,[weakSelf class]);
    }];
2、系统方式调用：
[self.person hxw_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
///回调
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"no blocks keyPath:%@,change:%@,class:%@",keyPath,change,[self class]);
}

///移除观察者
-(void)hxw_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
///移除所有观察者
-(void)hxw_removeAllObservers;
