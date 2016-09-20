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

	/// Storyboard 相关
	@IBOutlet weak var m_topView: UIView!
	@IBOutlet weak var m_bottomView: UIView!
	@IBOutlet weak var m_doneButton: UIButton!
	@IBOutlet weak var m_playButton: UIButton!
	@IBOutlet weak var m_slider: UISlider!

	/// 需要展示的视频
	var m_asset: PHAsset!
	
	/// 视频播放器
	var m_player: AVPlayer!
	
	/// 是否可以播放
	var m_isReadyToPlay = false
	
	var m_observer: AnyObject!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		PHPhotoLibrary.shared().register(self)
		
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
		PHPhotoLibrary.shared().unregisterChangeObserver(self)
	}

}

// MARK: - Initial & Update Functions
extension MyVideoPreviewVC {
	
	func initSubViews() {
		self.updateTopBottomView(isHidden: false)
		self.updatePlayButton(isPlay: false)
		
		PHImageManager.default().requestPlayerItem(forVideo: self.m_asset, options: nil) { (playerItem, info) in
			DispatchQueue.main.async(execute: {
				[weak self] () in
				
				guard let weakSelf = self else { return }
				
				weakSelf.m_player = AVPlayer(playerItem: playerItem!)
				
				let playerLayer = AVPlayerLayer(player: weakSelf.m_player)
				playerLayer.frame = weakSelf.view.bounds
				playerLayer.backgroundColor = UIColor.black.cgColor
				weakSelf.view.layer.addSublayer(playerLayer)
				
				weakSelf.view.bringSubview(toFront: weakSelf.m_topView)
				weakSelf.view.bringSubview(toFront: weakSelf.m_playButton)
				weakSelf.view.bringSubview(toFront: weakSelf.m_bottomView)
				weakSelf.view.bringSubview(toFront: weakSelf.m_slider)
				
				weakSelf.updateSliderValue()
				
				NotificationCenter.default.addObserver(weakSelf, selector: #selector(weakSelf.pauseVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: weakSelf.m_player.currentItem)
				weakSelf.m_player.currentItem?.addObserver(weakSelf, forKeyPath: "status", options: .new, context: nil)
			})
		}
	}
	
	/// 更新顶部和底部view是否隐藏
	///
	/// - parameter isHidden: 是否隐藏
	func updateTopBottomView(isHidden: Bool) {
		self.m_topView.isHidden = isHidden
		self.m_bottomView.isHidden = isHidden
	}
	
	/// 更新播放按钮展示
	///
	/// - parameter isPlay: 是否播放
	func updatePlayButton(isPlay: Bool) {
		let image = isPlay ? nil : UIImage(named: "play")
		self.m_playButton.setImage(image, for: UIControlState())
	}
	
	/// 根据视频播放更新滑动条
	func updateSliderValue() {
		// 1秒显示30帧
		self.m_observer = self.m_player.addPeriodicTimeObserver(forInterval: CMTimeMake(33, 1000), queue: DispatchQueue.main) {
			[weak self] (time) in
			
			guard let weakSelf = self else { return }
			
			let current = CMTimeGetSeconds(time)
			let total = CMTimeGetSeconds(weakSelf.m_player.currentItem!.duration)
			weakSelf.m_slider.setValue(Float(current/total), animated: true)
		} as AnyObject!
	}
}

// MARK: - KVO - 视频源状态
extension MyVideoPreviewVC {
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "status" {
			
			let value = (change![NSKeyValueChangeKey.newKey] as? NSNumber)?.intValue
			let status: AVPlayerItemStatus = AVPlayerItemStatus(rawValue: value!)!
			
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
		
		self.m_player.currentItem?.removeObserver(self, forKeyPath: "status")
	}
}

// MARK: - 方法
extension MyVideoPreviewVC {
	
	func playVideo() {
		self.m_player.play()
		self.updateTopBottomView(isHidden: true)
		self.updatePlayButton(isPlay: true)
	}
	
	func pauseVideo() {
		self.m_player.pause()
		self.updateTopBottomView(isHidden: false)
		self.updatePlayButton(isPlay: false)
	}
}

// MARK: - IBActions
extension MyVideoPreviewVC {
	
	@IBAction func backClick(_ sender: AnyObject) {
		_ = navigationController?.popViewController(animated: true)
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
		print(m_asset)
		dismiss(animated: true, completion: nil)
	}
	
	/// 手指按下
	///
	/// - parameter sender:
	@IBAction func sliderDown(_ sender: AnyObject) {
		self.m_player.removeTimeObserver(self.m_observer)
	}
	
	/// 手指抬起
	///
	/// - parameter sender:
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
}

// MARK: - PHPhotoLibraryChangeObserver
extension MyVideoPreviewVC: PHPhotoLibraryChangeObserver {
	
	func photoLibraryDidChange(_ changeInstance: PHChange) {
		
	}
}


