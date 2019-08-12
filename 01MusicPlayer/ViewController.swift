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
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    
    var player: AVAudioPlayer?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializePlayer()
    }

    @IBAction func touchUpPlayButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.player?.play()
        } else {
            self.player?.pause()
        }
        print("버튼 클릭")
    }
    
}

extension ViewController: AVAudioPlayerDelegate {
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
    }
}
