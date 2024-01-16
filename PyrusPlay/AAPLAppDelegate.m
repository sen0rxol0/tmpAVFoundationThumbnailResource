/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Application delegate.
*/


#import "AAPLAppDelegate.h"
#import "Spawn.h"

@implementation AAPLAppDelegate

- (void)startNode
{
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *bundleFullPath = [bundle bundlePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
    
        Spawn *spawn = [[Spawn alloc] init];
    
        if (![fileManager fileExistsAtPath:[bundleFullPath stringByAppendingString:@"/NodeRunner/js/main.js"]]) {
            
            NSArray *untarArgs = [NSArray arrayWithObjects:@"-C",
                                  [bundleFullPath stringByAppendingString:@"/NodeRunner/"],
                                  @"-xf",
                                  [bundle pathForResource:@"js" ofType:@"tar"],
                                  nil];
            [spawn spawnTask:@"/var/jb/bin/tar" withArguments:untarArgs];
        }

        NSString *nodeRunner = [NSString stringWithFormat:@"%@/NodeRunner/NodeRunner", bundleFullPath];
        NSString *nodeRunnerArg = [NSString stringWithFormat:@"%@/NodeRunner/js/main.js", bundleFullPath];

        [spawn spawnTask:nodeRunner withArguments:[NSArray arrayWithObjects:nodeRunnerArg, nil]];
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
