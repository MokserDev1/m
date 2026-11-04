//
//  SnakeGameEngine.m
//  Zmeyka
//

#import "SnakeGameEngine.h"

#define HIGH_SCORE_KEY @"Zmeyka_HighScore"
#define INITIAL_SPEED 0.22f
#define MIN_SPEED 0.08f
#define SPEED_DECREMENT 0.007f

@interface SnakeGameEngine () {
    NSMutableArray *_segments;
    Direction _currentDirection;
    Direction _nextDirection;
    NSTimer *_gameTimer;
    NSTimeInterval _currentInterval;
    NSInteger _score;
    NSInteger _highScore;
    BOOL _isNewHighScore;
    GameState _state;
    GridPoint _foodPosition;
}
@end

@implementation SnakeGameEngine

- (id)init {
    self = [super init];
    if (self) {
        _segments = [[NSMutableArray alloc] init];
        _state = GameStateReady;
        _highScore = [[NSUserDefaults standardUserDefaults] integerForKey:HIGH_SCORE_KEY];
        [self resetGame];
    }
    return self;
}

- (void)dealloc {
    [self stopTimer];
}

- (void)resetGame {
    [self stopTimer];
    [_segments removeAllObjects];
    
    _score = 0;
    _isNewHighScore = NO;
    _currentInterval = INITIAL_SPEED;
    _currentDirection = DirectionRight;
    _nextDirection = DirectionRight;
    _state = GameStateReady;
    
    // Initial snake (length 3, centered)
    int startX = GRID_COLS / 2;
    int startY = GRID_ROWS / 2;
    
    GridPoint head = GridPointMake(startX, startY);
    GridPoint body1 = GridPointMake(startX - 1, startY);
    GridPoint body2 = GridPointMake(startX - 2, startY);
    
    [_segments addObject:[NSValue valueWithBytes:&head objCType:@encode(GridPoint)]];
    [_segments addObject:[NSValue valueWithBytes:&body1 objCType:@encode(GridPoint)]];
    [_segments addObject:[NSValue valueWithBytes:&body2 objCType:@encode(GridPoint)]];
    
    [self spawnFood];
    
    if ([self.delegate respondsToSelector:@selector(gameEngineDidUpdate)]) {
        [self.delegate gameEngineDidUpdate];
    }
}

- (void)startNewGame {
    [self resetGame];
    _state = GameStateRunning;
    [self startTimer];
}

- (void)pauseGame {
    if (_state == GameStateRunning) {
        _state = GameStatePaused;
        [self stopTimer];
    }
}

- (void)resumeGame {
    if (_state == GameStatePaused) {
        _state = GameStateRunning;
        [self startTimer];
    }
}

