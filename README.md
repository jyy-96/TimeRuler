
# 时间尺 控件

由于项目中有视频监控回放的功能，需要做一个时间尺控件，用户可以进行 拖动选择时间、缩放时间尺 等操作。

效果如下：

![截图](/screenshot/timebar.jpg)

## 使用简介：

1. 可以根据视频进度调用相应方法，调用接口，刷新时间尺；
2. 用户可以手动拖动时间尺，提供代理方法，在代理方法中写回调事件；
3. 用户可以通过双指手势缩放时间尺，以便更精确的选择时间；


### 默认值
开始时间：与当前时间一致
结束时间：当前时间后推8小时
当前时间：当前实际时间

### 设置时间格式
_timebar.datePattern = @"yyyy-MM-dd HH:mm:ss";

默认值为 @"yyyy-MM-dd HH:mm:ss"

### 设置开始时间与结束时间
-(void) setStartTime:(NSString*)startTime endTime:(NSString*)endTime;

如：[_timeBar setStartTime:@"2022-09-16 08:10:10" endTime:@"2022-09-16 10:10:10"];
### 设置当前时间
- (void)setCurrentTime:(NSString*)currentTime;

如：[_timeBar setCurrentTime:@"2022-09-16 10:10:10"];

### delegate

用户拖动时间尺，手势结束后会触发此方法。

-(void) timeBarChanged:(int) startSecond endSecond:(int) endSecond currentSecond:(int) currentSecond;
