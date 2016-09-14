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
	
	var m_asset: PHAsset!
	
	var m_player: AVPlayer!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.initSubViews()
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.navigationController?.setNavigationBarHidden(false, animated: false)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

}

extension MyVideoPreviewVC {
	func initSubViews() {
		self.updateTopBottomView(false)
		self.updatePlayButton(false)
		
		PHImageManager.defaultManager().requestPlayerItemForVideo(self.m_asset, options: nil) { (playerItem, info) in
			dispatch_async(dispatch_get_main_queue(), { 
				self.m_player = AVPlayer(playerItem: playerItem!)
				
				let playerLayer = AVPlayerLayer(player: self.m_player)
				playerLayer.frame = self.view.bounds
				playerLayer.backgroundColor = UIColor.blackColor().CGColor
				self.view.layer.addSublayer(playerLayer)
				
				self.view.bringSubviewToFront(self.m_topView)
				self.view.bringSubviewToFront(self.m_playButton)
				self.view.bringSubviewToFront(self.m_bottomView)
				
				NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyVideoPreviewVC.pauseVideo), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.m_player.currentItem)
			})
		}
	}
	
	func updateTopBottomView(hidden: Bool) {
		self.m_topView.hidden = hidden
		self.m_bottomView.hidden = hidden
	}
	
	func updatePlayButton(play: Bool) {
		let image = play ? nil : UIImage(named: "play")
		self.m_playButton.setImage(image, forState: .Normal)
	}
}

extension MyVideoPreviewVC {
	@IBAction func backClick(sender: AnyObject) {
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	@IBAction func playClick(sender: AnyObject) {
		let curTime = self.m_player.currentItem?.currentTime()
		let durTime = self.m_player.currentItem?.duration
		
		// 0.0代表暂停，1.0代表播放中
		if (self.m_player.rate == 0.0) {
			// 播放结束则回到0
			if (curTime?.value == durTime?.value) {
				self.m_player.currentItem?.seekToTime(CMTimeMake(0, 1))
			}
			self.m_player.play()
			self.updateTopBottomView(true)
			self.updatePlayButton(true)
		} else {
			self.pauseVideo()
		}
	}
	
	@IBAction func doneClick(sender: AnyObject) {
	}
	
	func pauseVideo() {
		self.m_player.pause()
		self.updateTopBottomView(false)
		self.updatePlayButton(false)
	}
	
}
