//
//  MyPhotoGridVC.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/9/7.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import Foundation
import UIKit
import Photos

let kScreenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
let kScreenHeight = CGRectGetHeight(UIScreen.mainScreen().bounds)

class MyPhotoItem: NSObject {
	var m_img: UIImage! = UIImage()
	var m_asset: PHAsset! = PHAsset()
	var m_index: NSIndexPath!
	
	func updateWithData(image: UIImage, asset: PHAsset, index: NSIndexPath) {
		self.m_img = image
		self.m_asset = asset
		self.m_index = index
	}
}

class MyPhotoGridVC: UIViewController {
	
	// StoryBoard相关
	@IBOutlet weak var m_collectionView: UICollectionView!
	@IBOutlet weak var m_preview: UIBarButtonItem!
	@IBOutlet weak var m_done: UIBarButtonItem!
	@IBOutlet weak var m_toolBar: UIToolbar!
	
	// 视图相关
	let m_selectedLabelWidth: CGFloat = 30
	
	lazy var m_selectedBgView: UIView = {
		var tempBgView = UIView.init(frame: CGRectMake(kScreenWidth-56-28, (44-self.m_selectedLabelWidth)/2, self.m_selectedLabelWidth, self.m_selectedLabelWidth))
		tempBgView.backgroundColor = UIColor(red: 31/255.0, green: 183/255.0, blue: 27/255.0, alpha: 1)
		tempBgView.layer.cornerRadius = 15
		tempBgView.layer.masksToBounds = true
		
		return tempBgView
	}()
	
	lazy var m_selectedLabel: UILabel = {
		var tempLabel = UILabel.init(frame: CGRectMake(kScreenWidth-56-28, (44-self.m_selectedLabelWidth)/2, self.m_selectedLabelWidth, self.m_selectedLabelWidth))
		tempLabel.font = UIFont(name: "PingFang-SC-Regular", size: 15)
		tempLabel.textColor = UIColor.whiteColor()
		tempLabel.textAlignment = .Center
		tempLabel.backgroundColor = UIColor.clearColor()
		
		return tempLabel
	}()
	
	// Collectionview 视图相关
	let m_minLineSpace: CGFloat = 5.0
	let m_minItemSpace: CGFloat = 5.0
	let m_collectionTop: CGFloat = 0
	let m_collectionLeft: CGFloat = 5
	let m_collectionBottom: CGFloat = 0
	let m_collectionRight: CGFloat = 5
	
	// 数据相关
	var m_fetchResult: PHFetchResult!
    
    lazy var m_allAssets: [PHAsset] = {
        var tempArr: [PHAsset] = []
        for i in 0 ..< self.m_fetchResult.count {
            let asset = self.m_fetchResult[i] as! PHAsset
            tempArr.append(asset)
        }
        
        return tempArr
    }()
    
	var m_assetGridThumbnailSize: CGSize!
	
	var m_isPop = true
	
    override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
        self.initData()
		self.initSubViews()
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
    }
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		if (self.m_isPop) {
			MyPhotoSelectManager.defaultManager.clearData()
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
		print("\(self.classForCoder)内存泄露")
	}
	
	deinit {
//		print("释放\(self.classForCoder)")
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return false
	}

}

// MARK: - Initial Functions
extension MyPhotoGridVC {
	func initData() {
		// 计算出小图大小 （ 为targetSize做准备 ）
		let scale: CGFloat = 2.0
		let cellSize = (self.m_collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        
        self.m_assetGridThumbnailSize = CGSizeMake(cellSize.width*scale, cellSize.height*scale)
	}
	
	func initSubViews() {
		let rightBarItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action:#selector(MyPhotoGridVC.cancel) )
		self.navigationItem.rightBarButtonItem = rightBarItem
        
        self.initWithCollectionView()
        self.scrollToBottom()
						
		self.m_toolBar.addSubview(self.m_selectedBgView)
		self.m_toolBar.addSubview(self.m_selectedLabel)
		
		self.updateToolBarView()
	}
    
    func initWithCollectionView() {
        self.m_collectionView.backgroundColor = UIColor.whiteColor()
        self.m_collectionView.allowsMultipleSelection = true
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = self.m_minLineSpace
        collectionViewFlowLayout.minimumInteritemSpacing = self.m_minItemSpace
        collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(self.m_collectionTop, self.m_collectionLeft, self.m_collectionBottom, self.m_collectionRight)
        let width = (kScreenWidth - self.m_minItemSpace*3 - self.m_collectionLeft - self.m_collectionRight) / 4
        collectionViewFlowLayout.itemSize = CGSizeMake(width, width)
        self.m_collectionView.collectionViewLayout = collectionViewFlowLayout
    }
	
	func scrollToBottom() {
		self.m_collectionView.layoutIfNeeded()
		
		let contentSize = self.m_collectionView.contentSize
		let frameSize = self.m_collectionView.frame.size
		if contentSize.height + 64 > frameSize.height {
			self.m_collectionView.setContentOffset(CGPointMake(0, self.m_collectionView.contentSize.height - self.m_collectionView.frame.size.height + 64), animated: false)
		}
	}
	
	func updateToolBarView() {
		self.showSelectLabel()
		self.enableItems()
	}
}

extension MyPhotoGridVC {
	func enableItems() {
		let enable = MyPhotoSelectManager.defaultManager.m_selectedItems.count > 0

		self.m_preview.enabled = enable
		self.m_done.enabled = enable
	}
	
