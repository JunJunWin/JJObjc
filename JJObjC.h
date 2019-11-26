//
//  JJObjC.h
//  JJObjC
//
//  Created by JunWin on 19/11/26.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 在 HaloObjC.server 后被赋值，仅赋值一次

#pragma mark - 固定尺寸
extern CGRect  ScreenBounds;
extern CGRect  ScreenBoundsWithoutNavigationBar;
/// 手机启动时屏幕宽度，视手机启动时的横竖屏状态而定
extern CGFloat ScreenWidth;
/// 手机启动时屏幕高度，视手机启动时的横竖屏状态而定
extern CGFloat ScreenHeight;
/// 手机为竖屏状态下时的屏幕宽度，默认竖屏宽度一定小于高度
extern CGFloat VerticalScreenWidth;
/// 手机为竖屏状态下时的屏幕高度，默认竖屏宽度一定小于高度
extern CGFloat VerticalScreenHeight;
/// 手机为竖屏状态下时的系统导航栏高度，包含 statusbar，如 iPhone 8 应该为 64，iPhone X 为 64+24
extern CGFloat NavigationBarHeight;
extern CGFloat BottomSafeHeightForIPhoneX;
extern CGFloat TabBarHeight;
extern CGFloat StatusBarHeight;

#pragma mark - 沙盒路径
extern NSString *HomePath;
extern NSString *DocumentPath;
extern NSString *LibraryPath;
extern NSString *CachePath;
extern NSString *TempPath;

#pragma mark - Bundle
extern NSString *MainBundlePath;
extern NSString *ResourcePath;
extern NSString *ExecutablePath;

#pragma mark - 应用信息
extern NSString *AppBundleID;
extern NSString *AppVersion;
extern NSString *AppBuildVersion;

#pragma mark - 系统信息
extern NSString *SystemVersion;
extern float SystemVersionNumber;

extern BOOL iPhone5_5;
extern BOOL iPhone4_7;
extern BOOL iPhone4_0;
extern BOOL iPhone3_5;
extern BOOL iPhoneX __deprecated_msg("HaloObjC: use NeedSafeAreaLayout instead");
extern BOOL iPhone5_8 __deprecated_msg("HaloObjC: use NeedSafeAreaLayout instead");
extern BOOL iPhoneXsMax __deprecated_msg("HaloObjC: use NeedSafeAreaLayout instead");
extern BOOL iPhoneXR __deprecated_msg("HaloObjC: use NeedSafeAreaLayout instead");
extern BOOL NeedSafeAreaLayout;

#pragma mark - Measure

/**
 *  测量某段代码的执行时间
 *  你不用考虑 block 执行的线程
 *
 *  @param CodeWaitingForMeasure 你想测量的代码
 */
void Measure(void(^CodeWaitingForMeasure)(void));

#pragma mark - GCD

/**
 *  主线程异步执行
 *
 *  @param UITask 一些要做，而且需要在主线程做，但是可以放到最后做的事情
 */
void hl_last(void(^UITask)(void));

/**
 *
 *
 *  @param second  延迟多少秒
 *  @param UITask 在主线程中做的事情
 */
void hl_after(float second, void(^UITask)(void));


/**
 后台线程执行

 @param noUITask 非 UI 任务
 */

void hl_background(void(^noUITask)(void));

#pragma mark - Log

/**
 *  简化 NSLog 调用
 *
 *  @param obj Something you wants to print
 */
void cc(id obj);

/**
 *  简化 NSLog 调用
 *
 *  @param obj Something you wants to print with ✅
 */
void ccRight(id obj);

/**
 *  简化 NSLog 调用
 *
 *  @param obj Something you wants to print with ❌
 */
void ccError(id obj);

/**
 *  简化 NSLog 调用
 *
 *  @param obj Something you wants to print with ⚠️
 */
void ccWarning(id obj);

#pragma mark - HaloObjC

@interface HaloObjC : NSObject

/**
 *  是否开启 Log（也就是 ccLog），默认值是 YES
 */
+ (void)logEnable:(BOOL)enable;

/**
 *  如果要使用 HaloObjC 该方法必须被调用
 */
+ (void)server;

/**
 *  调用 ccError 时的回调
 */
+ (void)setCCErrorFunctionCallBack:(void(^)(NSString *displayInfo))callBack;

@property (readonly, class) UIWindow *appWindow;
@property (readwrite, class) UIViewController *appRootViewController;
@property (readonly, class) UIViewController *appTopViewController;
@property (readonly, class) BOOL appIsPortrait;
/// 当前屏幕高度
@property (readonly, class) CGFloat screenHeight;
/// 当前屏幕宽度
@property (readonly, class) CGFloat screenWidth;

@end

#pragma mark - NSObject

@interface NSObject (logProperties)

- (void)logProperties;

@end

#pragma mark - NSString

BOOL NSStringIsBlank(NSString *string);

BOOL NSStringIsAllSpaces(NSString *string);

BOOL NSStringIsMeaningless(NSString *string);

@interface NSString (HaloObjC)

@property (nonatomic, readonly) NSURL *URL;

@property (nonatomic, readonly) NSDictionary *hl_jsonDictionary;

@property (nonatomic, readonly) NSArray *hl_jsonArray;

@end

#pragma mark - NSDictionary

@interface NSDictionary (HaloObjC)

@property (nonatomic, readonly) NSString *hl_jsonString;

@end

#pragma mark - NSArray

@interface NSArray (HaloObjC)

@property (nonatomic, readonly) NSString *hl_jsonString;

@end

#pragma mark - HLMutableDeepCopying

@protocol HLMutableDeepCopying <NSObject>

-(id)hl_mutableDeepCopy;

@end

@interface NSDictionary (HLMutableDeepCopy) <HLMutableDeepCopying>
@end

