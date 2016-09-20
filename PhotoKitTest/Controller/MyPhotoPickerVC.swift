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

class MyPhotoAlbumItem: NSObject {
	var m_title: String = ""
	var m_content: PHFetchResult<AnyObject>!
	
	init(title: String, content: PHFetchResult<AnyObject>) {
		self.m_title = title;
		self.m_content = content;
	}
}

class MyPhotoPickerVC: UIViewController {
	
	@IBOutlet weak var m_tableView: UITableView!
	
	fileprivate lazy var m_albums: [MyPhotoAlbumItem] = []
	fileprivate var m_firstLoad: Bool = true
	
	var m_smartAlbums: PHFetchResult<PHAssetCollection>!
	var m_cloudAlbums: PHFetchResult<PHAssetCollection>!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "照片库"
		
		let rightBarItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.cancel) )
		navigationItem.rightBarButtonItem = rightBarItem
		
		// 列出所有相册智能相册
		m_smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: PHFetchOptions())
		convertCollection(m_smartAlbums)
		
		m_cloudAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: PHFetchOptions())
		convertCollection(m_cloudAlbums)
		
		PHPhotoLibrary.shared().register(self)
		
//		//列出用户创建的相册
//		let topLevelUserCollections: PHFetchResult = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
//		self.convertCollection(topLevelUserCollections)
		
//		//相册按包含的照片数量排序（降序）
//		self.m_items.sortInPlace { (item1, item2) -> Bool in
//			return item1.m_content.count > item2.m_content.count
//		}
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

extension MyPhotoPickerVC {
	func cancel() {
		self.dismiss(animated: true, completion: nil)
	}
	
	fileprivate func convertCollection(_ collection: PHFetchResult<PHAssetCollection>) {
		for i in 0 ..< collection.count {
			// 获取所有资源的集合，并按资源的创建时间排序
			let resultsOptions = PHFetchOptions()
			//这里是按照创建时间排序
			resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
			//			resultsOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
			
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

extension MyPhotoPickerVC: PHPhotoLibraryChangeObserver {
	
	func photoLibraryDidChange(_ changeInstance: PHChange) {
		DispatchQueue.main.sync {
			var assetChanged = false

			if let changeDetailsSmart = changeInstance.changeDetails(for: m_smartAlbums) {
				assetChanged = true
				m_smartAlbums = changeDetailsSmart.fetchResultAfterChanges
			}
			
			if let changeDetailsAlbums = changeInstance.changeDetails(for: m_cloudAlbums) {
				assetChanged = true
				m_cloudAlbums = changeDetailsAlbums.fetchResultAfterChanges
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
				for i in 0 ..< m_cloudAlbums.count {
					let resultsOptions = PHFetchOptions()
					resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
					
					let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: m_cloudAlbums[i], options: resultsOptions)
					
					if let _ = changeInstance.changeDetails(for: assetsFetchResult) {
						assetChanged = true
						break
					}
				}
			}
			
			if assetChanged {
				m_albums.removeAll()
				convertCollection(m_smartAlbums)
				convertCollection(m_cloudAlbums)
				m_tableView.reloadData()
			}
			
		}
	}
}


