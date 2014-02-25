//
//  DataController.m
//  ThisOrThat
//
//  Created by Charles Gorectke (Revision Works, LLC) on 9/27/13.
//  Copyright Revision Works 2013
//  Engineering A Better World
//

#import "DataController.h"

@interface DataController()

@property (nonatomic, strong) NSManagedObjectContext *masterManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *backgroundManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSManagedObjectContext *)masterManagedObjectContext;
- (NSManagedObjectContext *)newManagedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;

@end

@implementation DataController
@synthesize masterManagedObjectContext = _masterManagedObjectContext;
@synthesize backgroundManagedObjectContext = _backgroundManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (id)sharedData
{
    static dispatch_once_t once;
    static DataController *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Core Data stack

// Used to propegate saves to the persistent store (disk) without blocking the UI
- (NSManagedObjectContext *)masterManagedObjectContext
{
    if (_masterManagedObjectContext != nil) {
        return _masterManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _masterManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_masterManagedObjectContext performBlockAndWait:^{
            [_masterManagedObjectContext setPersistentStoreCoordinator:coordinator];
        }];
    }
    
    return _masterManagedObjectContext;
}

// Return the NSManagedObjectContext to be used in the background during sync
- (NSManagedObjectContext *)backgroundManagedObjectContext
{
    if (_backgroundManagedObjectContext != nil) {
        return _backgroundManagedObjectContext;
    }
    
    NSManagedObjectContext *masterContext = [self masterManagedObjectContext];
    if (masterContext != nil) {
        _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundManagedObjectContext performBlockAndWait:^{
            [_backgroundManagedObjectContext setParentContext:masterContext]; 
        }];
    }
    
    return _backgroundManagedObjectContext;
}

// Return a new NSManagedObjectContext
- (NSManagedObjectContext *)newManagedObjectContext
{
    NSManagedObjectContext *newContext = nil;
    NSManagedObjectContext *masterContext = [self masterManagedObjectContext];
    if (masterContext != nil) {
        newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [newContext performBlockAndWait:^{
            [newContext setParentContext:masterContext]; 
        }];
    }
    return newContext;
}

- (void)saveMasterContext
{
    [self.masterManagedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        BOOL saved = [self.masterManagedObjectContext save:&error];
        if (!saved) {
            // do some real error handling
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
}

- (void)saveBackgroundContext
{
    [self.backgroundManagedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        BOOL saved = [self.backgroundManagedObjectContext save:&error];
        if (!saved) {
            // do some real error handling
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ExampleModel" withExtension:@"mom"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ExampleModel.sqlite"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Error: %@ - %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

- (void)resetStore
{
        NSError *error = nil;
        [self saveBackgroundContext];
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        [self saveMasterContext];
        _backgroundManagedObjectContext = nil;
        _masterManagedObjectContext = nil;
        _managedObjectModel = nil;
        _persistentStoreCoordinator = nil;
}

- (void)deleteStore
{
    NSError *error;
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ExampleModel.sqlite"];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    for (NSManagedObject *ct in [_masterManagedObjectContext registeredObjects]) {
        [_masterManagedObjectContext deleteObject:ct];
    }
    
    //Make new persistent store for future saves
    _persistentStoreCoordinator = nil;
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // do something with the error
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

#pragma mark - Fetch Requests For Objects

- (NSArray *)managedObjectsForClass:(NSString *)className
{
    return [self managedObjectsForClass:className sortedByKey:nil];
}

- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key {
    return [self managedObjectsForClass:className sortedByKey:key withBatchSize:0];
}

- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key withBatchSize:(int)num
{
    return [self managedObjectsForClass:className sortedByKey:key withBatchSize:num withPredicate:nil];
}

- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key ascending:(BOOL)ascend
{
    return [self managedObjectsForClass:className sortedByKey:key withPredicate:nil ascending:ascend];
}

- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key withPredicate:(NSPredicate *)predicate
{
    return [self managedObjectsForClass:className sortedByKey:key withPredicate:predicate ascending:NO];
}

- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key withPredicate:(NSPredicate *)predicate ascending:(BOOL)ascend
{
    return [self managedObjectsForClass:className sortedByKey:key withBatchSize:0 withPredicate:predicate ascending:ascend];
}

- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key withBatchSize:(int)num ascending:(BOOL)ascend
{
    return [self managedObjectsForClass:className sortedByKey:key withBatchSize:num withPredicate:nil ascending:ascend];
}

- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key withBatchSize:(int)num withPredicate:(NSPredicate *)predicate
{
    return [self managedObjectsForClass:className sortedByKey:key withBatchSize:num withPredicate:predicate ascending:NO];
}

- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key withBatchSize:(int)num withPredicate:(NSPredicate *)predicate ascending:(BOOL)ascend
{
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[DataController sharedData] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    [fetchRequest setFetchBatchSize:num];
    
    if (key) {
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:ascend]]];
    }
    
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results;
}

#pragma mark - Fetch Requests For Dictionaries

- (NSArray *)managedObjsAsDictionariesForClass:(NSString *)className
{
    return [self managedObjsAsDictionariesForClass:className sortedByKey:nil];
}

- (NSArray *)managedObjsAsDictionariesForClass:(NSString *)className sortedByKey:(NSString *)key {
    return [self managedObjsAsDictionariesForClass:className sortedByKey:key withBatchSize:0];
}

- (NSArray *)managedObjsAsDictionariesForClass:(NSString *)className sortedByKey:(NSString *)key withBatchSize:(int)num
{
    return [self managedObjsAsDictionariesForClass:className sortedByKey:key withBatchSize:num withPredicate:nil];
}

- (NSArray *)managedObjsAsDictionariesForClass:(NSString *)className sortedByKey:(NSString *)key ascending:(BOOL)ascend
{
    return [self managedObjsAsDictionariesForClass:className sortedByKey:key withPredicate:nil ascending:ascend];
}

- (NSArray *)managedObjsAsDictionariesForClass:(NSString *)className sortedByKey:(NSString *)key withPredicate:(NSPredicate *)predicate
{
    return [self managedObjsAsDictionariesForClass:className sortedByKey:key withPredicate:predicate ascending:NO];
}

- (NSArray *)managedObjsAsDictionariesForClass:(NSString *)className sortedByKey:(NSString *)key withPredicate:(NSPredicate *)predicate ascending:(BOOL)ascend
{
    return [self managedObjsAsDictionariesForClass:className sortedByKey:key withBatchSize:0 withPredicate:predicate ascending:ascend];
}

- (NSArray *)managedObjsAsDictionariesForClass:(NSString *)className sortedByKey:(NSString *)key withBatchSize:(int)num ascending:(BOOL)ascend
{
    return [self managedObjsAsDictionariesForClass:className sortedByKey:key withBatchSize:num withPredicate:nil ascending:ascend];
}

- (NSArray *)managedObjsAsDictionariesForClass:(NSString *)className sortedByKey:(NSString *)key withBatchSize:(int)num withPredicate:(NSPredicate *)predicate
{
    return [self managedObjsAsDictionariesForClass:className sortedByKey:key withBatchSize:num withPredicate:predicate ascending:NO];
}

- (NSArray *)managedObjsAsDictionariesForClass:(NSString *)className sortedByKey:(NSString *)key withBatchSize:(int)num withPredicate:(NSPredicate *)predicate ascending:(BOOL)ascend
{
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[DataController sharedData] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    [fetchRequest setFetchBatchSize:num];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    if (key) {
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:ascend]]];
    }
    
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end