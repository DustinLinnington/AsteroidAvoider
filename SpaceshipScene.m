//
//  SpaceshipScene.m
//  SpriteWalkThrough
//
//  Created by Ash Mishra on 2014-09-19.
//  Copyright (c) 2014 VFS. All rights reserved.
//

#import "SpaceshipScene.h"
#import <CoreMotion/CoreMotion.h>
#import "math.h"

@interface SpaceshipScene()

@property int hitCount;

// for motion control
@property CMMotionManager* motionManager;

// variables we use when moving the ship
@property CGFloat shipWidth;
@property CGFloat shipHeight;
@property CGFloat xMax;
@property CGFloat yMax;

@end

@implementation SpaceshipScene

/*** contact bit masks ***/

static const uint32_t rockCategory          =  0x1 << 1;
static const uint32_t shipCategory          =  0x1 << 2;
static const uint32_t astronautCategory     =  0x1 << 3;

// Max lives and lifegain
int maxHitCount = 1;
int astronautLifeGain = 3;

-(void) didMoveToView:(SKView *)view
{
    [self initSceneContents];
    [self initMotionManager];
}

-(void) initSceneContents{
    self.backgroundColor = [SKColor purpleColor];
    
    self.physicsWorld.contactDelegate = self;
    
    [self addSpaceShip];
    [self addClock];
    [self addLives];
    [self addRocks];
    [self addAstronauts];
    
}

-(void) initMotionManager {
    self.motionManager = [[CMMotionManager alloc] init];
    
    // how often we will check the accelerometer
    self.motionManager.accelerometerUpdateInterval = 1.0/60.0;
    
    // for reference in the update block
    __block SKSpriteNode* ship = (SKSpriteNode*) [self childNodeWithName:@"spaceship"];
    __block SKLabelNode* timeNode = (SKLabelNode*) [self childNodeWithName:@"time"];
    __block CGFloat time = 0;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        
        time += 0.1;
        timeNode.text = [NSString stringWithFormat:@"%.1f", time];
        
        CGFloat xDelta = accelerometerData.acceleration.x*10;
        CGFloat xPosition = ship.position.x;
        CGFloat newX = xDelta + xPosition;
        
        if (newX < self.shipWidth || newX > self.xMax)
            xDelta = 0;
        
        CGFloat yDelta = accelerometerData.acceleration.y*10;
        CGFloat yPosition = ship.position.y;
        CGFloat newY = yDelta + yPosition;
        if (newY < self.shipHeight || newY > self.yMax)
            yDelta = 0;
        
        if (newX > 0 || newY > 0)
        {
            SKAction* moveShip = [SKAction moveByX:xDelta y:yDelta duration:0];
            
            [ship runAction:moveShip];
        }
    }];
}

- (void) addSpaceShip {
    SKTexture *shipTexture = [SKTexture textureWithImageNamed:@"rocket.png"];
    
    SKSpriteNode *ship =[SKSpriteNode spriteNodeWithTexture:shipTexture];
    
    ship.name = @"spaceship";
    
    ship.xScale = 0.5;
    ship.yScale = 0.5;
    
    ship.physicsBody = [SKPhysicsBody bodyWithTexture:shipTexture alphaThreshold:0 size:ship.size];
    ship.physicsBody.dynamic = NO;
    
    // Adds the spaceship to a category then allows it to collide with and recieve collision
    // events from objects in the rock and astronaught bitmask categories
    ship.physicsBody.categoryBitMask = shipCategory;
    ship.physicsBody.collisionBitMask = rockCategory | astronautCategory;
    ship.physicsBody.contactTestBitMask = rockCategory | astronautCategory;
    
    SKEmitterNode* engineFlare = [self engineFlare];
    engineFlare.position = (CGPointMake(0, -ship.size.height+30));
    [ship addChild:engineFlare];
    
    ship.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    [self addChild:ship];
    
    self.shipHeight = ship.size.height;
    self.shipWidth = ship.size.width;
    self.xMax = self.frame.size.width - self.shipWidth;
    self.yMax = self.frame.size.height - self.shipHeight;
}

-(void) addRocks {
    SKAction* addRocksAction = [SKAction sequence:
                                @[

                                    [SKAction performSelector:@selector(addRockNode) onTarget:self],
                                    [SKAction waitForDuration:(0.39) withRange:0.15]

                                 ]
                                ];
    [self runAction:[SKAction repeatActionForever:addRocksAction]];
}

-(void) addAstronauts {
    
    SKAction* addAstronautsAction = [SKAction sequence:
                                @[
                                  [SKAction performSelector:@selector(addAstronautNode) onTarget:self],
                                  [SKAction waitForDuration:3.60 withRange:0.15]
                                  ]
                                ];
    
    [self runAction:[SKAction repeatActionForever:addAstronautsAction]];
}

- (void) addClock {
    
    SKLabelNode* timeNode = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica"];
    timeNode.name = @"time";
    timeNode.fontSize = 22;
    timeNode.text = @"0.0";
    timeNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    
    timeNode.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height-40);
    [self addChild:timeNode];
}

-(void) addLives {
    SKLabelNode* livesNode = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica"];
    livesNode.name = @"lives";
    livesNode.fontSize = 24;
    livesNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    
    livesNode.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height-530);
    [self addChild:livesNode];
    
}

-(void) didSimulatePhysics {
    
    [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0) {
            [node removeFromParent];
        }
    }];
    
    [self enumerateChildNodesWithName:@"astronaut" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0) {
            [node removeFromParent];
        }
    }];
}

