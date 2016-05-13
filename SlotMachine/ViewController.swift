//
//  ViewController.swift
//  omikuji
//
//  Created by Tomohiro Yoshida on 2016/03/30.
//  Copyright © 2016年 Tomohiro Yoshida. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    var foodImageViews: [UIImageView]!
    var foodImages: [UIImage]!
    let foodCount = 3
    
    var slotViews: [UIView]!
    
    var resultLabel: UILabel!
    var resultView: UIView!
    var resultImageView: UIImageView!
    let resultNames:[String] = ["米", "パン", "麺類"]
    
    var startBtn: UIButton!
    var stopBtns: [UIButton]!
    
    var timers: [NSTimer]!
    
    var stopCount: Int = 0
    
    var stopSound: AVAudioPlayer!
    var successSound: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.view.backgroundColor = UIColor(red: 0, green: 0.8, blue: 1.0, alpha: 1.0)
        
        let midXOfView = self.view.bounds.width / 2
        let midYOfView = self.view.bounds.height / 2
        
        let rice = UIImage(named: "rice")
        let burger = UIImage(named: "burger")
        let ramen = UIImage(named: "ramen")
        
        
        
        foodImages = [rice!, burger!, ramen!]
        slotViews = []
        foodImageViews = []
        stopBtns = []
        timers = []
        
        //      　スロットのベースとなる円を作成・表示して配列に入れる
        
        for i in 0..<foodCount {
            let slotView = UIView()
            slotView.frame = CGRectMake(0, 0, 120, 120)
            slotView.layer.masksToBounds = true
            slotView.layer.cornerRadius = 60.0
            slotView.backgroundColor = UIColor(red: 0.8, green: 1.0, blue: 1.0, alpha: 0.8)
            slotView.tag = i
            slotViews.append(slotView)
            self.view.addSubview(slotViews[i])
        }
        //        作成したベースの位置を調整
        
        slotViews[0].layer.position = CGPoint(x: midXOfView / 2, y: 240.0)
        slotViews[1].layer.position = CGPoint(x: midXOfView, y: 100.0)
        slotViews[2].layer.position = CGPoint(x: midXOfView + (midXOfView / 2), y: 240.0)
        
        //        食べ物の画像をベースの上に配置する
        for j in 0..<foodCount {
            let foodImageView = UIImageView(image: foodImages[j])
            foodImageView.frame = CGRectMake(0, 0, 70, 70)
            foodImageView.layer.position = CGPoint(x: slotViews[j].bounds.width / 2,
                                                   y: slotViews[j].bounds.height / 2)
            foodImageView.backgroundColor = UIColor.clearColor()
            foodImageView.tag = j
            foodImageViews.append(foodImageView)
            self.slotViews[j].addSubview(foodImageViews[j])
        }
        
        
        
        //        スタートボタン作成
        startBtn = UIButton()
        startBtn.frame = CGRectMake(0, 0, 140, 40)
        startBtn.layer.masksToBounds = true
        startBtn.layer.cornerRadius = 20.0
        startBtn.layer.position = CGPoint(x: midXOfView , y: self.view.frame.maxY - 50)
        startBtn.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        startBtn.tintColor = UIColor.blackColor()
        startBtn.setTitle("START!", forState: .Normal)
        startBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        startBtn.setTitleColor(UIColor.redColor(), forState: .Disabled)
        startBtn.addTarget(self, action: #selector(start(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(startBtn)
        
        //        ストップボタンを作成
            
            
        for k in 0..<foodCount {
            let stopBtn = UIButton()
            stopBtn.frame = CGRectMake(0, 0, 90, 30)
            stopBtn.layer.masksToBounds = true
            stopBtn.layer.cornerRadius = 15.0
            stopBtn.layer.position = CGPoint(x: slotViews[k].frame.midX,
                                             y: slotViews[k].frame.maxY)
            stopBtn.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
            stopBtn.setTitle("STOP", forState: .Normal)
            stopBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            stopBtn.setTitleColor(UIColor.redColor(), forState: .Disabled)
            stopBtn.tag = k
            stopBtn.enabled = false
            stopBtn.addTarget(self, action: #selector(stop(_:)),
                              forControlEvents: UIControlEvents.TouchUpInside)
            stopBtns.append(stopBtn)
            self.view.addSubview(stopBtns[k])
        }
        
        //        結果表示のベースビューを作成
        resultView = UIView()
        resultView.frame = CGRectMake(0, 0, 200, 100)
        resultView.layer.position = CGPoint(x: midXOfView, y: startBtn.frame.minY - 90)
        resultView.layer.masksToBounds = true
        resultView.layer.cornerRadius = 20.0
        resultView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.7, alpha: 0.7)
        self.view.addSubview(resultView)
        
        //        結果表示右上のアイコン部分を作成
        resultImageView = UIImageView()
        resultImageView.frame = CGRectMake(0, 0, 50, 50)
        resultImageView.layer.position = CGPoint(x: resultView.frame.minX,
                                                 y: resultView.frame.minY)
        resultImageView.layer.masksToBounds = true
        resultImageView.layer.cornerRadius = 25.0
        resultImageView.backgroundColor = UIColor.whiteColor()
