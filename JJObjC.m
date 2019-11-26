//
//  JJObjC.m
//  JJObjC
//
//  Created by JunWin on 19/11/26.
//
//

#import "JJObjC.h"
#import <objc/runtime.h>

#pragma mark - 固定尺寸
CGRect  ScreenBounds;
CGRect  ScreenBoundsWithoutNavigationBar;
CGFloat ScreenWidth;
CGFloat ScreenHeight;
CGFloat VerticalScreenWidth;
CGFloat VerticalScreenHeight;
CGFloat NavigationBarHeight;
CGFloat BottomSafeHeightForIPhoneX;
CGFloat TabBarHeight;
CGFloat StatusBarHeight;

#pragma mark - 沙盒路径
NSString *HomePath;
NSString *DocumentPath;
NSString *LibraryPath;
NSString *CachePath;
NSString *TempPath;

#pragma mark - Bundle
NSString *MainBundlePath;
NSString *ResourcePath;
NSString *ExecutablePath;

#pragma mark - 应用信息
NSString *AppBundleID;
NSString *AppVersion;
NSString *AppBuildVersion;

#pragma mark - 系统信息
NSString *SystemVersion;
float SystemVersionNumber;

void(^CCErrorCallBackBlock)(NSString *);

BOOL iPhone5_5;
BOOL iPhone4_7;
BOOL iPhone4_0;
BOOL iPhone3_5;
BOOL iPhoneX;
BOOL iPhone5_8;
BOOL iPhoneXsMax;
BOOL iPhoneXR;
BOOL NeedSafeAreaLayout;

#pragma mark - Measure

void Measure(void(^CodeWaitingForMeasure)(void)) {
    NSDate *startTime = [NSDate date];
    if (CodeWaitingForMeasure) {
        CodeWaitingForMeasure();
    }
    NSTimeInterval endTime = [[NSDate date] timeIntervalSinceDate:startTime];
    cc([NSString stringWithFormat:@"代码执行时间为 %f 秒", endTime]);
}

#pragma mark - GCD

void hl_last(void(^UITask)(void)) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (UITask) {
            UITask();
        }
    });
}

void hl_after(float second, void(^UITask)(void)) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (UITask) {
            UITask();
        }
    });
}

void hl_background(void(^noUITask)(void)) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (noUITask) {
            noUITask();
        }
    });
}

#pragma mark - Log

static BOOL CCLogEnable = YES;

void cc(id obj) {
    if (!CCLogEnable) {
        return;
    }
    printf("%s\n", [[obj description] UTF8String]);
}

void ccRight(id obj) {
    if (!CCLogEnable) {
        return;
    }
    printf("%s\n", [[NSString stringWithFormat:@"%@%@", @"✅", [obj description]] UTF8String]);
}

void ccError(id obj) {
    if (CCErrorCallBackBlock) {
        CCErrorCallBackBlock([obj description] ?: @"NULL");
    }
    if (!CCLogEnable) {
        return;
    }
    printf("%s\n", [[NSString stringWithFormat:@"%@%@", @"❌", [obj description]] UTF8String]);
}

void ccWarning(id obj) {
    if (!CCLogEnable) {
        return;
    }
    printf("%s\n", [[NSString stringWithFormat:@"%@%@", @"⚠️", [obj description]] UTF8String]);
}

@implementation HaloObjC