-(void) addRockNode {
    SKSpriteNode* rock = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:CGSizeMake(15, 15)];
    
    rock.position = CGPointMake(skRand(0, self.size.width), skRand(self.size.height+100, self.size.height));
    rock.name = @"rock";
    rock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rock.size];
    rock.physicsBody.categoryBitMask = rockCategory;
    rock.physicsBody.usesPreciseCollisionDetection = YES;
    
    [self addChild:rock];
    
}

-(void) addAstronautNode {
    SKTexture *astronautTexture = [SKTexture textureWithImageNamed:@"astronaut-white.png"];
    SKSpriteNode *astronaut =[SKSpriteNode spriteNodeWithTexture:astronautTexture];
    
    astronaut.position = CGPointMake(skRand(0, self.size.width), skRand(self.size.height+100, self.size.height));
    astronaut.name = @"astronaut";
    astronaut.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:astronaut.size];
    astronaut.physicsBody.categoryBitMask = astronautCategory;
    astronaut.physicsBody.usesPreciseCollisionDetection = YES;
    
    [self addChild:astronaut];
    
}

-(void) didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *shipPhysicsBody;
    __block SKLabelNode* livesNode = (SKLabelNode*) [self childNodeWithName:@"lives"];
    
    if (contact.bodyA.categoryBitMask == shipCategory)
        shipPhysicsBody = contact.bodyA;
    else if (contact.bodyB.categoryBitMask == shipCategory)
        shipPhysicsBody = contact.bodyB;
    
    SKSpriteNode* ship = (SKSpriteNode*) shipPhysicsBody.node;
    
    // Checks to see whether the rocket was hit by an asteroid or an astronaut
    if (contact.bodyA.categoryBitMask == rockCategory
        || contact.bodyB.categoryBitMask == rockCategory)
    {
        SKAction* addDamage = [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:self.hitCount/maxHitCount duration:0];
        
        [ship runAction:addDamage];
        
        [self runAction:[SKAction playSoundFileNamed:@"asteroidHit.wav" waitForCompletion:NO]];
        
        ////this will change texture of hit asteroid
        //SKSpriteNode* bg = (SKSpriteNode* )rockPhysicsBody.node;
        //[bg runAction:[SKAction setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"astroid-explode.png"]]]];
        
        self.hitCount++;
        if (self.hitCount == maxHitCount)
            [self gameOver];
    }
    else
    {
        self.hitCount -= astronautLifeGain;
        
        if (self.hitCount < 0)
            self.hitCount = 0;
        
        [self runAction:[SKAction playSoundFileNamed:@"astronautHit.wav" waitForCompletion:NO]];
        
        
        
        [self enumerateChildNodesWithName:@"astronaut" usingBlock:^(SKNode *node, BOOL *stop) {
            [node removeFromParent];
        }];
    }
    
    livesNode.text = [NSString stringWithFormat:@"Lives Left: %d", maxHitCount - self.hitCount];

}

-(SKEmitterNode*) engineFlare {
    // add the flame
    NSString *burstPath = [[NSBundle mainBundle] pathForResource:@"Burst" ofType:@"sks"];
    
    SKEmitterNode *burstEmitter =[NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
    
    // change the angle of the fire emission to point down
    burstEmitter.emissionAngle = -1.571;
    
    // define the max width and height of each particle
    burstEmitter.particleSize = CGSizeMake(20,100);
    
    // define the X and Y variance of particle positions
    burstEmitter.particlePositionRange = CGVectorMake(10, 0);
    
    /**
     Normally the particles are rendered as if they were a child of the SKEmitterNode, they can also be rendered as if they were a child of any other node in the scene by setting the targetNode property. Defaults to nil (standard behavior).
     */
    [burstEmitter setTargetNode:self];
    
    return burstEmitter;
}

-(void) gameOver {
    
    [self removeAllActions];
    
    // stop the accelerometer!
    [self.motionManager stopAccelerometerUpdates];
    
    // add Game Over text
    [self addChild:self.createGameOverNode];
    [self addChild:self.createRestartGameNode];
    
    
    SKAction* zoomInAction = [SKAction group:
        @[
          [SKAction fadeAlphaTo:1.0 duration:0.25],
          [SKAction scaleXTo:1.0 y:1.0 duration:0.25]
          ]
    ];       
    
    SKAction* zoomOutAction = [SKAction group:
        @[
          [SKAction fadeAlphaTo:0.5 duration:0.25],
          [SKAction scaleXTo:0.9 y:0.9 duration:0.25]
         ]
        ];

    SKAction* showGameOverAction = [SKAction repeatActionForever:
              [SKAction sequence:@[
                                   zoomInAction,
                                   zoomOutAction]
                                ]
    ];
    
    SKNode* gameOverNode = [self childNodeWithName:@"gameover"];
    SKNode* restartGameNode = [self childNodeWithName:@"restart"];
    
    [gameOverNode runAction:showGameOverAction];
    [restartGameNode runAction:showGameOverAction];
}


-(SKLabelNode*) createGameOverNode {
    SKLabelNode* gameOverNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    gameOverNode.name = @"gameover";
    
    gameOverNode.text = @"GAME OVER";
    gameOverNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    gameOverNode.xScale = 0.1;
    gameOverNode.yScale = 0.1;
    gameOverNode.alpha = 0.0;
    
    return gameOverNode;
}

-(SKLabelNode*) createRestartGameNode {
    SKLabelNode* restartNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    restartNode.name = @"restart";
    
    restartNode.text = @"(tap to restart)";
    restartNode.position = CGPointMake(CGRectGetMidX(self.frame), (CGRectGetMidY(self.frame) - 35));
    restartNode.xScale = 0.1;
    restartNode.yScale = 0.1;
    restartNode.alpha = 0.0;
    
    return restartNode;
}

/**** C convenience functions ****/

static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high-low) + low;
}

@end
