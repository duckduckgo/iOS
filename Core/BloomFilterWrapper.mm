//
//  BloomFilterWrapper.m
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "BloomFilterWrapper.h"
#import "BloomFilter.hpp"

@interface BloomFilterWrapper() {
    BloomFilter *filter;
}
@end

@implementation BloomFilterWrapper

- (instancetype)initFromPath:(NSString*)path withBitCount:(int)bitCount andTotalItems:(int)totalItems {
    self = [super init];
    if (self != nil) {
        NSLog(@"Bloom: Importing data from %@", path);
        filter = new BloomFilter([path cStringUsingEncoding: NSString.defaultCStringEncoding], bitCount, totalItems);
    }
    return self;
}

- (instancetype)initWithTotalItems:(int)count errorRate:(double)errorRate {
    self = [super init];
    if (self != nil) {
        filter = new BloomFilter(count, errorRate);
    }
    return self;
}

- (void)add:(NSString*)entry {
    if (filter != nil) {
        filter->add([entry UTF8String]);
    }
}

- (BOOL)contains:(NSString*)entry {
    if (filter == nil || entry == nil) {
        return false;
    }
    return filter->contains([entry UTF8String]);
}

@end
