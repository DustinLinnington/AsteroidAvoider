//
//  HelloScene.m
//  SpriteWalkThrough
//
//  Created by Ash Mishra on 2014-09-18.
//  Copyright (c) 2014 VFS. All rights reserved.
//

#import "HelloScene.h"
#import "SpaceshipScene.h"
#import <SpriteKit/SpriteKit.h>

@interface HelloScene()

@property BOOL contentCreated;

@end

@implementation HelloScene

NSString* const kHelloNodeName = @"helloNode";

- (void) didMoveToView:(SKView *)view {
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

-(void) createSceneContents {
    self.backgroundColor = [SKColor redColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    [self addChild:self.helloNode];
}

-(SKLabelNode*) helloNode {
    SKLabelNode *helloNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    helloNode.name = kHelloNodeName;
    helloNode.text = @"Avoid the Asteroids!";
    helloNode.fontSize = 24;
    helloNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    return helloNode;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    SKNode* helloNode = [self childNodeWithName:kHelloNodeName];
    if (helloNode==nil) return;
    
    SKAction* moveUp = [SKAction moveByX:0 y:100 duration:0.5];
    SKAction* zoom = [SKAction scaleTo:0 duration:0.25];
    SKAction* remove = [SKAction removeFromParent];
    
    SKAction* moveSequence = [SKAction sequence:@[moveUp, zoom, remove]];
    
    [helloNode runAction:moveSequence completion:^{
        SKScene *shipScene = [[SpaceshipScene alloc] initWithSize:self.size];
        
        // animation between scenes
        SKTransition* doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
        [self.view presentScene:shipScene transition:doors];
    }];
    
}

@end
