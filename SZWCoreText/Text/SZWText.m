//
//  SZWRootViewController.m
//  SZWCoreText
//
//  GitHub:https://github.com/szweee
//  Blog:  http://www.szweee.com
//
//  Created by 索泽文 on 15/7/03.
//  Copyright © 2016年 索泽文. All rights reserved.
//

#import "SZWText.h"
#import "SZWCoreTextWithText.h"

@implementation SZWText

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    SZWCoreTextWithText *text = [[SZWCoreTextWithText alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    text.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:text];
}

@end
