//
//  IMSLifeLog.h
//  Pods
//
//  Created by Hager Hu on 12/01/2018.
//

#ifndef IMSLifeLog_h
#define IMSLifeLog_h

#import <IMSLog/IMSLog.h>

#define LOGTAG_LIFE @"IMSLife"

#define IMSLifeLogError(frmt, ...)       IMSLogError(LOGTAG_LIFE, frmt, ##__VA_ARGS__)
#define IMSLifeLogWarn(frmt, ...)        IMSLogWarn(LOGTAG_LIFE, frmt, ##__VA_ARGS__)
#define IMSLifeLogInfo(frmt, ...)        IMSLogInfo(LOGTAG_LIFE, frmt, ##__VA_ARGS__)
#define IMSLifeLogDebug(frmt, ...)       IMSLogDebug(LOGTAG_LIFE, frmt, ##__VA_ARGS__)
#define IMSLifeLogVerbose(frmt, ...)     IMSLogVerbose(LOGTAG_LIFE, frmt, ##__VA_ARGS__)

#endif /* IMSLifeLog_h */
