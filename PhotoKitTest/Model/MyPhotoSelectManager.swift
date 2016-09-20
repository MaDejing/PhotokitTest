//
//  MyPhotoSelectManager.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/9/14.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import UIKit
import Photos

// MARK: - Class - 选中项
class MySelectedItem: NSObject {
	var m_asset: PHAsset!
	var m_index: IndexPath!
	
	init(asset: PHAsset, index: IndexPath) {
		self.m_asset = asset
		self.m_index = index
	}
}

/// 最多选中的数目
let maxCount: Int = 9

// MARK: - Class - 照片选择管理类
class MyPhotoSelectManager: NSObject {
	
	var m_selectedItems: [MySelectedItem] = []
	var m_selectedIndex: [IndexPath] = []
	
	/// static是延时加载的，并且是常量，加载一次后不会加载第二次，所以实现了单例。
	static let defaultManager: MyPhotoSelectManager = MyPhotoSelectManager()
	
	/// 更新已选项
	///
	/// - parameter vcToShowAlert: 展示提示框的VC
	/// - parameter button:        选择按钮
	/// - parameter selectedItem:  被选择的资源
	func updateSelectItems(vcToShowAlert: UIViewController, button: UIButton, selectedItem: MySelectedItem) {
		if self.m_selectedItems.count >= maxCount && !button.isSelected {
			let alert = UIAlertController(title: nil, message: "最多可选择\(maxCount)张照片", preferredStyle: .alert)
			let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
			
			alert.addAction(cancelAction)
			
			vcToShowAlert.present(alert, animated: true, completion: nil)
		} else {
			button.isSelected = !button.isSelected
						
			if button.isSelected {
				self.m_selectedItems.append(selectedItem)
			} else {
				let index = self.m_selectedIndex.index(of: selectedItem.m_index)
				
				if (index != nil) {
					self.m_selectedItems.remove(at: index!)
				}
			}
			
			self.updateIndexArr()
		}
	}
	
	/// 更新已选项index数组
	func updateIndexArr() {
		self.m_selectedItems.sort { (item1, item2) -> Bool in
			return item1.m_index.item < item2.m_index.item
		}
		
		self.m_selectedIndex.removeAll()
		for asset in self.m_selectedItems {
			self.m_selectedIndex.append(asset.m_index)
		}
	}
	
	/// 清空已选数据
	func clearData() {
		self.m_selectedItems.removeAll()
		self.m_selectedIndex.removeAll()
	}
	
	/// 发送事件
	///
	/// - parameter vcToDismiss: 需要dismiss的VC
	func doSend(vcToDismiss: UIViewController) {
		print(MyPhotoSelectManager.defaultManager.m_selectedItems)
		vcToDismiss.dismiss(animated: true, completion: nil)
		MyPhotoSelectManager.defaultManager.clearData()
	}

}
