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

#import "SZWCoreTextWithEmoji.h"
#import "CoreText/CoreText.h"

// 行距 用于DrawTextLine情况下
const CGFloat kGlobalLineLeading = 5.0;

// 行间距比例 用于DrawTextLineAligement情况下比较好
// 在15字体下，比值小于1.4计算出来的高度会导致emoji显示不全 ？
const CGFloat kPerLineRatio = 1.5;

@implementation SZWCoreTextWithEmoji

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.drawType == DrawTextLine) {
        [self drawRectWithLineByLine];
    }else if (self.drawType == DrawTextLineAligement) {
        [self drawRectWithLineByLineAligement];
    }else if (self.drawType == DrawTextWithEllipses) {
        [self drawRectWithLineByLineAligementAndEllipses];
    }else{
        [self drawRectWithTextBoardCllor];
    }
}

#pragma mark - 一行一行绘制，未调整行高
- (void)drawRectWithLineByLine {
    
    // 1.创建需要绘制的文字
    NSMutableAttributedString *attributed = [[self class] addGlobalAttributeWithContent:self.content font:self.font];
    
    // 3.创建绘制区域，path的高度对绘制有直接影响，如果高度不够，则计算出来的CTLine的数量会少一行或者少多行
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.textHeight));
    
    // 4.根据NSAttributedString生成CTFramesetterRef
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributed);
    
    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), path, NULL);
    
    
    // 获取上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // 转换坐标系
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, self.textHeight); // 此处用计算出来的高度
    CGContextScaleCTM(contextRef, 1.0, -1.0);
  
    // 一行一行绘制
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    
    // 把ctFrame里每一行的初始坐标写到数组里，注意CoreText的坐标是左下角为原点
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    CGFloat frameY = 0;
    for (CFIndex i = 0; i < lineCount; i++) {
        // 遍历每一行CTLine
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading; // 行距
        // 该函数除了会设置好ascent,descent,leading之外，还会返回这行的宽度  整行高为(ascent+|descent|+leading)
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        CGPoint lineOrigin = lineOrigins[i];
        
        // 微调Y值，需要注意的是CoreText的Y值是在baseLine处，而不是下方的descent。
        // lineDescent为正数，self.font.descender为负数
        if (i > 0) {
            // 第二行之后需要计算
            frameY = frameY - kGlobalLineLeading - lineAscent;
            lineOrigin.y = frameY;
            
        }else{
            // 第一行可直接用
            frameY = lineOrigin.y;
        }
        // 调整坐标
        CGContextSetTextPosition(contextRef, lineOrigin.x, lineOrigin.y);
        CTLineDraw(line, contextRef);
        
        // 微调
        frameY = frameY - lineDescent;
        
        // 该方式与上述方式效果一样
//        frameY = frameY - lineDescent - self.font.descender;
    }
    
    
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(ctFrame);
}

#pragma mark - 一行一行绘制，行高确定，行与行之间对齐
- (void)drawRectWithLineByLineAligement {
    NSMutableAttributedString *attributed = [[self class] addGlobalAttributeWithContent:self.content font:self.font];

    CGMutablePathRef pathRef = CGPathCreateMutable();
#warning 这里的textHeight*1.3以上才会显示正常 小于1.3的话 下面的lines数组里面只有6行(本来是8行) 为什么？应该是attributed设置行距的方法影响到ctFrame的计算
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.textHeight));
    
