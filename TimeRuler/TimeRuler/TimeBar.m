//
//  TimeBar.m
//
//  Created by ji_yy on 2022/9/13.
//

#import "TimeBar.h"

// 刻度值模式 1小时模式  2分钟模式
static int const MODE_HOUR = 1;
static int const MODE_MINUTE = 2;
// 十分钟代表的秒数
static int const TEN_MINUTES = 10 * 60;
// 移动敏感度 防止刷新过于频繁
static CGFloat const MOVE_SENSITIVE = 0.2f;

@interface TimeBar()

@property (nonatomic, assign) float mDivisorWidth; // 每一小格的宽度
@property (nonatomic, assign) int mDivisorMode; // 刻度值模式
@property (nonatomic, strong) UIColor *mScaleColor; // 刻度颜色
@property (nonatomic, strong) UIColor *mTextColor; // 文字颜色
@property (nonatomic, assign) int mMiddleLineSeconds; // 中线代表的时间
@property (nonatomic, assign) int mLongLineHeight; // 长线高度
@property (nonatomic, assign) int mShortLineHeight; // 短线高度
@property (nonatomic, assign) int mLeftTime; // 最左侧时间
@property (nonatomic, assign) int mMiddleLineDuration; // 中心点距离最左边的时长
@property (nonatomic, assign) float mScaleRate; // 缩放比例
@property (nonatomic, assign) float mLastPanX; // 上次平移距离
@property (nonatomic, assign) bool mIsPanning; // 是否在滑动

@property(nonatomic, assign) int startSecond;
@property(nonatomic, assign) int endSecond;

@property(nonatomic, strong) NSDateFormatter* dateFormatter;

@end

@implementation TimeBar

- (instancetype)init {
    self = [super init];
    
    [self defaultValue];
    self.backgroundColor = [UIColor colorWithRed:21/255.0 green:23/255.0 blue:26/255.0 alpha:1];
    [self addGesture];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self defaultValue];
    self.backgroundColor = [UIColor colorWithRed:21/255.0 green:23/255.0 blue:26/255.0 alpha:1];
    [self addGesture];
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 绘制刻度线
    [self drawRuler: ctx];
    
    // 绘制选中时间段
    [self drawTimeArea: ctx];
    
    // 中心线，指示当前时间
    [[self viewWithTag:20] removeFromSuperview];
    int lineWidth = 6;
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width - lineWidth)/2, 0, lineWidth, self.bounds.size.height)];
    [image setImage:[UIImage imageNamed:@"time_center_line"]];
    [image setTag:20];
    [self addSubview:image];
}

-(void) defaultValue {
    self.mDivisorWidth = 8;
    self.mDivisorMode = MODE_HOUR;
    self.mScaleColor = [UIColor colorWithRed:151/255.0 green:151/255.0 blue:151/255.0 alpha:1];
    self.mTextColor = [UIColor colorWithRed:181/255.0 green:185/255.0 blue:190/255.0 alpha:1];
    self.mMiddleLineSeconds = (int)[[NSDate date] timeIntervalSince1970];
    self.mLongLineHeight = 16;
    self.mShortLineHeight = 8;
    self.startSecond = self.mMiddleLineSeconds;
    self.endSecond = self.startSecond + 60 * 60;
    self.datePattern = @"yyyy-MM-dd HH:mm:ss";
    self.mIsPanning = NO;
}

-(void) addGesture {
    // 放大缩小
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self addGestureRecognizer:pinch];
    
    // 滑动
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
}