	func showSelectLabel() {
		self.m_selectedBgView.hidden = MyPhotoSelectManager.defaultManager.m_selectedItems.count <= 0
		self.m_selectedBgView.transform = CGAffineTransformMakeScale(0.1, 0.1)
		UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
			self.m_selectedBgView.transform = CGAffineTransformIdentity
			}, completion: nil)
		
		self.m_selectedLabel.text = "\(MyPhotoSelectManager.defaultManager.m_selectedItems.count)"
		self.m_selectedLabel.hidden = MyPhotoSelectManager.defaultManager.m_selectedItems.count <= 0
	}
	
	func cancel() {
		self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func previewClick(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MyPhotoPreviewVC") as! MyPhotoPreviewVC
        
        var assets: [PHAsset] = []
        for item in MyPhotoSelectManager.defaultManager.m_selectedItems {
            assets.append(item.m_asset)
        }
        vc.m_assets = assets
        vc.m_allAssets = self.m_allAssets
        vc.m_firstIndexPath = NSIndexPath.init(forItem: 0, inSection: 0)
        vc.m_delegate = self
		
		self.m_isPop = false
		
        self.navigationController?.pushViewController(vc, animated: true)
	}
	
	@IBAction func doneClick(sender: AnyObject) {
		var hasVideo: Bool = false
		
		for item in MyPhotoSelectManager.defaultManager.m_selectedItems {
			if (item.m_asset.mediaType == .Video) {
				hasVideo = true
				break
			}
		}
		
		if hasVideo {
			let alert = UIAlertController(title: nil, message: "您同时选中了照片和视频，视频将作为照片发送", preferredStyle: .Alert)
			let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
			let doneAction = UIAlertAction(title: "确定", style: .Default, handler: { (action) in
				print(MyPhotoSelectManager.defaultManager.m_selectedItems)
				self.dismissViewControllerAnimated(true, completion: nil)
			})
			
			alert.addAction(cancelAction)
			alert.addAction(doneAction)
			
			self.presentViewController(alert, animated: true, completion: nil)
		} else {
			print(MyPhotoSelectManager.defaultManager.m_selectedItems)
			self.dismissViewControllerAnimated(true, completion: nil)
			MyPhotoSelectManager.defaultManager.clearData()
		}
	}
}

extension MyPhotoGridVC: MyPhotoGridCellDelegate, MyPhotoPreviewVCDelegate {
	func myPhotoGridCellButtonSelect(cell: MyPhotoGridCell, selected: Bool) {
		
		let selectedItem = MySelectedItem.init(asset: cell.m_data.m_asset, index: cell.m_data.m_index)
		MyPhotoSelectManager.defaultManager.updateSelectItems(self, selected: selected, button: cell.m_selectButton, selectedItem: selectedItem)
		self.updateToolBarView()
	}
	
	func afterChangeSelectedItem(vc: MyPhotoPreviewVC, selectedItems: [MySelectedItem], selectedIndex: [NSIndexPath]) {
		
        self.m_collectionView.reloadData()
		self.updateToolBarView()
		self.m_isPop = true
    }
}

extension MyPhotoGridVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.m_fetchResult.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MyPhotoGridCell.getCellIndentifier(), forIndexPath: indexPath) as! MyPhotoGridCell
		
		cell.m_delegate = self
		
		let asset = self.m_fetchResult[indexPath.item] as! PHAsset
		
		cell.updateData(asset, size: self.m_assetGridThumbnailSize, indexPath: indexPath)
		
//		let option = PHImageRequestOptions()
//		option.resizeMode = .Fast
//		
//		self.m_imageManager.requestImageForAsset(asset, targetSize: self.m_assetGridThumbnailSize, contentMode: PHImageContentMode.AspectFill, options: option) { (image, info) in
//			let item = MyPhotoItem()
//			item.updateWithData(image!, asset: asset, index: indexPath)
//			cell.updateCellWithData(item)
//		}
//		
		cell.m_selectButton.selected = MyPhotoSelectManager.defaultManager.m_selectedIndex.contains(indexPath)

		return cell
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		collectionView.deselectItemAtIndexPath(indexPath, animated: true)
		
		let asset = self.m_fetchResult[indexPath.item] as! PHAsset

		if (asset.mediaType == .Video) {
			if MyPhotoSelectManager.defaultManager.m_selectedItems.count > 0 {
				let alert = UIAlertController(title: nil, message: "选择照片时不能预览视频", preferredStyle: .Alert)
				let cancelAction = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
				alert.addAction(cancelAction)
				
				self.presentViewController(alert, animated: true, completion: nil)
			} else {
				let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MyVideoPreviewVC") as! MyVideoPreviewVC
				
				vc.m_asset = asset
				
				self.navigationController?.pushViewController(vc, animated: true)
			}
			
		} else {
			let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MyPhotoPreviewVC") as! MyPhotoPreviewVC
			
			vc.m_assets = self.m_allAssets
			vc.m_allAssets = self.m_allAssets
			vc.m_firstIndexPath = indexPath
			vc.m_delegate = self
			
			self.m_isPop = false
			
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
}
