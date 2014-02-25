//
//  User.h
//  DictionarySync
//
//  Created by Chase Gorectke on 2/25/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+SYNC.h"

@class Decision;

@interface User : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * default_user;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSData * profile_pic;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSSet *decisions;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addDecisionsObject:(Decision *)value;
- (void)removeDecisionsObject:(Decision *)value;
- (void)addDecisions:(NSSet *)values;
- (void)removeDecisions:(NSSet *)values;

@end
