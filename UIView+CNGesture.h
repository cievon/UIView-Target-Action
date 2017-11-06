//
//  UIView+CNGesture.h
//  Cievon
//
//  Created by cievon on 2017/10/27.
//  Copyright © 2017年 cievon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CNLongPressEvents) {
    CNLongPressEventsStart,
    CNLongPressEventsEnd,
    CNLongPressEventsCancel
};

@interface UIView (CNGesture)

- (void)cn_addTarget:(id)target action:(SEL)action;
- (void)cn_addDBclick:(id)target action:(SEL)action;
- (void)cn_addLongPressTarget:(id)target action:(SEL)action event:(CNLongPressEvents)event;

@end
