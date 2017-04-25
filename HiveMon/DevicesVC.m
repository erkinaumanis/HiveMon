//
//  DevicesVC.m
//  HiveMon
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import "Defines.h"
#import "DevicesVC.h"
#import "OrderedDictionary.h"
#import "Apiary.h"


@interface DevicesVC ()

@property (strong, nonatomic)   OrderedDictionary *discoveredPeripherals;
@property (strong, nonatomic)   CLLocation *currentLocation;
@property (strong, nonatomic)   Apiary *currentApiary;
@property (strong, nonatomic)   NSMutableArray *apiaries;

@end

@implementation DevicesVC

@synthesize blueToothMGR;
@synthesize discoveredPeripherals;
@synthesize currentLocation;
@synthesize currentApiary;
@synthesize apiaries;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        discoveredPeripherals = [[OrderedDictionary alloc] init];
        currentLocation = nil;
        currentApiary = nil;
        NSData *apiariesData = [NSKeyedUnarchiver unarchiveObjectWithFile:APIARIES_ARCHIVE];
        if (apiariesData) {
            apiaries = [NSKeyedUnarchiver unarchiveObjectWithData:apiariesData];
        } else {
            apiaries = [[NSMutableArray alloc] init];
            [self updateApiaries];
        }
    }
    return self;
}

- (void) updateApiaries {
    NSData *apiariesData = [NSKeyedArchiver
                            archivedDataWithRootObject:apiaries];
    if (![NSKeyedArchiver archiveRootObject:apiariesData
                                     toFile:APIARIES_ARCHIVE])
        NSLog(@"apiary save failed");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Devices";
    
    blueToothMGR.delegate = self;
    [locationMGR initLocationServices];
    [locationMGR awaitLocationData:self];
}

- (void) locationDataAvailable: (CLLocation *)location {
    if (location == nil) {  // no location data at this time
        if (locationMGR.locationDenied) {  // never available
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location data disabled"
                                                                           message:@"This app requires it"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction
                                            actionWithTitle:@"Enable and try again"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {}
                                            ];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        return;
    }
    currentLocation = location;
    [blueToothMGR startScan];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setOpaque:YES];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.toolbar.backgroundColor = [UIColor lightGrayColor];
    self.navigationController.toolbar.opaque = YES;
    self.navigationController.toolbar.translucent = NO;
    self.navigationController.toolbarHidden = NO;
    
//    SET_VIEW_WIDTH(iCloudHeaderView, self.view.frame.size.width);
//    SET_VIEW_WIDTH(localHeaderView, self.view.frame.size.width);
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void) newData: (BMData *)data {
    NSString *internalName = [data internalName];
    
    if ([discoveredPeripherals objectForKey:internalName]) {
        NSLog(@"Duplicate, ignoring: %@", internalName);
        return;
    }
    [discoveredPeripherals addObject:data withKey:internalName];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#ifdef notdef
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [discoveredPeripherals count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case EnvelopeInCloudSection:
            return iCloudHeaderView;
        case EnvelopeInLocalSection:
            return localHeaderView;
        default:
            return nil;   // inconceivable
    }
}
#endif

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [discoveredPeripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DeviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
#ifdef notyet                
    cell.textLabel.text = localTitle;
            cell.imageView.backgroundColor = [UIColor yellowColor];
                 cell.userInteractionEnabled = YES;
                cell.accessoryView = nil;
                UIActivityIndicatorView *busyLoading = [[UIActivityIndicatorView alloc]
                                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                CGRect f = cell.frame;
                f.size.width = f.size.height;
                f.origin.x = cell.frame.size.width - f.size.width;
                busyLoading.frame = f;
                busyLoading.hidesWhenStopped = YES;
                cell.accessoryView = busyLoading;
                return cell;
#endif

    BMData *d = [discoveredPeripherals
                     objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%20@  %3@ %3.0d%%  %3d°  %2d%%  %@",
                           [discoveredPeripherals keyAtIndex:indexPath.row],
                           d.rssi,
                           d.battery,
                           d.temperature,
                           d.humidity,
                           [d isScale] ? @"Scale" : @"Sensor"];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    cell.accessoryView = nil;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath {
    NSLog(@"move from %ld.%ld to %ld.%ld",
          (long)fromIndexPath.section, (long)fromIndexPath.row,
          (long)toIndexPath.section, (long)toIndexPath.row);
    
#ifdef notyet
    switch (toIndexPath.section) {
        case EnvelopeInLocalSection:
            [localEnvelopes removeObjectAtIndex:fromIndexPath.row];
            [localEnvelopes insertObject:e atIndex:toIndexPath.row];
            break;
        case EnvelopeInCloudSection:
            [self moveToCloud:e.path];
            [localEnvelopes removeObjectAtIndex:fromIndexPath.row];
            // XXXX delete this row
            // XXXX            [iCloudEnvelopes insertObject:e atIndex:toIndexPath.row];
            break;
    }
#endif
}


@end
