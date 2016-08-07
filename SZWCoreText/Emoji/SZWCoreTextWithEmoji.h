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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DrawType) {
    DrawTextLine, // emoji不对其
    DrawTextLineAligement, // emoji对齐
    DrawTextWithEllipses, //高度不够用省略号代替
    DrawTextBoardCllor
};

@interface SZWCoreTextWithEmoji : UIView

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat textHeight;

@property (nonatomic, assign) DrawType drawType;

+ (CGFloat)textHeightWithText:(NSString *)aText width:(CGFloat)aWidth font:(UIFont *)aFont type:(DrawType)aType;

@end
