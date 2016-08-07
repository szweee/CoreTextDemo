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

#import "SZWRootViewController.h"

@interface SZWRootViewController ()

@property (nonatomic, strong) NSMutableArray *cellTitles;
@property (nonatomic, strong) NSMutableArray *classNames;

@end

@implementation SZWRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"SZWCoreText";
    self.cellTitles = @[].mutableCopy;
    self.classNames = @[].mutableCopy;
    [self addCellWithTitle:@"Text" AndClass:@"SZWText"];
    [self addCellWithTitle:@"Image" AndClass:@"SZWImage"];
    [self addCellWithTitle:@"Emoji" AndClass:@"SZWEmoji"];
    [self addCellWithTitle:@"TextClick" AndClass:@"SZWTextClick"];
}

- (void)addCellWithTitle:(NSString *)title AndClass:(NSString *)class {
    [self.cellTitles addObject:title];
    [self.classNames addObject:class];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.cellTitles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *classNmae = self.classNames[indexPath.row];
    Class cls = NSClassFromString(classNmae);
    if (cls) {
        UIViewController *vc = [cls new];
        vc.title = self.cellTitles[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
