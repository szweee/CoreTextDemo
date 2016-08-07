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

#import "SZWCoreTextWithClick.h"
#import "CoreText/CoreText.h"

NSString *kAtRegularExpression = @"@[^\\s@]+?\\s{1}";
NSString *kNumberRegularExpression = @"\\d+[^\\d]{1}";

@interface SZWCoreTextWithClick () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CTFrameRef ctFrame;
@property (nonatomic, assign) NSRange pressRange;

@property (nonatomic, assign) int lineIndex;
@property (nonatomic, assign) CFIndex strIndex;

@end

@implementation SZWCoreTextWithClick

- (instancetype)init {
    self = [super init];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAttributedString:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    NSMutableAttributedString *attributed = [[self class] addGlobalAttributeWithContent:self.content font:self.font];
    [self recognizedSpecialStringWithAttributed:attributed];
    self.textHeight = [[self class] textHeightWithTextAligement:self.content width:CGRectGetWidth(self.bounds) font:self.font];
    if (self.pressRange.length != 0) {
        [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:self.pressRange];
    }
    if (self.textHeight > CGRectGetHeight(self.frame)) {
        self.textHeight = CGRectGetHeight(self.frame);
    }
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.textHeight));
    
    CTFramesetterRef setterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributed);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(setterRef, CFRangeMake(0, attributed.length), pathRef, NULL);
    self.ctFrame = CFRetain(ctFrame);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, self.textHeight);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    NSArray *lines = (NSArray *)CTFrameGetLines(self.ctFrame);
    NSInteger lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    
    for (int i = 0; i < lineCount; i ++) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        CGPoint lineOrigin = lineOrigins[i];
        CGFloat lineHeight = self.font.pointSize * 1.4;
        CGFloat frameY = self.textHeight - (i + 1)*lineHeight - self.font.descender;
        lineOrigin.y = frameY;
        CGContextSetTextPosition(contextRef, lineOrigin.x, lineOrigin.y);
        
        frameY = self.textHeight - frameY;
        if (self.textHeight - frameY > lineHeight) {
            CTLineDraw(line, contextRef);
        }else{
            static NSString *ellispese = @"\u2026";
            CFRange lastLineRange = CTLineGetStringRange(line);
            if (lastLineRange.location + lastLineRange.length < attributed.length) {
                NSInteger truncationPosition = lastLineRange.location + lastLineRange.length - 1;
                NSDictionary *tokenAttributed = [attributed attributesAtIndex:truncationPosition effectiveRange:nil];
                NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:ellispese attributes:tokenAttributed];
                CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)tokenString);
                NSMutableAttributedString *truncationString = [[attributed attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
                if (lastLineRange.length > 0) {
                    unichar lastChar = [[truncationString string] characterAtIndex:lastLineRange.length - 1];
                    if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:lastChar]) {
                        [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
                    }
                }
                [truncationString appendAttributedString:tokenString];
                CTLineRef truncationLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationString);
                CTLineTruncationType truncationType = kCTLineTruncationEnd;
                CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, self.frame.size.width, truncationType, truncationToken);
                if (!truncatedLine) {
                    truncatedLine = CFRetain(truncationToken);
                }
                CTLineDraw(truncatedLine, contextRef);
                CFRelease(truncationToken);
                CFRelease(truncationLine);
                CFRelease(truncatedLine);
            }else{
                CTLineDraw(line, contextRef);
            }
            break;
        }
    }
    CFRelease(pathRef);
    CFRelease(setterRef);
    CFRelease(ctFrame);
}

