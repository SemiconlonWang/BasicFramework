

#import "UIButton+TitleColor.h"
#import "DKNightVersionManager.h"
#import "objc/runtime.h"

@interface UIButton ()

@property (nonatomic, strong) UIColor *normalTitleColor;

@end

@implementation UIButton (TitleColor)

+ (void)load {
    static dispatch_once_t onceToken;                                              
    dispatch_once(&onceToken, ^{                                                   
        Class class = [self class];                                                
        SEL originalSelector = @selector(setTitleColor:forState:);                                  
        SEL swizzledSelector = @selector(hook_setTitleColor:forState:);                                 
        Method originalMethod = class_getInstanceMethod(class, originalSelector);  
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);  
        BOOL didAddMethod =                                                        
        class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));                   
        if (didAddMethod){
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));           
        } else {                                                                   
            method_exchangeImplementations(originalMethod, swizzledMethod);        
        }
    });
    [DKNightVersionManager addClassToSet:self.class];
}

- (void)hook_setTitleColor:(UIColor*)titleColor forState:(UIControlState)state {
    if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNormal) [self setNormalTitleColor:titleColor];
    [self hook_setTitleColor:titleColor forState:UIControlStateNormal];
}

- (UIColor *)nightTitleColor {
    UIColor *nightColor = objc_getAssociatedObject(self, @selector(nightTitleColor));
    if (nightColor) {
        return nightColor;
    } else if ([DKNightVersionManager useDefaultNightColor] && self.defaultNightTitleColor) {
        return self.defaultNightTitleColor;
    } else {
        UIColor *resultColor = self.normalTitleColor ?: [UIColor whiteColor];
        return resultColor;
    }
}

- (void)setNightTitleColor:(UIColor *)nightTitleColor {
    if ([DKNightVersionManager currentThemeVersion] == DKThemeVersionNight) [self setTitleColor:nightTitleColor forState:UIControlStateNormal];
    objc_setAssociatedObject(self, @selector(nightTitleColor), nightTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)normalTitleColor {
    return objc_getAssociatedObject(self, @selector(normalTitleColor));
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor {
    objc_setAssociatedObject(self, @selector(normalTitleColor), normalTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)defaultNightTitleColor {
    return [self isMemberOfClass:[UIButton class]] ? UIColorFromRGB(0x5F80AC) : nil;
}

@end
