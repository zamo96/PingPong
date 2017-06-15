//
//  ViewController.swift
//  PingPing
//
//  Created by Matvey on 03.06.17.
//  Copyright (c) 2017 Matvey. All rights reserved.
//
import UIKit

class ViewController: UIViewController {
    let MAX_SCORE = 3
    @IBOutlet weak var paddle1: UIView!
    @IBOutlet weak var paddle2: UIView!
    @IBOutlet weak var ball: UIView!
    @IBOutlet weak var wallLeft: UIView!
    @IBOutlet weak var wallRight: UIView!
    var dx:Float = 0.0
    var dy:Float = 0.0
    var speed:Float = 0.0
    var timer:NSTimer?
    var touch1:UITouch?
    var touch2:UITouch?
    var alert:UIAlertController?
    @IBOutlet weak var viewScore1: UILabel!
    @IBOutlet weak var viewScore2: UILabel!
       func gameOver()->Int
    {
        if viewScore1.text?.toInt() >= MAX_SCORE
        {
            return 1
        }
        else if viewScore2.text?.toInt() >= MAX_SCORE
        {
        return 2
        }
        return 0
    }
    // Game over еще не используется так как не могу разобраться с UIAlertController при вызове из функции self.presentViewController ...
    func newGame()->()
    {
        self.reset()
        viewScore1.text = "0"
        viewScore2.text = "0"
        self.displaymessage("Ready to go?")
            }
    func displaymessage(msg:String)->()
    {
        self.stop()
        alert = UIAlertController(title: "GAME", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert?.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{action in
            if self.gameOver() > 0
            {
                self.newGame()
                return
            }
            self.reset()
        self.start()}))
        self.viewDidAppear(true)
        
        // Сюда в handler хочу вставить проверку условия if self.gameOver > 0 {self.newGame()}
        // Тем самым можно проверять закончилась ли игра и можно начинать новый раунд
    }
    func start() -> ()
    {
        if timer == nil
        {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0/60.0, target: self, selector: "animate", userInfo: nil, repeats: true)
        }
         ball.hidden = false
    }
    func stop() -> ()
    {
        if timer != nil
        {
            timer?.invalidate()
            timer = nil
        }
        ball.hidden = true
    }
    func animate()->()
    {
        ball.center = CGPointMake(ball.center.x + CGFloat(dx*speed), ball.center.y + CGFloat(dy*speed))
        self.checkBallCollision(wallLeft.frame, Dirx: fabs(dx), Diry: 0)
        self.checkBallCollision(wallRight.frame, Dirx: -fabs(dx), Diry: 0)
        
        if(self.checkBallCollision(paddle1.frame, Dirx: Float(ball.center.x - paddle1.center.x)/32.0, Diry: -1))
        {
            self.increaseSpeed()
        }
        if(self.checkBallCollision(paddle2.frame, Dirx: Float(ball.center.x - paddle2.center.x)/32.0, Diry: 1))
        {
            self.increaseSpeed()
        }
        self.checkGoal()
        
        
    }
    func increaseSpeed()
    {
        speed += 0.5
        if speed > 10
        {
            speed = 10
        }
    }
    func checkGoal()->Bool {
        if ball.center.y > 650 || ball.center.y < 10 {
            var s1 = viewScore1.text?.toInt()
            var s2 = viewScore2.text?.toInt()
            if ball.center.y > 650
            {
                ++s2! //  Здесь может возникнуть ошибка слет приложения
            }
            else if ball.center.y < 10 {
                ++s1! //  Здесь может возникнуть ошибка слет приложения
            }
            viewScore1.text = toString(s1!)
            viewScore2.text = toString(s2!)
            
           if (self.gameOver() == 1)
            {
                self.displaymessage("Player 1 has won")
            }
            else if (self.gameOver() == 2)
            {
                self.displaymessage("Player 2 has won")
            }
            self.reset()
        
            return true
        }
        return false
    }
    func checkBallCollision(rect:CGRect,Dirx x:Float,Diry y:Float)-> Bool
    {
        if(CGRectIntersectsRect(ball.frame, rect))
        {
            if(x != 0){
                dx = x
            }
            if(y != 0)
            {
                dy = y
            }
        return true
        }
       return false
    }
    func reset()->()
    {
        if arc4random()%2 == 0
        {
            dx = -1
        }
        else
        {
            dx = 1
        }
        if dy != 0
        {
            dy = -dy
        }
        else if arc4random() % 2 == 0
        {
            dy = -1
        }
        else
        {
            dy = 1
        }
        ball.center = CGPointMake(15 + CGFloat(arc4random()) % (320-30),CGFloat(324) )
        speed = 2
    }
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
      
        for touch in touches as! Set<UITouch>
        {
            var point:CGPoint = touch.locationInView(view)
            if (point.y > 300 && touch1 == nil)
            {
                touch1 = touch
                paddle1.center = CGPointMake(point.x, paddle1.center.y)
            }
            else if (touch2 == nil && point.y <= 300)
            {
                
                touch2 = touch
                paddle2.center = CGPointMake(point.x, paddle2.center.y)
            }
            
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        touch1 = nil
        touch2 = nil
    }
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        self.touchesEnded(touches, withEvent: event)
    }
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
       for touch in touches as! Set<UITouch>
       {
        var point:CGPoint = touch.locationInView(view)
        
        if (touch == touch1)
        {
            paddle1.center = CGPointMake(point.x, paddle1.center.y)
        }
        else if (touch == touch2)
        {
             paddle2.center = CGPointMake(point.x, paddle2.center.y)
        }
        }
    }
    func pause()
    {
        self.stop()
    }
    func resume()
    {
        self.displaymessage("Continue?")
    }
    
    override func viewDidAppear(animated: Bool) {
    self.presentViewController(alert!, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newGame()
        //self.stop()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

}
