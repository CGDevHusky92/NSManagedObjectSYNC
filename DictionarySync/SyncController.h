//
//  SyncController.h
//  ThisOrThat
//
//  Created by Chase Gorectke on 1/25/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncController : NSObject

+ (SyncController *)sharedController;

- (void)startSync;

@end
