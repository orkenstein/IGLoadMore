//
//  IGLoadMoreControl.h
//  iGames
//
//  Created by orkenstein on 03.06.14.
//  Copyright (c) 2014 A&J Apps LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
  IGLoadMoreStateUnknown = 0,
  IGLoadMoreStatePending,
  IGLoadMoreStateVisible,
  IGLoadMoreStateLoading,
  IGLoadMoreStateDisabled,
  IGLoadMoreStateError
} IGLoadMoreState;

@interface IGLoadMoreControl : UIControl
@property (nonatomic, readonly) IGLoadMoreState loadMoreState;
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, assign) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL startRefreshingOnVisible;

- (void)setTitle:(NSString*)title forState:(IGLoadMoreState)loadMoreState;
- (BOOL)isRefreshing;
- (void)startRefreshing;
- (void)endRefreshing;
- (void)disableRefreshing;
- (void)enableRefreshing;
- (void)showError;

@end
