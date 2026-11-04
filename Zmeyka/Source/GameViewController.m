//
//  GameViewController.m
//  Zmeyka
//

#import "GameViewController.h"
#import "SnakeGameEngine.h"
#import "SnakeGridView.h"
#import "SkeuomorphicButton.h"
#import "SoundManager.h"
#import <QuartzCore/QuartzCore.h>

@interface GameViewController () <SnakeGameEngineDelegate> {
    SnakeGameEngine *_engine;
    SnakeGridView *_gridView;
    
    // Top Bar items
    UILabel *_scoreLabel;
    UILabel *_highScoreLabel;
    SkeuomorphicButton *_pauseButton;
    
    // On-screen D-Pad buttons
    SkeuomorphicButton *_btnUp;
    SkeuomorphicButton *_btnDown;
    SkeuomorphicButton *_btnLeft;
    SkeuomorphicButton *_btnRight;
    
    // Pause Overlay
    UIView *_pauseOverlay;
    
    // Game Over Overlay
    UIView *_gameOverOverlay;
    UILabel *_goScoreLabel;
    UILabel *_goRecordNotice;
}
@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.14 green:0.15 blue:0.17 alpha:1.0];
    
    _engine = [[SnakeGameEngine alloc] init];
    _engine.delegate = self;
    
    [self setupTopBar];
    [self setupGridView];
    [self setupDPadControls];
    [self setupSwipeGestures];
    [self setupPauseOverlay];
    [self setupGameOverOverlay];
    
    [_engine startNewGame];
}

