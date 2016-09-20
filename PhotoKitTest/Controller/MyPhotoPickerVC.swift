//
//  MyPhotoPickerVC.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/9/7.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import Foundation
import UIKit
import Photos

// MARK: - Class - 相册
class MyPhotoAlbumItem: NSObject {
	var m_title: String = ""
	var m_content: PHFetchResult<AnyObject>!
	
	init(title: String, content: PHFetchResult<AnyObject>) {
		self.m_title = title;
		self.m_content = content;
	}
}

// MARK: - Class - 相册展示
class MyPhotoPickerVC: UIViewController {
	
	/// Storyboard 相关
	@IBOutlet weak var m_tableView: UITableView!
	
	/// 相册数组
	fileprivate lazy var m_albums: [MyPhotoAlbumItem] = []
	
	/// 是否第一次出现（第一次出现时直接展示相册胶卷）
	fileprivate var m_firstLoad: Bool = true
	
	/// 智能相册 & 其他相册
	var m_smartAlbums: PHFetchResult<PHAssetCollection>!
	var m_otherAlbums: PHFetchResult<PHAssetCollection>!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "照片库"
		
		let rightBarItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.cancel) )
		navigationItem.rightBarButtonItem = rightBarItem
		
		m_smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: PHFetchOptions())
		convertCollection(m_smartAlbums)
		
		m_otherAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: PHFetchOptions())
		convertCollection(m_otherAlbums)
		
		PHPhotoLibrary.shared().register(self)
		
//		//列出用户创建的相册
//		let topLevelUserCollections: PHFetchResult = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
//		self.convertCollection(topLevelUserCollections)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if (m_firstLoad) {
			pushToAlbumDetail(0, animated: false)
			
			m_firstLoad = false
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	deinit {
		PHPhotoLibrary.shared().unregisterChangeObserver(self)
	}
	
}

// MARK: - 方法
extension MyPhotoPickerVC {
	func cancel() {
		dismiss(animated: true, completion: nil)
	}
	
	fileprivate func convertCollection(_ collection: PHFetchResult<PHAssetCollection>) {
		for i in 0 ..< collection.count {
			/// 获取所有资源的集合，并按资源的创建时间排序
			let resultsOptions = PHFetchOptions()
			resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
			
			let c = collection[i]
			let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: c, options: resultsOptions)
			if assetsFetchResult.count > 0 {
				let newAlbumItem = MyPhotoAlbumItem(title: c.localizedTitle!, content: assetsFetchResult as! PHFetchResult<AnyObject>)
				
				if (c.localizedTitle == "我的照片流") {
					m_albums.insert(newAlbumItem, at: 1)
				} else {
					m_albums.append(newAlbumItem)
				}
			}
		}
	}
	
	fileprivate func pushToAlbumDetail(_ index: Int, animated: Bool) {
		let sb = UIStoryboard(name: "Main", bundle: nil)
		let vc = sb.instantiateViewController(withIdentifier: "MyPhotoGridVC") as! MyPhotoGridVC
		
		let album = m_albums[index]
		vc.m_fetchResult = album.m_content as! PHFetchResult<PHAsset>!
		vc.title = album.m_title
		
		navigationController?.pushViewController(vc, animated: animated)
	}
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MyPhotoPickerVC: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return m_albums.count;
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: MyPhotoPickerCell.getCellIdentifier(), for: indexPath) as! MyPhotoPickerCell
		let row = (indexPath as NSIndexPath).row
		let item = m_albums[row]
		cell.updateRowWithData(item)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return MyPhotoPickerCell.getCellHeight()
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		pushToAlbumDetail((indexPath as NSIndexPath).row, animated: true)
	}
}

// MARK: - PHPhotoLibraryChangeObserver
extension MyPhotoPickerVC: PHPhotoLibraryChangeObserver {
	
	func photoLibraryDidChange(_ changeInstance: PHChange) {
		DispatchQueue.main.sync {
			var assetChanged = false

			if let changeDetailsSmart = changeInstance.changeDetails(for: m_smartAlbums) {
				assetChanged = true
				m_smartAlbums = changeDetailsSmart.fetchResultAfterChanges
			}
			
			if let changeDetailsAlbums = changeInstance.changeDetails(for: m_otherAlbums) {
				assetChanged = true
				m_otherAlbums = changeDetailsAlbums.fetchResultAfterChanges
			}
			
			if !assetChanged {
				for i in 0 ..< m_smartAlbums.count {
					let resultsOptions = PHFetchOptions()
					resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
					
					let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: m_smartAlbums[i], options: resultsOptions)
					
					if let _ = changeInstance.changeDetails(for: assetsFetchResult) {
						assetChanged = true
						break
					}
				}
			}

			if !assetChanged {
				for i in 0 ..< m_otherAlbums.count {
					let resultsOptions = PHFetchOptions()
					resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
					
					let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: m_otherAlbums[i], options: resultsOptions)
					
					if let _ = changeInstance.changeDetails(for: assetsFetchResult) {
						assetChanged = true
						break
					}
				}
			}
			
			if assetChanged {
				m_albums.removeAll()
				convertCollection(m_smartAlbums)
				convertCollection(m_otherAlbums)
				m_tableView.reloadData()
			}
			
		}
	}
}


