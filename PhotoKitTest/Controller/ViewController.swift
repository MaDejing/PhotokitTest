//
//  ViewController.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/8/31.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func choosePhoto(_ sender: AnyObject) {
		let sb = UIStoryboard(name: "Main", bundle: nil)
		let vc = sb.instantiateViewController(withIdentifier: "MyPhotoPickerVC") as! MyPhotoPickerVC
		let nav = UINavigationController(rootViewController: vc)
		nav.navigationBar.isTranslucent = true
		self.present(nav, animated: true, completion: nil)
	}
}