+ (void)server {
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    ScreenBounds         = mainScreen.bounds;
    ScreenHeight         = ScreenBounds.size.height;
    ScreenWidth          = ScreenBounds.size.width;
    
    VerticalScreenWidth        = MIN(ScreenHeight, ScreenWidth);
    VerticalScreenHeight       = MAX(ScreenHeight, ScreenWidth);
    
    iPhone3_5   = ScreenWidth == 320 && ScreenHeight == 480;
    iPhone4_0   = ScreenWidth == 320 && ScreenHeight == 568;
    iPhone4_7   = ScreenWidth == 375 && ScreenHeight == 667;
    iPhone5_5   = ScreenWidth == 414 && ScreenHeight == 736;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    iPhoneX            = ScreenWidth == 375 && ScreenHeight == 812;
    iPhone5_8          = iPhoneX;
    iPhoneXsMax        = ScreenWidth == 414 && ScreenHeight == 896;
    iPhoneXR           = iPhoneXsMax;
    NeedSafeAreaLayout = iPhoneX || iPhoneXsMax;
    
#pragma clang diagnostic pop
    
    NavigationBarHeight              = 64 + (NeedSafeAreaLayout ? 24 : 0);
    BottomSafeHeightForIPhoneX       = NeedSafeAreaLayout ? 34 : 0;
    TabBarHeight                     = 49 + BottomSafeHeightForIPhoneX;
    StatusBarHeight                  = 20;
    ScreenBoundsWithoutNavigationBar = CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavigationBarHeight);
    
    HomePath                     = NSHomeDirectory();
    CachePath                    = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    DocumentPath                 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    LibraryPath                  = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    TempPath                     = NSTemporaryDirectory();
    
    NSBundle *mainBundle         = [NSBundle mainBundle];
    MainBundlePath               = [mainBundle bundlePath];
    ResourcePath                 = [mainBundle resourcePath];
    ExecutablePath               = [mainBundle executablePath];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    AppBundleID                  = infoDictionary[@"CFBundleIdentifier"];
    AppVersion                   = infoDictionary[@"CFBundleShortVersionString"];
    AppBuildVersion              = infoDictionary[@"CFBundleVersion"];
    
    SystemVersion                = [UIDevice currentDevice].systemVersion;
    SystemVersionNumber          = SystemVersion.floatValue;
    
}

+ (void)setCCErrorFunctionCallBack:(void (^)(NSString *))callBack {
    CCErrorCallBackBlock = callBack;
}

+ (void)logEnable:(BOOL)enable {
    
    CCLogEnable = enable;
}

+ (UIViewController *)appRootViewController {
    return [[[[UIApplication sharedApplication] delegate] window] rootViewController];
}

+ (void)setAppRootViewController:(UIViewController *)appRootViewController {
    [[[UIApplication sharedApplication] delegate] window].rootViewController = appRootViewController;
}

+ (UIViewController *)appTopViewController {
    UIViewController *resultVC;
    resultVC = [self _appTopViewController:self.appRootViewController];
    while (resultVC.presentedViewController) {
        resultVC = [self _appTopViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_appTopViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _appTopViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _appTopViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

+ (UIWindow *)appWindow {
    return [[[UIApplication sharedApplication] delegate] window];
}

+ (BOOL)appIsPortrait {
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
}

+ (CGFloat)screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

@end

#pragma mark - NSObject

@implementation NSObject (logProperties)

- (void)logProperties {
    ccRight([NSString stringWithFormat:@"log properties for %@", self]);
    @autoreleasepool {
        unsigned int numberOfProperties = 0;
        objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
        for (NSUInteger i = 0; i < numberOfProperties; i++) {
            objc_property_t property = propertyArray[i];
            NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
            @try {
                cc([NSString stringWithFormat:@"%@ : %@", name, [self valueForKey:name]]);
            } @catch (NSException *exception) {
                ccWarning(exception);
            } @finally {
            }
        }
        free(propertyArray);
    }
}

@end

#pragma mark - NSString

BOOL NSStringIsBlank(NSString *string) {
    return string.length == 0;
}

BOOL NSStringIsAllSpaces(NSString *string) {
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([[string stringByTrimmingCharactersInSet: set] length] == 0) {
        return YES;
    }
    return NO;
}

BOOL NSStringIsMeaningless(NSString *string) {
    return NSStringIsBlank(string) || NSStringIsAllSpaces(string);
}

@implementation NSString (HaloObjC)

- (NSURL *)URL {
    return [NSURL URLWithString:self];
}

- (NSDictionary *)hl_jsonDictionary {
    NSError *err;
    NSDictionary *_dic = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&err];
    if (err) {
        ccWarning(err);
    }
    if ([_dic isKindOfClass:NSDictionary.class]) {
        return _dic;
    }
    return nil;
}

- (NSArray *)hl_jsonArray {
    NSError *err;
    NSArray *_array = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&err];
    if (err) {
        ccWarning(err);
    }
    if ([_array isKindOfClass:NSArray.class]) {
        return _array;
    }
    return nil;
}

@end

#pragma mark - NSDictionary

@implementation NSDictionary (HaloObjC)

- (NSString *)hl_jsonString {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end

#pragma mark - NSArray

@implementation NSArray (HaloObjC)

- (NSString *)hl_jsonString {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end

#pragma mark - HLMutableDeepCopying

@implementation NSDictionary (HLMutableDeepCopy)
- (NSMutableDictionary *)hl_mutableDeepCopy {
    NSMutableDictionary * returnDict = [[NSMutableDictionary alloc] initWithCapacity:self.count];
    NSArray * keys = [self allKeys];
    for(id key in keys) {
        id aValue = [self objectForKey:key];
        id theCopy = nil;
        if([aValue conformsToProtocol:@protocol(HLMutableDeepCopying)]) {
            theCopy = [aValue hl_mutableDeepCopy];
        } else if([aValue conformsToProtocol:@protocol(NSMutableCopying)]) {
            theCopy = [aValue mutableCopy];
        } else if([aValue conformsToProtocol:@protocol(NSCopying)]){
            theCopy = [aValue copy];
        } else {
            theCopy = aValue;
        }
        [returnDict setValue:theCopy forKey:key];
    }
    return returnDict;
}
@end

@implementation NSArray (HLMutableDeepCopy)
-(NSMutableArray *)hl_mutableDeepCopy {
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:self.count];
    for(id aValue in self) {
        id theCopy = nil;
        if([aValue conformsToProtocol:@protocol(HLMutableDeepCopying)]) {
            theCopy = [aValue hl_mutableDeepCopy];
        } else if([aValue conformsToProtocol:@protocol(NSMutableCopying)]) {
            theCopy = [aValue mutableCopy];
        } else if([aValue conformsToProtocol:@protocol(NSCopying)]){
            theCopy = [aValue copy];
        } else {
            theCopy = aValue;
        }
        [returnArray addObject:theCopy];
    }
    return returnArray;
}
@end

#pragma mark - SandBox

long long hl_sizeOfFolder(NSString *folderPath) {
    NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    __block unsigned long long int folderSize = 0;
    
    [folderContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *_filePath = [folderPath stringByAppendingPathComponent:obj];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil];
        
        if ([fileAttributes[NSFileType] isEqualToString:NSFileTypeDirectory]) {
            folderSize += hl_sizeOfFolder(_filePath);
        } else {
            folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
        }
    }];
    return folderSize;
}

