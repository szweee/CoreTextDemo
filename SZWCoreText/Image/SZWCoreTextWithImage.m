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

#import "SZWCoreTextWithImage.h"
#import "CoreText/CoreText.h"
#import "UIImageView+WebCache.h"

@implementation SZWCoreTextWithImage

/*
 CTFramesetter: 
 
 依赖一个富文本属性字符串
 根据这个富文本属性字符串，计算得到一个CTFrame
 可以看做是CTFrame的生产工厂
 */


/*
 CTFrame、CTLine、CTRun三者之间的关系:
 
 CTFrame: 就好比一篇文章，一篇文章会包含多个显示的行
 
 CTLine: 就是上面所说的文章中的每一行，而每一行又包含多个块
 
 CTRun: 就是一行中的很多的块，而块是指 一组共享 相同属性 的字体 的 集合
 */

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    // 1.获取上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // 2.翻转坐标系
    // 设置为当前文本绘制的矩阵
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    // 文本沿y轴移动 self.bounds.size.height
    CGContextTranslateCTM(contextRef, 0, self.bounds.size.height);
    // 翻转当前contextRef
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    // 3.创建NSAttributedString
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:@"CoreText上面是本地图片下面是网络图片CoreText上面是本地图片下面是网络图片CoreText上面是本地图片下面是网络图片CoreText上面是本地图片下面是网络图片CoreText上面是本地图片下面是网络图片CoreText上面是本地图片下面是网络图片CoreText上面是本地图片下面是网络图片"];
    
    
    // 4.创建绘制区域CGPathRef
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, self.bounds);
    
    // 4.1设置文字大小
    [attributed addAttribute:(id)kCTFontAttributeName /* NSFontAttributeName */ value:[UIFont systemFontOfSize:40] range:NSMakeRange(0, 10)];
    // 4.2设置文字颜色
    [attributed addAttribute:(id)kCTForegroundColorAttributeName /* NSForegroundColorAttributeName */ value:[UIColor redColor] range:NSMakeRange(10, 10)];
    // 4.3设置字体
    CGFloat fontSize = 25;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"Party LET", fontSize, NULL);
    [attributed addAttribute:(id)kCTFontAttributeName /* NSFontAttributeName */ value:(__bridge id)fontRef range:NSMakeRange(35, 20)];
    // 4.4设置段落（多个元素）
    CGFloat lineSpace = 20; //行距一般是这个值
    CGFloat lineMaxSpace = 50;
    CGFloat lineMinSpace = 5;
    const CFIndex numberOfSettings = 3;
    // 结构体数组（多个元素）
    CTParagraphStyleSetting settings[numberOfSettings] = {
        
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpace},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineMaxSpace},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineMinSpace}
        
    };
    CTParagraphStyleRef paragraphRef = CTParagraphStyleCreate(settings, numberOfSettings);
    [attributed addAttribute:(id)kCTParagraphStyleAttributeName /* NSParagraphStyleAttributeName */ value:(__bridge id)paragraphRef range:NSMakeRange(0, attributed.length)];
    
    
    // 9.插入图片部分（图文混排）
    // 为图片设置CTRunDelegate,delegate决定留给图片的空间大小
    // CTRunDelegateCallbacks：一个用于保存指针的结构体 指定回调函数
    NSString *imgName = @"xiaobai";
    CTRunDelegateCallbacks imageCallBacks;
    imageCallBacks.version = kCTRunDelegateVersion1;
    imageCallBacks.dealloc = RunDelegateDeallocCallBack; // 内存释放回调
    imageCallBacks.getAscent = RunDelegateGetAscentCallBack; // 设置CTLine上行高度
    imageCallBacks.getDescent = RunDelegateGetDescentCallBack; // 设置CTLine下行高度
    imageCallBacks.getWidth = RunDelegateGetWidthCallBack; // 设置CTLine最大显示宽度
    
    // 9.1该方式适用于图片在本地的情况
    // 创建CTRun的回调Deletate  获取被替换的CTRun的数据：上行高 下行高 块宽度
    CTRunDelegateRef runDelegateRef = CTRunDelegateCreate(&imageCallBacks, (__bridge void * _Nullable)(imgName));
    // 对富文本中的空白字符进行替换成图片
