//  Copyright 2013 happy_ryo
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "CRMute.h"

@implementation CRMute {
    NSMutableArray *_muteIdArray;
    NSMutableDictionary *_muteUserDictionary;
}

- (id)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *array = [defaults valueForKey:CR_MUTE];
        NSDictionary *userDictionary = [defaults valueForKey:CR_MUTE_USER];
        if (array) {
            _muteIdArray = [[NSMutableArray alloc] initWithArray:array];
            _muteUserDictionary = [[NSMutableDictionary alloc] initWithDictionary:userDictionary];
        } else {
            _muteIdArray = [NSMutableArray array];
            _muteUserDictionary = [NSMutableDictionary dictionary];
        }
    }
    return self;
}


- (void)registration:(NSString *)muteId screenName:(NSString *)screenName name:(NSString *)name {
    if (![_muteIdArray containsObject:muteId]) {
        [_muteIdArray addObject:muteId];
        NSDictionary *dictionary = @{CR_SCREEN_NAME : screenName, CR_USER_NAME : name};
        _muteUserDictionary[muteId] = dictionary;
        [self saveData];
    }
}


- (void)deletion:(NSString *)deleteId {
    if ([_muteIdArray containsObject:deleteId]) {
        [_muteIdArray removeObject:deleteId];
        [_muteUserDictionary removeObjectForKey:deleteId];
        [self saveData];
    }
}

- (BOOL)check:(NSString *)checkId {
    return [_muteIdArray containsObject:checkId];
}

- (NSDictionary *)loadUser:(NSString *)userId {
    return [_muteUserDictionary valueForKey:userId];
}

- (void)saveData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_muteIdArray forKey:CR_MUTE];
    [defaults setObject:_muteUserDictionary forKey:CR_MUTE_USER];
    [defaults synchronize];
}
@end