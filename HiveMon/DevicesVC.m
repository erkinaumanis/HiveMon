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

#import <unistd.h>

@interface DevicesVC ()

@property (strong, nonatomic)   BlueToothMGR *blueToothMGR;
@property (strong, nonatomic)   LocationMGR *locationMGR;
@property (strong, nonatomic)   CLLocation *currentLocation;
@property (strong, nonatomic)   Apiary *currentApiary;
@property (strong, nonatomic)   NSTimer *scanTimer;
@property (strong, nonatomic)   NSTimer *idleTimer;
@property (strong, nonatomic)   Log *log;
@property (strong, nonatomic)   UIView *statusView;
@property (strong, nonatomic)   UILabel *statusLabel;
@property (strong, nonatomic)   UIActivityIndicatorView *activityView;
@property (assign)              BOOL inBackground;
@property (nonatomic, strong)   NSThread *backgroundThread;
@property (assign)              NSTimeInterval backFireInterval;


@end

@implementation DevicesVC

@synthesize locationMGR;
@synthesize blueToothMGR;
@synthesize currentLocation;
@synthesize currentApiary;
@synthesize apiaries;
@synthesize devices;
@synthesize log;
@synthesize scanTimer, idleTimer;
@synthesize statusView, statusLabel, activityView;
@synthesize inBackground, backgroundThread;
@synthesize backFireInterval;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        currentLocation = nil;
        scanTimer = idleTimer = nil;
        log = [[Log alloc] init];
        inBackground = NO;
        backgroundThread = nil;
        
#ifdef CLEAR_FILES
        [[NSFileManager defaultManager] removeItemAtPath:APIARIES_ARCHIVE error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:DEVICES_ARCHIVE error:nil];
#endif
        // fetch apiary data
        currentApiary = nil;
        NSData *apiariesData = [NSKeyedUnarchiver unarchiveObjectWithFile:APIARIES_ARCHIVE];
        if (apiariesData) {
            apiaries = [NSKeyedUnarchiver unarchiveObjectWithData:apiariesData];
        } else {
            apiaries = [[NSMutableArray alloc] init];
            NSLog(@"current directory is %@", [[NSFileManager defaultManager]currentDirectoryPath]);
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

#define STATUS_VIEW_W    110
#define STATUS_WIDTH    70

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Devices";
    
    CGRect f = self.navigationController.navigationBar.frame;
    f.size.width = STATUS_VIEW_W;
    statusView = [[UIView alloc] initWithFrame:f];
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.frame = CGRectMake(-20, 0,
                                    f.size.height,  // square field
                                    f.size.height);
    activityView.hidesWhenStopped = YES;
    activityView.backgroundColor = [UIColor clearColor];
    [statusView addSubview:activityView];
    
    statusLabel = [[UILabel alloc] initWithFrame:
                   CGRectMake(activityView.frame.origin.x + activityView.frame.size.width - 5, 10,
                              statusView.frame.size.width - activityView.frame.size.width,
                              f.size.height-10)];
    statusLabel.text = @"";
    statusLabel.font = [UIFont systemFontOfSize:12];
    [statusView addSubview:statusLabel];
   
    UIBarButtonItem *statusBarItem = [[UIBarButtonItem alloc] initWithCustomView:statusView];
    self.navigationItem.leftBarButtonItem = statusBarItem;

    blueToothMGR.blueDelegate = self;
    [self startPoll];
}

//908 534 1486 shell

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

- (void) startPoll {
    if (!inBackground) {
        [activityView startAnimating];
        statusLabel.text = @"scanning";
        [statusLabel setNeedsDisplay];
    }
    [locationMGR initLocationServices];
    [locationMGR awaitLocationData:self];
}