- (NSMutableArray *)recognizedSpecialStringWithAttributed:(NSMutableAttributedString *)attributed {
    NSMutableArray *rangeArr = @[].mutableCopy;
    
    NSRegularExpression *atRegular = [NSRegularExpression regularExpressionWithPattern:kAtRegularExpression options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *atResult = [atRegular matchesInString:self.content options:NSMatchingWithTransparentBounds range:NSMakeRange(0, self.content.length)];
    
    for (NSTextCheckingResult *checkResult in atResult) {
        if (attributed) {
            [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(checkResult.range.location, checkResult.range.length - 1)];
        }
        [rangeArr addObject:[NSValue valueWithRange:checkResult.range]];
    }
    
    NSRegularExpression *numRegular = [NSRegularExpression regularExpressionWithPattern:kNumberRegularExpression options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *numResult = [numRegular matchesInString:self.content options:NSMatchingWithTransparentBounds range:NSMakeRange(0, self.content.length)];
    
    for (NSTextCheckingResult *checkResult in numResult) {
        if (attributed) {
            [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(checkResult.range.location, checkResult.range.length - 1)];
        }
        [rangeArr addObject:[NSValue valueWithRange:checkResult.range]];
    }
    return rangeArr;
}

- (void)tapAttributedString:(UITapGestureRecognizer *)tap {
    if (self.pressRange.length != 0) {
        NSString *clickStr = [self.content substringWithRange:self.pressRange];
        UIAlertView *alvertView=[[UIAlertView alloc]initWithTitle:clickStr message:[NSString stringWithFormat:@"点击了\n第%d行\n第%ld个字符", self.lineIndex, self.strIndex] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alvertView show];
    }
}

+ (NSMutableAttributedString *)addGlobalAttributeWithContent:(NSString *)aContent font:(UIFont *)aFont {
    
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:aContent];

    CTParagraphStyleSetting lineBreakStyle;
    CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
    lineBreakStyle.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakStyle.valueSize = sizeof(CTLineBreakMode);
    lineBreakStyle.value = &lineBreakMode;

    CTParagraphStyleSetting theSettings[] = {
        lineBreakStyle,
    };
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, 1);
    
    [attributed addAttribute:NSParagraphStyleAttributeName value:(__bridge id)(theParagraphRef) range:NSMakeRange(0, attributed.length)];
    [attributed addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, attributed.length)];
    [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, attributed.length)];
    
    CFRelease(theParagraphRef);
    return attributed;
}

+ (CGFloat)textHeightWithTextAligement:(NSString *)aText width:(CGFloat)aWidth font:(UIFont *)aFont {
    NSMutableAttributedString *content = [[self class] addGlobalAttributeWithContent:aText font:aFont];
    
    CTFramesetterRef setterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(setterRef, CFRangeMake(0, content.length), NULL, CGSizeMake(aWidth, MAXFLOAT), NULL);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, aWidth, suggestSize.height));
    
    CTFrameRef ctFrame = CTFramesetterCreateFrame(setterRef, CFRangeMake(0, content.length), pathRef, NULL);
    
    NSArray *lines = (NSArray *)CTFrameGetLines(ctFrame);
    NSInteger lineCount = [lines count];
    
    CGFloat totalHeight = lineCount * (aFont.pointSize * 1.4);
    
    CFRelease(setterRef);
    CFRelease(pathRef);
    CFRelease(ctFrame);
    return totalHeight;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL gustureShouldBegin = NO;
    CGPoint location = [gestureRecognizer locationInView:self];
    CGFloat lineHeight = self.font.pointSize * 1.4;
     self.lineIndex = location.y / lineHeight;
    
    CGPoint cilckPoint = CGPointMake(location.x, self.textHeight - location.y);
    CFArrayRef lines = CTFrameGetLines(self.ctFrame);
    if (self.lineIndex < CFArrayGetCount(lines)) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, self.lineIndex);
         self.strIndex = CTLineGetStringIndexForPosition(line, cilckPoint);
        
        NSMutableAttributedString *attributes = [[NSMutableAttributedString alloc] initWithString:self.content];
        NSArray *checkArr = [self recognizedSpecialStringWithAttributed:attributes];
        for (NSValue *value in checkArr) {
            NSRange range = [value rangeValue];
            if (self.strIndex > range.location && self.strIndex < range.location + range.length) {
                self.pressRange = range;
                gustureShouldBegin = YES;
                
                [self setNeedsDisplay];

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self cancelColorAdded];
                });
            }
        }
        return gustureShouldBegin;
    }
    return YES;
}

- (void)cancelColorAdded
{
    self.pressRange = NSMakeRange(0, 0);
    
    [self setNeedsDisplay];
}

@end
