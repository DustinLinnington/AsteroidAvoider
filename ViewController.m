//
//  ViewController.m
//  SpriteWalkThrough
//
//  Created by Ash Mishra on 2014-09-18.
//  Copyright (c) 2014 VFS. All rights reserved.
//

#import "ViewController.h"
#import "HelloScene.h"
#import <SpriteKit/SpriteKit.h>

@interface ViewController ()

@property SKView* spriteView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.spriteView = (SKView*) self.view;
    self.spriteView.showsDrawCount = YES;
    self.spriteView.showsNodeCount = YES;
    self.spriteView.showsFPS = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    HelloScene* hello = [[HelloScene alloc] initWithSize:self.spriteView.frame.size];
    [self.spriteView presentScene:hello];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void) viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
}

- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motion occurring");
}

@end
