/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Application delegate.
*/

#import <spawn.h>
#import "AAPLAppDelegate.h"
//#import "NodeRunner.h"

#define POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE 1
extern int posix_spawnattr_set_persona_np(const posix_spawnattr_t* __restrict, uid_t, uint32_t);
extern int posix_spawnattr_set_persona_uid_np(const posix_spawnattr_t* __restrict, uid_t);
extern int posix_spawnattr_set_persona_gid_np(const posix_spawnattr_t* __restrict, uid_t);

@implementation AAPLAppDelegate

- (void)startNode
{
    //NSArray* nodeArguments = [NSArray arrayWithObjects:@"node", [[NSBundle mainBundle] pathForResource:@"server.js" ofType:@""], nil];
    //[NodeRunner startEngineWithArguments:nodeArguments];
    
    //NSString* execPath = [[NSBundle mainBundle] pathForResource:@"nodejs14_13_1" ofType:@""];
    //NSString* mainPath = [[NSBundle mainBundle] pathForResource:@"server.js" ofType:@""];
        //NSString* shellCommand = [NSString stringWithFormat:@"%s %s > /var/.startNodeLog 2>&1", [execPath UTF8String], [mainPath UTF8String]];
        //[self spawnTask:@"/var/jb/bin/bash" withArguments:[NSArray arrayWithObjects:@"-c", shellCommand, nil]];
}

////https://github.com/rpetrich/RPSpawnTask/blob/master/RPSpawnTask.m
//- (void)spawnTask:(NSString *)processPath withArguments:(NSArray *)arguments
//{
////      Convert arguments to c-style
//        size_t count = [arguments count];
//        const char *args[count + 2];
//        args[0] = [processPath UTF8String];
//        for (size_t i = 0; i < count; i++) {
//            args[i+1] = [[arguments objectAtIndex:i] UTF8String];
//        }
//        args[count+1] = NULL;
//
//        posix_spawnattr_t attr;
//        posix_spawnattr_init(&attr);
//
//        posix_spawnattr_set_persona_np(&attr, 99, POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE);
//        posix_spawnattr_set_persona_uid_np(&attr, 0);
//        posix_spawnattr_set_persona_gid_np(&attr, 0);
//
//        pid_t task_pid;
//        posix_spawn(&task_pid, args[0], NULL, &attr, (void *)&args, NULL);
//        posix_spawnattr_destroy(&attr);
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
        NSThread* nodejsThread = nil;
        nodejsThread = [[NSThread alloc]
            initWithTarget:self
            selector:@selector(startNode)
            object:nil
        ];
        // Set 2MB of stack space for the Node.js thread.
        [nodejsThread setStackSize:2*1024*1024];
        [nodejsThread start];
        return YES;
}

@end
