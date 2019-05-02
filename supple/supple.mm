//
//  supple.mm
//  supple
//
//  Created by CokePokes on 5/2/19.
//  Copyright (c) 2019 ___ORGANIZATIONNAME___. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIWindow.h>

#import "CaptainHook/CaptainHook.h"

#import <FLEX/FLEX.h>

@interface UIStatusBarWindow : UIWindow @end

CHDeclareClass(UIWindow);

CHOptimizedMethod0(self, BOOL, UIWindow, _shouldCreateContextAsSecure)
{
    return [self isKindOfClass:objc_getClass("FLEXWindow")] ? YES : CHSuper0(UIWindow, _shouldCreateContextAsSecure);
}

CHOptimizedMethod1(self, id, UIWindow, initWithFrame, CGRect, frame)
{
    self = CHSuper1(UIWindow, initWithFrame, frame);
    
    id flex = [FLEXManager sharedManager];
    //SEL toggle = @selector(toggleExplorer);
    SEL show = @selector(showExplorer);
    
    UILongPressGestureRecognizer *tap = [[objc_getClass("UILongPressGestureRecognizer") alloc] initWithTarget:flex action:show];
    tap.minimumPressDuration = .5;
    tap.numberOfTouchesRequired = 3;
    
    [self addGestureRecognizer:tap];
    
    return self;
}

CHDeclareClass(UIStatusBarWindow);
CHOptimizedMethod1(self, id, UIStatusBarWindow, initWithFrame, CGRect, frame)
{
    self = CHSuper1(UIStatusBarWindow, initWithFrame, frame);
    [self addGestureRecognizer:[[objc_getClass("UILongPressGestureRecognizer") alloc] initWithTarget:FLEXManager.sharedManager action:@selector(showExplorer)]];
    return self;
}


CHConstructor {
    @autoreleasepool {
        NSArray *args = [[objc_getClass("NSProcessInfo") processInfo] arguments];
        NSUInteger count = args.count;
        if (count != 0) {
            NSString *executablePath = args[0];
            if (executablePath) {
                NSString *processName = [executablePath lastPathComponent];
                BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
                BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
                if (isSpringBoard || isApplication) {
                    CHLoadLateClass(UIWindow);
                    CHHook0(UIWindow, _shouldCreateContextAsSecure);
                    CHHook1(UIWindow, initWithFrame);
                    
                    CHLoadLateClass(UIStatusBarWindow);
                    CHHook1(UIStatusBarWindow, initWithFrame);
                }
            }
        }
    }
}