- (void)setupTopBar {
    CGFloat viewWidth = self.view.bounds.size.width;
    
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 44.0f)];
    topBar.backgroundColor = [UIColor colorWithRed:0.22 green:0.24 blue:0.26 alpha:1.0];
    
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = topBar.bounds;
    grad.colors = @[
        (__bridge id)[UIColor colorWithRed:0.30 green:0.32 blue:0.35 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:0.18 green:0.20 blue:0.22 alpha:1.0].CGColor
    ];
    [topBar.layer insertSublayer:grad atIndex:0];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43.0f, viewWidth, 1.0f)];
    line.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    [topBar addSubview:line];
    
    _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 4.0f, 105.0f, 36.0f)];
    _scoreLabel.text = @"Счёт: 0";
    _scoreLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    _scoreLabel.textColor = [UIColor whiteColor];
    _scoreLabel.backgroundColor = [UIColor clearColor];
    _scoreLabel.shadowColor = [UIColor blackColor];
    _scoreLabel.shadowOffset = CGSizeMake(0, 1.0f);
    [topBar addSubview:_scoreLabel];
    
    _highScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(115.0f, 4.0f, 125.0f, 36.0f)];
    _highScoreLabel.text = [NSString stringWithFormat:@"Рекорд: %ld", (long)_engine.highScore];
    _highScoreLabel.font = [UIFont systemFontOfSize:14.0f];
    _highScoreLabel.textColor = [UIColor colorWithRed:1.0 green:0.85 blue:0.3 alpha:1.0];
    _highScoreLabel.backgroundColor = [UIColor clearColor];
    _highScoreLabel.shadowColor = [UIColor blackColor];
    _highScoreLabel.shadowOffset = CGSizeMake(0, 1.0f);
    [topBar addSubview:_highScoreLabel];
    
    _pauseButton = [SkeuomorphicButton buttonWithTitle:@"Пауза" style:SkeuomorphicButtonStyleSilver];
    _pauseButton.frame = CGRectMake(viewWidth - 75.0f, 6.0f, 65.0f, 32.0f);
    [_pauseButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    [_pauseButton addTarget:self action:@selector(pauseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:_pauseButton];
    
    [self.view addSubview:topBar];
}

- (void)setupGridView {
    CGFloat fieldSide = GRID_COLS * CELL_SIZE; // 270 pt
    CGFloat x = (self.view.bounds.size.width - fieldSide) / 2.0f; // 25 pt margin
    CGFloat y = 48.0f;
    
    _gridView = [[SnakeGridView alloc] initWithFrame:CGRectMake(x, y, fieldSide, fieldSide)];
    [self.view addSubview:_gridView];
}

- (void)setupDPadControls {
    // Controller plate at the bottom (y = 325 to 475)
    CGFloat centerX = self.view.bounds.size.width / 2.0f; // 160
    CGFloat centerY = 398.0f;
    CGFloat btnW = 58.0f;
    CGFloat btnH = 44.0f;
    CGFloat offset = 48.0f;
    
    // UP
    _btnUp = [SkeuomorphicButton buttonWithTitle:@"▲" style:SkeuomorphicButtonStyleSilver];
    _btnUp.frame = CGRectMake(centerX - btnW / 2.0f, centerY - offset - btnH / 2.0f, btnW, btnH);
    _btnUp.tag = DirectionUp;
    [_btnUp addTarget:self action:@selector(dpadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnUp];
    
    // DOWN
    _btnDown = [SkeuomorphicButton buttonWithTitle:@"▼" style:SkeuomorphicButtonStyleSilver];
    _btnDown.frame = CGRectMake(centerX - btnW / 2.0f, centerY + offset - btnH / 2.0f, btnW, btnH);
    _btnDown.tag = DirectionDown;
    [_btnDown addTarget:self action:@selector(dpadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnDown];
    
    // LEFT
    _btnLeft = [SkeuomorphicButton buttonWithTitle:@"◀" style:SkeuomorphicButtonStyleSilver];
    _btnLeft.frame = CGRectMake(centerX - offset - btnW / 2.0f - 10.0f, centerY - btnH / 2.0f, btnW, btnH);
    _btnLeft.tag = DirectionLeft;
    [_btnLeft addTarget:self action:@selector(dpadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnLeft];
    
    // RIGHT
    _btnRight = [SkeuomorphicButton buttonWithTitle:@"▶" style:SkeuomorphicButtonStyleSilver];
    _btnRight.frame = CGRectMake(centerX + offset - btnW / 2.0f + 10.0f, centerY - btnH / 2.0f, btnW, btnH);
    _btnRight.tag = DirectionRight;
    [_btnRight addTarget:self action:@selector(dpadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnRight];
}

- (void)setupSwipeGestures {
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionUp:
            [_engine changeDirection:DirectionUp];
            break;
        case UISwipeGestureRecognizerDirectionDown:
            [_engine changeDirection:DirectionDown];
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            [_engine changeDirection:DirectionLeft];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            [_engine changeDirection:DirectionRight];
            break;
        default:
            break;
    }
}

- (void)dpadButtonTapped:(UIButton *)sender {
    [[SoundManager sharedManager] playButtonSound];
    [_engine changeDirection:(Direction)sender.tag];
}

- (void)pauseButtonTapped:(id)sender {
    [[SoundManager sharedManager] playButtonSound];
    [_engine pauseGame];
    _pauseOverlay.hidden = NO;
}

#pragma mark - Overlays

- (void)setupPauseOverlay {
    _pauseOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    _pauseOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.65];
    _pauseOverlay.hidden = YES;
    
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(30.0f, 110.0f, self.view.bounds.size.width - 60.0f, 260.0f)];
    card.backgroundColor = [UIColor colorWithRed:0.20 green:0.22 blue:0.25 alpha:1.0];
    card.layer.cornerRadius = 14.0f;
    card.layer.borderWidth = 2.0f;
    card.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:0.8].CGColor;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOpacity = 0.7f;
    card.layer.shadowRadius = 8.0f;
    card.layer.shadowOffset = CGSizeMake(0, 4.0f);
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 20.0f, card.bounds.size.width - 20.0f, 32.0f)];
    title.text = @"ПАУЗА";
    title.font = [UIFont boldSystemFontOfSize:26.0f];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.backgroundColor = [UIColor clearColor];
    [card addSubview:title];
    
    SkeuomorphicButton *btnResume = [SkeuomorphicButton buttonWithTitle:@"Продолжить" style:SkeuomorphicButtonStyleGreen];
    btnResume.frame = CGRectMake(25.0f, 75.0f, card.bounds.size.width - 50.0f, 44.0f);
    [btnResume addTarget:self action:@selector(resumeTapped:) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:btnResume];
    
    SkeuomorphicButton *btnRestart = [SkeuomorphicButton buttonWithTitle:@"Заново" style:SkeuomorphicButtonStyleDefault];
    btnRestart.frame = CGRectMake(25.0f, 130.0f, card.bounds.size.width - 50.0f, 44.0f);
    [btnRestart addTarget:self action:@selector(restartTapped:) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:btnRestart];
    
    SkeuomorphicButton *btnMenu = [SkeuomorphicButton buttonWithTitle:@"В меню" style:SkeuomorphicButtonStyleSilver];
    btnMenu.frame = CGRectMake(25.0f, 185.0f, card.bounds.size.width - 50.0f, 44.0f);
    [btnMenu addTarget:self action:@selector(menuTapped:) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:btnMenu];
    
    [_pauseOverlay addSubview:card];
    [self.view addSubview:_pauseOverlay];
}

