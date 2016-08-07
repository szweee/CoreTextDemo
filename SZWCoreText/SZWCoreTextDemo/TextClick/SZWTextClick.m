//
//  SZWRootViewController.m
//  SZWCoreText
//
//  GitHub:https://github.com/szweee
//  Blog:  http://www.szweee.com
//
//  Created by 索泽文 on 15/7/20.
//  Copyright © 2016年 索泽文. All rights reserved.
//

#import "SZWTextClick.h"
#import "SZWCoreTextWithClick.h"

@implementation SZWTextClick

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    SZWCoreTextWithClick *textClick = [[SZWCoreTextWithClick alloc] init];
    textClick.font = [UIFont systemFontOfSize:15];
    textClick.content = @"56321363464.而今识尽愁滋味，欲说还休，欲说还休，却道天凉好个秋。123456，@习大大 ，56321267895434。缺月挂疏桐，漏断人初静。谁见幽人独往来，缥缈孤鸿影。惊起却回头，有恨无人省。捡尽寒枝不肯栖，寂寞沙洲冷愁愁愁2734553 覅佛覅偶给不给瑞公布日光我renongorengrno 过几日偶尔会滚动就可能更不如而不顾二表哥一i4673285437 的开工日鞥我人鬼热固热狗二个热狗兄热奇偶@jgrihgurie 就覅偶二胡日和784937 @就覅额欧冠日 内工人愁愁愁愁愁愁愁😳😊😳😊😳😊😳愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁@suozewen 愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁";
    textClick.backgroundColor = [UIColor lightGrayColor];
    textClick.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 210);
    [self.view addSubview:textClick];
}

@end
