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
	
	/// static是延时加载的，并且是常量，加载一次后不会加载第二次，所以实现了单例。
	static let defaultManager: MyPhotoImageManager = MyPhotoImageManager()
	
	/// 是否允许原图
	var m_isAllowOrigin: Bool = false
	
	/// 获取某张照片
	///
	/// - parameter asset:      照片资源
	/// - parameter size:       请求的照片尺寸
	/// - parameter options:    请求选项
	/// - parameter completion: 完成后调用的block
	///
	/// - returns: 请求ID
	func getPhotoWithAsset(_ asset: PHAsset, size: CGSize, options: PHImageRequestOptions, completion: @escaping ((UIImage, [AnyHashable: Any], Bool) -> Void)) -> PHImageRequestID {

		let imageRequest = PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { (img, info) in
			
			guard let image = img else { return }
			
			let isDegrade: Bool = (info![PHImageResultIsDegradedKey]! as AnyObject).boolValue
			completion(image, info!, isDegrade)
		}
		
		return imageRequest
	}
	
	/// 获取照片资源的标识符
	///
	/// - parameter asset: 照片资源
	///
	/// - returns: 标识符
	func getAssetIndentifier(_ asset: PHAsset) -> String {
		return asset.localIdentifier
	}

}
