//  Copyright 2015 happy_ryo
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
#import <Foundation/Foundation.h>


@interface CRUser : NSObject
@property(nonatomic, copy) NSString *createdAt;
@property(nonatomic, copy) NSString *userDescription;
@property(nonatomic, strong) NSNumber *favoritesCount;
@property(nonatomic) BOOL followRequestSent;
@property(nonatomic, strong) NSNumber *followersCount;
@property(nonatomic) BOOL following;
@property(nonatomic, strong) NSNumber *friendsCount;
@property(nonatomic, copy) NSString *idStr;
@property(nonatomic, strong) NSNumber *idNum;
@property(nonatomic, copy) NSString *location;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *profileImageUrlHttps;
@property(nonatomic, copy) NSString *coverImageUrlHttps;
@property(nonatomic) BOOL userProtected;
@property(nonatomic, copy) NSString *screenName;
@property(nonatomic, strong) NSNumber *statusesCount;
@property(nonatomic, copy) NSString *url;
@end