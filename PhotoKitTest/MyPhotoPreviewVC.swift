//
//  MyPhotoPreviewVC.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/9/8.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import Foundation
import UIKit

class MyPhotoPreviewVC: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController?.setNavigationBarHidden(true, animated: false)
//		UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.navigationController?.setNavigationBarHidden(true, animated: false)
//		UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
}

extension MyPhotoPreviewVC {
	
	@IBAction func backClick(sender: AnyObject) {
	}
	
	@IBAction func selectClick(sender: AnyObject) {
	}
	
}
