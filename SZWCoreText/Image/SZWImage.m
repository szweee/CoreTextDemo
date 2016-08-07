//
//  SZWRootViewController.m
//  SZWCoreText
//
//  GitHub:https://github.com/szweee
//  Blog:  http://www.szweee.com
//
//  Created by 索泽文 on 15/7/10.
//  Copyright © 2016年 索泽文. All rights reserved.
//

#import "SZWImage.h"
#import "SZWCoreTextWithImage.h"

@implementation SZWImage

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    SZWCoreTextWithImage *image = [[SZWCoreTextWithImage alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    image.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:image];
}

@end
