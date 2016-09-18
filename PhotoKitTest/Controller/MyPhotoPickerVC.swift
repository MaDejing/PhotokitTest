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
	
	lazy var m_albums: [MyPhotoAlbumItem] = []
	var m_firstLoad: Bool = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "照片库"
		
		let rightBarItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action:#selector(MyPhotoPickerVC.cancel) )
		self.navigationItem.rightBarButtonItem = rightBarItem
		
		// 列出所有相册智能相册
		let smartAlbums: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: PHFetchOptions())
		self.convertCollection(smartAlbums as! PHFetchResult<AnyObject>)
		
		let cloudAlbums: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: PHFetchOptions())
		self.convertCollection(cloudAlbums as! PHFetchResult<AnyObject>)
		
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
		
		if (self.m_firstLoad) {
			self.pushToAlbumDetail(0, animated: false)
			
			self.m_firstLoad = false
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}

extension MyPhotoPickerVC {
	func cancel() {
		self.dismiss(animated: true, completion: nil)
	}
	
	fileprivate func convertCollection(_ collection: PHFetchResult<AnyObject>){
		for i in 0 ..< collection.count {
			// 获取所有资源的集合，并按资源的创建时间排序
			let resultsOptions = PHFetchOptions()
			//这里是按照创建时间排序
			resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
			//			resultsOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
			
			guard let c = collection[i] as? PHAssetCollection else { return }
			
			let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: c , options: resultsOptions)
			if assetsFetchResult.count > 0 {
				let newAlbumItem = MyPhotoAlbumItem(title: c.localizedTitle!, content: assetsFetchResult as! PHFetchResult<AnyObject>)
				
				if (c.localizedTitle == "我的照片流") {
					self.m_albums.insert(newAlbumItem, at: 1)
				} else {
					self.m_albums.append(newAlbumItem)
				}
			}
		}
	}
	
	func pushToAlbumDetail(_ index: Int, animated: Bool) {
		let sb = UIStoryboard(name: "Main", bundle: nil)
		let vc = sb.instantiateViewController(withIdentifier: "MyPhotoGridVC") as! MyPhotoGridVC
		
		let album = self.m_albums[index]
		vc.m_fetchResult = album.m_content as! PHFetchResult<PHAsset>!
		vc.title = album.m_title
		
		self.navigationController?.pushViewController(vc, animated: animated)
	}
}

extension MyPhotoPickerVC: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.m_albums.count;
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: MyPhotoPickerCell.getCellIdentifier(), for: indexPath) as! MyPhotoPickerCell
		let row = (indexPath as NSIndexPath).row
		let item = self.m_albums[row]
		cell.updateRowWithData(item)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return MyPhotoPickerCell.getCellHeight()
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		self.pushToAlbumDetail((indexPath as NSIndexPath).row, animated: true)
	}

}