#warning 在设置attributed的时候 里面设置行距的方法会影响到这里ctFrame里面CTline的数量  所以在DrawTextLineAligement情况下不适用设置行距的方式  在DrawTextLine下可以使用
    CTFramesetterRef setterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributed);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(setterRef, CFRangeMake(0, attributed.length), pathRef, NULL);

    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, self.textHeight);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
   
    NSArray *lines = (NSArray *)CTFrameGetLines(ctFrame);
    NSInteger lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    for (int i = 0; i < lineCount; i ++) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        CGPoint lineOrigin = lineOrigins[i];
        
        // 微调Y值，需要注意的是CoreText的Y值是在baseLine处，而不是下方的descent。
        CGFloat lineHeight = self.font.pointSize * kPerLineRatio;
        // 调节self.font.descender该值可改变文字排版的上下间距，此处下间距为0
        CGFloat frameY = self.textHeight - (i + 1)*lineHeight - self.font.descender;
        lineOrigin.y = frameY;
        
        CGContextSetTextPosition(contextRef, lineOrigin.x, lineOrigin.y);
        CTLineDraw(line, contextRef);
        
    }
    
    CFRelease(pathRef);
    CFRelease(setterRef);
    CFRelease(ctFrame);
}

#pragma mark - 一行一行绘制，行高确定，高度不够时加上省略号
- (void)drawRectWithLineByLineAligementAndEllipses {
    NSMutableAttributedString *attributed = [[self class] addGlobalAttributeWithContent:self.content font:self.font];
    self.textHeight = [[self class] textHeightWithText:self.content width:CGRectGetWidth(self.bounds) font:self.font type:self.drawType];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.textHeight));
    
    CTFramesetterRef setterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributed);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(setterRef, CFRangeMake(0, attributed.length), pathRef, NULL);
    
    if (self.textHeight > CGRectGetHeight(self.frame)) {
        self.textHeight = CGRectGetHeight(self.frame);
    }
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, self.textHeight);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    NSArray *lines = (NSArray *)CTFrameGetLines(ctFrame);
    NSInteger lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    CGFloat frameY;
    for (int i = 0; i < lineCount; i ++) {
        CTLineRef line = (__bridge CTLineRef)(lines[i]);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        CGPoint lineOrigin = lineOrigins[i];
        
        CGFloat lineHeight = self.font.pointSize * kPerLineRatio;
        frameY = self.textHeight - (i + 1)*lineHeight - self.font.descender;
        lineOrigin.y = frameY;
        
        CGContextSetTextPosition(contextRef, lineOrigin.x, lineOrigin.y);
        
        // 翻转坐标系
        frameY = self.textHeight - frameY;
        if (self.textHeight - frameY > lineHeight) {
            CTLineDraw(line, contextRef);
        }else{
            // 最后一行
            // 省略号
            static NSString *ellipses = @"\u2026";
            // 得到阶段后最后一行的range
            // lastRange.location的位置是在ctframe整个中的位置，如：第二行的第一个字符的index是加上第一行所有字符后的index
            CFRange lastRange = CTLineGetStringRange(line);
            // 如果截断后的最后一行的location+length小于attributed.length  说明这不是整个ctFrame的最后一行
            if (lastRange.location + lastRange.length < attributed.length) {
                
                /*
                 CTLineTruncationType:
                 kCTLineTruncationStart  = 0,  从开始截断
                 kCTLineTruncationEnd    = 1,  从中间截断
                 kCTLineTruncationMiddle = 2   从末尾截断
                 */
                CTLineTruncationType truncationType = kCTLineTruncationEnd;
                // 截断后最后一个字符的位置
                NSUInteger truncationAttributePosition = lastRange.location + lastRange.length - 1;
                // 截断后最后一个字符的属性字典
                NSDictionary *lastAttributesDic = [attributed attributesAtIndex:truncationAttributePosition effectiveRange:NULL];
                // 根据最后一个字符的属性字典给省略号设置颜色、大小等
                NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:ellipses attributes:lastAttributesDic];
                // 用省略号单独创建一个CTLine
                CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)tokenString);
                // 把截断后最后一行的字符串copy一份  如果要调整省略号的位置(省略号后面的文字不再显示的情况下)，只需指定复制长度即可 （如：lastRange.length/3.0表示省略号放在1/3的地方）
                // 如果省略号在中间的情况下还要显示后面的文字  只需把上面truncationType这个参数设置为kCTLineTruncationMiddle即可
                NSInteger copyLenth = lastRange.length;
                NSMutableAttributedString *copyLastString = [[attributed attributedSubstringFromRange:NSMakeRange(lastRange.location, copyLenth)] mutableCopy];
                
