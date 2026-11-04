//
//  SoundManager.m
//  Zmeyka
//

#import "SoundManager.h"
#import <AudioToolbox/AudioToolbox.h>

#define SOUND_KEY @"Zmeyka_SoundEnabled"

@interface SoundManager () {
    SystemSoundID _eatSoundID;
    SystemSoundID _gameOverSoundID;
    SystemSoundID _buttonSoundID;
}
@end

@implementation SoundManager

+ (SoundManager *)sharedManager {
    static SoundManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SoundManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:SOUND_KEY] == nil) {
            _soundEnabled = YES;
            [defaults setBool:YES forKey:SOUND_KEY];
            [defaults synchronize];
        } else {
            _soundEnabled = [defaults boolForKey:SOUND_KEY];
        }
        
        [self loadSounds];
    }
    return self;
}

- (void)loadSounds {
    // Attempt to load wav files from main bundle if present
    NSString *eatPath = [[NSBundle mainBundle] pathForResource:@"eat" ofType:@"wav"];
    if (eatPath) {
        NSURL *eatURL = [NSURL fileURLWithPath:eatPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)eatURL, &_eatSoundID);
    } else {
        // Fallback standard system sound
        _eatSoundID = 1104; // Tock/Tap sound
    }
    
    NSString *goPath = [[NSBundle mainBundle] pathForResource:@"gameover" ofType:@"wav"];
    if (goPath) {
        NSURL *goURL = [NSURL fileURLWithPath:goPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)goURL, &_gameOverSoundID);
    } else {
        _gameOverSoundID = 1053; // Alert
    }
    
    NSString *btnPath = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"wav"];
    if (btnPath) {
        NSURL *btnURL = [NSURL fileURLWithPath:btnPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)btnURL, &_buttonSoundID);
    } else {
        _buttonSoundID = 1105;
    }
}

- (void)playEatSound {
    if (!self.soundEnabled) return;
    if (_eatSoundID) {
        AudioServicesPlaySystemSound(_eatSoundID);
    }
}

- (void)playGameOverSound {
    if (!self.soundEnabled) return;
    if (_gameOverSoundID) {
        AudioServicesPlaySystemSound(_gameOverSoundID);
    }
    // Also trigger subtle haptic vibration on iPhone
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)playButtonSound {
    if (!self.soundEnabled) return;
    if (_buttonSoundID) {
        AudioServicesPlaySystemSound(_buttonSoundID);
    }
}

- (void)toggleSound {
    self.soundEnabled = !self.soundEnabled;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.soundEnabled forKey:SOUND_KEY];
    [defaults synchronize];
}

@end

