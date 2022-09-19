//
//  ViewController.m
//  TimeRuler
//
//  Created by ecidi on 2022/9/19.
//

#import "ViewController.h"

@interface ViewController () <TimeBarDelegate>

@property (nonatomic, strong) TimeBar *timeBar;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSString *pattern;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pattern = @"yyyy-MM-dd HH:mm:ss";
    
    [self.view addSubview:self.timeBar];
    [self.view addSubview:self.textView];
    
    // default startTime & currentTime is now
    // default endTime is eight hours behind now
    int currentSecond = [[NSDate date] timeIntervalSince1970];
    int startSecond = currentSecond - 60*60;
    int endSecond = currentSecond + 60*60;
    
    NSString *startTime = [self dateStrFromTimeInternal:startSecond];
    NSString *endTime = [self dateStrFromTimeInternal:endSecond];
    NSString *currentTime = [self dateStrFromTimeInternal:currentSecond];
    
    [_textView setText:[NSString stringWithFormat:@"startTime:%@; \n endTime:%@; \n currentTime:%@;", startTime, endTime, currentTime]];
    
    [_timeBar setStartTime:startTime endTime:endTime];
    [_timeBar setCurrentTime:currentTime];
    
    
}

#pragma mark -  getter & setter
- (TimeBar*) timeBar {
    if (_timeBar == nil) {
        _timeBar = [[TimeBar alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 49)];
        _timeBar.delegate = self;
    }
    return _timeBar;
}

- (UITextView*) textView {
    if (_textView == nil) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(30, 260, self.view.bounds.size.width, 200)];
        _textView.font = [UIFont systemFontOfSize:18];
    }
    return _textView;
}

#pragma mark -  HikTimeBarDelegate
- (void)timeBarChanged:(int)startSecond endSecond:(int)endSecond currentSecond:(int)currentSecond {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:_pattern];
    [formatter setLocale:[NSLocale systemLocale]];
    
    NSString *startTime = [self dateStrFromTimeInternal:startSecond];
    NSString *endTime = [self dateStrFromTimeInternal:endSecond];
    NSString *currentTime = [self dateStrFromTimeInternal:currentSecond];
    
    [_textView setText:[NSString stringWithFormat:@"startTime:%@; \n endTime:%@; \n currentTime:%@;", startTime, endTime, currentTime]];
}

#pragma mark -  Utils
- (NSString*) dateStrFromTimeInternal:(int) second {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:_pattern];
    [formatter setLocale:[NSLocale systemLocale]];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:second]];
}

@end
