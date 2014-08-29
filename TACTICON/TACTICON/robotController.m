//
//  robotController.m
//  TACTICON
//
//  Created by [CHY]Jomkwan  on 5/4/57.
//  Copyright (c) พ.ศ. 2557 Jomkwan . All rights reserved.
//

#import "robotController.h"
#import <GLKit/GLKit.h>

@interface robotController ()

@end

@implementation robotController
@synthesize myHPTxt,enemysHP,connectNetWorkTxt,connectRobotTxt,systemStatustxt,networkStatustxt,spinCen1,spinCen2,spinCen3,spinCen4,spinLeft1,spinLeft2,spinLeft3,spinLeft5,spinLift4,spinRight1,spinRight2,spinRight3,spinRight4,spinRight5,enRing1,enRing2,resetTxt,leftTxt,rightTxt,faceBase,faceEyes,faceGundam,faceMouth,gunBase,gunSlider,ble,spiner01,spiner02,leftBox,rightBox,slinderBox;

#define degrees(x) (180 * x / M_PI)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    onMotion = NO;
    turningLeftBool = NO;
    turningRightBool = NO;
    isAnimationON = NO;
	[myHPTxt setFont:[UIFont fontWithName:@"Digit" size:myHPTxt.font.pointSize]];
    [enemysHP setFont:[UIFont fontWithName:@"Digit" size:enemysHP.font.pointSize]];
    [connectNetWorkTxt setFont:[UIFont fontWithName:@"Digitaltech" size:connectNetWorkTxt.font.pointSize]];
    [connectRobotTxt setFont:[UIFont fontWithName:@"Digitaltech" size:connectRobotTxt.font.pointSize]];
    [systemStatustxt setFont:[UIFont fontWithName:@"Digitaltech" size:systemStatustxt.font.pointSize]];
    [networkStatustxt setFont:[UIFont fontWithName:@"Digitaltech" size:networkStatustxt.font.pointSize]];
    
    rotationSpeed = 1.0f;
    currentGunHoldingis = laserGun;
    
    iAmConnect = NO;
    sliderOriginPos = CGPointMake(slinderBox.center.x, slinderBox.center.y);
    //----MCConnect----
    [self setUpMutipeer];
    //----BLE----------
    ble = [[BLE alloc]init];
    [ble controlSetup:1];
    ble.delegate = self;
    //----MotionManager----
    motionManager = [[CMMotionManager alloc]init];
    motionManager.deviceMotionUpdateInterval = 1/60;
    
    laserGun = 1;
    catGun = 2;
    gaterlingGun = 3;
    
}

