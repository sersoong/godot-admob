#import "AdmobRewarded.h"
#import <GoogleMobileAds/GADRewardBasedVideoAd.h>
#import <GoogleMobileAds/GADAdReward.h>
#include "reference.h"


@implementation AdmobRewarded


- (void)initialize:(BOOL)is_real: (int)instance_id {
    isReal = is_real;
    initialized = true;
    instanceId = instance_id;
    rootController = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
}

- (void) loadRewardedVideo:(NSString*) rewardedId {
    NSLog(@"Calling loadRewardedVideo");
    //init
    if (!initialized) {
        return;
    }
    
    if(!isReal) {
        [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request]
                                               withAdUnitID:@"ca-app-pub-3940256099942544/1712485313"];
    }
    else {
        [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request] withAdUnitID:rewardedId];
    }
    
    
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    
}

- (void) showRewardedVideo {
    NSLog(@"Calling showRewardedVideo");
    //init
    if (!initialized) {
        return;
    }
    
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:rootController];
    }
    
}


- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward {
    NSString *rewardMessage = [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf",
                                reward.type, [reward.amount doubleValue]];
    NSLog(rewardMessage);
                                        
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_rewarded", [reward.type UTF8String], reward.amount.doubleValue);
                                        
}
         
- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is received.");
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_rewarded_video_ad_loaded");
}
         
- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Opened reward based video ad.");
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_rewarded_video_ad_opened");
}
         
- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad started playing.");
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_rewarded_video_started");
}
         
- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is closed.");
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_rewarded_video_ad_closed");
}
         
- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad will leave application.");
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_rewarded_video_ad_left_application");
}
         
- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error {
    NSLog(@"Reward based video ad failed to load: %@ ", error.localizedDescription);
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_rewarded_video_ad_failed_to_load", error.code);
}

@end