NSString *hl_sizeStringOfSize(long long size) {
    NSString *sizeString = [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
    return sizeString;
}

NSString *hl_sizeStringOfFolder(NSString *folderPath) {
    NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    __block unsigned long long int folderSize = 0;
    
    [folderContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:obj] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }];
    NSString *folderSizeStr = hl_sizeStringOfSize(folderSize);
    return folderSizeStr;
}

void hl_fetchSizeOfFolder(NSString *folderPath, void(^finished)(long long sizeOfFolder)) {
    hl_background(^{
        NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
        __block unsigned long long int folderSize = 0;
        
        [folderContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *_filePath = [folderPath stringByAppendingPathComponent:obj];
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil];
            
            if ([fileAttributes[NSFileType] isEqualToString:NSFileTypeDirectory]) {
                folderSize += hl_sizeOfFolder(_filePath);
            } else {
                folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
            }
        }];
        hl_last(^{
            if (finished) {
                finished(folderSize);
            }
        });
    });
}

#pragma mark - UIFont

UIFont *hl_systemFontOfSize(CGFloat size) {
    return [UIFont systemFontOfSize:size];
}

#pragma mark - UIButton

@implementation UIButton (HaloObjC)

- (UIFont *)hl_titleFont {
    return self.titleLabel.font;
}

- (void)setHl_titleFont:(UIFont *)hl_titleFont {
    self.titleLabel.font = hl_titleFont;
}

- (UIColor *)hl_normalTitleColor {
    return [self titleColorForState:UIControlStateNormal];
}

- (void)setHl_normalTitleColor:(UIColor *)hl_normalTitleColor {
    [self setTitleColor:hl_normalTitleColor forState:UIControlStateNormal];
}

- (NSString *)hl_normalTitle {
    return [self titleForState:UIControlStateNormal];
}

- (void)setHl_normalTitle:(NSString *)hl_normalTitle {
    [self setTitle:hl_normalTitle forState:UIControlStateNormal];
}

