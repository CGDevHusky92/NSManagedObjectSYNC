//
//  main.m
//  DictionarySync
//
//  Created by Chase Gorectke on 2/24/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncController.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        [[SyncController sharedController] startSync];
    }
    return 0;
}

