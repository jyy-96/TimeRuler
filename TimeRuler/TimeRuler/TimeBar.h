//
//  TimeBar.h
//
//
//  Created by ji_yy on 2022/9/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TimeBarDelegate <NSObject>

@required
-(void) timeBarChanged:(int) startSecond endSecond:(int) endSecond currentSecond:(int) currentSecond;

@end

@interface TimeBar : UIView

@property(nonatomic, strong) NSString* datePattern; // 传入时间参数的格式，默认 @"yyyy-MM-dd HH:mm:ss"
@property (nonatomic, assign) id<TimeBarDelegate> delegate;

-(void) setStartTime:(NSString*)startTime endTime:(NSString*)endTime;
- (void)setCurrentTime:(NSString*)currentTime;

@end



NS_ASSUME_NONNULL_END
