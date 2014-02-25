//
//  Choice.h
//  DictionarySync
//
//  Created by Chase Gorectke on 2/25/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+SYNC.h"

@class Decision;

@interface Choice : NSManagedObject

@property (nonatomic, retain) NSNumber * clicks;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSSet *decisions;
@end

@interface Choice (CoreDataGeneratedAccessors)

- (void)addDecisionsObject:(Decision *)value;
- (void)removeDecisionsObject:(Decision *)value;
- (void)addDecisions:(NSSet *)values;
- (void)removeDecisions:(NSSet *)values;

@end
