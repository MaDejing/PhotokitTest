//
//  MyPhotoGridCell.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/9/7.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol MyPhotoGridCellDelegate: NSObjectProtocol {
	func myPhotoGridCellButtonSelect(_ cell: MyPhotoGridCell, selected: Bool)
}

class MyPhotoGridCell: UICollectionViewCell {
	@IBOutlet weak var m_imageView: UIImageView!
	@IBOutlet weak var m_selectButton: UIButton!
	
	@IBOutlet weak var m_videoView: UIView!
	@IBOutlet weak var m_videoLength: UILabel!
	
	weak var m_delegate: MyPhotoGridCellDelegate?
	
	var m_data: MyPhotoItem!
	
	
	var m_representedAssetIdentifier: String!
	
	var m_imageRequestID: PHImageRequestID!
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.m_videoView.isHidden = true
	}
	
	static func getCellIndentifier() -> String {
		return "MyPhotoGridCell"
	}
	
	func updateData(_ asset: PHAsset, size: CGSize, indexPath: IndexPath) {
		self.m_representedAssetIdentifier = MyPhotoImageManager.defaultManager.getAssetIndentifier(asset)
		
		let option = PHImageRequestOptions()
		option.resizeMode = .fast
		
		let imageRequestId = MyPhotoImageManager.defaultManager.getPhotoWithAsset(asset, size: size, options: option) { (image, info, isDegraded) in
			if (self.m_representedAssetIdentifier == MyPhotoImageManager.defaultManager.getAssetIndentifier(asset)) {
				let item = MyPhotoItem()
				item.updateWithData(image, asset: asset, index: indexPath)
				self.updateCellWithData(item)
			} else {
				PHImageManager.default().cancelImageRequest(self.m_imageRequestID)
			}
			
			if (!isDegraded) {
				self.m_imageRequestID = 0
			}
		}
				
		if (self.m_imageRequestID != nil && imageRequestId != self.m_imageRequestID) {
			PHImageManager.default().cancelImageRequest(self.m_imageRequestID)
		}
		
		self.m_imageRequestID = imageRequestId
	}
	
	func updateCellWithData(_ data: MyPhotoItem) {
		self.m_data = data
		
		self.m_imageView.image = data.m_img
		
		self.m_videoView.isHidden = !(data.m_asset.mediaType == .video)
		
		if (data.m_asset.mediaType == .video) {
			let length = Int(round(data.m_asset.duration))
			self.m_videoLength.text = self.getShowVideoLength(length)
		}
	}
	
	func getShowVideoLength(_ length: Int) -> String {
		var showLength = ""
		
		let min = Int(length / 60)
		let sec = Int(length % 60)
		
		if (sec < 10) {
			showLength = "\(min):0\(sec)"
		} else {
			showLength = "\(min):\(sec)"
		}
		
		return showLength
	}
	
	@IBAction func photoSelect(_ sender: AnyObject) {
		let button  = sender as! UIButton
//		button.selected = !button.selected;
		
		self.m_delegate!.myPhotoGridCellButtonSelect(self, selected: button.isSelected)
	}
	
}
