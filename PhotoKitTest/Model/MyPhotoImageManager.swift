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
	
	func getPhotoWithAsset(asset: PHAsset, size: CGSize, options: PHImageRequestOptions, completion: ((UIImage, [NSObject : AnyObject], Bool) -> Void)) -> PHImageRequestID {

		
		let imageRequest = PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: .AspectFill, options: options) { (image, info) in
			
			let isDegrade: Bool = info![PHImageResultIsDegradedKey]!.boolValue
			completion(image!, info!, isDegrade)
		}
		
		return imageRequest
	}
	
	func getAssetIndentifier(asset: PHAsset) -> String {
		return asset.localIdentifier
	}

}
