#import "AxsQQDicePickerViewController.h"
#import "AxsQQDiceConfig.h"
#import "AxsQQDiceDiceResources.h"

@interface AxsQQDicePickerViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>
@property (nonatomic, copy) void (^completion)(NSInteger points);
@end

@implementation AxsQQDicePickerViewController

+ (void)showFrom:(UIViewController *)host completion:(void (^)(NSInteger))completion {
    if (!host) {
        return;
    }
    AxsQQDicePickerViewController *picker = [[AxsQQDicePickerViewController alloc] init];
    picker.completion = completion;
    picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [host presentViewController:picker animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];
    self.view.accessibilityIdentifier = @"axs_qqdice_picker";

    UITapGestureRecognizer *outside = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(axs_qqdice_cancel:)];
    outside.delegate = self;
    [self.view addGestureRecognizer:outside];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(64, 76);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;

    UICollectionView *grid = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    grid.backgroundColor = [UIColor secondarySystemBackgroundColor];
    grid.layer.cornerRadius = 20;
    grid.layer.cornerCurve = kCACornerCurveContinuous;
    grid.contentInset = UIEdgeInsetsMake(16, 20, 16, 20);
    grid.scrollEnabled = NO;
    grid.dataSource = self;
    grid.delegate = self;
    [grid registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"dice"];
    [self.view addSubview:grid];
    grid.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [grid.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [grid.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [grid.widthAnchor constraintEqualToConstant:3 * 64 + 2 * 10 + 40],
        [grid.heightAnchor constraintEqualToConstant:2 * 76 + 10 + 32],
    ]];
}

- (void)axs_qqdice_cancel:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.view];
    UIView *hit = [self.view hitTest:point withEvent:nil];
    if (hit == self.view) {
        [self axs_qqdice_finishWithPoints:0];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self.view;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"dice" forIndexPath:indexPath];
    NSInteger points = indexPath.item + 1;
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1002];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.tag = 1002;
        imageView.contentMode = UIViewContentModeCenter;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:imageView];
        cell.backgroundColor = [UIColor tertiarySystemBackgroundColor];
        cell.layer.cornerRadius = 14;
        cell.layer.cornerCurve = kCACornerCurveContinuous;
    }
    imageView.image = [self axs_qqdice_imageForPoints:points];
    cell.layer.borderColor = [UIColor systemBlueColor].CGColor;
    cell.layer.borderWidth = (points == axs_qqdice_storedPoints()) ? 2 : 0;
    return cell;
}

// 用 Core Graphics 画点阵，不依赖字体里的 ⚀ 是否可用。
- (UIImage *)axs_qqdice_imageForPoints:(NSInteger)points {
    CGFloat side = 52;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(side, side)];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        CGContextRef ctx = context.CGContext;
        CGRect rect = CGRectMake(1, 1, side - 2, side - 2);
        CGContextSetFillColorWithColor(ctx, [UIColor labelColor].CGColor);
        CGPathRef rounded = CGPathCreateWithRoundedRect(rect, 10, 10, NULL);
        CGContextAddPath(ctx, rounded);
        CGPathRelease(rounded);
        CGContextFillPath(ctx);

        // 每行是 [x1,y1,x2,y2]，比例值；0 表示该位没有点。
        static const CGFloat layouts[6][8] = {
            {0.5, 0.5, 0, 0, 0, 0, 0, 0},
            {0.3, 0.3, 0.7, 0.7, 0, 0, 0, 0},
            {0.3, 0.3, 0.5, 0.5, 0.7, 0.7, 0, 0},
            {0.3, 0.3, 0.3, 0.7, 0.7, 0.3, 0.7, 0.7},
            {0.3, 0.3, 0.3, 0.7, 0.7, 0.3, 0.7, 0.7},
            {0.3, 0.3, 0.3, 0.7, 0.7, 0.3, 0.7, 0.7},
        };
        CGFloat dot = 9;
        CGContextSetFillColorWithColor(ctx, [UIColor systemBackgroundColor].CGColor);
        for (NSInteger i = 0; i < 4; i++) {
            CGFloat x = layouts[points - 1][i * 2];
            CGFloat y = layouts[points - 1][i * 2 + 1];
            if (x <= 0 || y <= 0) {
                continue;
            }
            CGContextFillEllipseInRect(ctx, CGRectMake(x * side - dot / 2, y * side - dot / 2, dot, dot));
        }
        if (points == 5) {
            CGContextFillEllipseInRect(ctx, CGRectMake(side / 2 - dot / 2, side / 2 - dot / 2, dot, dot));
        }
        if (points == 6) {
            for (NSInteger column = 0; column < 2; column++) {
                CGFloat x = column == 0 ? 0.3 : 0.7;
                for (NSInteger row = 0; row < 3; row++) {
                    CGFloat y = 0.3 + row * 0.2;
                    CGContextFillEllipseInRect(ctx, CGRectMake(x * side - dot / 2, y * side - dot / 2, dot, dot));
                }
            }
        }
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self axs_qqdice_finishWithPoints:indexPath.item + 1];
}

- (void)axs_qqdice_finishWithPoints:(NSInteger)points {
    void (^completion)(NSInteger) = self.completion;
    self.completion = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        if (completion) {
            completion(points);
        }
    }];
}

@end