-(void) drawRuler:(CGContextRef)context {
    
    // 计算需要画的格子数量
    int scaleNum = (int) (self.bounds.size.width / _mDivisorWidth) + 2;
    // 中心点距离最左边的时长
    _mMiddleLineDuration = (int) ((self.bounds.size.width / 2.0) * (TEN_MINUTES / _mDivisorWidth));
    // 最左边的时间
    _mLeftTime = _mMiddleLineSeconds - _mMiddleLineDuration;
    //
    int minuteNum = ceil(_mLeftTime / TEN_MINUTES);
    float xPosition = (minuteNum * TEN_MINUTES - _mLeftTime) * (_mDivisorWidth / TEN_MINUTES);
    
    for (int i = 0; i < scaleNum; i++) {
        if (_mDivisorMode == MODE_HOUR) {
            if (minuteNum % 6 == 0) {
                // 大刻度
                CGRect rect = CGRectMake(xPosition + i * _mDivisorWidth, 0, 1, self.mLongLineHeight);
                CGContextSetFillColorWithColor(context, _mScaleColor.CGColor);
                CGContextFillRect(context, rect);
                // 文字
                CGFloat textWidth = 36;
                CGFloat textHeight = 17;
                CGFloat textRectX = rect.origin.x - textWidth * 0.5;
                CGFloat textRectY = self.bounds.size.height - textHeight - 4.0;
                CGRect textRect = CGRectMake(textRectX, textRectY, textWidth, textHeight);
                NSString *ocString = [self getHourMinute:minuteNum];
                
                NSDictionary *textAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0],
                                       NSForegroundColorAttributeName:[UIColor colorWithRed:181/255.0 green:185/255.0 blue:190/255.0 alpha:1]};
                
                [ocString drawInRect:textRect withAttributes:textAttribute];
            } else {
                // 小刻度
                CGRect rect = CGRectMake(xPosition + i * _mDivisorWidth, 0, 1, self.mShortLineHeight);
                CGContextSetFillColorWithColor(context, _mScaleColor.CGColor);
                CGContextFillRect(context, rect);
            }
        } else if (_mDivisorMode == MODE_MINUTE) {
            
            for (int j = 0; j < 10; j++) {
                float startX = xPosition + i * _mDivisorWidth;
                if (j == 0) {
                    // 大刻度
                    CGRect rect = CGRectMake(startX, 0, 1, self.mLongLineHeight);
                    CGContextSetFillColorWithColor(context, _mScaleColor.CGColor);
                    CGContextFillRect(context, rect);
                    // 文字
                    CGFloat textWidth = 36;
                    CGFloat textHeight = 17;
                    CGFloat textRectX = rect.origin.x - textWidth * 0.5;
                    CGFloat textRectY = self.bounds.size.height - textHeight - 4.0;
                    CGRect textRect = CGRectMake(textRectX, textRectY, textWidth, textHeight);
                    NSString *ocString = [self getHourMinute:minuteNum];
                    
                    NSDictionary *textAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0],
                                           NSForegroundColorAttributeName:[UIColor colorWithRed:181/255.0 green:185/255.0 blue:190/255.0 alpha:1]};
                    
                    [ocString drawInRect:textRect withAttributes:textAttribute];
                } else {
                    // 小刻度
                    CGRect rect = CGRectMake(startX + j * _mDivisorWidth * 0.1, 0, 1, self.mShortLineHeight);
                    CGContextSetFillColorWithColor(context, _mScaleColor.CGColor);
                    CGContextFillRect(context, rect);
                }
            }
        }
        minuteNum++;
    }
}

-(void) drawTimeArea:(CGContextRef)ctx {
    if (_startSecond == 0 && _endSecond == 0) {
        return;
    }
    
    int rightTime = _mLeftTime + _mMiddleLineDuration * 2;
    
    float x = 0;
    float width = 0;
    
    bool isContainTime = _startSecond <= _mLeftTime && _endSecond >= rightTime;
    bool containLeft = _startSecond > _mLeftTime && _startSecond < rightTime;
    bool containRight = _endSecond > _mLeftTime && _endSecond < rightTime;
    
    if (isContainTime) {
        width = self.bounds.size.width;
    } else if (containLeft && containRight) {
        x = (_startSecond - _mLeftTime) * (_mDivisorWidth / TEN_MINUTES);
        width = (_endSecond - _startSecond) * (_mDivisorWidth / TEN_MINUTES);
    } else if (containLeft) {
        x = (_startSecond - _mLeftTime) * (_mDivisorWidth / TEN_MINUTES);
        width = (rightTime - _startSecond) * (_mDivisorWidth / TEN_MINUTES);
    } else if (containRight) {
        width = (_endSecond - _mLeftTime) * (_mDivisorWidth / TEN_MINUTES);
    }
    
    CGContextSetFillColorWithColor(ctx, [[UIColor alloc]initWithRed:69/255.0 green:69/255.0 blue:209/255.0 alpha:1.0].CGColor);
    CGRect rect = CGRectMake(x, 0, width, _mLongLineHeight);
    CGContextFillRect(ctx, rect);
}

