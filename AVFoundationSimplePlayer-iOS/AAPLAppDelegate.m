/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Application delegate.
*/


#import "AAPLAppDelegate.h"
#import "Task.h"

@implementation AAPLAppDelegate

- (void)startNode
{
        [self shellCommand:@"echo StartNode"];
    
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *bundleFullPath = [bundle bundlePath];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/NodeRunner/js/main.js", bundleFullPath]]) {
                NSString *untarArchiveCommand = [NSString stringWithFormat:@"/var/jb/bin/tar -C %@/NodeRunner/ -xvf %@", bundleFullPath, [bundle pathForResource:@"js" ofType:@"tar"]];
                [self shellCommand:untarArchiveCommand];
        }

        NSString *nodeRunner = [NSString stringWithFormat:@"%@/NodeRunner/NodeRunner", bundleFullPath];
        NSString *nodeRunnerArg = [NSString stringWithFormat:@"%@/NodeRunner/js/main.js", bundleFullPath];
        
        Task *task = [[Task alloc] init];
        [task spawnTask:nodeRunner withArguments:[NSArray arrayWithObjects:nodeRunnerArg, nil]];
}

- (void)shellCommand:(NSString *)command
{
        NSString *c = [NSString stringWithFormat:@"%s >> /var/.shellCommandLog 2>&1", [command UTF8String]];
        Task *task = [[Task alloc] init];
        [task spawnTask:@"/var/jb/bin/bash" withArguments:[NSArray arrayWithObjects:@"-c", c, nil]];
}

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
