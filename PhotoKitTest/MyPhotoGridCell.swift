//
//  MyPhotoGridCell.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/9/7.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import Foundation
import UIKit

protocol MyPhotoGridCellDelegate: NSObjectProtocol {
	func myPhotoGridCellButtonSelect(cell: MyPhotoGridCell, selected: Bool)
}

class MyPhotoGridCell: UICollectionViewCell {
	@IBOutlet weak var m_imageView: UIImageView!
	@IBOutlet weak var m_selectButton: UIButton!
	
	@IBOutlet weak var m_videoView: UIView!
	@IBOutlet weak var m_videoLength: UILabel!
	
	weak var m_delegate: MyPhotoGridCellDelegate?
	
	var m_data: MyPhotoItem!
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.m_videoView.hidden = true
	}
	
	static func getCellIndentifier() -> String {
		return "MyPhotoGridCell"
	}
	
	func updateCellWithData(data: MyPhotoItem) {
		self.m_data = data
		
		self.m_imageView.image = data.m_img
		
		self.m_videoView.hidden = !(data.m_asset.mediaType == .Video)
		self.m_selectButton.hidden = !(data.m_asset.mediaType == .Image)
		
		if (data.m_asset.mediaType == .Video) {
			let length = Int(round(data.m_asset.duration))
			self.m_videoLength.text = self.getShowVideoLength(length)
		}
	}
	
	func getShowVideoLength(length: Int) -> String {
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
	
	@IBAction func photoSelect(sender: AnyObject) {
		let button  = sender as! UIButton
		button.selected = !button.selected;
		
		self.m_delegate!.myPhotoGridCellButtonSelect(self, selected: button.selected)
	}
	
}
