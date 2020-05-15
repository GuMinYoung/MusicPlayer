//
//  ViewController.swift
//  01MusicPlayer
//
//  Created by 구민영 on 12/08/2019.
//  Copyright © 2019 구민영. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    // MARK:- IBOutlets
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    
    // MARK: Properties
    var player: AVAudioPlayer?
    var timer: Timer?
    
    
    // MARK:- Methods
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializePlayer()
    }

    // MARK: IBActions
    @IBAction func touchUpPlayButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.player?.play()
            self.makeAndFireTimer()
        } else {
            self.player?.pause()
            self.invalidateTimer()
        }
    }
    
    @IBAction func valueChanged(_ sender: UISlider) {
        self.updateTimerLabelText(time: TimeInterval(sender.value))
        
        // isTracking : 터치 이벤트가 진행 중인지에 대한 Bool 값
        // if sender.isTracking {return}
        
        // MARK: *Code Review - guard~else
        guard sender.isTracking else {return}
        
        // TimeInterval : 초의 Double 값
        self.player?.currentTime = TimeInterval(sender.value)
    }
    
    // MARK: Custom Method
    func initializePlayer() {
        guard let soundAsset = NSDataAsset(name: "sound") else {
            print("음원 파일을 가져올 수 없습니다.")
            return
        }
        
        // 오디오 파일 데이터를 재생할 AVAudioPlayer 객체 생성 및 예외처리
        do {
            try self.player = AVAudioPlayer(data: soundAsset.data)
            self.player?.delegate = self
        } catch let error as NSError {
            print("플레이어 초기화 실패")
            print("코드 : \(error.code), 메세지 : \(error.localizedDescription)")
        }
        
        self.progressSlider.minimumValue = 0
        guard let maximumValue = self.player?.duration, let value = self.player?.currentTime else {
            return
        }
        self.progressSlider.maximumValue = Float(maximumValue)
        self.progressSlider.value = Float(value)
    }
    
    func updateTimerLabelText(time : TimeInterval) {
        let minute = Int(time/60)
        // time.truncatingRemainder(dividingBy other: Double) - time을 other로 나눈 나머지값
        // 나누는 값, 나눠지는 값 중 하나라도 Double 값일 경우 % 연산자를 사용할 수 없다.
        let second = Int(time.truncatingRemainder(dividingBy: 60))
        let millisecond = Int(time.truncatingRemainder(dividingBy: 1) * 100)
        // %02d : 앞에 0을 붙임, 0 포함해서 두자리, %d는 Int형의 형식 지정자
        let timeText = String(format: "%02d:%02d:%02d", minute, second, millisecond)
        timeLabel.text = timeText
    }
    
    func makeAndFireTimer() {
        // withTimeInterval : 타이머 실행 시간 간격 (초 단위)
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] (timer : Timer) in
            // MARK: *Code Review - self capturing
            guard let self = self else {return}
            
            if self.progressSlider.isTracking {return}
            guard let currentTime = self.player?.currentTime else {
                return
            }
            self.updateTimerLabelText(time: currentTime)
            self.progressSlider.value = Float(currentTime)
        })
        self.timer?.fire()
    }
    
    func invalidateTimer() {
        self.timer?.fire()
        self.timer = nil
    }
}

// MARK: AVAudioPlayerDelegate
extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard let error = error else {
            print("오디어 플레이어 디코드 오류 발생")
            return
        }
        
        let message = "오디오 플레이어 오류 발생 \(error.localizedDescription)"
        
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { Void in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            playPauseButton.isSelected = false
            progressSlider.value = 0
            updateTimerLabelText(time: 0)
            timer?.invalidate()
    }
}
