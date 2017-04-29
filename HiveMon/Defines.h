//
//  Defines.h
//  HiveMon
//
//  Created by ches on 17/4/24.
//  Copyright © 2017 Cheswick.com. All rights reserved.
//

#ifndef Defines_h
#define Defines_h


#define kBlueToothRestoreKey    @"BlueToothRestoreKey"

#define APIARIES_ARCHIVE        @"./Apiaries"
#define DEVICES_ARCHIVE         @"./Devices"
#define OBSERVATIONS_LOG        @"./Observations.log"

#define USED(x) ((void)(x))

// view tools

#define BELOW(r)    ((r).origin.y + (r).size.height)
#define RIGHT(r)    ((r).origin.x + (r).size.width)

#define SET_VIEW_X(v,nx) {CGRect f = (v).frame; f.origin.x = (nx); (v).frame = f;}
#define SET_VIEW_Y(v,ny) {CGRect f = (v).frame; f.origin.y = (ny); (v).frame = f;}

#define SET_VIEW_WIDTH(v,w)     {CGRect f = (v).frame; f.size.width = (w); (v).frame = f;}
#define SET_VIEW_HEIGHT(v,h)    {CGRect f = (v).frame; f.size.height = (h); (v).frame = f;}

#define CENTER_VIEW(cv, v)  {CGRect f = (cv).frame; \
f.origin.x = ((v).frame.size.width - f.size.width)/2.0; \
(cv).frame = f;}


#endif /* Defines_h */
