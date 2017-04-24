//
//  OrderedDictionary.h
//  ChesCharts
//
//  Created by ches on 15/8/22.
//  Copyright (c) 2015 Cheswick.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_NOT_FOUND_INDEX (-1)

@interface OrderedDictionary : NSObject {
    NSMutableDictionary *dict;  // keyed objects
    NSMutableArray *keys;       // keys, in order
}

@property (nonatomic, strong)   NSMutableDictionary *dict;
@property (nonatomic, strong)   NSMutableArray *keys;

- (id) initWithCapacity: (size_t) size;

- (NSInteger) indexForKey:(NSString *) key;
- (id) objectForKey: (NSString *)key;
- (id) objectAtIndex: (size_t) index;
- (void) removeObjectAtIndex: (size_t) index;
- (void) removeObjectWithKey: (NSString *)key;
- (void) addObject: (id) object withKey: (NSString *) key;
- (void) insertObject: (id) object withKey: (NSString *) key atIndex: (size_t) index;

- (void) moveObjectAtIndex: (size_t)from to:(size_t) to;
- (void) changeObjectForKey:(NSString *)key toValue:(id) object;

- (size_t) count;
- (NSString *) keyAtIndex: (size_t) index;
- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState *) enumerationState
                                   objects: (id __unsafe_unretained []) stackBuffer
                                     count: (NSUInteger) length;

@end
