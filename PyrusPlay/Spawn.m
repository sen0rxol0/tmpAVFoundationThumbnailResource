//
//  Spawn.m
//  AVFoundationSimplePlayer-iOS
//
//  Created by sen0rxol0 on 15/01/2024.
//  Copyright © 2024 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spawn.h"

@interface Spawn ()
@end

@implementation Spawn

////https://github.com/rpetrich/RPSpawnTask/blob/master/RPSpawnTask.m
- (void)spawnTask:(NSString *)processPath withArguments:(NSArray *)arguments
{
//      Convert arguments to c-style
        size_t count = [arguments count];
        const char *args[count + 2];
        args[0] = [processPath UTF8String];
        for (size_t i = 0; i < count; i++) {
            args[i+1] = [[arguments objectAtIndex:i] UTF8String];
        }
        args[count+1] = NULL;

        posix_spawnattr_t attr;
        posix_spawnattr_init(&attr);

        posix_spawnattr_set_persona_np(&attr, 99, POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE);
        posix_spawnattr_set_persona_uid_np(&attr, 0);
        posix_spawnattr_set_persona_gid_np(&attr, 0);

        pid_t task_pid;
        int result;
    
        if (posix_spawn(&task_pid, args[0], NULL, &attr, (void *)&args, NULL)) {
            
            posix_spawnattr_destroy(&attr);
            waitpid(task_pid, &result, 0);
        }
}

//- (void)shellCommand:(NSString *)command
//{
//        NSString *c = [NSString stringWithFormat:@"%s >> /var/.shellCommandLog 2>&1", [command UTF8String]];
//        Task *task = [[Task alloc] init];
//        [task spawnTask:@"/var/jb/bin/bash" withArguments:[NSArray arrayWithObjects:@"-c", c, nil]];
//}

@end
