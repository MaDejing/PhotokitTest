//
//  MyVideoPreviewVC.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/9/13.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import UIKit
import Photos

class MyVideoPreviewVC: UIViewController {

	@IBOutlet weak var m_topView: UIView!
	@IBOutlet weak var m_bottomView: UIView!
	@IBOutlet weak var m_doneButton: UIButton!
	@IBOutlet weak var m_playButton: UIButton!
	@IBOutlet weak var m_slider: UISlider!

	var m_asset: PHAsset!
	
	var m_player: AVPlayer!
	
	var m_isReadyToPlay = false
	
	var m_observer: AnyObject!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.initSubViews()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.navigationController?.setNavigationBarHidden(false, animated: false)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override var prefersStatusBarHidden : Bool {
		return true
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

}

extension MyVideoPreviewVC {
	func initSubViews() {
		self.updateTopBottomView(false)
		self.updatePlayButton(false)
		
		PHImageManager.default().requestPlayerItem(forVideo: self.m_asset, options: nil) { (playerItem, info) in
			DispatchQueue.main.async(execute: { 
				self.m_player = AVPlayer(playerItem: playerItem!)
				
				let playerLayer = AVPlayerLayer(player: self.m_player)
				playerLayer.frame = self.view.bounds
				playerLayer.backgroundColor = UIColor.black.cgColor
				self.view.layer.addSublayer(playerLayer)
				
				self.view.bringSubview(toFront: self.m_topView)
				self.view.bringSubview(toFront: self.m_playButton)
				self.view.bringSubview(toFront: self.m_bottomView)
				self.view.bringSubview(toFront: self.m_slider)
				
				self.updateSliderValue()
				
				NotificationCenter.default.addObserver(self, selector: #selector(MyVideoPreviewVC.pauseVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.m_player.currentItem)
				self.m_player.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
			})
		}
	}
	
	func updateTopBottomView(_ hidden: Bool) {
		self.m_topView.isHidden = hidden
		self.m_bottomView.isHidden = hidden
	}
	
	func updatePlayButton(_ play: Bool) {
		let image = play ? nil : UIImage(named: "play")
		self.m_playButton.setImage(image, for: UIControlState())
	}
	
	func updateSliderValue() {
		// 1秒显示30帧
		self.m_observer = self.m_player.addPeriodicTimeObserver(forInterval: CMTimeMake(33, 1000), queue: DispatchQueue.main) {
			(time) in
			
			let current = CMTimeGetSeconds(time)
			let total = CMTimeGetSeconds(self.m_player.currentItem!.duration)
			self.m_slider.setValue(Float(current/total), animated: true)
		} as AnyObject!
	}
}

extension MyVideoPreviewVC {
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "status" {
			let status: AVPlayerItemStatus = AVPlayerItemStatus(rawValue: ((change![NSKeyValueChangeKey.newKey] as AnyObject).intValue)!)!
			
			switch status {
			case .unknown:
				self.m_isReadyToPlay = false
				print("视频资源出现未知错误")
				break
			case .readyToPlay:
				self.m_isReadyToPlay = true
				break
			case .failed:
				self.m_isReadyToPlay = false
				print("item 有误")
				break
			}
		}
		
		(object as AnyObject).removeObserver(self, forKeyPath: "status")
	}
}

extension MyVideoPreviewVC {
	@IBAction func backClick(_ sender: AnyObject) {
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func playClick(_ sender: AnyObject) {
		
		if (self.m_isReadyToPlay) {
			let curTime = self.m_player.currentItem?.currentTime()
			let durTime = self.m_player.currentItem?.duration
			
			// 0.0代表暂停，1.0代表播放中
			if (self.m_player.rate == 0.0) {
				// 播放结束则回到0
				if (curTime?.value == durTime?.value) {
					self.m_player.currentItem?.seek(to: CMTimeMake(0, 1))
				}
				self.playVideo()
			} else {
				self.pauseVideo()
			}
		} else {
			print("视频加载中。。。")
		}
	}
	
	@IBAction func doneClick(_ sender: AnyObject) {
	}
	
	@IBAction func sliderDown(_ sender: AnyObject) {
		self.m_player.removeTimeObserver(self.m_observer)
	}
	
	@IBAction func sliderUp(_ sender: AnyObject) {
		let durTime = Float(CMTimeGetSeconds((self.m_player.currentItem?.duration)!))

		let startTime = CMTimeMake(Int64(self.m_slider.value*durTime), 1)
		
		self.m_player.currentItem?.seek(to: startTime, completionHandler: { (finished) in
			if (finished) {
				if (self.m_isReadyToPlay) {
					if (self.m_player.rate == 0.0) {
						self.pauseVideo()
					} else {
						self.playVideo()
					}
				}
				
				self.updateSliderValue()
			}
		})
	}
	
	func playVideo() {
		self.m_player.play()
		self.updateTopBottomView(true)
		self.updatePlayButton(true)
	}
	
	func pauseVideo() {
		self.m_player.pause()
		self.updateTopBottomView(false)
		self.updatePlayButton(false)
	}
	
}