@interface NSArray (HLMutableDeepCopy) <HLMutableDeepCopying>
@end

#pragma mark - SandBox

long long hl_sizeOfFolder(NSString *folderPath);

NSString *hl_sizeStringOfSize(long long size);

NSString *hl_sizeStringOfFolder(NSString *folderPath);

void hl_fetchSizeOfFolder(NSString *folderPath, void(^finished)(long long sizeOfFolder));

#pragma mark - UIFont

UIFont *hl_systemFontOfSize(CGFloat size);

#pragma mark - UIButton

@interface UIButton (HaloObjC)

@property (nonatomic, strong) UIFont *hl_titleFont;
@property (nonatomic, strong) UIColor *hl_normalTitleColor;
@property (nonatomic, strong) NSString *hl_normalTitle;
@property (nonatomic, strong) UIImage *hl_normalImage;

+ (UIButton *)custom;

- (instancetype)hl_touchUpInSideTarget:(id)target action:(SEL)action;

@end

#pragma mark - UIViewController

@interface UIViewController (HaloObjC)

- (instancetype)title:(NSString *)title;

@end

#pragma mark - UIView

/// 相当于 CGRectMake
CGRect RM(CGFloat x, CGFloat y, CGFloat width, CGFloat height);

/// 创建一个水平居中（相对于屏幕）的 CGRect 值
CGRect CM(CGFloat y, CGFloat width, CGFloat height);

/// 像素对齐
CGFloat pixelIntegral(CGFloat value);

@interface UIView (HaloObjC)

+ (instancetype)addToSuperview:(UIView *)superview;

- (instancetype)addToSuperview:(UIView *)superview;

/**
 *  设定圆角半径
 *
 *  @param radius 圆角半径
 */
- (void)hl_cornerRadius:(CGFloat)radius;

/**
 *  同时设定 圆角半径 描边宽度 描边颜色
 *
 *  @param radius      圆角半径
 *  @param borderWidth 描边宽度
 *  @param borderColor 描边颜色
 */
- (void)hl_cornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

@end

#pragma mark - UIScrollView

@interface UIScrollView (HaloObjC)

@property (nonatomic, assign) CGFloat hl_insetTop;
@property (nonatomic, assign) CGFloat hl_insetBottom;
@property (nonatomic, assign) CGFloat hl_insetLeft;
@property (nonatomic, assign) CGFloat hl_insetRight;
@property (nonatomic, assign) CGFloat hl_indicatorTop;
@property (nonatomic, assign) CGFloat hl_indicatorBottom;

@property (nonatomic, assign) CGFloat hl_offsetX;
@property (nonatomic, assign) CGFloat hl_offsetY;

@end

#pragma mark - UITableView

@interface UITableView (HaloObjC)

/**
 *  默认使用 class 名作为 reuseIdentifier
 *
 *  @param cellClass 要注册的 Cell 类型
 */
- (void)hl_registerCellClass:(Class)cellClass;


/**
 该方法通过修改 frame.size.height 来阻止 UITableView 的单元格冲用，实现和 static UITableView 相同的效果

 @param viewController 添加该 UITableView 的 UIViewController，调用本方法后，该 UIViewController 的 automaticallyAdjustsScrollViewInsets 会被置为 NO
 */
- (void)disableCellReuseInViewController:(UIViewController *)viewController;

@end

#pragma mark - UITableViewCell

@interface UITableViewCell (HaloObjC)

+ (NSString *)hl_reuseIdentifier;

- (instancetype)selectionStyle:(UITableViewCellSelectionStyle)style;

@end

@interface UITableViewValue1Cell : UITableViewCell

@end

#pragma mark - UICollectionView

@interface UICollectionView (HaloObjC)

- (void)hl_registerCellClass:(Class)cellClass;

@end

#pragma mark - UICollectionViewCell

@interface UICollectionViewCell (HaloObjC)

+ (NSString *)hl_reuseIdentifier;

@end

#pragma mark - UINavigatoinController

@interface UINavigationController (HaloObjC)

/**
*  使用纯色填充 NavigationBar
*
*  @param color       NavigationBar 背景颜色
*  @param tintColor   NavigationBar 标题颜色
*  @param shadowColor NavigationBar 下边分割线颜色
*/
- (void)hl_barUseColor:(UIColor *)color tintColor:(UIColor *)tintColor shadowColor:(UIColor *)shadowColor;

+ (instancetype)root:(UIViewController *)rootVC;

@end

#pragma mark - UIImage

@interface UIImage (HaloObjC)

+ (UIImage *)hl_imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)hl_imageWithColor:(UIColor *)color;

@end

#pragma mark - UIColor

#ifndef HEXStr
/**
 *  use hexstring like @"FFFFFF" (or @"#FFFFFF") to create a UIColor object
 */
UIColor *HEXStr(NSString *hexString);

/**
 Get a string like "FF0066" from UIColor object
 */
NSString *HEXStringFromColor(UIColor *color);

#endif


#ifndef HEX
/**
 *  use hexValue like 0xFFFFFF to create a UIColor object
 */
UIColor *HEX(NSUInteger hex);

#endif

#ifndef RGB

/**
 RGB

 @param r 0~255
 @param g 0~255
 @param b 0~255
 */
UIColor *RGB(CGFloat r, CGFloat g, CGFloat b);

#endif

#ifndef RGBA

/**
 带有 alpha 的 RGB

 @param r 0~255
 @param g 0~255
 @param b 0~255
 @param a 0~1
 */
UIColor *RGBA(CGFloat r, CGFloat g, CGFloat b, CGFloat a);

#endif

#ifndef ColorWithHexValueA

UIColor *ColorWithHexValueA(NSUInteger hexValue, CGFloat a);

#endif
