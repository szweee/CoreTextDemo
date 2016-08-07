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

#import "SZWCoreTextWithText.h"
#import "CoreText/CoreText.h"

@implementation SZWCoreTextWithText


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    //整个流程大概是：获取上下文 -> 翻转坐标系 -> 创建NSAttributedString -> 创建绘制区域CGPathRef -> 根据NSAttributedString创建CTFramesetterRef -> 根据CTFramesetterRef和CGPathRef创建CTFrame -> CTFrameDraw绘制 -> 释放CF对象
    
    // 1.获取上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // 2.翻转坐标系
    NSLog(@"转换前的坐标系：%@", NSStringFromCGAffineTransform(CGContextGetCTM(contextRef)));
    
    // 下面这两种翻转方式的效果一样
    // 2.1
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    //    CGContextConcatCTM(contextRef, CGAffineTransformMake(1, 0, 0, -1, 0, self.bounds.size.height));
    
    // 2.2
    CGContextTranslateCTM(contextRef, 0, self.bounds.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    NSLog(@"转换后的坐标系：%@", NSStringFromCGAffineTransform(CGContextGetCTM(contextRef)));
    
    
    // 3.创建NSAttributedString
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:@"初识CoreText初识CoreText初识CoreText初识CoreText初识CoreText初识CoreText初识CoreText初识CoreText初识CoreText初识CoreText初识CoreText初识CoreText初识CoreText初识CoreText"];
    [attributed addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, attributed.length)];
    // 3.1设置颜色 下面这两种方法都可以
    [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, 2)];
    [attributed addAttribute:(id)kCTForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(2, 7)];
    
    // 设置空心字
    int  number = 2;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
    [attributed addAttribute:(id)kCTStrokeWidthAttributeName value:(__bridge id)num range:NSMakeRange(0, 70)];
    
    // 3.2设置行间距
    CGFloat lineSpace = 30; // 行间距一般取决于这个值
    CGFloat lineMaxSpace = 50; // 最大行间距
    CGFloat lineMinSpace = 5; // 最小行间距
    
    // 3.3创建多个段落样式  同3.2原理一样
    // 3.3.1断行模式
    CTParagraphStyleSetting lineBreakStyle;
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping;
    lineBreakStyle.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakStyle.value = &lineBreak;
    lineBreakStyle.valueSize = sizeof(CTLineBreakMode);
    // 3.3.2文本对齐属性
    CTParagraphStyleSetting alignmentStyle;
    CTTextAlignment alignment = kCTTextAlignmentJustified;
    alignmentStyle.spec = kCTParagraphStyleSpecifierAlignment;
    alignmentStyle.value = &alignment;
    alignmentStyle.valueSize = sizeof(alignmentStyle);
    // 3.3.3首行缩进
//    CTParagraphStyleSetting firstLineStyle;
//    CGFloat firstLine = 50.0f;
//    firstLineStyle.spec = kCTParagraphStyleSpecifierHeadIndent;
//    firstLineStyle.value = &firstLine;
//    firstLineStyle.valueSize = sizeof(CGFloat);
    // sizeof(CGFloat) 和 sizeof(alignmentStyle) 和 sizeof(CTLineBreakMode) 这三个参数填写的形式都不同  这个括号里面的参数和什么有关？不理解
    
    // 结构体数组(设置多个元素) Paragraph段落
    // 将上述3.3.所有的样式组装成数组容器
    CTParagraphStyleSetting settings[] = {
        
        // 3.2
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpace},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineMaxSpace},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineMinSpace},
        
        // 3.3
        lineBreakStyle, alignmentStyle/*, firstLineStyle*/
        
    };
    
    // 设置单个元素
    //CTParagraphStyleSetting settings = {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFontRef), &lineSpace};
    
    // 创建总段落样式
    CTParagraphStyleRef paragraphRef = CTParagraphStyleCreate(settings, 6);
    
    // 将设置的行距应用于整段文字
    [attributed addAttribute:NSParagraphStyleAttributeName/* (id)kCTParagraphStyleAttributeName */ value:(__bridge id)paragraphRef range:NSMakeRange(0, attributed.length)];
    // 3.3设置字体
    CGFloat fontSize = 40;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    [attributed addAttribute:NSFontAttributeName/* (id)kCTFontAttributeName */ value:(__bridge id)fontRef range:NSMakeRange(6, 10)];
    
    // 3.4设置空心
    CFNumberRef num2 = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
    [attributed addAttribute:(id)kCTStrokeWidthAttributeName value:(__bridge id)num2 range:NSMakeRange(0, 50)];
    
    // 3.5设置斜体字
    CTFontRef font1 = CTFontCreateWithName((CFStringRef)[UIFont italicSystemFontOfSize:20].fontName, 30, NULL);
    [attributed addAttribute:(id)kCTFontAttributeName value:(__bridge id)font1 range:NSMakeRange(80, 20)];
    
    // 3.6设置下划线
    [attributed addAttribute:(id)kCTUnderlineStyleAttributeName value:(id)[NSNumber numberWithInt:kCTUnderlineStyleDouble] range:NSMakeRange(65, 20)];
    
    // 3.7下划线颜色
    [attributed addAttribute:(id)kCTUnderlineColorAttributeName value:(id)[UIColor redColor].CGColor range:NSMakeRange(65, 15)];
    
    //4.创建绘制区域CGPathRef 可以对path进行个性化裁剪以改变显示区域
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, self.bounds);
    //    CGPathAddEllipseInRect(pathRef, NULL, self.bounds);
    
    // 5.根据NSAttributedString创建CTFramesetterRef
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributed);
    
    // 6.根据CTFramesetterRef和CGOathRef创建CTFrame
    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), pathRef, NULL);
    
    // 7.CTFrameDraw绘制
    CTFrameDraw(ctFrame, contextRef);
    
    // 8.内存管理  ARC不能管理CF开头的对象 创建CF的对象需要手动释放
    // 注意：一般释放的是创建的时候带有Create字段的对象
    //    CFRelease(contextRef);
    
    CFRelease(pathRef);
    CFRelease(framesetter);
    CFRelease(ctFrame);
    CFRelease(paragraphRef);
    CFRelease(fontRef);
}


@end