- (void)setupGameOverOverlay {
    _gameOverOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    _gameOverOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
    _gameOverOverlay.hidden = YES;
    
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(25.0f, 95.0f, self.view.bounds.size.width - 50.0f, 290.0f)];
    card.backgroundColor = [UIColor colorWithRed:0.22 green:0.20 blue:0.20 alpha:1.0];
    card.layer.cornerRadius = 14.0f;
    card.layer.borderWidth = 2.0f;
    card.layer.borderColor = [UIColor colorWithRed:0.75 green:0.25 blue:0.25 alpha:0.8].CGColor;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOpacity = 0.8f;
    card.layer.shadowRadius = 10.0f;
    card.layer.shadowOffset = CGSizeMake(0, 5.0f);
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 18.0f, card.bounds.size.width - 20.0f, 32.0f)];
    title.text = @"Игра окончена";
    title.font = [UIFont boldSystemFontOfSize:26.0f];
    title.textColor = [UIColor colorWithRed:1.0 green:0.35 blue:0.35 alpha:1.0];
    title.textAlignment = NSTextAlignmentCenter;
    title.backgroundColor = [UIColor clearColor];
    [card addSubview:title];
    
    _goScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 58.0f, card.bounds.size.width - 20.0f, 28.0f)];
    _goScoreLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    _goScoreLabel.textColor = [UIColor whiteColor];
    _goScoreLabel.textAlignment = NSTextAlignmentCenter;
    _goScoreLabel.backgroundColor = [UIColor clearColor];
    [card addSubview:_goScoreLabel];
    
    _goRecordNotice = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 90.0f, card.bounds.size.width - 20.0f, 24.0f)];
    _goRecordNotice.font = [UIFont boldSystemFontOfSize:16.0f];
    _goRecordNotice.textColor = [UIColor colorWithRed:1.0 green:0.85 blue:0.25 alpha:1.0];
    _goRecordNotice.textAlignment = NSTextAlignmentCenter;
    _goRecordNotice.backgroundColor = [UIColor clearColor];
    _goRecordNotice.text = @"Новый рекорд!";
    _goRecordNotice.hidden = YES;
    [card addSubview:_goRecordNotice];
    
    SkeuomorphicButton *btnPlayAgain = [SkeuomorphicButton buttonWithTitle:@"Ещё раз" style:SkeuomorphicButtonStyleGreen];
    btnPlayAgain.frame = CGRectMake(25.0f, 140.0f, card.bounds.size.width - 50.0f, 48.0f);
    [btnPlayAgain addTarget:self action:@selector(restartTapped:) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:btnPlayAgain];
    
    SkeuomorphicButton *btnMenu = [SkeuomorphicButton buttonWithTitle:@"В меню" style:SkeuomorphicButtonStyleSilver];
    btnMenu.frame = CGRectMake(25.0f, 202.0f, card.bounds.size.width - 50.0f, 44.0f);
    [btnMenu addTarget:self action:@selector(menuTapped:) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:btnMenu];
    
    [_gameOverOverlay addSubview:card];
    [self.view addSubview:_gameOverOverlay];
}

#pragma mark - Button Actions

- (void)resumeTapped:(id)sender {
    [[SoundManager sharedManager] playButtonSound];
    _pauseOverlay.hidden = YES;
    [_engine resumeGame];
}

- (void)restartTapped:(id)sender {
    [[SoundManager sharedManager] playButtonSound];
    _pauseOverlay.hidden = YES;
    _gameOverOverlay.hidden = YES;
    _gridView.isDead = NO;
    [_engine startNewGame];
}

- (void)menuTapped:(id)sender {
    [[SoundManager sharedManager] playButtonSound];
    [_engine resetGame];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SnakeGameEngineDelegate

- (void)gameEngineDidUpdate {
    _gridView.snakeSegments = _engine.snakeSegments;
    _gridView.foodPosition = _engine.foodPosition;
    _gridView.currentDirection = _engine.currentDirection;
}

- (void)gameEngineDidEatFoodWithScore:(NSInteger)score isNewHighScore:(BOOL)isNewHighScore {
    [[SoundManager sharedManager] playEatSound];
    _scoreLabel.text = [NSString stringWithFormat:@"Счёт: %ld", (long)score];
    _highScoreLabel.text = [NSString stringWithFormat:@"Рекорд: %ld", (long)_engine.highScore];
}

- (void)gameEngineDidGameOverWithScore:(NSInteger)score isNewHighScore:(BOOL)isNewHighScore {
    [[SoundManager sharedManager] playGameOverSound];
    _gridView.isDead = YES;
    
    _goScoreLabel.text = [NSString stringWithFormat:@"Набрано очков: %ld", (long)score];
    _goRecordNotice.hidden = !isNewHighScore;
    _gameOverOverlay.hidden = NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
