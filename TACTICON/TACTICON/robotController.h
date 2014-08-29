//
//  robotController.h
//  TACTICON
//
//  Created by [CHY]Jomkwan  on 5/4/57.
//  Copyright (c) พ.ศ. 2557 Jomkwan . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "BLE.h"

@interface robotController : UIViewController<MCBrowserViewControllerDelegate,MCSessionDelegate,UITextFieldDelegate,BLEDelegate>

{
    CMMotionManager *motionManager;
    NSOperationQueue *operationQuene;
    NSTimer *timer;
    AVAudioPlayer *audioPlayer;
    
@public float yawAngle;
@public float pitchAngle;
@public float rollAngle;
    
@public int pitchHitZero;
@public Boolean firingPositionEngage;
@public Boolean readyToFire;
@public CGPoint sliderOriginPos;
    
@public Boolean iAmConnect;
@public int hitSum;
    
@public Boolean turningLeftBool;
@public Boolean turningRightBool;
@public Boolean onMotion;
    
@public float attack;
@public float damage;
@public float attackSent;
@public float damageReceived;
    
@public Boolean onLine;
@public Boolean aimingPose;
@public Boolean isAnimationON;
    
@public float blinkTime;
    @public int blinkTimeInt;
    
@public int currentGunHoldingis;
@public int laserGun;
@public int catGun;
@public int gaterlingGun;

    

    
    //----RESET
@public float originPitch;
@public float originRoll;
@public float originYaw;
    
@public float rotationSpeed;
@public CGPoint scrollPoint;
}

@property (strong,nonatomic)BLE *ble;

//----MCConnect----
@property(nonatomic, strong)MCBrowserViewController *browserVC;
@property(nonatomic, strong)MCAdvertiserAssistant *advertiser;
@property(nonatomic, strong)MCSession *mySession;
@property(nonatomic, strong)MCPeerID *myPeerID;
//-----------------

//--UI---

@property (weak, nonatomic) IBOutlet UIImageView *spinCen1;
@property (weak, nonatomic) IBOutlet UIImageView *spinCen2;
@property (weak, nonatomic) IBOutlet UIImageView *spinCen3;
@property (weak, nonatomic) IBOutlet UIImageView *spinCen4;

//Right
@property (weak, nonatomic) IBOutlet UIImageView *spinRight1;
@property (weak, nonatomic) IBOutlet UIImageView *spinRight2;
@property (weak, nonatomic) IBOutlet UIImageView *spinRight3;
@property (weak, nonatomic) IBOutlet UIImageView *spinRight4;
@property (weak, nonatomic) IBOutlet UIImageView *spinRight5;

//Left
@property (weak, nonatomic) IBOutlet UIImageView *spinLeft1;
@property (weak, nonatomic) IBOutlet UIImageView *spinLeft2;
@property (weak, nonatomic) IBOutlet UIImageView *spinLeft3;
@property (weak, nonatomic) IBOutlet UIImageView *spinLift4;
@property (weak, nonatomic) IBOutlet UIImageView *spinLeft5;

//Reset
- (IBAction)resetOriginPosition:(id)sender;

//ShowHpEn
@property (weak, nonatomic) IBOutlet UIImageView *enRing1;
@property (weak, nonatomic) IBOutlet UIImageView *enRing2;
//HP Font
@property (weak, nonatomic) IBOutlet UILabel *myHPTxt;//////
//En HP
@property (weak, nonatomic) IBOutlet UILabel *enemysHP;

//Connection
@property (weak, nonatomic) IBOutlet UIButton *connectRobotTxt;
- (IBAction)connectRobot:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *connectNetWorkTxt;
- (IBAction)connnectNetWork:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *systemStatustxt;
@property (weak, nonatomic) IBOutlet UILabel *networkStatustxt;
- (IBAction)turnRight:(id)sender;
- (IBAction)turnLeft:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *myHpTxt;//////
@property (weak, nonatomic) IBOutlet UILabel *rightTxt;
@property (weak, nonatomic) IBOutlet UILabel *leftTxt;
- (IBAction)resetOrigin:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *resetTxt;

//Face
@property (weak, nonatomic) IBOutlet UIImageView *faceBase;
@property (weak, nonatomic) IBOutlet UIImageView *faceMouth;
@property (weak, nonatomic) IBOutlet UIImageView *faceGundam;
@property (weak, nonatomic) IBOutlet UIImageView *faceEyes;
//Gun Interface
@property (weak, nonatomic) IBOutlet UIImageView *gunBase;
@property (weak, nonatomic) IBOutlet UIImageView *gunSlider;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spiner01;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spiner02;
//View
@property (weak, nonatomic) IBOutlet UIView *rightBox;
@property (weak, nonatomic) IBOutlet UIView *leftBox;
@property (weak, nonatomic) IBOutlet UIView *slinderBox;

@end
