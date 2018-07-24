//
//  DialView.m
//  MyTest
//
//  Created by PeteyMi on 22/07/2018.
//  Copyright © 2018 PeteyMi. All rights reserved.
//

#import "DialView.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


@interface SectorView : UIView

@property (nonatomic, assign) CGPoint arcCenterPoint;

@end

@implementation SectorView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.opaque = NO;
    }
    return self;
}

- (void)setArcCenterPoint:(CGPoint)arcCenterPoint {
    _arcCenterPoint = arcCenterPoint;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2].CGColor);
//    CGContextMoveToPoint(ctx, 10, 0);
//    CGContextAddArc(ctx, self.center.x, 0, 100, 0, M_PI, 0);
//    CGContextDrawPath(ctx, kCGPathFill); //填充路径
}

@end

#define SCALE_VIEW_DIVIDE       120
#define SCALE_VIEW_REMAINDER    10
#define SCALE_VIEW_LINE_NORMAL_WIDTH        5
#define SCALE_VIEW_LINE_BIG_WIDTH       10

@interface ScaleView : UIView

@property (nonatomic,assign)CGFloat arcAngle;
@property (nonatomic,assign)CGFloat startAngle;
@property (nonatomic,assign)CGFloat endAngle;
@property (nonatomic, strong) UIColor    *scaleColor;
@property (nonatomic, assign) CGFloat  intervalValue;
@property (nonatomic, assign) CGFloat   radius;
@end

@implementation ScaleView

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.startAngle = -M_PI_2 ;
        self.endAngle = M_PI_2 * 3.0;
        self.arcAngle = self.endAngle - self.startAngle;
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.scaleColor = [UIColor whiteColor];
        self.intervalValue = 30;
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.radius = CGRectGetWidth(self.bounds) / 2.0;
    [self drawScaleWithDivide:SCALE_VIEW_DIVIDE andRemainder:SCALE_VIEW_REMAINDER strokeColor:_scaleColor filleColor:_scaleColor scaleLineNormalWidth:SCALE_VIEW_LINE_NORMAL_WIDTH scaleLineBigWidth:SCALE_VIEW_LINE_BIG_WIDTH];
}

- (void)setScaleColor:(UIColor *)scaleColor {
    _scaleColor = scaleColor;
    [self drawScaleWithDivide:SCALE_VIEW_DIVIDE andRemainder:SCALE_VIEW_REMAINDER strokeColor:_scaleColor filleColor:_scaleColor scaleLineNormalWidth:SCALE_VIEW_LINE_NORMAL_WIDTH scaleLineBigWidth:SCALE_VIEW_LINE_BIG_WIDTH];
}

//默认计算半径-10,计算label的坐标
- (CGPoint)calculateTextPositonWithArcCenter:(CGPoint)center Angle:(CGFloat)angel {
    CGFloat x = (self.radius - 10 + 3*1)* cosf(angel);
    CGFloat y = (self.radius - 10 + 3*1)* sinf(angel);
    return CGPointMake(center.x + x, center.y - y);
}

-(void)DrawScaleValueWithDivide:(NSInteger)divide {
    CGFloat textAngel = self.arcAngle/divide;
    if (divide==0) {
        return;
    }
    for (NSUInteger i = 1; i <= divide; i++) {
        CGPoint point = [self calculateTextPositonWithArcCenter:self.center Angle:-(self.endAngle-textAngel*i)];
        NSString *tickText = [NSString stringWithFormat:@"%ld°",(divide - i)*SCALE_VIEW_DIVIDE/divide];
        //默认label的大小23 * 14
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectZero];
        text.font = [UIFont systemFontOfSize:10.f];
        text.textColor = self.scaleColor;
        text.textAlignment = NSTextAlignmentCenter;
        
        text.text = tickText;
        [text sizeToFit];
        text.center = point;
        
        [self addSubview:text];
    }
}

- (void) transferRotation:(CGFloat)value {
    self.transform = CGAffineTransformRotate(self.transform, (value * M_PI)/180);
    
    for (UIView *item in self.subviews) {
        if ([item isKindOfClass:[UILabel class]]) {
            item.transform = CGAffineTransformRotate(item.transform, (-value * M_PI)/180);
        }
    }
}

- (void)cleanSubView {
    NSArray *array = self.subviews;
    
    for (UIView *item in array) {
        [item removeFromSuperview];
    }
}

