/*
 *  GRF.h
 *  GaborRFMap
 *
 *  Copyright (c) 2006. All rights reserved.
 *
 */

@class GRFDigitalOut;

#define kPI          		(atan(1) * 4)
#define k2PI         		(atan(1) * 4 * 2)
#define kRadiansPerDeg      (kPI / 180.0)
#define kDegPerRadian		(180.0 / kPI)

// The following should be changed to be unique for each application

enum {kTaskGabor = 0, kMapGabor0, kMapGabor1, kGabors};
enum {kAttend0 = 0, kAttend1, kLocations};
enum {kLinear = 0, kLogarithmic};
enum {kUniform = 0, kExponential};
enum {kAuto = 0, kManual};
enum {kRewardFixed = 0, kRewardVariable};
enum {kNullStim = 0, kValidStim, kTargetStim, kFrontPadding, kBackPadding};
enum {kMyEOTCorrect = 0, kMyEOTMissed, kMyEOTEarlyToValid, kMyEOTEarlyToInvalid, kMyEOTBroke, 
				kMyEOTIgnored, kMyEOTQuit, kMyEOTTypes};
enum {  kTrialStartDigitOutCode = 0x0010,
        kFixateDigitOutCode = 0x0020,
        kStimulusOnDigitOutCode = 0x0030,
        kStimulusOffDigitOutCode = 0x0040,
        kTargetOnDigitOutCode = 0x0050,
        kSaccadeDigitOutCode = 0x0060,
        kTrialEndDigitOutCode = 0x0070};

#define	kSleepInMicrosec	5000
#define	kMaxOriChanges      12
#define kMaxMapValues       6

typedef struct {
	long	levels;				// number of active stimulus levels
	float   maxValue;			// maximum stimulus value (i.e., direction change in degree)
	float   minValue;			// minimum stimulus value
} StimParams;

typedef struct StimDesc {
	long	gaborIndex;
	long	sequenceIndex;
	long	stimOnFrame;
	long	stimOffFrame;
	short	stimType;
	float	orientationChangeDeg;
	float	contrastPC;
	float	azimuthDeg;
	float	elevationDeg;
	float	sigmaDeg;
	float	radiusDeg;
	float	spatialFreqCPD;
	float	directionDeg;
    float   temporalFreqHz;
	long	azimuthIndex;
	long	elevationIndex;
	long	sigmaIndex;
	long	spatialFreqIndex;
	long	directionIndex;
	long	contrastIndex;
    long    temporalFreqIndex;
    long   temporalModulation;
} StimDesc;

typedef struct TrialDesc {
	BOOL	instructTrial;
	BOOL	catchTrial;
	long	numStim;
	long	targetIndex;				// index (count) of target in stimulus sequence
	long	targetOnTimeMS;				// time from first stimulus (start of stimlist) to the target
	long	orientationChangeIndex;
	float	orientationChangeDeg;
} TrialDesc;

typedef struct BlockStatus {
	long	changes;
	float	orientationChangeDeg[kMaxOriChanges];
	float	validReps[kMaxOriChanges];
	long	validRepsDone[kMaxOriChanges];
	float	invalidReps[kMaxOriChanges];
	long	invalidRepsDone[kMaxOriChanges];
	long	instructDone;			// number of instruction trials done
	long	instructTrials;			// number of instruction trials to be done
	long	sidesDone;				// number of sides (out of kLocations) done
	long	blockLimit;				// number of blocks before stopping
	long	blocksDone;				// number of blocks completed
} BlockStatus;

typedef struct MappingBlockStatus {
	long	stimDone;				// number of stim done in this block
	long	stimLimit;				// number of stim in block
	long	blocksDone;				// number of blocks completed
	long	blockLimit;				// number of blocks before stopping
} MappingBlockStatus;

typedef struct  MapParams {
    long    n;                      // number of different conditions
    float   minValue;               // smallest value tested
    float   maxValue;               // largest value tested
} MapParams;

typedef struct  MapSettings {
    MapParams    azimuthDeg;
    MapParams    elevationDeg;
    MapParams    directionDeg;
    MapParams    spatialFreqCPD;
    MapParams    sigmaDeg;
    MapParams    contrastPC;
    MapParams    temporalFreqHz;
} MapSettings;

// put parameters set in the behavior controller

typedef struct BehaviorSetting {
	long	blocks;
	long	intertrialMS;
	long	acquireMS;
	long	fixGraceMS;
	long	fixateMS;
	long	fixateJitterPC;
	long	responseTimeMS;
	long	tooFastMS;
	long	minSaccadeDurMS;
	long	breakPunishMS;
	long	rewardSchedule;
	long	rewardMS;
	float	fixWinWidthDeg;
	float	respWinWidthDeg;
} BehaviorSetting;

// put parameters set in the Stimulus controller

