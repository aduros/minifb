//
//  AppDelegate.m
//  MiniFB
//
//  Created by Carlos Aragones on 22/04/2020.
//  Copyright © 2020 Carlos Aragones. All rights reserved.
//

#import "AppDelegate.h"
#include <MiniFB.h>
#include <iOSViewController.h>

#define kUnused(var)        (void) var;

struct mfb_window   *g_window = 0x0;
uint32_t            *g_buffer = 0x0;
uint32_t            g_width   = 0;
uint32_t            g_height  = 0;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    kUnused(application);
    kUnused(launchOptions);
    if(g_window == 0x0) {
        g_width  = [UIScreen mainScreen].bounds.size.width;
        g_height = [UIScreen mainScreen].bounds.size.height;
        g_buffer = malloc(g_width * g_height * 4);

        g_window = mfb_open("noise", g_width, g_height);
    }
    return YES;
}

- (void) applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    kUnused(application);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    kUnused(application);
    [mDisplayLink invalidate];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    kUnused(application);
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    kUnused(application);
    mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onUpdate)];
    [mDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    kUnused(application);
    [mDisplayLink invalidate];
}

- (void) onUpdate {
    static int seed = 0xbeef;
    int noise, carry;

    if(g_buffer != 0x0) {
        for (uint32_t i = 0; i < g_width * g_height; ++i) {
            noise = seed;
            noise >>= 3;
            noise ^= seed;
            carry = noise & 1;
            noise >>= 1;
            seed >>= 1;
            seed |= (carry << 30);
            noise &= 0xFF;
            g_buffer[i] = MFB_RGB(noise, noise, noise);
        }
    }
    
    mfb_update_state state = mfb_update(g_window, g_buffer);
    if (state != STATE_OK) {
        free(g_buffer);
        g_buffer = 0x0;
        g_width   = 0;
        g_height  = 0;
    }
}

@end