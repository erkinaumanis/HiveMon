//
//  DevicesVC.m
//  HiveMon
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import "Defines.h"
#import "DevicesVC.h"
#import "Device.h"
#import "OrderedDictionary.h"
#import "Apiary.h"


@interface DevicesVC ()

@property (strong, nonatomic)   BlueToothMGR *blueToothMGR;
@property (strong, nonatomic)   LocationMGR *locationMGR;
@property (strong, nonatomic)   CLLocation *currentLocation;
@property (strong, nonatomic)   Apiary *currentApiary;

@end

@implementation DevicesVC

@synthesize locationMGR;
@synthesize blueToothMGR;
@synthesize currentLocation;
@synthesize currentApiary;
@synthesize apiaries;
@synthesize devices;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        currentLocation = nil;
        
        // XXXX debug:
//        [[NSFileManager defaultManager] removeItemAtPath:APIARIES_ARCHIVE error:nil];
//        [[NSFileManager defaultManager] removeItemAtPath:DEVICES_ARCHIVE error:nil];

        // fetch apiary data
        currentApiary = nil;
        NSData *apiariesData = [NSKeyedUnarchiver unarchiveObjectWithFile:APIARIES_ARCHIVE];
        if (apiariesData) {
            apiaries = [NSKeyedUnarchiver unarchiveObjectWithData:apiariesData];
        } else {
            apiaries = [[NSMutableArray alloc] init];
        }
        if ([apiaries count] == 0) {
            Apiary *da = [[Apiary alloc] init];
            [da makeDefaultApiary];
            [apiaries addObject:da];
            [self updateApiaries];
        }
        
        // fetch device data
        NSData *deviceData = [NSKeyedUnarchiver unarchiveObjectWithFile:DEVICES_ARCHIVE];
        if (deviceData) {
            devices = [NSKeyedUnarchiver unarchiveObjectWithData:deviceData];
        } else {
            devices = [[OrderedDictionary alloc] init];
            [self updateDevices];
        }
        
        // Start services
        blueToothMGR = [[BlueToothMGR alloc] init];
        locationMGR = [[LocationMGR alloc] init];
    }
    return self;
}

- (void) updateDevices {
    NSData *devicesData = [NSKeyedArchiver
                            archivedDataWithRootObject:devices];
    if (![NSKeyedArchiver archiveRootObject:devicesData
                                     toFile:DEVICES_ARCHIVE])
        NSLog(@"devices update failed");
}

- (void) updateApiaries {
    NSData *apiariesData = [NSKeyedArchiver
                            archivedDataWithRootObject:apiaries];
    if (![NSKeyedArchiver archiveRootObject:apiariesData
                                     toFile:APIARIES_ARCHIVE])
        NSLog(@"apiary update failed");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Devices";
    
    blueToothMGR.delegate = self;
    [self startPoll];
}

- (void) startPoll {
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
    [self startApiaryScan];
}

- (void) startApiaryScan {
    if ([self findCurrentApiary]) {
        NSLog(@"found current apiary: %@", currentApiary.name);
        [blueToothMGR startScan];
    } else {    // Name the apiary, then start bluetooth scan
        UIAlertController * alertController = [UIAlertController
                                               alertControllerWithTitle: @"Local apiary name"
                                               message: @"Enter name"
                                               preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = currentApiary.name;
            textField.textColor = [UIColor blueColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
        }];
        [alertController addAction:[UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action) {
                                        NSArray *textfields = alertController.textFields;
                                        UITextField *namefield = textfields[0];
                                        NSString *newName = namefield.text;
                                        currentApiary = nil;
                                        NSLog(@"apiary name is %@", newName);
                                        for (int i=0; i<[apiaries count]; i++) {
                                            Apiary *a = apiaries[i];
                                            if ([newName isEqualToString:a.name]) { // existing apiary
                                                currentApiary = a;
                                                break;
                                            }
                                        }
                                        if (!currentApiary) {   // Create a new apiary
                                            currentApiary = [[Apiary alloc] init];
                                            currentApiary.location = currentLocation;
                                            currentApiary.name = newName;
                                            currentApiary.hives = [[NSMutableArray alloc] init];
                                            [apiaries addObject:currentApiary];
                                            [self updateApiaries];
                                        }
                                        [blueToothMGR startScan];   // <--- important control code
                                    }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

// find the closest apiary to our current location.  If it isn't close enough,
// set it to the best guess, and return NO.

#define APIARY_CLOSE_ENOUGH     50  // meters

- (BOOL) findCurrentApiary {
    CLLocationDistance minDistance = DBL_MAX;
    currentApiary = nil;
    
    for (int i=0; i<[apiaries count]; i++) {
        Apiary *a = apiaries[i];
        
        CLLocationDistance distance = [currentLocation distanceFromLocation:a.location];
        NSLog(@"  distance = %.2f", distance);
        if (distance < minDistance) {
            minDistance = distance;
            currentApiary = a;
        }
    }
    if (currentApiary) {
        return minDistance <= APIARY_CLOSE_ENOUGH;
    } else
        return NO;
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

// We have fresh data about a device

- (void) newData: (BMData *)data {
    NSString *internalName = [data internalName];
    Device *device = [devices objectForKey:internalName];
    if (!device) {   // create new device
        NSLog(@"Creating device: %@", internalName);
        device = [[Device alloc] init];
        device.isScale = [data isScale];
        [devices addObject:device withKey:internalName];
        [self updateDevices];
    } else
        NSLog(@"Updating device: %@", internalName);
    device.lastObservation = [data makeObservation];
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
    return [devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DeviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    Device *device = [devices
                     objectAtIndex:indexPath.row];
    
    NSString *label = [NSString stringWithFormat:@"%@", [devices keyAtIndex:indexPath.row]];
    UIColor *color = [UIColor redColor];
    
    if (device.lastObservation) {  // we have current data for this device
        color = [UIColor blueColor];
        label = [NSString stringWithFormat:@"%@ %3@ 🔋%.0d%% %3d°  %2d%%",
                           label,
                           device.lastObservation.rssi,
                           device.lastObservation.battery,
                           device.lastObservation.temperature,
                           device.lastObservation.humidity];
        
        if (device.isScale)
            label =  [NSString stringWithFormat:@"%@  ⚖%.2f", label,
                      device.lastObservation.weight];
    }
    cell.textLabel.text = label;
    cell.textLabel.textColor = color;
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
