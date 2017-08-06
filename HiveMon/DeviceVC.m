//
//  DeviceVC.m
//  HiveMon
//
//  Created by William Cheswick on 8/4/17.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#import "DeviceVC.h"
#import "Defines.h"

@interface DeviceVC ()

@property (nonatomic, strong)   Device *device;
@property (nonatomic, strong)   UIView *containerView;

@property (nonatomic, strong)   UILabel *statusLabel;
@property (nonatomic, strong)   UILabel *deviceStatus;
@property (nonatomic, strong)   UILabel *apiaryLabel;
@property (nonatomic, strong)   UITextField *apiaryText;
@property (nonatomic, strong)   UILabel *hiveLabel;
@property (nonatomic, strong)   UITextField *hiveText;
@property (nonatomic, strong)   UILabel *nameLabel;
@property (nonatomic, strong)   UITextField *nameText;
@property (nonatomic, strong)   UILabel *locationLabel;
@property (nonatomic, strong)   UITextField *locationText;


@end

@implementation DeviceVC

@synthesize device;
@synthesize containerView;
@synthesize statusLabel, deviceStatus;
@synthesize apiaryLabel, apiaryText;
@synthesize hiveLabel, hiveText;
@synthesize nameLabel, nameText;
@synthesize locationLabel, locationText;

- (id)initWithDevice:(Device *)d {
    self = [super init];
    if (self) {
        device = d;
    }
    return self;
}

#define FONT    [UIFont boldSystemFontOfSize:18]

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = device.name;
    
    containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:containerView];
    self.view.backgroundColor = [UIColor whiteColor];

    statusLabel = [[UILabel alloc] init];
    statusLabel.text = @"Status:";
    statusLabel.font = FONT;
    [containerView addSubview:statusLabel];
    deviceStatus = [[UILabel alloc] init];
    deviceStatus.font = FONT;
    [containerView addSubview:deviceStatus];
    
    apiaryLabel = [[UILabel alloc] init];
    apiaryLabel.text = @"Apiary:";
    apiaryLabel.font = FONT;
    [containerView addSubview:apiaryLabel];
    apiaryText = [[UITextField alloc] init];
    apiaryText.font = FONT;
    [containerView addSubview:apiaryText];
    
    hiveLabel = [[UILabel alloc] init];
    hiveLabel.text = @"Hive:";
    hiveLabel.font = FONT;
    [containerView addSubview:hiveLabel];
    hiveText = [[UITextField alloc] init];
    hiveText.font = FONT;
    [containerView addSubview:hiveText];
    
    nameLabel = [[UILabel alloc] init];
    nameLabel.text = @"Name:";
    nameLabel.font = FONT;
    [containerView addSubview:nameLabel];
    nameText = [[UITextField alloc] init];
    nameText.font = FONT;
    [containerView addSubview:nameText];
}

#define VSEP    9
#define LABELW  100

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect f = self.view.frame;
    f.size.width = 320;
    f.origin.x = (self.view.frame.size.width - f.size.width)/2.0;
    f.origin.y = 20;
    f.size.height = self.view.frame.size.height;
    containerView.frame = f;
    
    f.origin.x = 0;
    f.origin.y = 0;
    f.size.height = 24;
    f.size.width = LABELW;
    statusLabel.frame = f;
    f.origin.x = RIGHT(f);
    f.size.width = containerView.frame.size.width - f.origin.x;
    deviceStatus.frame = f;
    deviceStatus.text = [device statusString];
    
    f = statusLabel.frame;
    f.origin.y = BELOW(statusLabel.frame) + VSEP;
    apiaryLabel.frame = f;
    f = deviceStatus.frame;
    f.origin.y = apiaryLabel.frame.origin.y;
    apiaryText.frame = f;
    apiaryText.text = device.apiaryName;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    f = apiaryLabel.frame;
    f.origin.y = BELOW(apiaryLabel.frame) + VSEP;
    hiveLabel.frame = f;
    f = apiaryText.frame;
    f.origin.y = hiveLabel.frame.origin.y;
    hiveText.frame = f;
    hiveText.text = device.hiveName;
    
    f = hiveLabel.frame;
    f.origin.y = BELOW(hiveLabel.frame) + VSEP;
    nameLabel.frame = f;
    f = hiveText.frame;
    f.origin.y = nameLabel.frame.origin.y;
    nameText.frame = f;
    nameText.text = device.displayLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