- (UIImage *)hl_normalImage {
    return [self imageForState:UIControlStateNormal];
}

- (void)setHl_normalImage:(UIImage *)hl_normalImage {
    [self setImage:hl_normalImage forState:UIControlStateNormal];
}

+ (UIButton *)custom {
    return [self buttonWithType:UIButtonTypeCustom];
}

- (instancetype)hl_touchUpInSideTarget:(id)target action:(SEL)action {
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return self;
}

@end

#pragma mark - UIViewController

@implementation UIViewController (HaloObjC)

- (instancetype)title:(NSString *)title {
    self.title = title;
    return self;
}

@end

#pragma mark - UIView

CGRect RM(CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
    return CGRectMake(x, y, width, height);
}

CGRect CM(CGFloat y, CGFloat width, CGFloat height) {
    return RM((ScreenWidth - width) / 2, y, width, height);
}

CGFloat pixelIntegral(CGFloat value) {
    CGFloat screenScale = [UIScreen mainScreen].scale;
    return round(value * screenScale / screenScale);
}

@implementation UIView (HaloObjC)

+ (instancetype)addToSuperview:(UIView *)superview {
    return [[self new] addToSuperview:superview];
}

- (instancetype)addToSuperview:(UIView *)superview {
    [superview addSubview:self];
    return self;
}

- (void)hl_cornerRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

- (void)hl_cornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = true;
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = borderColor.CGColor;
    
}

@end

#pragma mark - UIScrollView

@implementation UIScrollView (HaloObjC)

- (CGFloat)hl_insetBottom {
    return self.contentInset.bottom;
}

- (void)setHl_insetBottom:(CGFloat)hl_insetBottom {
    UIEdgeInsets inset = self.contentInset;
    self.contentInset = UIEdgeInsetsMake(inset.top, inset.left, hl_insetBottom, inset.right);
}

- (CGFloat)hl_insetTop {
    return self.contentInset.top;
}

- (void)setHl_insetTop:(CGFloat)hl_insetTop {
    UIEdgeInsets inset = self.contentInset;
    self.contentInset = UIEdgeInsetsMake(hl_insetTop, inset.left, inset.bottom, inset.right);
}

- (CGFloat)hl_insetLeft {
    return self.contentInset.left;
}

- (void)setHl_insetLeft:(CGFloat)hl_insetLeft {
    UIEdgeInsets inset = self.contentInset;
    self.contentInset = UIEdgeInsetsMake(inset.top, hl_insetLeft, inset.bottom, inset.right);
}

- (CGFloat)hl_insetRight {
    return self.contentInset.right;
}

- (void)setHl_insetRight:(CGFloat)hl_insetRight {
    UIEdgeInsets inset = self.contentInset;
    self.contentInset = UIEdgeInsetsMake(inset.top, inset.right, inset.bottom, hl_insetRight);
}

- (CGFloat)hl_offsetX {
    return self.contentOffset.x;
}

- (void)setHl_offsetX:(CGFloat)hl_offsetX {
    CGPoint offset = self.contentOffset;
    self.contentOffset = CGPointMake(hl_offsetX, offset.y);
}

- (CGFloat)hl_offsetY {
    return self.contentOffset.y;
}

- (void)setHl_offsetY:(CGFloat)hl_offsetY {
    CGPoint offset = self.contentOffset;
    self.contentOffset = CGPointMake(offset.x, hl_offsetY);
}

- (CGFloat)hl_indicatorTop {
    return self.scrollIndicatorInsets.top;
}

- (CGFloat)hl_indicatorBottom {
    return self.scrollIndicatorInsets.bottom;
}

- (void)setHl_indicatorTop:(CGFloat)hl_indicatorTop {
    UIEdgeInsets inset = self.scrollIndicatorInsets;
    self.scrollIndicatorInsets = UIEdgeInsetsMake(hl_indicatorTop, inset.left, inset.bottom, inset.right);
}

- (void)setHl_indicatorBottom:(CGFloat)hl_indicatorBottom {
    UIEdgeInsets inset = self.scrollIndicatorInsets;
    self.scrollIndicatorInsets = UIEdgeInsetsMake(inset.top, inset.left, hl_indicatorBottom, inset.right);
}

@end

#pragma mark - UITableView