//        resultImageView.image = foodImages[0]
        resultImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(resultImageView)
        
        //        結果表示の文字部分を作成
        resultLabel = UILabel()
        resultLabel.frame = CGRectMake(0, 0, 120, 60)
        resultLabel.layer.position = CGPoint(x: resultView.bounds.width / 2,
                                             y: resultView.bounds.height / 2)
        resultLabel.font = UIFont.boldSystemFontOfSize(24)
        resultLabel.backgroundColor = UIColor.clearColor()
        resultLabel.textColor = UIColor.blackColor()
        resultLabel.text = ""
        resultLabel.textAlignment = NSTextAlignment.Center
        self.resultView.addSubview(resultLabel)
        
//        オーディオ設定
        let stopAudioFilePath: NSString = NSBundle.mainBundle().pathForResource("decision3", ofType: "mp3")!
        let stopAudioFileURL:NSURL = NSURL(fileURLWithPath: stopAudioFilePath as String)
        do {
            try stopSound = AVAudioPlayer(contentsOfURL: stopAudioFileURL)
        } catch let error as NSError {
            print(error)
        }
        stopSound.delegate = self
        
        let successAudioFilePath = NSBundle.mainBundle().pathForResource("decision4", ofType: "mp3")!
        let successAudioFileURL = NSURL(fileURLWithPath: successAudioFilePath)
        do {
            try successSound = AVAudioPlayer(contentsOfURL: successAudioFileURL)
        } catch let error as NSError {
            print(error)
        }
        successSound.delegate = self
    }
    
    func start(sender: UIButton) {
        if startBtn.enabled {
            for i in 0 ..< foodCount {
                stopBtns[i].enabled = true
            }
            shuffle()
        }
        stopCount = 0
        startBtn.enabled = false
        resultLabel.text = ""
        resultImageView.image = nil
        
    }
    
    func shuffle() {
        let timer0 = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(shuffleImages0), userInfo: nil, repeats: true)
        let timer1 = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(shuffleImages1), userInfo: nil, repeats: true)
        let timer2 = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(shuffleImages2), userInfo: nil, repeats: true)
        timers.append(timer0)
        timers.append(timer1)
        timers.append(timer2)
    }
    
    func shuffleImages0 (){
        let rnd:Int = Int(arc4random_uniform(UInt32(foodCount)))
        foodImageViews[0].image = foodImages[rnd]
        
    }
    func shuffleImages1 () {
        let rnd:Int = Int(arc4random_uniform(UInt32(foodCount)))
        foodImageViews[1].image = foodImages[rnd]
    }
    func shuffleImages2 () {
        let rnd:Int = Int(arc4random_uniform(UInt32(foodCount)))
        foodImageViews[2].image = foodImages[rnd]
    }
    
    func stop(sender: UIButton) {
        if stopSound.playing {
            stopSound.stop()
        }
        if startBtn.enabled {
            return
        }
        sender.enabled = false
        timers[sender.tag].invalidate()
        stopCount += 1
        stopSound.play()
        if stopCount >= 3 {
            allslotStopped()
        }
        print(stopCount)
    }
    
    func allslotStopped () {
        startBtn.enabled = true
        timers = []
        print(startBtn.enabled)
        for i in 0 ..< stopBtns.count {
            print(stopBtns[i].enabled)
        }
        print(timers)
        let result0 = foodImageViews[0].image
        let result1 = foodImageViews[1].image
        let result2 = foodImageViews[2].image
        if result0 == result1 && result1 == result2 && result0 == result0 {
            resultImageView.image = result0
            resultLabel.text = "あたり"
            successSound.play()
        } else {
            resultLabel.text = "はずれ"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

