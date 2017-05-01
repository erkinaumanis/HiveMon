//
//  AppDelegate.m
//  HiveMOn
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import "AppDelegate.h"
#import "DevicesVC.h"


@interface AppDelegate ()

@property (strong, nonatomic)   DevicesVC *devicesVC;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;
@synthesize navController;
@synthesize devicesVC;

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if (![[NSFileManager defaultManager] changeCurrentDirectoryPath: documentsDirectory])
        NSLog(@"AppDelegate: could not cd to documents directory ***");
    
    self.window = [[UIWindow alloc]
                   initWithFrame:[[UIScreen mainScreen]
                                  bounds]];
    devicesVC = [[DevicesVC alloc]
                   initWithStyle:UITableViewStyleGrouped];
    self.navController = [[UINavigationController alloc]
                          initWithRootViewController: devicesVC];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
#ifdef DEBUG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
    [devicesVC goingToBackground];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
#ifdef DEBUG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
#ifdef notdef
    UIBackgroundTaskIdentifier __block bgTask = [application
                                                 beginBackgroundTaskWithName:@"BeeMonTask"
                                                 expirationHandler:^{
                                                     // Clean up any unfinished task business by marking where you
                                                     // stopped or ending the task outright.
                                                     [application endBackgroundTask:bgTask];
                                                     bgTask = UIBackgroundTaskInvalid;
#ifdef DEBUG
                                                     NSLog(@"%s FINISHED", __PRETTY_FUNCTION__);
#endif
                                                 }];
#endif
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"%s dispatch", __PRETTY_FUNCTION__);
        [devicesVC doBackgroundIdleCycles];
        NSLog(@"%s dispatch FINISHED", __PRETTY_FUNCTION__);

#ifdef notdef
        NSLog(@"%s dispatch", __PRETTY_FUNCTION__);
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
#endif
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
#ifdef DEBUG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
#ifdef DEBUG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
    [devicesVC leftBackground];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
#ifdef DEBUG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
}

-(BOOL) application:(UIApplication *)application
            openURL:(nonnull NSURL *)url
  sourceApplication:(nullable NSString *)sourceApplication
         annotation:(nonnull id)annotation {
#ifdef DEBUG
    NSLog(@"handleOpenURL: %@", url);
#endif
    if (!url)
        return NO;
    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtPath:url.absoluteString error:&error]) {
        NSLog(@"%s: could not remove %@, %@", __PRETTY_FUNCTION__, url.absoluteString, [error localizedDescription]);
        return NO;
    }
    return YES;
}

- (void)saveContext {
#ifdef NOTYET
    NSError *error = nil;
    NSManagedObjectContext *moc = self.managedObjectContext;
    if (moc != nil) {
        if ([moc hasChanges] && ![moc save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
#endif
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
#ifdef NOTYET
    if (self.managedObjectContext != nil) {
        return self.managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
#endif
    return managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)currentManagedObjectModel {
#ifdef NOTYET
    if (self.managedObjectModel != nil) {
        return self.managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Envelope" withExtension:@"momd"];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
#endif
    return self.managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
#ifdef notyet
    if (self.persistentStoreCoordinator != nil) {
        return self.persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Envelope.sqlite"];
    
    NSError *error = nil;
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self currentManagedObjectModel]];
    if (![self.persistentStoreCoordinator
          addPersistentStoreWithType:NSSQLiteStoreType
          configuration:nil URL:storeURL
          options:nil
          error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
#endif
    return self.persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask]
            lastObject];
}

@end