-(void)read
{
    CMAttitude *attitude;
    CMDeviceMotion *motion = motionManager.deviceMotion;
    attitude = motion.attitude;
    

    
    yawAngle = degrees(attitude.yaw);
    pitchAngle = degrees(attitude.pitch);
    rollAngle = degrees(attitude.roll);
    
    static Boolean inZeroRange_motion;
    static Boolean openFire;
    
    static int onCountingForward;
    
    
    //----hitting 0 counting
    if (originPitch + pitchAngle <= 20.0f &&  originPitch + pitchAngle >= -20.0f) {
        if (!inZeroRange_motion) {
            pitchHitZero++;
            
        }
        inZeroRange_motion = YES;
    } else {
        inZeroRange_motion = NO;
    }
    if (pitchHitZero > 1) {
        onMotion = YES;
    }
    //----resetting  pitchHitZero
    if (pitchHitZero == 2) {
        onCountingForward++;
        /////// move moter here!!!
        
        
        UInt8 buf[3] = {0x01, 0x00, 0x00};
        if (originRoll+rollAngle > -45 ) {
            buf[1] = 0x01;
        }
        else {
            buf[1] = 0x02;
        }
        
        if (turningLeftBool) {
            NSLog(@"TurnLeft");
             buf[2] = 20.0f;
        }
        else if (turningRightBool)
        {
            NSLog(@"TurnRight");
            buf[2] = 160.0f;
        }
        else
        {
            buf[2] = 90.0f;
        }
        
        NSData *data = [[NSData alloc]initWithBytes:buf length:3];
        [ble write:data];
        
        ////////
        pitchHitZero = 0;
        onMotion = NO;
    }
    
    //----shooting Part
    //----setting shooting position
    if (yawAngle - originYaw <= -50.0f && yawAngle  - originYaw >= -120.0f) {
        if (!firingPositionEngage) {
            firingPositionEngage = YES;
            pitchHitZero = 0;
        }
    } else {
        firingPositionEngage = NO;
    }
    //-----Hidden UIView
    if (firingPositionEngage) {
        
        leftBox.hidden = YES;
        rightBox.hidden = YES;
        
        slinderBox.hidden = NO;
        gunBase.hidden = NO;
        gunSlider.hidden = NO;
        
        //---- firing protocall
        if (pitchAngle <= 10.0f && pitchAngle >= -10.0f) {
            if (!aimingPose) {
                aimingPose = YES;
            }
        }
        if (pitchAngle <= 90.0f && pitchAngle >= 50.0f) {
            if (!openFire) {
                openFire = YES;
            }
        } else {
            openFire = NO;
        }
    
        
        if (openFire && aimingPose && readyToFire) {
            ///Fire HERE!!!!!!!!!!!!!!!
            UInt8 buf[3] = {0x02, 0x00, 0x00};
            if (currentGunHoldingis == laserGun) {
                buf[1] = 0x01;
            }
            else if (currentGunHoldingis == catGun){
                buf[1] = 0x02;
            }
            else if (currentGunHoldingis == gaterlingGun){
                buf[1] = 0x03;
            }
            NSData *data = [[NSData alloc]initWithBytes:buf length:3];
            [ble write:data];
            /////////////
            NSString *audioBarretaPath = [[NSBundle mainBundle]pathForResource:@"barreta_m9"
                                                                        ofType:@"wav"];
            NSURL *audioBarretaURL = [NSURL fileURLWithPath:audioBarretaPath];
            audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:audioBarretaURL
                                                                error:nil];
            [audioPlayer play];
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            openFire  = NO;
            aimingPose = NO;
            readyToFire = NO;
        }
        
        ///////// firing protocall END
        
    } else {
        if (onLine) {
            
 
            leftBox.hidden = NO;
            rightBox.hidden = NO;
            
        }
        
        
        slinderBox.hidden = YES;
        gunSlider.hidden = YES;
        gunBase.hidden = YES;
        
        readyToFire = NO;
        openFire  = NO;
        aimingPose = NO;
    }
    
    blinkTime += 0.1f;
    blinkTimeInt = roundf(blinkTime);
    if (onLine) {
        
    if (blinkTimeInt%7 == 0) {
        UIImage *image = [UIImage imageNamed: @"faceBlinkEyes.png"];
        [faceEyes setImage:image];
    }
    else
    {
        UIImage *image = [UIImage imageNamed: @"faceOpenEyes.png"];
        [faceEyes setImage:image];
    }
    }
    else
    {
        UIImage *image = [UIImage imageNamed: @"faceBlinkEyes.png"];
        [faceEyes setImage:image];
    }
    
    //----Animation Spinning Center
    
    CABasicAnimation* rotationspinCen1;
    rotationspinCen1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationspinCen1.toValue = [NSNumber numberWithFloat:  M_PI  *2.0 * 30.0 *  rotationSpeed];
    rotationspinCen1.cumulative = YES;
    rotationspinCen1.repeatCount = 1.0;
    rotationspinCen1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [spinCen1.layer addAnimation:rotationspinCen1 forKey:@"rotationspinCen1"];
    
    CABasicAnimation* rotationspinCen2;
    rotationspinCen2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationspinCen2.toValue = [NSNumber numberWithFloat:  M_PI  *2.0 * 100.0 *  rotationSpeed];
    rotationspinCen2.cumulative = YES;
    rotationspinCen2.repeatCount = 1.0;
    rotationspinCen2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [spinCen2.layer addAnimation:rotationspinCen2 forKey:@"rotationspinCen2"];
    
    CABasicAnimation* rotationspinCen3;
    rotationspinCen3 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationspinCen3.toValue = [NSNumber numberWithFloat:  M_PI  *2.0 * 200.0 *  rotationSpeed * -1.0];
    rotationspinCen3.cumulative = YES;
    rotationspinCen3.repeatCount = 1.0;
    rotationspinCen3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [spinCen3.layer addAnimation:rotationspinCen3 forKey:@"rotationspinCen3"];
    
    CABasicAnimation* rotationspinCen4;
    rotationspinCen4 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationspinCen4.toValue = [NSNumber numberWithFloat:  M_PI  *2.0 * 200.0 *  rotationSpeed];
    rotationspinCen4.cumulative = YES;
    rotationspinCen4.repeatCount = 1.0;
    rotationspinCen4.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [spinCen4.layer addAnimation:rotationspinCen4 forKey:@"rotationspinCen4"];
    
    //----spinLeft
    
    CABasicAnimation* animeSpinLeft1;
    animeSpinLeft1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animeSpinLeft1.toValue = [NSNumber numberWithFloat: M_PI  *2.0 * 30.0 *  rotationSpeed * -1.0];
    animeSpinLeft1.cumulative = YES;
    animeSpinLeft1.repeatCount = 1.0;
    animeSpinLeft1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [spinLeft1.layer addAnimation:animeSpinLeft1 forKey:@"animeSpinLeft1"];
    
    CABasicAnimation* animeSpinLeft2;
    animeSpinLeft2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animeSpinLeft2.toValue = [NSNumber numberWithFloat: M_PI  *2.0 * 30.0 *  rotationSpeed * 1.0];
    animeSpinLeft2.cumulative = YES;
    animeSpinLeft2.repeatCount = 1.0;
    animeSpinLeft2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [spinLeft2.layer addAnimation:animeSpinLeft2 forKey:@"animeSpinLeft2"];
    
    CABasicAnimation* animeSpinLeft3;
    animeSpinLeft3 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animeSpinLeft3.toValue = [NSNumber numberWithFloat: M_PI  *2.0 * 300.0 *  rotationSpeed * -1.0];
    animeSpinLeft3.cumulative = YES;
    animeSpinLeft3.repeatCount = 1.0;
    animeSpinLeft3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [spinLeft3.layer addAnimation:animeSpinLeft3 forKey:@"animeSpinLeft3"];
    
    
    CABasicAnimation* animeSpinLeft4;
    animeSpinLeft4 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animeSpinLeft4.toValue = [NSNumber numberWithFloat: M_PI  *2.0 * 100.0 *  rotationSpeed * -1.0];
    animeSpinLeft4.cumulative = YES;
    animeSpinLeft4.repeatCount = 1.0;
    animeSpinLeft4.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [spinLift4.layer addAnimation:animeSpinLeft4 forKey:@"animeSpinLeft4"];
    
    CABasicAnimation* animeSpinLeft5;
    animeSpinLeft5 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animeSpinLeft5.toValue = [NSNumber numberWithFloat: M_PI  *2.0 * 30.0 *  rotationSpeed * -1.0];
    animeSpinLeft5.cumulative = YES;
    animeSpinLeft5.repeatCount = 1.0;
    animeSpinLeft5.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [spinLeft5.layer addAnimation:animeSpinLeft5 forKey:@"animeSpinLeft5"];
    
    //----spinRight
    
    CABasicAnimation* animeSpinRight1;
    animeSpinRight1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animeSpinRight1.toValue = [NSNumber numberWithFloat: M_PI  *2.0 * 30.0 *  rotationSpeed * 1.0];
    animeSpinRight1.cumulative = YES;
    animeSpinRight1.repeatCount = 1.0;
    animeSpinRight1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [spinRight1.layer addAnimation:animeSpinRight1 forKey:@"animeSpinRight1"];
    
    CABasicAnimation* animeSpinRight2;
    animeSpinRight2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animeSpinRight2.toValue = [NSNumber numberWithFloat: M_PI  *2.0 * 30.0 *  rotationSpeed * -1.0];
    animeSpinRight2.cumulative = YES;
    animeSpinRight2.repeatCount = 1.0;
    animeSpinRight2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [spinRight1.layer addAnimation:animeSpinRight1 forKey:@"animeSpinRight1"];
    
    CABasicAnimation* animeSpinRight3;
    animeSpinRight3 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animeSpinRight3.toValue = [NSNumber numberWithFloat: M_PI  *2.0 * 300.0 *  rotationSpeed * 1.0];
    animeSpinRight3.cumulative = YES;
    animeSpinRight3.repeatCount = 1.0;
    animeSpinRight3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [spinRight3.layer addAnimation:animeSpinRight2 forKey:@"animeSpinRight3"];
    
    CABasicAnimation* animeSpinRight4;
    animeSpinRight4 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animeSpinRight4.toValue = [NSNumber numberWithFloat: M_PI  *2.0 * 100.0 *  rotationSpeed * 1.0];
    animeSpinRight4.cumulative = YES;
    animeSpinRight4.repeatCount = 1.0;
    animeSpinRight4.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [spinRight4.layer addAnimation:animeSpinRight4 forKey:@"animeSpinRight4"];
    
    CABasicAnimation* animeSpinRight5;
    animeSpinRight5 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animeSpinRight5.toValue = [NSNumber numberWithFloat: M_PI  *2.0 * 30.0 *  rotationSpeed * 1.0];
    animeSpinRight5.cumulative = YES;
    animeSpinRight5.repeatCount = 1.0;
    animeSpinRight5.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [spinRight5.layer addAnimation:animeSpinRight5 forKey:@"animeSpinRight5"];
    

    
    
   
    if(!isAnimationON){
    [spinLeft1.layer removeAllAnimations];
    [spinLeft2.layer removeAllAnimations];
    [spinLeft3.layer removeAllAnimations];
    [spinLift4.layer removeAllAnimations];
    [spinLeft5.layer removeAllAnimations];
        
    [spinRight1.layer removeAllAnimations];
    [spinRight2.layer removeAllAnimations];
    [spinRight3.layer removeAllAnimations];
    [spinRight4.layer removeAllAnimations];
    [spinRight5.layer removeAllAnimations];
    
    [spinCen1.layer removeAllAnimations];
    [spinCen2.layer removeAllAnimations];
    [spinCen3.layer removeAllAnimations];
    [spinCen4.layer removeAllAnimations];
    }
    
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        
        if ( aimingPose && readyToFire) {
            ///Fire HERE!!!!!!!!!!!!!!!
            
            UInt8 buf[3] = {0x02, 0x00, 0x00};
            buf[1] = 0x01;
            NSData *data = [[NSData alloc]initWithBytes:buf length:3];
            [ble write:data];
            
            
            /////////////
            NSString *audioBarretaPath = [[NSBundle mainBundle]pathForResource:@"barreta_m9"
                                                                        ofType:@"wav"];
            NSURL *audioBarretaURL = [NSURL fileURLWithPath:audioBarretaPath];
            audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:audioBarretaURL
                                                                error:nil];
            [audioPlayer play];
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            aimingPose = NO;
            readyToFire = NO;
        }
    } 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resetOriginPosition:(id)sender {
}
- (IBAction)connectRobot:(id)sender {
    if (ble.activePeripheral)
        if (ble.activePeripheral.isConnected)
        {
            [[ble CM]cancelPeripheralConnection:[ble activePeripheral]];
            [connectRobotTxt setTitle:@"CONNECT" forState:UIControlStateNormal];
            return;
        }
    if (ble.peripherals)
        ble.peripherals = nil;
    [ble findBLEPeripherals:2];
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0
                                     target:self
                                   selector:@selector(connectionTimer:)
                                   userInfo:nil
                                    repeats:NO];
    faceEyes.hidden = YES;
    [self.spiner01 startAnimating];
    [self.spiner02 startAnimating];
    
    
}
- (IBAction)connnectNetWork:(id)sender {
    [self presentViewController:self.browserVC animated:YES completion:nil];
}
-(void)turningRight:(UIGestureRecognizer *)sender
{
    turningRightBool = YES;
    if (!onMotion) {
        UInt8 buf[3] = {0x00, 0x00, 0x00};
        
        float turnRightValue = 180.0f;
        buf[2] = 160.0f;
        //buf[1] = 180.0f;
        //buf[2] = (int)turnRightValue >> 8;
        
        if ([sender state]==UIGestureRecognizerStateEnded) {
            turningRightBool = NO;
            NSLog(@"END TURNING");
            turnRightValue = 90.0f;
            buf[2] = 90.0f;
            //buf[1] = 90.0f;
            //buf[2] = (int)turnRightValue >> 8;
            
        }
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];
    }
    if ([sender state]==UIGestureRecognizerStateEnded) {
        turningRightBool = NO;
    }
}
-(void)turningLeft:(UIGestureRecognizer *)sender
{
    NSLog(@"%@",sender);
    turningLeftBool = YES;
    if (!onMotion) {
        UInt8 buf[3] = {0x03, 0x00, 0x00};
        float turnLeftValue = 0.0f;
        buf[2] = 20.0f;
        //buf[1] = 0.0f;
        //buf[2] = (int)turnLeftValue >> 8;
        
        if ([sender state]==UIGestureRecognizerStateEnded) {
            NSLog(@"END TURNING");
            turnLeftValue = 90.0f;
             buf[2] = 90.0f;
            //buf[1] = 90.0f;
            //buf[2] = (int)turnLeftValue >> 8;
            turningLeftBool = NO;
            
        }
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];
    }
    if ([sender state]==UIGestureRecognizerStateEnded) {
        turningLeftBool = NO;
    }

}

