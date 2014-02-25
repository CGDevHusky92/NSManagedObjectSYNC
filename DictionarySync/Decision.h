//
//  Decision.h
//  DictionarySync
//
//  Created by Chase Gorectke on 2/25/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+SYNC.h"

@class Choice, User;

@interface Decision : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * dec;
@property (nonatomic, retain) NSSet *choices;
@property (nonatomic, retain) User *user;
@end

@interface Decision (CoreDataGeneratedAccessors)

- (void)addChoicesObject:(Choice *)value;
- (void)removeChoicesObject:(Choice *)value;
- (void)addChoices:(NSSet *)values;
- (void)removeChoices:(NSSet *)values;

@end
