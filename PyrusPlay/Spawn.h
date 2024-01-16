//
//  Spawn.h
//  AVFoundationSimplePlayer-iOS
//
//  Created by sen0rxol0 on 15/01/2024.
//  Copyright © 2024 Apple Inc. All rights reserved.
//

#ifndef Spawn_h
#define Spawn_h

#include <spawn.h>
#include <sys/wait.h>

#define POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE 1
extern int posix_spawnattr_set_persona_np(const posix_spawnattr_t* __restrict, uid_t, uint32_t);
extern int posix_spawnattr_set_persona_uid_np(const posix_spawnattr_t* __restrict, uid_t);
extern int posix_spawnattr_set_persona_gid_np(const posix_spawnattr_t* __restrict, uid_t);

@interface Spawn : NSObject

- (void)spawnTask:(NSString *)processPath withArguments:(NSArray *)arguments;

@end

#endif /* Spawn_h */
