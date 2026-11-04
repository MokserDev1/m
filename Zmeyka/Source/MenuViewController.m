//
//  MenuViewController.m
//  Zmeyka
//

#import "MenuViewController.h"
#import "GameViewController.h"
#import "SkeuomorphicButton.h"
#import "SoundManager.h"
#import <QuartzCore/QuartzCore.h>

#define HIGH_SCORE_KEY @"Zmeyka_HighScore"

@interface MenuViewController () {
    UILabel *_highScoreLabel;
    SkeuomorphicButton *_soundButton;
}
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Classic linen / textured background
    self.view.backgroundColor = [UIColor colorWithRed:0.18 green:0.20 blue:0.22 alpha:1.0];
    
    // Background gradient overlay
    CAGradientLayer *bgGrad = [CAGradientLayer layer];
    bgGrad.frame = self.view.bounds;
    bgGrad.colors = @[
        (__bridge id)[UIColor colorWithRed:0.25 green:0.28 blue:0.32 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:0.12 green:0.14 blue:0.16 alpha:1.0].CGColor
    ];
    [self.view.layer insertSublayer:bgGrad atIndex:0];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateHighScoreDisplay];
    [self updateSoundButtonTitle];
}

- (void)setupUI {
    CGFloat viewWidth = self.view.bounds.size.width;
    
    // 1. App Title: "Змейка"
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 40.0f, viewWidth - 40.0f, 54.0f)];
    titleLabel.text = @"Змейка";
    titleLabel.font = [UIFont boldSystemFontOfSize:42.0f];
    titleLabel.textColor = [UIColor colorWithRed:0.92 green:0.95 blue:0.88 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    titleLabel.shadowOffset = CGSizeMake(0.0f, 2.0f);
    [self.view addSubview:titleLabel];
    
    // Subtitle
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 92.0f, viewWidth - 40.0f, 24.0f)];
    subTitle.text = @"Классическая игра";
    subTitle.font = [UIFont systemFontOfSize:16.0f];
    subTitle.textColor = [UIColor colorWithRed:0.65 green:0.75 blue:0.65 alpha:1.0];
    subTitle.textAlignment = NSTextAlignmentCenter;
    subTitle.backgroundColor = [UIColor clearColor];
    subTitle.shadowColor = [UIColor blackColor];
    subTitle.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.view addSubview:subTitle];
    
    // 2. Decorative Center Emblem (Classic Snake Artwork / Plate)
    UIView *emblemPlate = [[UIView alloc] initWithFrame:CGRectMake((viewWidth - 140.0f) / 2.0f, 130.0f, 140.0f, 140.0f)];
    emblemPlate.backgroundColor = [UIColor colorWithRed:0.75 green:0.80 blue:0.68 alpha:1.0];
    emblemPlate.layer.cornerRadius = 16.0f;
    emblemPlate.layer.borderWidth = 3.5f;
    emblemPlate.layer.borderColor = [UIColor colorWithRed:0.35 green:0.42 blue:0.30 alpha:1.0].CGColor;
    emblemPlate.layer.shadowColor = [UIColor blackColor].CGColor;
    emblemPlate.layer.shadowOpacity = 0.5f;
    emblemPlate.layer.shadowRadius = 5.0f;
    emblemPlate.layer.shadowOffset = CGSizeMake(0, 3.0f);
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectInset(emblemPlate.bounds, 10.0f, 10.0f)];
    iconView.image = [UIImage imageNamed:@"Icon-Small-50.png"];
    if (!iconView.image) {
        iconView.image = [UIImage imageNamed:@"Icon.png"];
    }
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.layer.cornerRadius = 10.0f;
    iconView.layer.masksToBounds = YES;
    [emblemPlate addSubview:iconView];
    [self.view addSubview:emblemPlate];
    
    // 3. High Score Card
    UIView *scoreCard = [[UIView alloc] initWithFrame:CGRectMake(35.0f, 285.0f, viewWidth - 70.0f, 44.0f)];
    scoreCard.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.35];
    scoreCard.layer.cornerRadius = 8.0f;
    scoreCard.layer.borderWidth = 1.0f;
    scoreCard.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.15].CGColor;
    
    _highScoreLabel = [[UILabel alloc] initWithFrame:scoreCard.bounds];
    _highScoreLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    _highScoreLabel.textColor = [UIColor colorWithRed:1.0 green:0.85 blue:0.3 alpha:1.0];
    _highScoreLabel.textAlignment = NSTextAlignmentCenter;
    _highScoreLabel.backgroundColor = [UIColor clearColor];
    _highScoreLabel.shadowColor = [UIColor blackColor];
    _highScoreLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [scoreCard addSubview:_highScoreLabel];
    [self.view addSubview:scoreCard];
    
    // 4. Play Button
    SkeuomorphicButton *playButton = [SkeuomorphicButton buttonWithTitle:@"ИГРАТЬ" style:SkeuomorphicButtonStyleGreen];
    playButton.frame = CGRectMake(35.0f, 345.0f, viewWidth - 70.0f, 50.0f);
    [playButton.titleLabel setFont:[UIFont boldSystemFontOfSize:22.0f]];
    [playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
    
    // 5. Sound Button
    _soundButton = [SkeuomorphicButton buttonWithTitle:@"Звук: ВКЛ" style:SkeuomorphicButtonStyleSilver];
    _soundButton.frame = CGRectMake(35.0f, 408.0f, viewWidth - 70.0f, 42.0f);
    [_soundButton addTarget:self action:@selector(soundButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:soundButton];
}

- (void)updateHighScoreDisplay {
    NSInteger hs = [[NSUserDefaults standardUserDefaults] integerForKey:HIGH_SCORE_KEY];
    _highScoreLabel.text = [NSString stringWithFormat:@"Рекорд: %ld", (long)hs];
}

- (void)updateSoundButtonTitle {
    BOOL enabled = [SoundManager sharedManager].soundEnabled;
    [_soundButton setTitle:enabled ? @"Звук: ВКЛ" : @"Звук: ВЫКЛ" forState:UIControlStateNormal];
}

- (void)playButtonTapped:(id)sender {
    [[SoundManager sharedManager] playButtonSound];
    GameViewController *gameVC = [[GameViewController alloc] init];
    gameVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:gameVC animated:YES completion:nil];
}

- (void)soundButtonTapped:(id)sender {
    [[SoundManager sharedManager] toggleSound];
    [[SoundManager sharedManager] playButtonSound];
    [self updateSoundButtonTitle];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