#warning 这个判断、删除最后一个空格或者换行的方法必须要吗？ 好像不要没什么影响
                if (lastRange.length > 0) {
                    // 拿到copy字符串的最后一个字符
                    unichar lastCharacter = [[copyLastString string] characterAtIndex:copyLenth - 1];
                    // 如果取到的最后一个字符是空格或者换行
                    if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:lastCharacter]) {
                        // 删除掉
                        [copyLastString deleteCharactersInRange:NSMakeRange(copyLenth - 1, 1)];
                    }
                }
                // 把省略号拼接到copy的字符串
                [copyLastString appendAttributedString:tokenString];
                // 把新的字符串创建成CTLine
                CTLineRef truncationLine = CTLineCreateWithAttributedString((CFAttributedStringRef)copyLastString);
                // 创建一个截断的CTLine，该方法不能少
                CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, self.frame.size.width, truncationType, truncationToken);
                if (!truncatedLine) {
                    truncatedLine = CFRetain(truncationToken);
                }
                
                CTLineDraw(truncatedLine, contextRef);
                CFRelease(truncationToken);
                CFRelease(truncationLine);
                CFRelease(truncatedLine);
                
            }else{
                // 这一行刚好是最后一行，且最后一行的字符可以完全绘制出来
                CTLineDraw(line, contextRef);
            }
            break;
        }
    }
  
    CFRelease(pathRef);
    CFRelease(setterRef);
    CFRelease(ctFrame);
}

#pragma mark - 文字加边框
- (void)drawRectWithTextBoardCllor {
    NSMutableAttributedString *attributed = [[self class] addGlobalAttributeWithContent:self.content font:self.font];
    self.textHeight = [[self class] textHeightWithText:self.content width:CGRectGetWidth(self.bounds) font:self.font type:self.drawType];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.textHeight));
    
    CTFramesetterRef setterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributed);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(setterRef, CFRangeMake(0, attributed.length), pathRef, NULL);
    
    if (self.textHeight > CGRectGetHeight(self.frame)) {
        self.textHeight = CGRectGetHeight(self.frame);
    }
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, self.textHeight);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    CFArrayRef Lines = CTFrameGetLines(ctFrame);
    long linecount = CFArrayGetCount(Lines);
    CGPoint origins[linecount];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), origins);
    
    NSInteger lineIndex = 0;
    for (id oneLine in (__bridge NSArray *)Lines) {
        CGRect lineBounds = CTLineGetImageBounds((CTLineRef)oneLine, contextRef);
        
        lineBounds.origin.x += origins[lineIndex].x;
        lineBounds.origin.y += origins[lineIndex].y;
        
        lineIndex++;
        //画长方形
        
        //设置颜色，仅填充4条边
        CGContextSetStrokeColorWithColor(contextRef, [[UIColor redColor] CGColor]);
        //设置线宽为1
        CGContextSetLineWidth(contextRef, 1.0);
        //设置长方形4个顶点
        CGPoint poins[] = {CGPointMake(lineBounds.origin.x, lineBounds.origin.y),CGPointMake(lineBounds.origin.x+lineBounds.size.width, lineBounds.origin.y),CGPointMake(lineBounds.origin.x+lineBounds.size.width, lineBounds.origin.y+lineBounds.size.height),CGPointMake(lineBounds.origin.x, lineBounds.origin.y+lineBounds.size.height)};
        CGContextAddLines(contextRef,poins,4);
        CGContextClosePath(contextRef);
        CGContextStrokePath(contextRef);
    }
    
    CTFrameDraw(ctFrame,contextRef);
    
    CFRelease(pathRef);
    CFRelease(ctFrame);
    CFRelease(setterRef);
}


+ (NSMutableAttributedString *)addGlobalAttributeWithContent:(NSString *)aContent font:(UIFont *)aFont {
    
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:aContent];
#warning 这几个属性有待研究
    CTParagraphStyleSetting lineBreakStyle;
    CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
    lineBreakStyle.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakStyle.valueSize = sizeof(CTLineBreakMode);
    lineBreakStyle.value = &lineBreakMode;

