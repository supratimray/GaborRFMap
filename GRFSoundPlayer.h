//
//  GRFSoundPlayer.h
//  GaborRFMap
//
//  Created by Murty V P S Dinavahi on 03/05/15.
//
//

#import <Foundation/Foundation.h>

// Define the class
@class GRFSoundPlayer;

// Define delegate to the class and its associated methods
@protocol GRFSoundPlayerDelegate <NSObject>
-(void)playerDidFinishJob;
-(void)stopPlaying;
-(void)startPlaying;
@end

@interface GRFSoundPlayer : NSObject <GRFSoundPlayerDelegate>

// Define the instance variables associated with the class
{
//    GRFSoundObjects *soundObject;
    NSArray         *soundDetails;
    NSString        *soundPath;
    NSString        *soundFile;
    NSString        *soundName;
    NSSound         *player;
    float            stimVolume;
    id<GRFSoundPlayerDelegate> delegate; // Now, the same class can act as its own delegate
}

// Define class specific methods
-(void)playerDeactivate;
-(void)stopPlay;
-(void)startPlay;

// Assign properties of the delegate.
@property (nonatomic,assign) id<GRFSoundPlayerDelegate> delegate;

@end
