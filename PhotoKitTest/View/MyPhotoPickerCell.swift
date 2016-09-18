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
		
		self.layoutMargins = UIEdgeInsets.zero
	}
	
	static func getCellHeight() -> CGFloat {
		return 80.0
	}
	
	static func getCellIdentifier() -> String {
		return "myPhotoPickerCell"
	}
	
	func updateRowWithData(_ data: MyPhotoAlbumItem) {
		self.m_title.text = data.m_title;
		
		let content = data.m_content
		self.m_count.text = "(\(content?.count))";
		
		let option = PHImageRequestOptions()
		option.resizeMode = .fast
		
		let lastAssert = content?.lastObject as! PHAsset
		PHImageManager.default().requestImage(for: lastAssert, targetSize: CGSize(width: MyPhotoPickerCell.getCellHeight(), height: MyPhotoPickerCell.getCellHeight()), contentMode: .aspectFill, options: option) { (image, nfo) in
			self.m_imageView.image = image
		}
	}
	
}
