//
//  NEOColorPickerFavoritesViewController.m
//
//  Created by Karthik Abram on 10/24/12.
//  Copyright (c) 2012 Neovera Inc.
//


/*
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

#import "NEOColorPickerFavoritesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+NEOColor.h"

@interface NEOColorPickerFavoritesViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) CALayer *selectedColorLayer;

@end

@implementation NEOColorPickerFavoritesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.selectedColorText.length != 0) {
        self.selectedColorLabel.text = self.selectedColorText;
    }
    
    CGRect frame = CGRectMake(130, 16, 100, 40);
    UIImageView *checkeredView = [[UIImageView alloc] initWithFrame:frame];
    checkeredView.layer.cornerRadius = 6.0;
    checkeredView.layer.masksToBounds = YES;
    checkeredView.backgroundColor = [UIColor colorWithPatternImage:[Resources imageNamed:@"colorPicker.bundle/color-picker-checkered"]];
    [self.view addSubview:checkeredView];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(130, 16, 100, 40);
    layer.cornerRadius = 6.0;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 2);
    layer.shadowOpacity = 0.8;
    
    [self.view.layer addSublayer:layer];
    self.selectedColorLayer = layer;
    self.selectedColorLayer.backgroundColor = self.selectedColor.CGColor;
    
    NSOrderedSet *colors = [NEOColorPickerFavoritesManager instance].favoriteColors;
    UIColor *pattern = [UIColor colorWithPatternImage:[Resources imageNamed:@"colorPicker.bundle/color-picker-checkered"]];
    NSInteger count = [colors count];
    for (NSInteger i = 0; i < count; i++) {
        NSInteger page = i / 24;
        NSInteger x = i % 24;
        NSInteger column = x % 4;
        NSInteger row = x / 4;
        CGRect frame = CGRectMake(page * 320 + 8 + (column * 78), 8 + row * 48, 70, 40);
        
        UIImageView *checkeredView = [[UIImageView alloc] initWithFrame:frame];
        checkeredView.layer.cornerRadius = 6.0;
        checkeredView.layer.masksToBounds = YES;
        checkeredView.backgroundColor = pattern;
        [self.scrollView addSubview:checkeredView];
        
        CALayer *layer = [CALayer layer];
        layer.cornerRadius = 6.0;
        UIColor *color = [colors objectAtIndex:i];
        layer.backgroundColor = color.CGColor;
        layer.frame = frame;
        [self setupShadow:layer];
        [self.scrollView.layer addSublayer:layer];
    }
    NSInteger pages = (count - 1) / 24 + 1;
    
    self.scrollView.contentSize = CGSizeMake(pages * 320, 296);
    self.scrollView.delegate = self;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorGridTapped:)];
    [self.scrollView addGestureRecognizer:recognizer];

    self.pageControl.numberOfPages = pages;
}


- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
}


- (void) colorGridTapped:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.scrollView];
    NSInteger page = point.x / 320;
    NSInteger delta = (int)point.x % 320;
    
    NSInteger row = (int)((point.y - 8) / 48);
    NSInteger column = (int)((delta - 8) / 78);
    NSInteger index = 24 * page + row * 4 + column;
    
    if (index < [[NEOColorPickerFavoritesManager instance].favoriteColors count])
    {
        self.selectedColor = [[NEOColorPickerFavoritesManager instance].favoriteColors objectAtIndex:index];
        self.selectedColorLayer.backgroundColor = self.selectedColor.CGColor;
        [self.selectedColorLayer setNeedsDisplay];
        if ([self.delegate respondsToSelector:@selector(colorPickerViewController:didChangeColor:)]) {
            [self.delegate colorPickerViewController:self didChangeColor:self.selectedColor];
        }
    }
}


- (IBAction)pageValueChange:(id)sender {
    [self.scrollView scrollRectToVisible:CGRectMake(self.pageControl.currentPage * 320, 0, 320, 296) animated:YES];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = scrollView.contentOffset.x / 320;
}

@end