typedef struct StimSetting {
	long	stimDurationMS;
	long	stimDurJitterPC;
	long	interStimMS;
	long	interStimJitterPC;
	long	stimLeadMS;
	float	stimSpeedHz;
	long	stimDistribution;
	long	minTargetOnTimeMS;
	long	meanTargetOnTimeMS;
	long	maxTargetOnTimeMS;
	float	eccentricityDeg;
	float	polarAngleDeg;
	float	driftDirectionDeg;
	float	contrastPC;
	short	numberOfSurrounds;
	long	changeScale;
	long	orientationChanges;
	float	maxChangeDeg;
	float	minChangeDeg;
	long	changeRemains;
} StimSetting;


#ifndef	NoGlobals

// Behavior settings dialog

extern NSString *GRFAcquireMSKey;
extern NSString *GRFAlphaTargetDetectionTaskKey;
extern NSString *GRFBlockLimitKey;
extern NSString *GRFBreakPunishMSKey;
extern NSString *GRFCatchTrialPCKey;
extern NSString *GRFCatchTrialMaxPCKey;
extern NSString *GRFCueMSKey;
//extern NSString *GRFChageScaleKey;
extern NSString *GRFDoSoundsKey;
extern NSString *GRFFixateKey;
extern NSString *GRFFixateMSKey;
extern NSString *GRFFixateOnlyKey;
extern NSString *GRFFixGraceMSKey;
extern NSString *GRFFixJitterPCKey;
extern NSString *GRFFixWindowWidthDegKey;
extern NSString *GRFIntertrialMSKey;
extern NSString *GRFInstructionTrialsKey;
extern NSString *GRFInvalidRewardFactorKey;
extern NSString *GRFMaxTargetMSKey;
extern NSString *GRFMinTargetMSKey;
extern NSString *GRFMeanTargetMSKey;
extern NSString *GRFNontargetContrastPCKey;
//extern NSString *GRFNumInstructTrialsKey;
extern NSString *GRFRandTaskGaborDirectionKey;
extern NSString *GRFRespSpotSizeDegKey;
extern NSString *GRFRespTimeMSKey;
extern NSString *GRFRespWindowWidthDegKey;
extern NSString *GRFRewardMSKey;
extern NSString *GRFMinRewardMSKey;
extern NSString *GRFRewardScheduleKey;
extern NSString *GRFSaccadeTimeMSKey;
extern NSString *GRFStimDistributionKey;
extern NSString *GRFStimRepsPerBlockKey;
extern NSString *GRFTaskStatus;
extern NSString *GRFTooFastMSKey;

// Stimulus settings dialog

extern NSString *GRFInterstimMSKey;
extern NSString *GRFMapInterstimDurationMSKey;
extern NSString *GRFInterstimJitterPCKey;
extern NSString *GRFStimDurationMSKey;
extern NSString *GRFMapStimDurationMSKey;
extern NSString *GRFMappingBlocksKey;
extern NSString *GRFStimJitterPCKey;
extern NSString *GRFChangeScaleKey;
extern NSString *GRFOrientationChangesKey;
extern NSString *GRFMaxDirChangeDegKey;
extern NSString *GRFMinDirChangeDegKey;
extern NSString *GRFChangeRemainKey;
extern NSString *GRFChangeArrayKey;
extern NSString *GRFTargetAlphaKey;
extern NSString *GRFTargetRadiusKey;

extern NSString *GRFMapStimContrastPCKey;
extern NSString *GRFMapStimRadiusSigmaRatioKey;

extern NSString *GRFKdlPhiDegKey;
extern NSString *GRFKdlThetaDegKey;
extern NSString *GRFRadiusDegKey;
extern NSString *GRFSeparationDegKey;
extern NSString *GRFSpatialFreqCPDKey;
extern NSString *GRFSpatialPhaseDegKey;
extern NSString *GRFTemporalFreqHzKey;

extern NSString *GRFChangeKey;
extern NSString *GRFInvalidRepsKey;
extern NSString *GRFValidRepsKey;

extern NSString *GRFHideLeftKey;
extern NSString *GRFHideRightKey;
extern NSString *GRFHideLeftDigitalKey;
extern NSString *GRFHideRightDigitalKey;
extern NSString *GRFConvertToGratingKey;
extern NSString *GRFUseSingleITC18Key;

extern NSString *GRFHideTaskGaborKey;
extern NSString *GRFIncludeCatchTrialsinDoneListKey;
extern NSString *GRFMapTemporalModulationKey;

extern NSString *GRFConvertToPlaidKey;
extern NSString *GRFPlayAudStimKey;

long		argRand;

#import "GRFStimuli.h"

BlockStatus						blockStatus;
BehaviorSetting					behaviorSetting;
BOOL							brokeDuringStim;
MappingBlockStatus				mappingBlockStatus;
BOOL							resetFlag;
LLScheduleController			*scheduler;
GRFStimuli						*stimuli;
GRFDigitalOut					*digitalOut;
long                            trialCounter;

#endif

LLTaskPlugIn					*task;


