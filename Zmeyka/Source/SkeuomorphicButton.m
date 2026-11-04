//
//  SkeuomorphicButton.m
//  Zmeyka
//

#import "SkeuomorphicButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation SkeuomorphicButton

+ (SkeuomorphicButton *)buttonWithTitle:(NSString *)title style:(SkeuomorphicButtonStyle)style {
    SkeuomorphicButton *btn = [SkeuomorphicButton buttonWithType:UIButtonTypeCustom];
    btn.buttonStyle = style;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    return btn;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    _buttonStyle = SkeuomorphicButtonStyleDefault;
    self.layer.cornerRadius = 8.0f;
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.35f;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.6f] forState:UIControlStateNormal];
    self.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
}

- (void)setButtonStyle:(SkeuomorphicButtonStyle)buttonStyle {
    _buttonStyle = buttonStyle;
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) return;
    
    CGRect bounds = self.bounds;
    
    // Choose colors based on style and state
    UIColor *topColor, *bottomColor, *borderColor;
    
    if (self.isHighlighted) {
        switch (_buttonStyle) {
            case SkeuomorphicButtonStyleGreen:
                topColor = [UIColor colorWithRed:0.18 green:0.42 blue:0.18 alpha:1.0];
                bottomColor = [UIColor colorWithRed:0.28 green:0.62 blue:0.28 alpha:1.0];
                borderColor = [UIColor colorWithRed:0.12 green:0.32 blue:0.12 alpha:1.0];
                break;
            case SkeuomorphicButtonStyleRed:
                topColor = [UIColor colorWithRed:0.55 green:0.12 blue:0.12 alpha:1.0];
                bottomColor = [UIColor colorWithRed:0.75 green:0.22 blue:0.22 alpha:1.0];
                borderColor = [UIColor colorWithRed:0.40 green:0.08 blue:0.08 alpha:1.0];
                break;
            case SkeuomorphicButtonStyleSilver:
                topColor = [UIColor colorWithWhite:0.65 alpha:1.0];
                bottomColor = [UIColor colorWithWhite:0.80 alpha:1.0];
                borderColor = [UIColor colorWithWhite:0.45 alpha:1.0];
                break;
            case SkeuomorphicButtonStyleDefault:
            default:
                topColor = [UIColor colorWithRed:0.10 green:0.30 blue:0.58 alpha:1.0];
                bottomColor = [UIColor colorWithRed:0.20 green:0.45 blue:0.75 alpha:1.0];
                borderColor = [UIColor colorWithRed:0.08 green:0.22 blue:0.45 alpha:1.0];
                break;
        }
    } else {
        switch (_buttonStyle) {
            case SkeuomorphicButtonStyleGreen:
                topColor = [UIColor colorWithRed:0.38 green:0.72 blue:0.35 alpha:1.0];
                bottomColor = [UIColor colorWithRed:0.18 green:0.52 blue:0.18 alpha:1.0];
                borderColor = [UIColor colorWithRed:0.12 green:0.38 blue:0.12 alpha:1.0];
                break;
            case SkeuomorphicButtonStyleRed:
                topColor = [UIColor colorWithRed:0.85 green:0.28 blue:0.28 alpha:1.0];
                bottomColor = [UIColor colorWithRed:0.60 green:0.15 blue:0.15 alpha:1.0];
                borderColor = [UIColor colorWithRed:0.45 green:0.10 blue:0.10 alpha:1.0];
                break;
            case SkeuomorphicButtonStyleSilver:
                topColor = [UIColor colorWithWhite:0.92 alpha:1.0];
                bottomColor = [UIColor colorWithWhite:0.72 alpha:1.0];
                borderColor = [UIColor colorWithWhite:0.50 alpha:1.0];
                break;
            case SkeuomorphicButtonStyleDefault:
            default:
                topColor = [UIColor colorWithRed:0.30 green:0.55 blue:0.85 alpha:1.0];
                bottomColor = [UIColor colorWithRed:0.12 green:0.35 blue:0.65 alpha:1.0];
                borderColor = [UIColor colorWithRed:0.10 green:0.25 blue:0.50 alpha:1.0];
                break;
        }
    }
    
    // Outer Border & Base Clip
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:8.0f];
    CGContextSaveGState(ctx);
    [path addClip];
    
    // Draw Gradient
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *colors = @[(__bridge id)topColor.CGColor, (__bridge id)bottomColor.CGColor];
    CGFloat locations[] = {0.0f, 1.0f};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0), CGPointMake(0, bounds.size.height), 0);
    CGGradientRelease(gradient);
    
    // iOS 6 Gloss / Sheen overlay (top half)
    if (!self.isHighlighted) {
        CGRect glossRect = CGRectMake(0, 0, bounds.size.width, bounds.size.height * 0.48f);
        UIBezierPath *glossPath = [UIBezierPath bezierPathWithRoundedRect:glossRect cornerRadius:7.0f];
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.30].CGColor);
        [glossPath fill];
        
        // Crisp top inner highlight line
        CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.55].CGColor);
        CGContextSetLineWidth(ctx, 1.0f);
        CGContextMoveToPoint(ctx, 8.0f, 1.0f);
        CGContextAddLineToPoint(ctx, bounds.size.width - 8.0f, 1.0f);
        CGContextStrokePath(ctx);
    }
    
    CGContextRestoreGState(ctx);
    
    // Draw outer border stroke
    [borderColor setStroke];
    path.lineWidth = 1.5f;
    [path stroke];
}

@end