#warning 在这里设置了行距  但是在DrawTextLineAligement情况下  行间距并没有用这个参数 所以算高度的时候会对计算CTline的行数有影响  以至于最后n行的文字显示不出来
#warning 这种设置行距的方式  在DrawTextLineAligement的情况下不要用 在DrawTextLine情况下用  DrawTextLineAligement情况下用kPerLineRatio（行间距比例的方式）
//    CTParagraphStyleSetting lineSpaceStyle;
//    CGFloat lineSpace = kGlobalLineLeading; // 行距 用于DrawTextLine情况下
//    lineSpaceStyle.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
//    lineSpaceStyle.value = &lineSpace;
//    lineSpaceStyle.valueSize = sizeof(CGFloat);
    
    // 结构体数组
    CTParagraphStyleSetting theSettings[] = {
        lineBreakStyle,
//        lineSpaceStyle
    };
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, 1);
    
    [attributed addAttribute:NSParagraphStyleAttributeName value:(__bridge id)(theParagraphRef) range:NSMakeRange(0, attributed.length)];
    
//    CFStringRef fontName = (__bridge CFStringRef)aFont.fontName;
//    CTFontRef fontRef = CTFontCreateWithName(fontName, aFont.pointSize, NULL);
    // 将字体大小应用于整段文字
//    [attributed addAttribute:NSFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, aContent.length)];
    [attributed addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, attributed.length)];

    [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, attributed.length)];
    
    CFRelease(theParagraphRef);
//    CFRelease(fontRef);
    return attributed;
}


+ (CGFloat)textHeightWithText:(NSString *)aText width:(CGFloat)aWidth font:(UIFont *)aFont type:(DrawType)aType{
    if (aType == DrawTextLine) {
        return [self textHeightWithText:aText width:aWidth font:aFont];
    }else{
        return [self textHeightWithTextAligement:aText width:aWidth font:aFont];
    }
}

#pragma mark - calculateDrawTextLineHeight
/**
 *  高度 = 每行的asent + 每行的descent + 行数*行间距
 *  行间距为指定的数值
 */
+ (CGFloat)textHeightWithText:(NSString *)aText width:(CGFloat)aWidth font:(UIFont *)aFont {
    NSMutableAttributedString *content = [[self class] addGlobalAttributeWithContent:aText font:aFont];
    
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, aText.length), NULL, CGSizeMake(aWidth, MAXFLOAT), NULL);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, aWidth, suggestSize.height));
    
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, aText.length), path, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    
    CGFloat ascent = 0;
    CGFloat descent = 0;
    CGFloat leading = 0;
    
    CGFloat totalHeight = 0;
    for (CFIndex i = 0; i < lineCount; i++) {
        
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, i);
        CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
        totalHeight += ascent + descent;
    }
    leading = kGlobalLineLeading; // 行间距，
    totalHeight += (lineCount ) * leading;
    
    return totalHeight;
}

#pragma mark - calculateDrawTextLineAligementHeight
// 高度 = 每行的固定高度 * 行数
+ (CGFloat)textHeightWithTextAligement:(NSString *)aText width:(CGFloat)aWidth font:(UIFont *)aFont {
    NSMutableAttributedString *content = [[self class] addGlobalAttributeWithContent:aText font:aFont];
    
    CTFramesetterRef setterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(setterRef, CFRangeMake(0, content.length), NULL, CGSizeMake(aWidth, MAXFLOAT), NULL);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, aWidth, suggestSize.height));
    
    CTFrameRef ctFrame = CTFramesetterCreateFrame(setterRef, CFRangeMake(0, content.length), pathRef, NULL);
    
    NSArray *lines = (NSArray *)CTFrameGetLines(ctFrame);
    NSInteger lineCount = [lines count];
    
    CGFloat totalHeight = lineCount * (aFont.pointSize * kPerLineRatio);
    return totalHeight;
}

@end
