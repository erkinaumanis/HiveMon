//
//  Peripheral.m
//  HiveMon
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//
// A low power bluetooth device that we have discovered in our neighborhood

#import "Peripheral.h"

// From the supplied doc:

// broodminder stuff is at 14:
// 02 01 06 02 0a 03 18 ff 8d 02 2a 38 02 00 5a f2 00 30 5f 00 00 00 00 00 20 9f 0a 42 00 00 00 ae
// 1) Check for "Manufacturer Specific Data"
//         Bytes 6,7 = 0x18, 0xff
// 2) Check for IF, LLC as the manufacturer
//         Bytes 8,9 = 0x8d, 0x02
// 3) Bytes 10-29 are the data from the BroodMinder as outlined below.
//         deviceModelIFllc_1 = 2b (43d = scale)
//         DeviceVersionMinor_1 = 15 (21d)
//         DeviceVersionMajor_1  = 02 (FW 2.21)
//         Battery_1V2 = 2%
//         Elapsed_2V2 = 21 (33d)
//         Temperature_2V2 = 62d0
//         WeightL_2V2 = 7FFF
//         WeightR_2V2 = 8005
//         Humidity_1V2 = 37
//         UUID_3V2 = b5:30:07

// bytes in evt_le_meta_event

// bytes in evt_le_meta_event

// NB: iOS doesn't give us bytes 0--7, so this struct starts at 8,
// and this Broodminder test might accept something that isn't:

//  #define IS_BROODMINDER(info)    \
//      (((info)[6] == 0x18) && \
//      ((info)[7] == 0xff) && \
//      ((info)[8] == 0x8d) && \
//      ((info)[9] == 0x02))

typedef struct bm_adv_resp {
    uint8_t bm_man0;
    uint8_t bm_man1;
    uint8_t bm_model;
    uint8_t bm_devminor;
    uint8_t bm_devmajor;
    uint8_t bm_unused13;
    union {
        struct v1 { // I am told there are no more V1 devices extant
            uint8_t bm_battery;
            uint8_t bm_samples;
            uint8_t bm_samples_2;
            uint8_t bm_temp;
            uint8_t bm_temp_2;
            uint8_t bm_temp14d_ave;
            uint8_t bm_temp14d_min;
            uint8_t bm_temp14d_min_2;
            uint8_t bm_temp14d_max;
            uint8_t bm_temp14d_max_2;
            uint8_t bm_humidity;
            uint8_t bm_hum14d_ave;
            uint8_t bm_hum14d_min;
            uint8_t bm_hum14d_min_2;
            uint8_t bm_hum14d_max;
            uint8_t bm_hum14d_max_2;
        } v1;
        struct v2 {
            uint8_t bm_battery;
            uint8_t bm_samples;     // "elapsed"
            uint8_t bm_samples_2;
            uint8_t bm_temp;
            uint8_t bm_temp_2;
            uint8_t bm_unused19;
            uint8_t bm_weight_left;
            uint8_t bm_weight_left_2;
            uint8_t bm_weight_right;
            uint8_t bm_weight_right_2;
            uint8_t bm_humidity;
            u_char  bm_UUID[3];
        } v2;
    };
} bm_adv_resp;


#define USHORT(a)       ((uint16_t)(((a))) + (*(&(a)+1)<<8))

// Compute degrees F:

#define F(s)    (((double)(USHORT(s)) / (double)0x10000*165.0 - 40.0)*(9.0/5.0) + 32.0)

// values for bm_model:

#define BM_SENSOR       42
#define BM_SCALE        43

// magic to convert temperature field to degress F

inline int
bm_f(u_short tr) {
    double c = (double)tr / (double)0x10000 * 165.0 - 40.0;
    int f = c * (9.0/5.0) + 32.0;
    return f;
}


// similar magic for weights

inline double
bm_w(uint8_t *b) {
    return (*(b+1) * 256.0 + *b - 32767.0)/100.0;
}

@implementation Peripheral

@synthesize peripheral;
@synthesize advertisementData;
@synthesize rssi;

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (BOOL) isBroodMinder {
    NSData *manData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    if (!manData || manData.length < sizeof(bm_adv_resp))
        return NO;
    bm_adv_resp *buf = (bm_adv_resp *)manData.bytes;

    if (buf->bm_man0 != 0x8d || buf->bm_man1 != 0x02)
        return NO; // wrong manufacturer
    return YES;
}

- (NSString *) internalName {
    NSString *name = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if (!name) {
        name = peripheral.name;
        NSLog(@"Name missing, using: %@", name);
    }
    return name;
}

- (BOOL) isScale {
    NSData *manData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    bm_adv_resp *buf = (bm_adv_resp *)manData.bytes;
    if (buf->bm_model == BM_SCALE)
        return YES;
    else if (buf->bm_model == BM_SENSOR)
        return NO;

    printf("Unknown Broodminder device: 0x%.02    ",
           buf->bm_model & 0xff);
    return NO;
}

@end
