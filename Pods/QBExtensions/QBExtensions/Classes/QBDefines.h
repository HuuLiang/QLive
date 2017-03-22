//
//  QBMacros.h
//  Pods
//
//  Created by Sean Yue on 16/6/17.
//
//

#ifndef QBMacros_h
#define QBMacros_h

#ifdef  DEBUG
#define QBLog(fmt,...) {printf("%s\n", [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String]);}
#else
#define QBLog(...)
#endif

#define QBDefineLazyPropertyInitialization(propertyType, propertyName) \
-(propertyType *)propertyName { \
if (_##propertyName) { \
return _##propertyName; \
} \
_##propertyName = [[propertyType alloc] init]; \
return _##propertyName; \
}

#define QBSafelyCallBlock(block,...) \
if (block) block(__VA_ARGS__);

#define QBSafelyCallBlockAndRelease(block,...) \
if (block) { block(__VA_ARGS__); block = nil;};

#define QBDeclareSingletonMethod(methodName) \
+ (instancetype)methodName;

#define QBSynthesizeSingletonMethod(methodName) \
+ (instancetype)methodName { \
static id _methodName; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{\
_methodName = [[self alloc] init]; \
}); \
return _methodName; \
}

#define QBAssociatedButtonWithActionByPassOriginalSender(button, action) \
__weak typeof(self) button##WeakSelf = self; \
[button bk_addEventHandler:^(id sender) { \
__strong typeof(button##WeakSelf) button##StrongSelf = button##WeakSelf; \
SafelyCallBlock(button##StrongSelf.action, sender); \
} forControlEvents:UIControlEventTouchUpInside];

#define QBAssociatedButtonWithAction(button, action) \
__weak typeof(self) button##WeakSelf = self; \
[button bk_addEventHandler:^(id sender) { \
__strong typeof(button##WeakSelf) button##StrongSelf = button##WeakSelf; \
SafelyCallBlock(button##StrongSelf.action, self); \
} forControlEvents:UIControlEventTouchUpInside];

#define QBAssociatedViewWithTapAction(view, action) \
__weak typeof(self) view##WeakSelf = self; \
[view bk_whenTapped:^{ \
__strong typeof(view##WeakSelf) view##StrongSelf = view##WeakSelf; \
SafelyCallBlock(view##StrongSelf.action, self); \
}];

#define kScreenHeight     [ [ UIScreen mainScreen ] bounds ].size.height
#define kScreenWidth      [ [ UIScreen mainScreen ] bounds ].size.width

typedef void (^QBAction)(id obj);
typedef void (^QBCompletionHandler)(BOOL success, id obj);

#endif /* QBMacros_h */
