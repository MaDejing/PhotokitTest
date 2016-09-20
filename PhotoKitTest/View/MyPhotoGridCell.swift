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
	func myPhotoGridCellButtonSelect(cell: MyPhotoGridCell)
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
		
		m_videoView.isHidden = true
	}
	
	static func getCellIndentifier() -> String {
		return "MyPhotoGridCell"
	}
	
	func updateData(_ asset: PHAsset, size: CGSize, indexPath: IndexPath) {
		m_representedAssetIdentifier = MyPhotoImageManager.defaultManager.getAssetIndentifier(asset)
		
		let option = PHImageRequestOptions()
		option.resizeMode = .fast
		
		let imageRequestId = MyPhotoImageManager.defaultManager.getPhotoWithAsset(asset, size: size, options: option) {
			[weak self] (image, _, isDegraded) in
			
			guard let weakSelf = self else { return }
			
			if (weakSelf.m_representedAssetIdentifier == MyPhotoImageManager.defaultManager.getAssetIndentifier(asset)) {
				let item = MyPhotoItem()
				item.updateWithData(image, asset: asset, index: indexPath)
				weakSelf.updateCellWithData(item)
			} else {
				PHImageManager.default().cancelImageRequest(weakSelf.m_imageRequestID)
			}
			
			if (!isDegraded) {
				weakSelf.m_imageRequestID = 0
			}
		}
				
		if (m_imageRequestID != nil && imageRequestId != m_imageRequestID) {
			PHImageManager.default().cancelImageRequest(m_imageRequestID)
		}
		
		m_imageRequestID = imageRequestId
	}
	
	func updateCellWithData(_ data: MyPhotoItem) {
		m_data = data
		
		m_imageView.image = data.m_img
		
		m_videoView.isHidden = !(data.m_asset.mediaType == .video)
		
		if (data.m_asset.mediaType == .video) {
			let length = Int(round(data.m_asset.duration))
			m_videoLength.text = getShowVideoLength(length)
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
		m_delegate!.myPhotoGridCellButtonSelect(cell: self)
	}
	
}
