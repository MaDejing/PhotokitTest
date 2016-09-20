//
//  GlobalData.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/9/20.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
	class func getFont(name: String, size: CGFloat) -> UIFont {
		if let font = UIFont(name: name, size: size) {
			return font
		} else {
			return UIFont.systemFont(ofSize: size)
		}
	}
}

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height
let kThemeColor: UIColor = UIColor(red: 31/255.0, green: 183/255.0, blue: 27/255.0, alpha: 1)

let kSelectedLabelWidth: CGFloat = 30.0
let kSelectedLabelFont: UIFont = UIFont.getFont(name: "PingFang-SC-Regular", size: 15)
