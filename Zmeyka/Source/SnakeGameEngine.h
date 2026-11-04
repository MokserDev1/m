//
//  SnakeGameEngine.h
//  Zmeyka
//

#import <Foundation/Foundation.h>
#import "GameConstants.h"

typedef NS_ENUM(NSInteger, GameState) {
    GameStateReady,
    GameStateRunning,
    GameStatePaused,
    GameStateGameOver
};

@protocol SnakeGameEngineDelegate <NSObject>
@required
- (void)gameEngineDidUpdate;
- (void)gameEngineDidEatFoodWithScore:(NSInteger)score isNewHighScore:(BOOL)isNewHighScore;
- (void)gameEngineDidGameOverWithScore:(NSInteger)score isNewHighScore:(BOOL)isNewHighScore;
@end

@interface SnakeGameEngine : NSObject

@property (nonatomic, weak) id<SnakeGameEngineDelegate> delegate;
@property (nonatomic, readonly) GameState state;
@property (nonatomic, readonly) NSInteger score;
@property (nonatomic, readonly) NSInteger highScore;
@property (nonatomic, readonly) BOOL isNewHighScore;
@property (nonatomic, readonly) GridPoint foodPosition;
@property (nonatomic, readonly) NSArray *snakeSegments; // Array of NSValue with GridPoint
@property (nonatomic, readonly) Direction currentDirection;

- (void)startNewGame;
- (void)pauseGame;
- (void)resumeGame;
- (void)resetGame;
- (void)changeDirection:(Direction)newDirection;

@end