-(void)drawScaleWithDivide:(int)divide andRemainder:(NSInteger)remainder strokeColor:(UIColor*)strokeColor filleColor:(UIColor*)fillColor scaleLineNormalWidth:(CGFloat)scaleLineNormalWidth scaleLineBigWidth:(CGFloat)scaleLineBigWidth{
    [self cleanSubView];
    
    self.layer.sublayers = nil;

    UIBezierPath *arcPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-10, -10, CGRectGetWidth(self.bounds) + 20, CGRectGetHeight(self.bounds) + 20)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = arcPath.CGPath;
    maskLayer.fillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2].CGColor;

    [self.layer addSublayer:maskLayer];
    
    CGFloat perAngle=self.arcAngle/divide;
    
    //我们需要计算出每段弧线的起始角度和结束角度
    //这里我们从- M_PI 开始，我们需要理解与明白的是我们画的弧线与内侧弧线是同一个圆心
    for (NSInteger i = 0; i<= divide; i++) {
        
        CGFloat startAngel = (self.startAngle+ perAngle * i);
        CGFloat endAngel   = startAngel + perAngle/5;
        
        UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:self.center radius:self.radius - self.intervalValue startAngle:startAngel endAngle:endAngel clockwise:YES];
        CAShapeLayer *perLayer = [CAShapeLayer layer];
        
        if((remainder!=0)&&(i % remainder) == 0) {
            perLayer.strokeColor = strokeColor.CGColor;
            perLayer.lineWidth   = scaleLineBigWidth;
        }else{
            perLayer.strokeColor = strokeColor.CGColor;;
            perLayer.lineWidth   = scaleLineNormalWidth;
            
        }
        
        perLayer.path = tickPath.CGPath;
        [self.layer addSublayer:perLayer];
    }
    
    [self DrawScaleValueWithDivide:12];
}

@end


//****************************************************************//
@interface DialView () {
    NSInteger _angle;
}

//@property (nonatomic, readonly) UIView  *backgroundView;
@property (nonatomic, readonly) UICollectionView    *collectionView;
@property (nonatomic, readonly) ScaleView   *scaleView;
@property (nonatomic, assign) CGPoint   startPoint;
@property (nonatomic, readonly) UILabel *textLabel;

@end

@implementation DialView
//@synthesize backgroundView = _backgroundView;
@synthesize collectionView = _collectionView;
@synthesize scaleView = _scaleView;
@synthesize textLabel = _textLabel;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];

    [self setup];
}

- (void)setup {
    _angle = 0;
    self.backgroundColor = [UIColor clearColor];
    self.angleValue = 60;
    self.clipsToBounds = YES;
    self.textLabel.text = [NSString stringWithFormat:@"%ld°",(long)_angle];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    if (_textLabel) {
        [_textLabel sizeToFit];
        _textLabel.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, 60);
    }
}


- (ScaleView*)scaleView {
    if (_scaleView == nil) {
        _scaleView = [[ScaleView alloc] initWithFrame:CGRectZero];
        [self addSubview:_scaleView];
    }
    return _scaleView;
}

- (void)transferRotation:(CGFloat)value {
    
    [self.scaleView transferRotation:value];

    if (_angle - value < 0) {
        _angle = 360;
    }
    _angle -= value;
    _angle = _angle % 360;
    
    CGFloat tmp = _angle / 3;
    
    self.textLabel.text = [NSString stringWithFormat:@"%ld°",(long)tmp];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dialView:angleChangeValue:)]) {
        [self.delegate dialView:self angleChangeValue:_angle];
    }
}

- (void)setScaleColor:(UIColor *)scaleColor {
    self.scaleView.scaleColor = scaleColor;
    self.textLabel.textColor = scaleColor;
}
- (UIColor*)scaleColor {
    return self.scaleView.scaleColor;
}
- (UILabel*)textLabel {
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:12];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor whiteColor];
        [self addSubview:_textLabel];
    }
    return _textLabel;
}

- (void)setAngleValue:(CGFloat)angleValue {
    _angleValue = angleValue;
    
    CGFloat r = (CGRectGetWidth(self.bounds) / 2.0) / sinf(DEGREES_TO_RADIANS(angleValue));
    self.scaleView.frame = CGRectMake(0, 0, 2 * r, 2*r);
    self.scaleView.center = CGPointMake(self.center.x + 4, r + 10);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    self.startPoint = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    CGPoint endPoint = [touch locationInView:self];
    CGFloat value = endPoint.x - self.startPoint.x;
    
    if (value > 0) {
        self.startPoint = endPoint;
        [self transferRotation:3];
    } else if (value < 0) {
        self.startPoint = endPoint;
        [self transferRotation:-3];
    }
}

@end
