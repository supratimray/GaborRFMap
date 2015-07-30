/*
GRFStimuli.h
*/

#import "GRF.h"
#import "GRFMapStimTable.h"
#import "GRFSoundObjects.h"
#import "GRFImageStim.h"

@interface GRFStimuli : NSObject {

	BOOL				 	abortStimuli;
	DisplayParam			display;
	long					durationMS;
	float					fixSizePix;
	LLFixTarget				*fixSpot;
	BOOL					fixSpotOn;
	NSArray					*fixTargets;
	NSArray					*gabors;
	NSMutableArray			*mapStimList0;
	NSMutableArray			*mapStimList1;
    NSMutableArray          *mapStimImage;
    NSBitmapImageRep	    *bmpRep0;

	LLIntervalMonitor 		*monitor;
	short					selectTable[kMaxOriChanges];
	long					targetOnFrame;
	NSMutableArray			*taskStimList;
	BOOL					stimulusOn;
	BOOL					targetPresented;
    TrialDesc               trial;
    LLFixTarget				*targetSpot;
//	LLGabor 				*taskGabor;
    LLPlaid                 *plaid;
    GRFImageStim            *imageStim;
    GRFSoundObjects         *player;
}

- (void)doFixSettings;
- (void)doGabor0Settings;
- (void)presentStimSequence;
- (void)dumpStimList;
- (void)erase;
- (LLGabor *)mappingGabor0;
- (LLGabor *)mappingGabor1;
- (LLGabor *)taskGabor;
- (LLGabor *)initGabor:(BOOL)bindTemporalFreq;
- (LLPlaid *)initPlaid:(BOOL)bindTemporalFreq;
- (void)loadGabor:(LLGabor *)gabor withStimDesc:(StimDesc *)pSD;
- (void)loadImage:(StimDesc *)pSD;
- (void)loadImageFromBitmap:(StimDesc *)pSD bitmapFile:(NSBitmapImageRep *)bmp;
- (void)loadPlaid:(LLPlaid *)plaid withStimDesc0:(StimDesc *)pSD0 withStimDesc1:(StimDesc *)pSD1;
- (void)makeStimLists:(TrialDesc *)pTrial;
- (void)clearStimLists:(TrialDesc *)pTrial;
- (LLIntervalMonitor *)monitor;
- (void)setFixSpot:(BOOL)state;
- (void)shuffleStimListFrom:(short)start count:(short)count;
- (void)startStimSequence;
- (BOOL)stimulusOn;
- (void)stopAllStimuli;
- (void)tallyStimLists:(long)count;
- (long)targetOnFrame;
- (BOOL)targetPresented;

@end
