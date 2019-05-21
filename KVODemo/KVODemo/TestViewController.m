//
//  TestViewController.m
//  KVODemo
//
//  Created by BTI-HXW on 2019/5/17.
//  Copyright © 2019 BTI-HXW. All rights reserved.
//

#import "TestViewController.h"
#import "NSObject+HXW_KVO.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.person addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) weakSelf = self;
    [self.person hxw_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld observerBlock:^(NSString * _Nonnull keyPath, NSDictionary * _Nonnull change, id  _Nonnull observer) {
        NSLog(@"keyPath:%@,change:%@,class:%@",keyPath,change,[weakSelf class]);
    }];
    [self.person hxw_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    [self.person hxw_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
}
static int i = 0;
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    i++;
    self.person.name = [NSString stringWithFormat:@"cesji-%d",i];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//    [self.person hxw_removeObserver:self forKeyPath:@"name"];
}
-(void)dealloc{
    NSLog(@"delloc:%@",[self class]);
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"no blocks keyPath:%@,change:%@,class:%@",keyPath,change,[self class]);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