- (void)startTimer {
    [self stopTimer];
    _gameTimer = [NSTimer scheduledTimerWithTimeInterval:_currentInterval
                                                  target:self
                                                selector:@selector(tick:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopTimer {
    if (_gameTimer) {
        [_gameTimer invalidate];
        _gameTimer = nil;
    }
}

- (void)spawnFood {
    NSMutableArray *freeCells = [NSMutableArray array];
    
    for (int y = 0; y < GRID_ROWS; y++) {
        for (int x = 0; x < GRID_COLS; x++) {
            GridPoint candidate = GridPointMake(x, y);
            BOOL occupied = NO;
            for (NSValue *val in _segments) {
                GridPoint seg;
                [val getValue:&seg];
                if (GridPointEqualToPoint(seg, candidate)) {
                    occupied = YES;
                    break;
                }
            }
            if (!occupied) {
                [freeCells addObject:[NSValue valueWithBytes:&candidate objCType:@encode(GridPoint)]];
            }
        }
    }
    
    if (freeCells.count > 0) {
        NSUInteger randomIndex = arc4random_uniform((u_int32_t)freeCells.count);
        NSValue *chosen = [freeCells objectAtIndex:randomIndex];
        [chosen getValue:&_foodPosition];
    } else {
        // Victory / Full field!
        _foodPosition = GridPointMake(-1, -1);
    }
}

- (void)changeDirection:(Direction)newDirection {
    if (_state != GameStateRunning) return;
    
    // Prevent 180-degree turn
    if ((_currentDirection == DirectionUp && newDirection == DirectionDown) ||
        (_currentDirection == DirectionDown && newDirection == DirectionUp) ||
        (_currentDirection == DirectionLeft && newDirection == DirectionRight) ||
        (_currentDirection == DirectionRight && newDirection == DirectionLeft)) {
        return;
    }
    
    _nextDirection = newDirection;
}

- (void)tick:(NSTimer *)timer {
    if (_state != GameStateRunning) return;
    
    _currentDirection = _nextDirection;
    
    // Current head
    NSValue *headVal = [_segments objectAtIndex:0];
    GridPoint currentHead;
    [headVal getValue:&currentHead];
    
    GridPoint newHead = currentHead;
    switch (_currentDirection) {
        case DirectionUp:    newHead.y -= 1; break;
        case DirectionDown:  newHead.y += 1; break;
        case DirectionLeft:  newHead.x -= 1; break;
        case DirectionRight: newHead.x += 1; break;
        default: break;
    }
    
    // Check wall collision
    if (newHead.x < 0 || newHead.x >= GRID_COLS || newHead.y < 0 || newHead.y >= GRID_ROWS) {
        [self triggerGameOver];
        return;
    }
    
    // Check self collision (ignoring tail if we don't eat food, but strict check is safer)
    for (NSUInteger i = 0; i < _segments.count - 1; i++) {
        GridPoint seg;
        [[_segments objectAtIndex:i] getValue:&seg];
        if (GridPointEqualToPoint(seg, newHead)) {
            [self triggerGameOver];
            return;
        }
    }
    
    // Move snake
    [_segments insertObject:[NSValue valueWithBytes:&newHead objCType:@encode(GridPoint)] atIndex:0];
    
    // Check food eaten
    if (GridPointEqualToPoint(newHead, _foodPosition)) {
        _score++;
        if (_score > _highScore) {
            _highScore = _score;
            _isNewHighScore = YES;
            [[NSUserDefaults standardUserDefaults] setInteger:_highScore forKey:HIGH_SCORE_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        // Speed up
        if (_currentInterval > MIN_SPEED) {
            _currentInterval -= SPEED_DECREMENT;
            if (_currentInterval < MIN_SPEED) _currentInterval = MIN_SPEED;
            [self startTimer]; // Update timer interval
        }
        
        [self spawnFood];
        
        if ([self.delegate respondsToSelector:@selector(gameEngineDidEatFoodWithScore:isNewHighScore:)]) {
            [self.delegate gameEngineDidEatFoodWithScore:_score isNewHighScore:_isNewHighScore];
        }
    } else {
        // Remove tail
        [_segments removeLastObject];
    }
    
    if ([self.delegate respondsToSelector:@selector(gameEngineDidUpdate)]) {
        [self.delegate gameEngineDidUpdate];
    }
}

- (void)triggerGameOver {
    _state = GameStateGameOver;
    [self stopTimer];
    
    if ([self.delegate respondsToSelector:@selector(gameEngineDidGameOverWithScore:isNewHighScore:)]) {
        [self.delegate gameEngineDidGameOverWithScore:_score isNewHighScore:_isNewHighScore];
    }
}

#pragma mark - Getters

- (GameState)state { return _state; }
- (NSInteger)score { return _score; }
- (NSInteger)highScore { return _highScore; }
- (BOOL)isNewHighScore { return _isNewHighScore; }
- (GridPoint)foodPosition { return _foodPosition; }
- (NSArray *)snakeSegments { return [_segments copy]; }
- (Direction)currentDirection { return _currentDirection; }

@end

