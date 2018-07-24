//
//  DialView.h
//  MyTest
//
//  Created by PeteyMi on 22/07/2018.
//  Copyright © 2018 PeteyMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DialView;

@protocol DialViewDelegate <NSObject>

- (void)dialView:(DialView*)view angleChangeValue:(CGFloat)value;

@end

@interface DialView : UIView

@property (nonatomic, strong) UIColor   *scaleColor;
@property (nonatomic, assign) CGFloat   angleValue;
@property (nonatomic, weak) id      delegate;

@end