-(void)slidingLikeABoss:(UIPanGestureRecognizer *)sender
{
    NSString *audioReloadPath = [[NSBundle mainBundle]pathForResource:@"shotgun-reload"
                                                               ofType:@"wav"];
    NSURL *audioRelaodURL = [NSURL fileURLWithPath:audioReloadPath];
    static float slideX;
    CGPoint translation = [sender translationInView:slinderBox];
    sender.view.center = CGPointMake(translation.x, sender.view.center.y);
    slideX = translation.x;
    
  
    if (slideX >= 250.0f) {
        if (!readyToFire) {
            readyToFire = YES;
        }
    }
    if ([sender state]==UIGestureRecognizerStateEnded) {
        sender.view.center = CGPointMake(sliderOriginPos.x, sliderOriginPos.y);
        
        
        audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:audioRelaodURL
                                                            error:nil];
        [audioPlayer play];
    }
    
    gunSlider.center = CGPointMake(sender.view.center.x, sender.view.center.y);
}

- (IBAction)turnRight:(id)sender {
    
}

- (IBAction)turnLeft:(id)sender {
    }
- (IBAction)resetOrigin:(id)sender {
    originPitch = pitchAngle;
    originRoll = rollAngle;
    originYaw = yawAngle;
}
//----BLE----