-(void) setStartTime:(NSString*)startTime endTime:(NSString*)endTime {
    self.startSecond = [[self.dateFormatter dateFromString:startTime] timeIntervalSince1970];
    self.endSecond = [[self.dateFormatter dateFromString:endTime] timeIntervalSince1970];
    self.mMiddleLineSeconds = self.startSecond;
    [self setNeedsDisplay];
}

-(void) setCurrentTime:(NSString*)currentTime {
    if (!self.mIsPanning) {
        self.mMiddleLineSeconds = [[self.dateFormatter dateFromString:currentTime] timeIntervalSince1970];
        [self setNeedsDisplay];
    }
}

-(NSString*) getHourMinute:(int) timeIndex {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    [formatter setLocale:[NSLocale systemLocale]];
    return [formatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:(timeIndex * 10 * 60)]];
}

#pragma mark -- getter & setter
-(NSDateFormatter*) dateFormatter {
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:self.datePattern];
    [_dateFormatter setLocale:[NSLocale systemLocale]];
    return _dateFormatter;
}

#pragma mark -- gesture
- (void)pinchAction:(UIPinchGestureRecognizer*)recoginer{
    if (recoginer.state == UIGestureRecognizerStateBegan){
        self.mScaleRate = recoginer.scale;
    }else if (recoginer.state == UIGestureRecognizerStateChanged){
        self.mScaleRate = recoginer.scale;
        _mDivisorWidth = _mDivisorWidth * _mScaleRate;
        
        if (_mDivisorWidth >= 32 && _mDivisorWidth <= 60) {
            // 防止32～60的空窗期没有反应
            _mDivisorWidth = _mScaleRate > 1 ? 60 : 32;
        } else {
            // 最大限制
            _mDivisorWidth = _mDivisorWidth > 160 ? 160 : _mDivisorWidth;
            // 最小限制
            _mDivisorWidth = _mDivisorWidth < 8 ? 8 : _mDivisorWidth;
        }
        
        // 模式
        _mDivisorMode = _mDivisorWidth > 32 ? MODE_MINUTE : MODE_HOUR;
        
        [self setNeedsDisplay];
    }
}

- (void)panAction:(UIPanGestureRecognizer*)recoginer{
    CGPoint translation = [recoginer translationInView:recoginer.view];

    if (recoginer.state == UIGestureRecognizerStateBegan) {
        _mLastPanX = 0;
        self.mIsPanning = YES;
    } else {
        _mMiddleLineSeconds = _mMiddleLineSeconds - ((translation.x - _mLastPanX)/ _mDivisorWidth) * TEN_MINUTES;
        
        if (recoginer.state == UIGestureRecognizerStateEnded) {
            if (_startSecond > _mMiddleLineSeconds) {
                _startSecond = _mMiddleLineSeconds;
            }
            if (_endSecond < _mMiddleLineSeconds) {
                _startSecond = _mMiddleLineSeconds;
                _endSecond = _startSecond + 8*60*60;
            }
       }
        
        [self setNeedsDisplay];
        _mLastPanX = translation.x;
    }
    
    if (recoginer.state == UIGestureRecognizerStateEnded) {
        // 滑动结束，刷新视频
        self.mIsPanning = NO;
        
        if (translation.x >= MOVE_SENSITIVE || translation.x <= -MOVE_SENSITIVE) {
            [_delegate timeBarChanged:_startSecond endSecond:_endSecond currentSecond:_mMiddleLineSeconds];
        }
    }
}
@end