#warning 这里需要注意的是，用来代替图片的占位符使用空格有时会带来排版上的异常，具体原因未知，猜测是 CoreText 的 bug，参考 Nimbus 的实现后，使用 0xFFFC作为占位符，就没有遇到问题了。
    NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc] initWithString:@" "]; //用空格给图片预留位置
    // 给空白字符对应的range 一个长度
    [imageAttributedString addAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id _Nonnull)(runDelegateRef) range:NSMakeRange(0, 1)];
    // 给富文本某个range添加键值对 这个range会被作为一个CTRun块
    [imageAttributedString addAttribute:@"imageName" value:imgName range:NSMakeRange(0, 1)];
    // 在外层富文本的index处插入图片  可插入多张
    [attributed insertAttributedString:imageAttributedString atIndex:30];
    
    // 9.2若图片资源在网络上  则需要使用0xFFFC作为占位符
    NSString *picURL = @"https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Littlegreenman_no_antenna.svg/200px-Littlegreenman_no_antenna.svg.png";
    // 图片信息字典
    NSDictionary *imageInfoDic = @{@"width":@100, @"height":@150};
    // 设置CTRun代理
    CTRunDelegateRef delegate = CTRunDelegateCreate(&imageCallBacks, (__bridge void * _Nullable)(imageInfoDic));
    // 使用0xFFFC作为空白占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    // 将空白的AttributedString插入到当前的attrString中  位置随便  不能越界
    [attributed insertAttributedString:space atIndex:70];
    
    // 5.根据NSAttributedString生成CTFramesetterRef
    CTFramesetterRef setterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributed);
    
    // 6.根据CTFramesetterRef和CGPathRef生成CTFrameRef
    CTFrameRef ctFrame = CTFramesetterCreateFrame(setterRef, CFRangeMake(0, attributed.length), pathRef, NULL);
    
    // 调用CoreGraphics完成最后的绘制
    // 7.绘制文字
    CTFrameDraw(ctFrame, contextRef);
    
    // 10.绘制图片
    // 获得CTLine数组
    NSArray *lines = (NSArray *)CTFrameGetLines(ctFrame);
    NSInteger lineCount = [lines count];
    
    // 坐标原点数组
    CGPoint lineOrigins[lineCount];
    
    // 把CTFrame里每一行的初始坐标写到数组里
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    // 遍历每一行CTLine
    for (NSInteger i = 0; i < lineCount; i++) {
        
        CTLineRef line = (__bridge CTLineRef)(lines[i]);
        NSArray *runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        
        // 遍历每一个CTLine中的CTRun
        for (id runObj in runObjArray) {
            
            // 记录一个CTRun的上行高度、下行高度
            CGFloat runAscent;
            CGFloat runDescent;
            
            // 获取该行的初始坐标
            CGPoint lineOrigin = lineOrigins[i];
            
            // 当前的CTRun
            CTRunRef run = (__bridge CTRunRef)runObj;
            
            // 取出每一个CTRun的属性字典
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            
            // 获取CTRun的参数值
            double runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
            
            // 修改CTRun的Frame
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            CGFloat runX = lineOrigin.x + xOffset;
            CGFloat runY = lineOrigin.y - runDescent;
            CGFloat runW = runWidth;
            CGFloat runH = runAscent + runDescent;
            CGRect runRect = CGRectMake(runX, runY, runW, runH);
            
            // 判断当前CTRun是否应该显示图片  把需要被图片替换的字符位置画上图片
            NSString *imageName = [runAttributes objectForKey:@"imageName"];
            
            // 给当前CTRun所处区域绘制图片
            if ([imageName isKindOfClass:[NSString class]]) {
                // 绘制本地图片
                UIImage *image = [UIImage imageNamed:imageName];
                
                CGRect imageDrawRect;
                imageDrawRect.size = image.size;
                imageDrawRect.origin.x = runRect.origin.x;
                imageDrawRect.origin.y = lineOrigin.y;
                CGContextDrawImage(contextRef, imageDrawRect, image.CGImage);
                
            }else{
                imageName = nil;
                CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes objectForKey:(id)kCTRunDelegateAttributeName];
                if (!delegate) {
                    continue; // 如果是非图片的CTRun 则跳过
                }
                
                //绘制网络图片
                UIImage *image;
                if (!self.image) {
                    // 图片未完成下载  使用占位图片
                    image = [UIImage imageNamed:imageName];
                    // 下载图片
                    [self downLoadImageWithURL:[NSURL URLWithString:picURL]];
                }else{
                    image = self.image;
                }
                
                // 绘制网络图片
                CGRect imageDrawRect;
                imageDrawRect.size = image.size;
                imageDrawRect.origin.x = runRect.origin.x;
                imageDrawRect.origin.y = lineOrigin.y;
                CGContextDrawImage(contextRef, imageDrawRect, image.CGImage);
            }
        }
    }
    
    // 8.释放CF对象
    CFRelease(pathRef);
    CFRelease(fontRef);
    CFRelease(paragraphRef);
    CFRelease(setterRef);
    CFRelease(ctFrame);
    CFRelease(runDelegateRef);
    CFRelease(delegate);
}

#pragma mark - CTRunDelegate
// CTRun的回调  销毁内存的回调
void RunDelegateDeallocCallBack(void *ref)
{
    NSLog(@"RunDelegate Dealloc");
}

// CTRun的回调  获取CTLine的上行高度
CGFloat RunDelegateGetAscentCallBack(void *ref)
{
    NSString *imageName = (__bridge NSString *)(ref);
    if ([imageName isKindOfClass:[NSString class]]) {
        // 对应本地图片
        return [UIImage imageNamed:imageName].size.height;
    }
    // 对应网络图片
    return [[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}

// CTRun的回调  获取CTLine的下行高度
CGFloat RunDelegateGetDescentCallBack(void *ref)
{
    return 0;
}

// CTRun的回调  获取CTLine的最大显示宽度
CGFloat RunDelegateGetWidthCallBack(void *ref)
{
    NSString *imageName = (__bridge NSString *)ref;
    if ([imageName isKindOfClass:[NSString class]]) {
        // 对应本地图片
        return [UIImage imageNamed:imageName].size.width;
    }
    // 对应网络图片
    return [[(__bridge NSDictionary *)ref objectForKey:@"width"] floatValue];
}

- (void)downLoadImageWithURL:(NSURL *)url
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SDWebImageOptions options = SDWebImageRetryFailed | SDWebImageHandleCookies | SDWebImageContinueInBackground;
        options = SDWebImageRetryFailed | SDWebImageContinueInBackground;
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:options progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
            weakSelf.image = image;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.image) {
                    [self setNeedsDisplay];
                }
            });
            
        }];
    });
}

@end