-(void)bleDidDisconnect
{
    isAnimationON = NO;
    onLine = NO;
    
    myHPTxt.hidden = YES;
    UIImage *image = [UIImage imageNamed: @"faceBlinkEyes.png"];
    [faceEyes setImage:image];
    
    
    //[systemStatustxt setTextColor:[UIColor redColor]];
    //[self.connectRobotTxt setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.connectRobotTxt setTitle:@"CONNECT" forState:UIControlStateNormal];
    [self.systemStatustxt setText:@"SYSTEM OFFLINE"];
    //intBGimg.hidden = NO;
    [motionManager stopDeviceMotionUpdates];
    
    NSString *audioSystemOffline = [[NSBundle mainBundle]pathForResource:@"offline"
                                                                  ofType:@"wav"];
    NSURL *audioOfflineURL = [NSURL fileURLWithPath:audioSystemOffline];
    audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:audioOfflineURL
                                                        error:nil];
    
    [audioPlayer play];
    iAmConnect = NO;
    
    
    
    
}

-(void)bleDidConnect
{
    
    myHPTxt.hidden = NO;
    onLine = YES;
    isAnimationON = YES;
    
    [self.spiner01 stopAnimating];
    [self.spiner02 stopAnimating];
    faceEyes.hidden = NO;
    UIImage *image = [UIImage imageNamed: @"faceOpenEyes.png"];
    [faceEyes setImage:image];
    
    
    
    [self.connectRobotTxt setTitle:@"DISCONNECT"
                             forState:UIControlStateNormal];
    [self.systemStatustxt setText:@"SYSTEM ONLINE"];
    
    
    if (!iAmConnect) {
        NSString *audioSystemOnline = [[NSBundle mainBundle]pathForResource:@"online"
                                                                     ofType:@"wav"];
        NSURL *audioOnlineURL = [NSURL fileURLWithPath:audioSystemOnline];
        audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:audioOnlineURL
                                                            error:nil];
        
        [audioPlayer play];
        iAmConnect = YES;
        
 
    }
    
    
    ////
    [motionManager startDeviceMotionUpdates];
    if ([motionManager isGyroAvailable]) {
        if (![motionManager isGyroActive]) {
            [motionManager setGyroUpdateInterval:.1];
            [motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
                                       withHandler:^(CMGyroData *gyroData, NSError *error) {
                                           //
                                       }];
        }
    } else {
        UIAlertView *alret = [[UIAlertView alloc]initWithTitle:@"NO GYRO"
                                                       message:@"NO GYRO DETECTED"
                                                      delegate:self
                                             cancelButtonTitle:@"FUCK"
                                             otherButtonTitles:nil];
        [alret show];
    }
    UILongPressGestureRecognizer *longLeftHold =
    [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                 action:@selector(turningRight:)];
    longLeftHold.minimumPressDuration = 0.01;
    [leftBox addGestureRecognizer:longLeftHold];
    
    UILongPressGestureRecognizer *longRightHold =
    [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                 action:@selector(turningLeft:)];
    longRightHold.minimumPressDuration = 0.01;
    [rightBox addGestureRecognizer:longRightHold];
    

    
 
    UIPanGestureRecognizer *slindingBox =
    [[UIPanGestureRecognizer alloc]initWithTarget:self
                                           action:@selector(slidingLikeABoss:)];
    [slindingBox setMinimumNumberOfTouches:1];
    [slindingBox setMaximumNumberOfTouches:1];
    [slinderBox addGestureRecognizer:slindingBox];
  
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.05 target:self
                                           selector:@selector(read)
                                           userInfo:nil
                                            repeats:YES];
    
    
    
    
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    static int myHp = 999;
    for (int i = 0; i < length; i+=3) {
        if (data[i] == 0x0A) {
            if (data[i + 1] == 0x01) {
                //NSLog(@"0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
                myHp = myHp - 10;
                myHPTxt.text = [NSString stringWithFormat:@"%d",myHp];
                }
            else if (data[i + 1] == 0x02){
                myHp = myHp - 3;
                myHPTxt.text = [NSString stringWithFormat:@"%d",myHp];
                }
            else if (data[i + 1]== 0x03){
                myHp = myHp - 30;
                myHPTxt.text = [NSString stringWithFormat:@"%d",myHp];
            }
        }
        else if (data[i] == 0x0B){
                if (data[i + 1] == 0x01) {
                    currentGunHoldingis = laserGun;
                }
                else if (data[i + 1] == 0x02){
                    currentGunHoldingis = catGun;
                }
                else if (data[i + 1] == 0x03){
                    currentGunHoldingis = gaterlingGun;
                }
            }
        else
            {
                //////////DO SOMETHING else HERE
            }
        }
    }


