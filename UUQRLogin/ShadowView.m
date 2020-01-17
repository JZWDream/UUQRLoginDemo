//
//  ShadowView.m
//  UUQRLogin
//
//  Created by wdgeeker on 2019/12/19.
//  Copyright © 2019 wdgeeker. All rights reserved.
//

#import "ShadowView.h"

@interface ShadowView ()
@property (nonatomic, strong) UIImageView *lineView;
@property (nonatomic, strong) UILabel *infoLabel;

@end

@implementation ShadowView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.lineView  = [[UIImageView alloc] init];
        self.lineView.image = [UIImage imageNamed:@"qr_line"];
        [self addSubview:self.lineView];
        
        self.infoLabel = [[UILabel alloc] init];
        self.infoLabel.text = @"将二维码放入框内，扫码需联网";
        self.infoLabel.font = [UIFont systemFontOfSize:15];
        self.infoLabel.textColor = [UIColor whiteColor];
        self.infoLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.infoLabel];

    }
    return self;
}

- (void)uu_scanStart {
    [self addAnimationAboutScan];
}

- (void)uu_scanStop
{
    [self removeAnimationAboutScan];
}

/// 添加扫码动画
-(void)addAnimationAboutScan{
    
    self.lineView.hidden = NO;
    CABasicAnimation *animation = [ShadowView moveYTime:3 fromY:[NSNumber numberWithFloat:0] toY:[NSNumber numberWithFloat:(self.uu_showSize.height-1)] rep:OPEN_MAX];
    [self.lineView.layer addAnimation:animation forKey:@"LineAnimation"];
}

+ (CABasicAnimation *)moveYTime:(float)time fromY:(NSNumber *)fromY toY:(NSNumber *)toY rep:(int)rep{

    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [animationMove setFromValue:fromY];
    [animationMove setToValue:toY];
    animationMove.duration = time;
    animationMove.repeatCount  = rep;
    animationMove.fillMode = kCAFillModeForwards;
    animationMove.removedOnCompletion = NO;
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animationMove;
}

- (void)removeAnimationAboutScan{

    [self.lineView.layer removeAnimationForKey:@"LineAnimation"];
    self.lineView.hidden = YES;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.infoLabel.frame = CGRectMake(0, (self.frame.size.height + self.uu_showSize.height) / 2, self.frame.size.width, 20);
    
    self.lineView.frame = CGRectMake((self.frame.size.width - self.uu_showSize.width) / 2, (self.frame.size.height - self.uu_showSize.height) / 2 - 10, self.uu_showSize.width, 2);
    [self uu_scanStart];
    
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 整体颜色
    CGContextSetRGBFillColor(ctx, 0.15, 0.15, 0.15, 0.6);
    CGContextFillRect(ctx, rect);   //draw the transparent layer
        
    //中间清空矩形框
    CGRect clearDrawRect = CGRectMake((rect.size.width - self.uu_showSize.width) / 2, (rect.size.height - self.uu_showSize.height) / 2 - 10, self.uu_showSize.width, self.uu_showSize.height);
    CGContextClearRect(ctx, clearDrawRect);
   
    //边框
    CGContextStrokeRect(ctx, clearDrawRect);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);  //颜色
    CGContextSetLineWidth(ctx, 1);               //线宽
    CGContextAddRect(ctx, clearDrawRect);       //矩形
    CGContextStrokePath(ctx);
    
    [self addCornerLineWithContext:ctx rect:clearDrawRect];
    
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect{
    
    float cornerWidth = 2.0;
    
    float cornerLong = 20.0;
    
    //画四个边角 线宽
    CGContextSetLineWidth(ctx, cornerWidth);
    
    //颜色
    CGContextSetRGBStrokeColor(ctx, 255 /255.0, 255/255.0, 255/255.0, 1);//白色
    
    //左上角
    CGPoint poinsTopLeftA[] = {CGPointMake(rect.origin.x + cornerWidth/2, rect.origin.y),
                               CGPointMake(rect.origin.x + cornerWidth/2, rect.origin.y + cornerLong)};
    
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y + cornerWidth/2),
                               CGPointMake(rect.origin.x + cornerLong, rect.origin.y + cornerWidth/2)};
    
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    
    
    //左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x + cornerWidth/2, rect.origin.y + rect.size.height - cornerLong),
                                  CGPointMake(rect.origin.x + cornerWidth/2, rect.origin.y + rect.size.height)};
    
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y + rect.size.height - cornerWidth/2),
                                  CGPointMake(rect.origin.x + cornerLong, rect.origin.y + rect.size.height - cornerWidth/2)};
    
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    
    
    //右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x+ rect.size.width - cornerLong, rect.origin.y + cornerWidth/2),
                                CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + cornerWidth/2 )};
    
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x+ rect.size.width - cornerWidth/2, rect.origin.y),
                                CGPointMake(rect.origin.x + rect.size.width- cornerWidth/2, rect.origin.y + cornerLong)};
    
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    //右下角
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x+ rect.size.width - cornerWidth/2, rect.origin.y+rect.size.height - cornerLong),
                                   CGPointMake(rect.origin.x- cornerWidth/2 + rect.size.width, rect.origin.y +rect.size.height )};
    
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x+ rect.size.width - cornerLong, rect.origin.y + rect.size.height - cornerWidth/2),
                                   CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - cornerWidth/2 )};
    
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    
    
    CGContextStrokePath(ctx);
}

- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}

@end
