//
//  SZWRootViewController.m
//  SZWCoreText
//
//  GitHub:https://github.com/szweee
//  Blog:  http://www.szweee.com
//
//  Created by 索泽文 on 15/7/13.
//  Copyright © 2016年 索泽文. All rights reserved.
//

#import "SZWEmoji.h"
#import "SZWCoreTextWithEmoji.h"

@implementation SZWEmoji

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *text = @"我自横刀向天笑，去留肝胆两昆仑。--谭嗣同同学你好啊。😳😊😳😊😳😊😳去年今日此门中，人面桃花相映红。人面不知何处去，桃花依旧笑春风。😳😊😳😊😳😊😳少年不知愁滋味，爱上层楼，爱上层楼，为赋新词强说愁。我自横刀向天笑，去留肝胆两昆仑。--谭嗣同同学你好啊。去年今日此门中，人面桃花相映红。人面不知何处去，桃花依旧笑春风。少年不知愁滋味，爱上层楼，爱上层楼，为赋新词强说愁。";
    
    SZWCoreTextWithEmoji *emoji = [[SZWCoreTextWithEmoji alloc] init];
    emoji.backgroundColor = [UIColor lightGrayColor];
    emoji.font = [UIFont systemFontOfSize:15];
    emoji.content = text;
    emoji.drawType = DrawTextLine;
    CGFloat height = [SZWCoreTextWithEmoji textHeightWithText:text width:[UIScreen mainScreen].bounds.size.width font:emoji.font type:DrawTextLine];
    emoji.textHeight = height;
    emoji.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, height);
    [self.view addSubview:emoji];
    
    
    SZWCoreTextWithEmoji *emojiAligement = [[SZWCoreTextWithEmoji alloc] init];
    emojiAligement.backgroundColor = [UIColor lightGrayColor];
    emojiAligement.font = [UIFont systemFontOfSize:15];
    emojiAligement.content = text;
    emojiAligement.drawType = DrawTextLineAligement;
    CGFloat heightAligement = [SZWCoreTextWithEmoji textHeightWithText:text width:[UIScreen mainScreen].bounds.size.width font:emojiAligement.font type:DrawTextLineAligement];
    emojiAligement.textHeight = heightAligement;
    emojiAligement.frame = CGRectMake(0, emoji.frame.origin.y + emoji.frame.size.height + 20, [UIScreen mainScreen].bounds.size.width, heightAligement);
    [self.view addSubview:emojiAligement];
    
    SZWCoreTextWithEmoji *emojiEllispses = [[SZWCoreTextWithEmoji alloc] init];
    emojiEllispses.font = [UIFont systemFontOfSize:15];
    emojiEllispses.content = text;
    emojiEllispses.backgroundColor = [UIColor lightGrayColor];
    emojiEllispses.drawType = DrawTextWithEllipses;
    emojiEllispses.frame = CGRectMake(0, emojiAligement.frame.origin.y + emojiAligement.frame.size.height + 20, [UIScreen mainScreen].bounds.size.width, 70);
    [self.view addSubview:emojiEllispses];
    
    SZWCoreTextWithEmoji *emojiBoardColor = [[SZWCoreTextWithEmoji alloc] init];
    emojiBoardColor.font = [UIFont systemFontOfSize:15];
    emojiBoardColor.content = @"愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁😳😊😳😊😳😊😳愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁愁";
    emojiBoardColor.backgroundColor = [UIColor lightGrayColor];
    emojiBoardColor.drawType = DrawTextBoardCllor;
    emojiBoardColor.frame = CGRectMake(0, emojiEllispses.frame.origin.y + emojiEllispses.frame.size.height + 20, [UIScreen mainScreen].bounds.size.width, 70);
    [self.view addSubview:emojiBoardColor];
}

@end
