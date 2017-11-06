//
//  UIView+CNGesture.m
//  Cievon
//
//  Created by cievon on 2017/10/27.
//  Copyright © 2017年 cievon. All rights reserved.
//

#import "UIView+CNGesture.h"
#import "objc/runtime.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

static char const * kTargetKey = "kTargetKey";
static char const * kTapActionKey = "kTapActionKey";
static char const * kDBActionKey = "kDBActionKey";
static char const * kSimpleTapRecognizerKey = "kSimpleTapRecognizerKey";
static char const * kLongPressStartActionKey = "kLongPressStartActionKey";
static char const * kLongPressEndActionKey = "kLongPressEndActionKey";
static char const * kLongPressCancelActionKey = "kLongPressCancelActionKey";

@implementation UIView (CNGesture)

- (void)cn_addTarget:(id)target action:(SEL)action {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tap];
    
    objc_setAssociatedObject(self, kSimpleTapRecognizerKey, tap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, kTargetKey, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, kTapActionKey, NSStringFromSelector(action), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cn_addDBclick:(id)target action:(SEL)action {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *dbTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    dbTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:dbTap];
    
    objc_setAssociatedObject(self, kTargetKey, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, kDBActionKey, NSStringFromSelector(action), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UITapGestureRecognizer *simpleTapGesture = objc_getAssociatedObject(self, kSimpleTapRecognizerKey);
    if (simpleTapGesture) {
        [simpleTapGesture requireGestureRecognizerToFail:dbTap];
    }
}

- (void)cn_addLongPressTarget:(id)target action:(SEL)action event:(CNLongPressEvents)event {
    self.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    [self addGestureRecognizer:longPress];
    
    switch (event) {
        case CNLongPressEventsStart:
            objc_setAssociatedObject(self, kLongPressStartActionKey, NSStringFromSelector(action), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            break;
        case CNLongPressEventsEnd:
            objc_setAssociatedObject(self, kLongPressEndActionKey, NSStringFromSelector(action), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            break;
        case CNLongPressEventsCancel:
            objc_setAssociatedObject(self, kLongPressCancelActionKey, NSStringFromSelector(action), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            break;
        default:
            break;
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    const char *actionKey;
    switch (gesture.numberOfTapsRequired) {
        case 1:
        {
            gesture.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                gesture.enabled = YES;
            });
            actionKey = kTapActionKey;
        }
            break;
        case 2:
        {
            actionKey = kDBActionKey;
        }
            break;
        default:
            break;
    }
    
    id target = objc_getAssociatedObject(self, kTargetKey);
    SEL tapAction = NSSelectorFromString(objc_getAssociatedObject(self, actionKey));
    
    if (!target && tapAction) return;
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        SuppressPerformSelectorLeakWarning([target performSelector:tapAction withObject:self]);
    }
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture {
    SuppressPerformSelectorLeakWarning(
                                       id target = objc_getAssociatedObject(self, kTargetKey);
                                       SEL longPressStartAction = NSSelectorFromString(objc_getAssociatedObject(self, kLongPressStartActionKey));
                                       SEL longPressEndAction = NSSelectorFromString(objc_getAssociatedObject(self, kLongPressEndActionKey));
                                       SEL longPressCancelAction = NSSelectorFromString(objc_getAssociatedObject(self, kLongPressCancelActionKey));
                                       
                                       if (gesture.state == UIGestureRecognizerStateBegan) {
                                           if (!(target && longPressStartAction)) return;
                                           [target performSelector:longPressStartAction withObject:self];
                                       }else if (gesture.state == UIGestureRecognizerStateEnded) {
                                           if (!(target && longPressEndAction)) return;
                                           [target performSelector:longPressEndAction withObject:self];
                                       }else if (gesture.state == UIGestureRecognizerStateCancelled){
                                           if (!(target && longPressCancelAction)) return;
                                           [target performSelector:longPressCancelAction withObject:self];
                                       }
                                       );
}

@end
