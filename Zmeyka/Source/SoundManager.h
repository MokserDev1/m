//
//  SoundManager.h
//  Zmeyka
//

#import <Foundation/Foundation.h>

@interface SoundManager : NSObject

+ (SoundManager *)sharedManager;

@property (nonatomic, assign) BOOL soundEnabled;

- (void)playEatSound;
- (void)playGameOverSound;
- (void)playButtonSound;
- (void)toggleSound;

@end

