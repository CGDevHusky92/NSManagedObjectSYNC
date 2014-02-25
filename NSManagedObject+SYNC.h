//
//  NSManagedObject+SYNC.h
//  ThisOrThat
//
//  Created by Chase Gorectke on 2/23/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface NSManagedObject (SYNC)

- (BOOL)updateFromDictionary:(NSDictionary *)dic;
- (NSDictionary *)dictionaryFromObject;

@end
