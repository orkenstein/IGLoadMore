//
//  IGLoadMoreControl.m
//  iGames
//
//  Created by orkenstein on 03.06.14.
//  Copyright (c) 2014 A&J Apps LLC. All rights reserved.
//

#import "IGLoadMoreControl.h"
#import <Block-KVO/MTKObserving.h>
#import <DSXActivityIndicator.h>

@interface IGLoadMoreControl ()
@property (nonatomic, strong) DSXActivityIndicator *activityView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) IGLoadMoreState loadMoreState;
@property (nonatomic, strong) NSMutableDictionary *titlesForState;

@end

@implementation IGLoadMoreControl

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupSubviews];
  }
  return self;
}

- (void)setupSubviews {
  DSXActivityIndicator *activityView = [[DSXActivityIndicator alloc] init];
  activityView.tintColor = [UIColor lightGrayColor];
  [activityView sizeToFit];
  activityView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
                                  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  activityView.fadeInOut = YES;
  activityView.center = self.center;
  [self addSubview:activityView];
  self.activityView = activityView;

  UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
  label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  label.textAlignment = NSTextAlignmentCenter;
  label.numberOfLines = 0;
  [self addSubview:label];
  self.titleLabel = label;
}

#pragma mark - Scrolling

- (void)setScrollView:(UIScrollView *)scrollView {
  if (_scrollView != scrollView) {
    
    [self removeAllObservations];
    
    _scrollView = scrollView;
    self.loadMoreState = IGLoadMoreStatePending;
    
    if (scrollView != nil) {
      [self observeProperty:@keypath(self.scrollView.contentOffset)
                  withBlock:^(__weak id self, NSValue *old, NSValue *new) {
                    [self handleScrollViewContentOffset:new.CGPointValue];
                  }];
      [self observeProperty:@keypath(self.scrollView.contentSize)
                  withBlock:^(__weak id self, NSValue *old, NSValue *new) {
                    [self handleScrollViewContentOffset:[self scrollView].contentOffset];
                  }];
    }
  }
}

- (void)dealloc {
  [self removeAllObservations];
}

- (void)didMoveToSuperview {
  if (self.superview == nil) {
    [self removeAllObservations];
  } else {
    UIView *superview = self.superview;
    while (superview != nil) {
      if ([superview isKindOfClass:[UIScrollView class]]) {
        self.scrollView = (UIScrollView *)superview;
        break;
      }
      superview = superview.superview;
    }
  }

  [super didMoveToSuperview];
}

- (void)handleScrollViewContentOffset:(CGPoint)newOffset {
  //  NSLog(@"dragging: %d \r decelerating: %d", self.scrollView.dragging, self.scrollView.decelerating);

  if (self.superview == nil) {
    return;
  }
  CGRect frameInContainer = [self.scrollView.superview convertRect:self.frame fromView:self.superview];
  if (CGRectIsEmpty(frameInContainer) == YES) {
    return;
  }
//  CGFloat bottomY = CGRectGetMaxY(frameInContainer);
//  NSLog(@"BottomY: %f \r Size: %@", bottomY, NSStringFromCGSize(self.scrollView.contentSize));

  if (CGRectContainsRect(self.scrollView.frame, frameInContainer)) {
    if (self.loadMoreState == IGLoadMoreStatePending && self.scrollView.dragging == NO) {
      self.loadMoreState = self.startRefreshingOnVisible ? IGLoadMoreStateLoading : IGLoadMoreStateVisible;
    } else if (self.loadMoreState == IGLoadMoreStateVisible && self.scrollView.dragging == YES) {
      self.loadMoreState = IGLoadMoreStateLoading;
    }
  } else {
    if (self.loadMoreState == IGLoadMoreStateVisible && self.scrollView.dragging == NO) {
      self.loadMoreState = IGLoadMoreStatePending;
    }
  }
}

#pragma mark - States

- (void)setLoadMoreState:(IGLoadMoreState)loadMoreState {
  if (_loadMoreState != loadMoreState) {
    _loadMoreState = loadMoreState;
    
    [self handleLoadMoreState:loadMoreState];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    NSLog(@"Load more state: %d", loadMoreState);
  }
}

- (void)handleLoadMoreState:(IGLoadMoreState)newState {
  if (newState == IGLoadMoreStateLoading) {
    [self.activityView startAnimating];
    self.titleLabel.hidden = YES;
  } else {
    [self.activityView stopAnimating];
    self.titleLabel.hidden = NO;
  }
  [self updateTitle];
}

- (void)updateTitle {
  NSString *newTitle = self.titlesForState[@(self.loadMoreState)];
  newTitle = newTitle ? newTitle : self.titlesForState[@(IGLoadMoreStatePending)];
  self.titleLabel.text = newTitle ? newTitle : @"Pull";
}

- (void)setTitle:(NSString *)title forState:(IGLoadMoreState)loadMoreState {
  if (self.titlesForState == nil) {
    self.titlesForState = [NSMutableDictionary dictionary];
  }
  self.titlesForState[@(loadMoreState)] = title;
  
  [self updateTitle];
}
- (void)setRefreshingState:(IGLoadMoreState)refreshingState {
  
}

- (BOOL)isRefreshing {
  return self.loadMoreState == IGLoadMoreStateLoading;
}

- (void)startRefreshing {
  NSLog(@"Start refreshing");
  [self setLoadMoreState:IGLoadMoreStateLoading];
}

- (void)endRefreshing {
  NSLog(@"End refreshing");
  [self setLoadMoreState:self.loadMoreState == IGLoadMoreStateLoading ? IGLoadMoreStatePending : self.loadMoreState];
}

- (void)enableRefreshing {
  NSLog(@"Enable refreshing");
  [self setLoadMoreState:(self.loadMoreState == IGLoadMoreStateDisabled || self.loadMoreState == IGLoadMoreStateError)
                             ? IGLoadMoreStatePending
                             : self.loadMoreState];
}

- (void)disableRefreshing {
  NSLog(@"Disable refreshing");
  [self setLoadMoreState:IGLoadMoreStateDisabled];
}

- (void)showError {
  NSLog(@"Show error");
  [self setLoadMoreState:IGLoadMoreStateError];
}

@end
