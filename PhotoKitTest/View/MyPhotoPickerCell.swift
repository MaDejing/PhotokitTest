//
//  MyPhotoPickerCell.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/9/7.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import Foundation
import UIKit
import Photos

class MyPhotoPickerCell: UITableViewCell {
	
	@IBOutlet weak var m_title: UILabel!
	@IBOutlet weak var m_count: UILabel!
	@IBOutlet weak var m_imageView: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		layoutMargins = UIEdgeInsets.zero
	}
	
	static func getCellHeight() -> CGFloat {
		return 80.0
	}
	
	static func getCellIdentifier() -> String {
		return "myPhotoPickerCell"
	}
	
	func updateRowWithData(_ data: MyPhotoAlbumItem) {
		m_title.text = data.m_title;
		
		let content: PHFetchResult = data.m_content
		m_count.text = "(\(content.count))";
		
		
		let lastAssert = content.lastObject as! PHAsset
		let imageWidth = MyPhotoPickerCell.getCellHeight()-10
		let size = CGSize(width:imageWidth * 2.0, height: imageWidth * 2.0)
		
		PHImageManager.default().requestImage(for: lastAssert, targetSize: size, contentMode: .aspectFill, options: nil) { (image, nfo) in
			self.m_imageView.image = image
		}
	}
	
}
