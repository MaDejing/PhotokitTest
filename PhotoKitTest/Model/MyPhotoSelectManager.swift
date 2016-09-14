//
//  MyPhotoSelectManager.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/9/14.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import UIKit

class MyPhotoSelectManager: NSObject {
	
	var m_selectedItems: [MySelectedItem] = []
	var m_selectedIndex: [NSIndexPath] = []
	
	// static是延时加载的，并且是常量，加载一次后不会加载第二次，所以实现了单例。
	static let defaultManager: MyPhotoSelectManager = MyPhotoSelectManager()
	
	func updateSelectItems(vcToShowAlert: UIViewController, selected: Bool, button: UIButton, selectedItem: MySelectedItem) {
		if self.m_selectedItems.count >= 9 && !selected {
			let alert = UIAlertController(title: nil, message: "最多可选择9张照片", preferredStyle: .Alert)
			let cancelAction = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
			
			alert.addAction(cancelAction)
			
			vcToShowAlert.presentViewController(alert, animated: true, completion: nil)
		} else {
			button.selected = !button.selected
						
			if button.selected {
				self.m_selectedItems.append(selectedItem)
			} else {
				let index = self.m_selectedIndex.indexOf(selectedItem.m_index)
				
				if (index != nil) {
					self.m_selectedItems.removeAtIndex(index!)
				}
			}
			
			self.updateIndexArr()
		}
	}
	
	func updateIndexArr() {
		self.m_selectedItems.sortInPlace { (item1, item2) -> Bool in
			return item1.m_index.item < item2.m_index.item
		}
		
		self.m_selectedIndex.removeAll()
		for asset in self.m_selectedItems {
			self.m_selectedIndex.append(asset.m_index)
		}
	}
	
	func clearData() {
		self.m_selectedItems.removeAll()
		self.m_selectedIndex.removeAll()
	}

}
