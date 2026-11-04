//
//  SkeuomorphicButton.h
//  Zmeyka
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SkeuomorphicButtonStyle) {
    SkeuomorphicButtonStyleDefault, // Glossy blue (classic iOS 6 tint)
    SkeuomorphicButtonStyleGreen,   // Glossy game green
    SkeuomorphicButtonStyleRed,     // Glossy cancel / danger red
    SkeuomorphicButtonStyleSilver   // Brushed aluminum / silver
};

@interface SkeuomorphicButton : UIButton

@property (nonatomic, assign) SkeuomorphicButtonStyle buttonStyle;

+ (SkeuomorphicButton *)buttonWithTitle:(NSString *)title style:(SkeuomorphicButtonStyle)style;

@end

