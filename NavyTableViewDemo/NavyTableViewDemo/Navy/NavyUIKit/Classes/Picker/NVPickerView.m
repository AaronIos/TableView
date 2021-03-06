//
//  NVPickerView.m
//  Navy
//
//  Created by Astraea尊 on 16/01/10.
//  Copyright © 2016年 Astraea尊. All rights reserved.
//

#import "NVPickerView.h"
#import "NVBackgroundControl.h"
#import "NavyUIKit.h"




@implementation NVPickerDataModel

@end


@implementation NVPickerListModel

@end

#define TOOLBAR_COLOR [UIColor colorWithRed:255.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0]

@interface NVPickerView ()
<UIPickerViewDataSource,
UIPickerViewDelegate,
NVBackgroundControlDelegate>
@property (nonatomic, strong) UIView* uiToolbar;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIPickerView* uiPickerView;
- (void) onCancel:(id)sender;
- (void) onDone:(id)sender;
@end


#define HEIGHT_OF_TOOLBAR           (44.0f)
#define HEIGHT_OF_PICKER_VIEW       (214.0f)

@implementation NVPickerView


- (id) init {
    CGRect frame        = CGRectMake(0.0f, 0.0f, APPLICATIONWIDTH, HEIGHT_OF_PICKER_VIEW + HEIGHT_OF_TOOLBAR);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor    = COLOR_DEFAULT_WHITE;
        
        self.uiToolbar          = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                           0.0f,
                                                                           APPLICATIONWIDTH,
                                                                           HEIGHT_OF_TOOLBAR)];
        [self addSubview:self.uiToolbar];
        
        
        CALayer *layerLine      = [CALayer new];
        layerLine.frame         = CGRectMake(0,
                                              HEIGHT_OF_TOOLBAR,
                                              APPLICATIONWIDTH,
                                              LINE_HEIGHT);
        layerLine.backgroundColor = COLOR_LINE.CGColor;
        [self.layer addSublayer:layerLine];
        
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (HEIGHT_OF_TOOLBAR - 20.0f)/2, APPLICATIONWIDTH, 20)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = nvNormalFontWithSize(18.0f);
        [self.uiToolbar addSubview:_titleLabel];
        
        
        UIButton* button        = [[UIButton alloc] initWithFrame:CGRectMake(15.0f,
                                                                             (HEIGHT_OF_TOOLBAR - 20.0f)/2,
                                                                             60.0f,
                                                                             20.0f)];
        [self.uiToolbar addSubview:button];
        [button setTitle:@"取消" forState:UIControlStateNormal];
        [button setTitleColor:TOOLBAR_COLOR forState:UIControlStateNormal];
        button.titleLabel.font  = nvNormalFontWithSize(18.0f);
        [button addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
        
        
        button        = [[UIButton alloc] initWithFrame:CGRectMake(APPLICATIONWIDTH - 15.0f - 60.0f,
                                                                   (HEIGHT_OF_TOOLBAR - 20.0f)/2,
                                                                   60.0f,
                                                                   20.0f)];
        [self.uiToolbar addSubview:button];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button setTitleColor:TOOLBAR_COLOR forState:UIControlStateNormal];
        button.titleLabel.font  = nvNormalFontWithSize(18.0f);
        [button addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
        
        
        self.uiPickerView           = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                     HEIGHT_OF_TOOLBAR,
                                                                                     APPLICATIONWIDTH,
                                                                                     HEIGHT_OF_PICKER_VIEW)];
        [self addSubview:self.uiPickerView];
        self.uiPickerView.dataSource= self;
        self.uiPickerView.delegate  = self;
        
    }
    
    return self;
}


- (void) show {
    UIWindow* window        = [UIApplication sharedApplication].delegate.window;
    [self showInView:window];
}

- (void) showInView:(UIView *)view {
    CGRect bounds = view.bounds;
    NVBackgroundControl* bgControl  = [[NVBackgroundControl alloc] initWithFrame:CGRectMake(0.0f,
                                                                                            0.0f,
                                                                                            bounds.size.width,
                                                                                            bounds.size.height)];
    [view addSubview:bgControl];
    bgControl.delegate      = self;
    [bgControl addSubview:self];
    [bgControl show];
    
    __block CGRect frame    = CGRectMake((bounds.size.width - self.frame.size.width)/2,
                                         bounds.size.height,
                                         self.frame.size.width,
                                         self.frame.size.height);
    self.frame              = frame;
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         frame.origin.y = bounds.size.height - self.frame.size.height;
                         self.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         
                     }];

}

- (void) hide {
    NVBackgroundControl* bgControl = (NVBackgroundControl*)self.superview;
    if (bgControl) {
        CGRect bounds = bgControl.bounds;
        __block CGRect frame    = CGRectMake((bounds.size.width - self.frame.size.width)/2,
                                             bounds.size.height - self.frame.size.height,
                                             self.frame.size.width,
                                             self.frame.size.height);
        self.frame              = frame;
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             frame.origin.y = bounds.size.height;
                             self.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             [bgControl removeFromSuperview];
                         }];
    }
    
}


- (void) setColorToolbar:(UIColor *)colorToolbar {
    _colorToolbar = colorToolbar;
    
    self.uiToolbar.backgroundColor      = _colorToolbar;
}

-(void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}

- (void) onCancel:(id)sender {
    [self hide];
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(didDismissAtPickerView:)]) {
        [self.delegate didDismissAtPickerView:self];
    }
}

- (void) onDone:(id)sender {
    [self hide];
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(pickerView:didSelectItems:)]) {
        NVPickerListModel* listModels = [[NVPickerListModel alloc] init];
        
        NSInteger count = [self.arrayPickerDataModel count];
        for (NSInteger i = 0; i < count; i++) {
            NSInteger index                 = [self.uiPickerView selectedRowInComponent:i];
            NVPickerListModel* listModel    = [self.arrayPickerDataModel objectAtIndex:i];
            NVPickerDataModel* item         = [listModel.items objectAtIndex:index];
            
            [listModels.items addObject:item];
        }
        
        [self.delegate pickerView:self didSelectItems:listModels];
    }
}


#pragma mark - NVBackgroundControlDelegate
- (void) didTouchUpInsideOnBackgroundControl:(NVBackgroundControl *)control {
    [self hide];
}


#pragma mark - UIPickerViewDataSource
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [self.arrayPickerDataModel count];
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NVPickerListModel* listModel    = [self.arrayPickerDataModel objectAtIndex:component];
    return [listModel.items count];
}

#pragma mark - UIPickerViewDelegate
//- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    NVPickerListModel* listModel    = [self.arrayPickerDataModel objectAtIndex:component];
//    NVPickerDataModel* dataModel    = [listModel.items objectAtIndex:row];
//    
//    return dataModel.title;
//}

- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NVPickerListModel* listModel    = [self.arrayPickerDataModel objectAtIndex:component];
    NVPickerDataModel* dataModel    = [listModel.items objectAtIndex:row];
    
    NSAttributedString* attributedString = nil;
    attributedString = [[NSAttributedString alloc] initWithString:dataModel.title
                                                       attributes:ATTR_DICTIONARY(COLOR_HM_BLACK, 18.0f + fontScale)];
    return attributedString;
}


@end


