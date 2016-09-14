//
//  MyPhotoImageManager.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/9/13.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import UIKit
import Foundation
import Photos

class MyPhotoImageManager: NSObject {
	
	// static是延时加载的，并且是常量，加载一次后不会加载第二次，所以实现了单例。
	static let defaultManager: MyPhotoImageManager = MyPhotoImageManager()

//	var m_cachingImageManager: PHCachingImageManager! = PHCachingImageManager()
	
	func getPhotoWithAsset(asset: PHAsset, size: CGSize, completion: ((UIImage, [NSObject : AnyObject]) -> Void)) -> PHImageRequestID {
		let option = PHImageRequestOptions()
		option.resizeMode = .Fast
		
		let imageRequest = PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: .AspectFill, options: option) { (image, info) in
			
			completion(image!, info!)
		}
		
		return imageRequest
	}

}
