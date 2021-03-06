//
//  NSManagedObject+SYNC.m
//  ThisOrThat
//
//  Created by Chase Gorectke on 2/23/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import "DataController.h"
#import "NSManagedObject+SYNC.h"
#import "objc/runtime.h"

@implementation NSManagedObject (SYNC)

- (BOOL)updateFromDictionary:(NSDictionary *)dic
{
    BOOL ret = YES;
    if (![[self dictionaryFromObject] isEqualToDictionary:dic]) {
        NSMutableDictionary *mutDic = [dic mutableCopy];
        [mutDic removeObjectsForKeys:[self relationshipKeys]];
        [self setValuesForKeysWithDictionary:mutDic];
        
        for (NSString *relKey in [self relationshipKeys]) {
            NSRelationshipDescription *description = [[[self entity] relationshipsByName] objectForKey:relKey];
            
            if ([description isToMany]) {
                NSArray *objIds = [dic objectForKey:relKey];
                if (![objIds isKindOfClass:[NSNull class]]) {
                    for (NSString *objId in objIds) {
                        NSArray *objArr = [[DataController sharedData] managedObjectsForClass:[[description destinationEntity] managedObjectClassName] sortedByKey:nil withPredicate:[NSPredicate predicateWithFormat:@"objectId == %@", objId]];
                        if (objArr && [objArr count] > 0) {
                            NSManagedObject *obj = [objArr objectAtIndex:0];
                            NSString *sel = [NSString stringWithFormat:@"add%@sObject:", [[description destinationEntity] managedObjectClassName]];
                            SEL selSelector = NSSelectorFromString(sel);
                            if ([self respondsToSelector:selSelector]) {
                                IMP imp = [self methodForSelector:selSelector];
                                void (*add)(id, SEL, NSManagedObject *) = (void *)imp;
                                add(self, selSelector, obj);
                            }
                            
                            if ([[description inverseRelationship] isToMany]) {
                                NSString *objSel = [NSString stringWithFormat:@"add%@sObject:", [[self entity] managedObjectClassName]];
                                SEL objSelector = NSSelectorFromString(objSel);
                                if ([obj respondsToSelector:objSelector]) {
                                    IMP imp = [obj methodForSelector:objSelector];
                                    void (*add)(id, SEL, NSManagedObject *) = (void *)imp;
                                    add(obj, objSelector, self);
                                }
                            } else {
                                NSString *objSel = [NSString stringWithFormat:@"set%@:", [[self entity] managedObjectClassName]];
                                SEL objSelector = NSSelectorFromString(objSel);
                                if ([obj respondsToSelector:objSelector]) {
                                    IMP imp = [obj methodForSelector:objSelector];
                                    void (*add)(id, SEL, NSManagedObject *) = (void *)imp;
                                    add(obj, objSelector, self);
                                }
                            }
                        } else {
                            ret = NO;
                        }
                    }
                }
            } else {
                NSArray *objArr = [[DataController sharedData] managedObjectsForClass:[[description destinationEntity] managedObjectClassName] sortedByKey:nil withPredicate:[NSPredicate predicateWithFormat:@"objectId == %@", [dic objectForKey:relKey]]];
                if (objArr && [objArr count] > 0) {
                    NSManagedObject *obj = [objArr objectAtIndex:0];
                    NSString *sel = [NSString stringWithFormat:@"set%@:", [[description destinationEntity] managedObjectClassName]];
                    SEL selSelector = NSSelectorFromString(sel);
                    if ([self respondsToSelector:selSelector]) {
                        IMP imp = [self methodForSelector:selSelector];
                        void (*add)(id, SEL, NSManagedObject *) = (void *)imp;
                        add(self, selSelector, obj);
                    }
                    
                    if ([[description inverseRelationship] isToMany]) {
                        NSString *objSel = [NSString stringWithFormat:@"add%@sObject:", [[self entity] managedObjectClassName]];
                        SEL objSelector = NSSelectorFromString(objSel);
                        if ([obj respondsToSelector:objSelector]) {
                            IMP imp = [obj methodForSelector:objSelector];
                            void (*add)(id, SEL, NSManagedObject *) = (void *)imp;
                            add(obj, objSelector, self);
                        }
                    } else {
                        NSString *objSel = [NSString stringWithFormat:@"set%@:", [[self entity] managedObjectClassName]];
                        SEL objSelector = NSSelectorFromString(objSel);
                        if ([obj respondsToSelector:objSelector]) {
                            IMP imp = [obj methodForSelector:objSelector];
                            void (*add)(id, SEL, NSManagedObject *) = (void *)imp;
                            add(obj, objSelector, self);
                        }
                    }
                } else {
                    ret = NO;
                }
            }
        }
    }
    
    return ret;
}

- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary *propDic = [[self propertyDictionaryFromObject] mutableCopy];
    [propDic addEntriesFromDictionary:[self relationshipDictionaryFromObject]];
    return propDic;
}

- (NSDictionary *)propertyDictionaryFromObject
{
    return [self dictionaryWithValuesForKeys:[self propertyKeys]];
}

- (NSDictionary *)relationshipDictionaryFromObject
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSDictionary *relationshipsByName = [[self entity] relationshipsByName];
    for (NSString *rel in [relationshipsByName allKeys]) {
        NSRelationshipDescription *description = [relationshipsByName objectForKey:rel];
        if ([description isToMany]) {
            NSMutableArray *objIds = [[NSMutableArray alloc] init];
            NSSet *relationship = [self valueForKey:rel];
            for (NSManagedObject *obj in relationship) {
                [objIds addObject:[obj valueForKey:@"objectId"]];
            }
            if ([objIds count] > 0) {
                [dic setObject:objIds forKey:rel];
            } else {
                [dic setObject:[NSNull null] forKey:rel];
            }
        } else {
            NSManagedObject *object = [self valueForKey:rel];
            if (object && ![[object valueForKey:@"objectId"] isEqualToString:@""]) {
                [dic setObject:[object valueForKey:@"objectId"] forKey:rel];
            } else {
                [dic setObject:[NSNull null] forKey:rel];
            }
        }
    }
    
    return dic;
}

- (NSArray *)propertyKeys
{
    return [[self entity] attributeKeys];
}

- (NSArray *)relationshipKeys
{
    return [[[self entity] relationshipsByName] allKeys];
}

@end