- (void) locationDataAvailable: (CLLocation *)location {
    if (location == nil) {  // no location data at this time
        if (locationMGR.locationDenied) {  // never available
            NSLog(@"Location data never available");
            if (!inBackground) {
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
        }
        return;
    }
    currentLocation = location;
    [self startApiaryScan];
}

- (void) startApiaryScan {
    if ([self findCurrentApiary]) {
        NSLog(@"found current apiary: %@", currentApiary.name);
        self.title = [NSString stringWithFormat:@"Apiary: %@", currentApiary.name];
        [self startBlueToothScan];
    } else {    // Name the apiary, then start bluetooth scan
        if (inBackground) {
            NSLog(@"XXXX apiary assignment in background, help");
        } else {
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
            
            UIPickerView *pickApiaryView = [[UIPickerView alloc] init];
            pickApiaryView.dataSource = self;
            pickApiaryView.delegate = self;
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.inputView = pickApiaryView;
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
                                            self.title = [NSString stringWithFormat:@"Apiary: %@", currentApiary.name];
                                            [self startBlueToothScan];
                                        }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [apiaries count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    Apiary *a = apiaries[component];
    return a.name;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    Apiary *a = apiaries[component];
    NSLog(@"picked %@", a.name);
}


#define SCAN_DURATION   60      // seconds
#define IDLE_DURATION   120     // seconds.  Will be 3600

- (void) goingToBackground {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (scanTimer) {    // we are still scanning, finish it now
        NSLog(@"  scan aborted");
        [self finishScan: scanTimer];
        backFireInterval = IDLE_DURATION;
    } else {    // we are idled, disable the timer
        NSDate *fireTime = idleTimer.fireDate;
        backFireInterval = [fireTime timeIntervalSinceDate:[NSDate date]];
        NSLog(@"going into background, next fire interval: %f", backFireInterval);
    }
    [scanTimer invalidate]; // switch to background timer
}

- (void) doBackgroundIdleCycles {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    inBackground = YES;
    
    backgroundThread = [NSThread currentThread];
//    while (TRUE) {
        backFireInterval = 3;
//        NSLog(@"Thread sleeping for %f....", backFireInterval);
//        [NSThread sleepForTimeInterval:backFireInterval];
//       sleep(backFireInterval);
        NSLog(@"... done sleeping");
        backFireInterval = IDLE_DURATION;
        [self startBlueToothScan];
 //   }
}

- (void) leftBackground {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    inBackground = NO;
}

- (void) startBlueToothScan {
    [log logIPhoneStatus];
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:SCAN_DURATION
                                     target:self
                                           selector:@selector(finishScan:)
                                   userInfo:nil
                                    repeats:NO];
    [blueToothMGR startScan];
}

- (void) bluetoothError: (NSString *)err {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Bluetooth error"
                                                                   message:err
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {}
                                    ];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) finishScan:(NSTimer *)t {
    if (DEBUG)
        NSLog(@"Finished scan");
    [t invalidate];
    scanTimer = nil;
    
    statusLabel.text = @"";
    if (inBackground) {
        return;
    }
    
    [statusLabel setNeedsDisplay];
    [activityView stopAnimating];
    [locationMGR stopUpdatingLocation];
    [blueToothMGR stopScan];
    
#ifdef OLD
    idleTimer = [NSTimer scheduledTimerWithTimeInterval:IDLE_DURATION
                                             target:self
                                           selector:@selector(startBlueToothScan)
                                           userInfo:nil
                                            repeats:NO];
#endif
}

// find the closest apiary to our current location.  If it isn't close enough,
// set it to the best guess, and return NO.

#define APIARY_CLOSE_ENOUGH     15  // meters

- (BOOL) findCurrentApiary {
    CLLocationDistance minDistance = DBL_MAX;
    currentApiary = nil;
    
    for (int i=0; i<[apiaries count]; i++) {
        Apiary *a = apiaries[i];
        
        CLLocationDistance distance = [currentLocation distanceFromLocation:a.location];
        NSLog(@"  distance to %@: %.2f", a.name, distance);
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

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

// We have fresh data about a device

- (void) newData: (BMData *)data {
    NSString *internalName = data.internalName;
    Device *device = [devices objectForKey:internalName];
    if (!device) {   // create new device
        device = [data makeNewDevice];
        device.name = data.internalName;
        if (DEBUG)
            NSLog(@"Creating device: %@", device.name);
        [devices addObject:device withKey:internalName];
    }
    
    device.apiaryName = currentApiary.name;
    device.lastObservation = [data makeObservation];
    device.peripheral = data.peripheral;
    NSString *obsLogEntry = [device.lastObservation formatForLogging: device.name];
    [log add:obsLogEntry];
    [self updateDevices];
    if (!inBackground) {
        [self.tableView reloadData];
    }
}

- (void) updatePeripheralStatus {
    if (!inBackground) {
        [self.tableView reloadData];
    }
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
        NSString *stateChar;
        switch (device.peripheral.state) {
            case CBPeripheralStateConnected:
                stateChar = @"✓";
                break;
            case CBPeripheralStateConnecting:
                stateChar = @"+";
                break;
            case CBPeripheralStateDisconnected:
                stateChar = @"×";
                break;
            case CBPeripheralStateDisconnecting:
                stateChar = @"-";
                break;
        }
        label = [NSString stringWithFormat:@"%@%@ %3@ 🔋%.0d%% %3d°  %2d%%",
                           label, stateChar,
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
