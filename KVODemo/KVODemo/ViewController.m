//
//  ViewController.m
//  KVODemo
//
//  Created by BTI-HXW on 2019/5/13.
//  Copyright © 2019 BTI-HXW. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "NSObject+HXW_KVO.h"
#import "TestViewController.h"

@interface ViewController ()
- (IBAction)pushToTestVC:(id)sender;


@property (nonatomic, strong) Person* p;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Person* p = [Person new];
    p.dog = [Dog new];
    p.arr = [NSMutableArray new];
    ///添加观察者
    [p addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    ///观察成员变量
    [p addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew context:nil];
    [p addObserver:self forKeyPath:@"dog" options:NSKeyValueObservingOptionNew context:nil];
    self.p = p;
    
    ///成员变量赋值
    self.p->age = @"10";
    NSLog(@"p.age:%@",self.p->age);
    self.p.dog.name = @"wawa";
    self.p.name = @"呵呵呵";
    [self.p addObserver:self forKeyPath:@"arr" options:NSKeyValueObservingOptionNew context:nil];
    [self.p.arr addObject:@"nihao"];
    ///观察集合类属性
    NSMutableArray* tempArr = [self.p mutableArrayValueForKeyPath:@"arr"];
    [tempArr addObject:@"hehe"];
    
    self.p.name = @"Test";
    __weak typeof(self) weakSelf = self;
    [self.p hxw_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld observerBlock:^(NSString * _Nonnull keyPath, NSDictionary * _Nonnull change, id  _Nonnull observer) {
        NSLog(@"keyPath:%@,change:%@,class:%@",keyPath,change,[weakSelf class]);
    }];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    self.p.name = @"cesji";
}
///监听回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"keyPath:%@,change:%@,observer:%@",keyPath,change,[self class]);
    if ([keyPath isEqualToString:@"dog"]) {
        NSLog(@"dog changed name:%@",((Dog*)change[@"new"]).name);
    }
}

///注销监听者
-(void)dealloc{
    [self.p hxw_removeObserver:self forKeyPath:@"name"];
    [self.p removeObserver:self forKeyPath:@"dog"];
    [self.p removeObserver:self forKeyPath:@"arr"];
}
- (IBAction)pushToTestVC:(id)sender {
    TestViewController* vc = [TestViewController new];
    vc.person = self.p;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
