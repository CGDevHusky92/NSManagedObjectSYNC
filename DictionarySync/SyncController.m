//
//  SyncController.m
//  ThisOrThat
//
//  Created by Chase Gorectke on 1/25/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//


#import <pthread.h>
#import "SyncController.h"
#import "DataController.h"

#import "User.h"
#import "Decision.h"
#import "Choice.h"

@interface SyncController ()

@end

@implementation SyncController

+ (SyncController *)sharedController
{
    static SyncController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[SyncController alloc] init];
    });
    return sharedController;
}

- (void)startSync
{
    for (NSString *class in [self availableClassesToSync]) {
        [self startRefreshForClass:class];
    }
}

- (void)startRefreshForClass:(NSString *)class
{
    [self generateStartUp];
    if ([class isEqualToString:@"Choice"]) {
        NSArray *array = [[DataController sharedData] managedObjectsForClass:@"Choice"];
        if (array && [array count] > 0) {
            Choice *chc = [array objectAtIndex:0];
            NSMutableDictionary *chcDic = [[chc dictionaryFromObject] mutableCopy];
            [chcDic setObject:@[ @"0135622" ] forKey:@"decisions"];
            [chc updateFromDictionary:chcDic];
        }
    } else if ([class isEqualToString:@"Decision"]) {
        NSArray *array = [[DataController sharedData] managedObjectsForClass:@"Decision"];
        if (array && [array count] > 0) {
            Decision *dec = [array objectAtIndex:0];
            NSMutableDictionary *decDic = [[dec dictionaryFromObject] mutableCopy];
            [decDic setObject:@"0135623" forKey:@"user"];
            [dec updateFromDictionary:decDic];
        }
    } else if ([class isEqualToString:@"User"]) {
        NSArray *array = [[DataController sharedData] managedObjectsForClass:@"User"];
        if (array && [array count] > 0) {
            User *user = [array objectAtIndex:0];
            
            NSMutableDictionary *userDic = [[user dictionaryFromObject] mutableCopy];
            [userDic setObject:@[ @"0135622" ] forKey:@"decisions"];
            [user updateFromDictionary:userDic];
        }
    }
}

- (void)generateStartUp
{
    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *coms = [[NSDateComponents alloc] init];
    [coms setYear:2014];
    [coms setMonth:2];
    [coms setDay:24];
    [coms setHour:1];
    [coms setMinute:0];
    [coms setSecond:0];
    
    NSDate *date = [cal dateFromComponents:coms];
    NSManagedObjectContext *context = [[DataController sharedData] backgroundManagedObjectContext];
    NSArray *arrayChoice = [[DataController sharedData] managedObjectsForClass:@"Choice"];
    if (!arrayChoice || [arrayChoice count] == 0) {
        // Generate first fake choice
        Choice *choice = [NSEntityDescription insertNewObjectForEntityForName:@"Choice" inManagedObjectContext:context];
        [choice setClicks:@0];
        [choice setCreatedAt:date];
        [choice setObjectId:@"0135621"];
    }
    
    NSArray *arrayDecision = [[DataController sharedData] managedObjectsForClass:@"Decision"];
    if (!arrayDecision || [arrayDecision count] == 0) {
        // Generate first fake decision
        Decision *decision = [NSEntityDescription insertNewObjectForEntityForName:@"Decision" inManagedObjectContext:context];
        [decision setCreatedAt:date];
        [decision setObjectId:@"0135622"];
    }
    
    NSArray *arrayUser = [[DataController sharedData] managedObjectsForClass:@"User"];
    if (!arrayUser || [arrayUser count] == 0) {
        // Generate first fake decision
        User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        [user setObjectId:@"0135623"];
        [user setUsername:@"crgorect"];
    }
    
    [[DataController sharedData] saveBackgroundContext];
    [[DataController sharedData] saveMasterContext];
}

- (NSArray *)availableClassesToSync
{
    return [NSArray arrayWithObjects:@"Choice", @"Decision", nil];
}

@end