@implementation UITableView (HaloObjC)

- (void)hl_registerCellClass:(Class)cellClass {
    [self registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
}

- (void)disableCellReuseInViewController:(UIViewController *)viewController {
    CGFloat additionValue = 10000.f;
    CGRect frame = CGRectMake(self.frame.origin.x, -additionValue, self.frame.size.width, self.frame.size.height + additionValue * 2);
    self.frame = frame;
    viewController.automaticallyAdjustsScrollViewInsets = NO;
    self.hl_insetTop = additionValue;
    self.hl_insetBottom = -additionValue;
}

@end

#pragma mark - UITableViewCell

@implementation UITableViewCell (HaloObjC)

+ (nonnull NSString *)hl_reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)selectionStyle:(UITableViewCellSelectionStyle)style {
    self.selectionStyle = style;
    return self;
}

@end

@implementation UITableViewValue1Cell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
}

@end


@implementation UICollectionView (HaloObjC)

- (void)hl_registerCellClass:(Class)cellClass {
    [self registerClass:cellClass forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
}

@end

#pragma mark - UICollectionViewCell

@implementation UICollectionViewCell (HaloObjC)

+ (NSString *)hl_reuseIdentifier {
    return NSStringFromClass([self class]);
}

@end

#pragma mark - UINavigatoinController

@implementation UINavigationController (HaloObjC)

- (void)hl_barUseColor:(UIColor *)color tintColor:(UIColor *)tintColor shadowColor:(UIColor *)shadowColor {
    
    UIImage *image = [UIImage hl_imageWithColor:color size:CGSizeMake(1, 1)];
    
    if (color) {
        [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    
    if (tintColor) {
        self.navigationBar.tintColor = tintColor;
        NSMutableDictionary *newDictionary = [NSMutableDictionary dictionaryWithDictionary:self.navigationBar.titleTextAttributes];
        newDictionary[NSForegroundColorAttributeName] = tintColor;
        self.navigationBar.titleTextAttributes = newDictionary;
    }
    
    if (shadowColor) {
        self.navigationBar.shadowImage = [UIImage hl_imageWithColor:shadowColor size:CGSizeMake(1, 1)];
    } else {
        self.navigationBar.shadowImage = image;
    }
}

+ (instancetype)root:(UIViewController *)rootVC {
    return [[self alloc] initWithRootViewController:rootVC];
}

@end

#pragma mark - UIImage

@implementation UIImage (HaloObjC)

+ (UIImage *)hl_imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddRect(ctx, CGRectMake(0, 0, size.width, size.height));
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillPath(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)hl_imageWithColor:(UIColor *)color {
    CGSize size = CGSizeMake(1, 1);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddRect(ctx, CGRectMake(0, 0, size.width, size.height));
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillPath(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end


#pragma mark - UIColor

/// @see http://stackoverflow.com/questions/3805177/how-to-convert-hex-rgb-color-codes-to-uicolor

#ifndef HEXStr

void _SKScanHexColor(NSString *hexString, float *red, float *green, float *blue, float *alpha) {
    
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)], [cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)], [cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)], [cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if ([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    if (red) {*red = ((baseValue >> 24) & 0xFF) / 255.0f;}
    if (green) {*green = ((baseValue >> 16) & 0xFF) / 255.0f;}
    if (blue) {*blue = ((baseValue >> 8) & 0xFF) / 255.0f;}
    if (alpha) {*alpha = ((baseValue >> 0) & 0xFF) / 255.0f;}
}

UIColor *HEXStr(NSString *hexString) {
    float red, green, blue, alpha;
    _SKScanHexColor(hexString, &red, &green, &blue, &alpha);
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

NSString *HEXStringFromColor(UIColor *color) {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

#endif

#ifndef HEX

UIColor *HEX(NSUInteger hex) {
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0];
}
#endif

#ifndef RGB

UIColor *RGB(CGFloat r, CGFloat g, CGFloat b) {
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0];
}

#endif

#ifndef RGBA

UIColor *RGBA(CGFloat r, CGFloat g, CGFloat b, CGFloat a) {
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a];
}

#endif

#ifndef ColorWithHexValueA

UIColor *ColorWithHexValueA(NSUInteger hexValue, CGFloat a) {
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:a];
}

#endif
