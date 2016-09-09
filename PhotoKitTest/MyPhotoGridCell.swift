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
	
	weak var m_delegate: MyPhotoGridCellDelegate?
	
	var m_data: MyPhotoItem!
	var m_indexPath: NSIndexPath!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	static func getCellIndentifier() -> String {
		return "MyPhotoGridCell"
	}
	
	func updateCellWithData(data: MyPhotoItem, indexPath: NSIndexPath) {
		self.m_data = data
		
		self.m_imageView.image = data.m_img
		self.m_indexPath = indexPath
	}
	
	@IBAction func photoSelect(sender: AnyObject) {
		let button  = sender as! UIButton
		button.selected = !button.selected;
		
		self.m_delegate!.myPhotoGridCellButtonSelect(self, selected: button.selected)
	}
	
}