-(void) connectionTimer:(NSTimer *)timer
{
    
    [connectRobotTxt setEnabled:true];
    //[systemStatustxt setTextColor:[UIColor greenColor]];
    
    [connectRobotTxt setTitle:@"DISCONNECT" forState:UIControlStateNormal];
    
    if (ble.peripherals.count > 0 )
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    } else {
        
        [connectRobotTxt setTitle:@"CONNECT" forState:UIControlStateNormal];
        
        [self.spiner01 stopAnimating];
        [self.spiner02 stopAnimating];
        faceEyes.hidden = NO;
    }
    
    
}
-(void)bleDidUpdateRSSI:(NSNumber *)rssi
{
    static float rssitrack;
    //lblRSSI.text = rssi.stringValue;
    //rssitrack = rssi.floatValue;
    //rssitrack = -rssitrack;
    //rssitrack = rssitrack/100;
    //NSLog(@"rssi = %f", rssitrack);
    //barRSSIReal.progress = rssitrack;
    
}


//----BLE END----
//----MCConnect----

- (void) dismissBrowserVC{
    [self.browserVC dismissViewControllerAnimated:YES completion:nil];
    [self.connectNetWorkTxt setTitle:@"CONNECTION" forState:UIControlStateNormal];
}

- (void) receiveMessage: (NSString *) message fromPeer: (MCPeerID *) peer{
    //  Create the final text to append
    NSString *finalText;
    if (peer == self.myPeerID) {
        
    }
    else {
        finalText = [NSString stringWithFormat:@"%@", message];
    }
    
    //  Append text to text box
    //receivedTxt.text = [NSString stringWithString:finalText];
}
-(void)setUpMutipeer{
    self.myPeerID = [[MCPeerID alloc]initWithDisplayName:[UIDevice currentDevice].name];
    
    self.mySession = [[MCSession alloc]initWithPeer:self.myPeerID];
    self.mySession.delegate = self;
    
    //setup Browser
    self.browserVC = [[MCBrowserViewController alloc]initWithServiceType:@"chat" session:self.mySession];
    self.browserVC.delegate =self;
    
    //set up Advertiser
    self.advertiser = [[MCAdvertiserAssistant alloc]initWithServiceType:@"chat" discoveryInfo:nil session:self.mySession];
    [self.advertiser start];
}
- (void) sendText{
    //  Retrieve text from chat box and clear chat box
    //NSString *message = @"X";
    //self.receivedTxt.text = @"X";
    attackSent = attack;
    
    //  Convert text to NSData
    //NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data;
    // [data getBytes:&damageReceived length:sizeof(float)];
    
    
    //  Send data to connected peers
    NSError *error;
    [self.mySession sendData:data toPeers:[self.mySession connectedPeers] withMode:MCSessionSendDataUnreliable error:&error];
    
}

#pragma marks MCBrowserViewControllerDelegate

// Notifies the delegate, when the user taps the done button
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [self dismissBrowserVC];
}

// Notifies delegate that the user taps the cancel button.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [self dismissBrowserVC];
}

#pragma marks UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self sendText];
    return YES;
}

#pragma marks MCSessionDelegate
// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    //  Decode data back to NSString
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // Decode data to float
    [data getBytes:&damageReceived length:sizeof(float)];
    
    
    //  append message to text box:
    dispatch_async(dispatch_get_main_queue(), ^{
        [self receiveMessage:message fromPeer:peerID];
    });
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}
//-----------------
@end
