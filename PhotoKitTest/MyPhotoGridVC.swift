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
	var m_img: UIImage!
	var m_asset: PHAsset!
	var m_index: NSIndexPath!
	
	init(image: UIImage, asset: PHAsset, index: NSIndexPath) {
		self.m_img = image
		self.m_asset = asset
		self.m_index = index
	}
}

class MyPhotoGridVC: UIViewController {
	
	@IBOutlet weak var m_collectionView: UICollectionView!
	@IBOutlet weak var m_preview: UIBarButtonItem!
	@IBOutlet weak var m_done: UIBarButtonItem!
	@IBOutlet weak var m_toolBar: UIToolbar!
	
	var m_selectedAssets: [MyPhotoItem]! = []
	var m_selectedIndex: [NSIndexPath]! = []
	
	let m_selectedLabelWidth: CGFloat = 30
	
	lazy var m_selectedBgView: UIView = {
		var tempBgView = UIView.init(frame: CGRectMake(kScreenWidth-56-28, (44-self.m_selectedLabelWidth)/2, self.m_selectedLabelWidth, self.m_selectedLabelWidth))
		tempBgView.backgroundColor = UIColor.blackColor()
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
	
	var m_fetchResult: PHFetchResult!
	
	lazy var m_imageManager: PHCachingImageManager = PHCachingImageManager()
	
	/// 小图大小
	var m_assetGridThumbnailSize: CGSize!
	
	let m_minLineSpace: CGFloat = 5.0
	let m_minItemSpace: CGFloat = 5.0
	let m_collectionTop: CGFloat = 0
	let m_collectionLeft: CGFloat = 5
	let m_collectionBottom: CGFloat = 0
	let m_collectionRight: CGFloat = 5
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.m_imageManager.stopCachingImagesForAllAssets()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.initData()
		self.initSubViews()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
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
		
		self.m_collectionView.backgroundColor = UIColor.whiteColor()
		self.m_collectionView.allowsMultipleSelection = true
		
		self.scrollToBottom()
		
		self.m_toolBar.addSubview(self.m_selectedBgView)
		self.m_toolBar.addSubview(self.m_selectedLabel)
		
		self.updateToolBarView()
	}
	
	func scrollToBottom() {
		self.m_collectionView.layoutIfNeeded()
		self.m_collectionView.reloadData()
		
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
		let enable = self.m_selectedAssets.count > 0

		self.m_preview.enabled = enable
		self.m_done.enabled = enable
	}
	
	func showSelectLabel() {
		self.m_selectedBgView.hidden = self.m_selectedAssets.count <= 0
		self.m_selectedBgView.transform = CGAffineTransformMakeScale(0.1, 0.1)
		UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
			self.m_selectedBgView.transform = CGAffineTransformIdentity
			}, completion: nil)
		
		self.m_selectedLabel.text = "\(self.m_selectedAssets.count)"
		self.m_selectedLabel.hidden = self.m_selectedAssets.count <= 0
	}
	
	func cancel() {
		self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func previewClick(sender: AnyObject) {
		
	}
	
	@IBAction func doneClick(sender: AnyObject) {
		
	}
}

extension MyPhotoGridVC: MyPhotoGridCellDelegate {
	func myPhotoGridCellButtonSelect(cell: MyPhotoGridCell, selected: Bool) {
		if selected {
			self.m_selectedAssets.append(cell.m_data)
		} else {
		    let index = self.m_selectedAssets.indexOf(cell.m_data)
			
			if (index != nil) {
				self.m_selectedAssets.removeAtIndex(index!)
			}
		}
		
		self.m_selectedIndex.removeAll()
		for asset in self.m_selectedAssets {
			self.m_selectedIndex.append(asset.m_index)
		}

		self.updateToolBarView()
	}
}

extension MyPhotoGridVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.m_fetchResult.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MyPhotoGridCell.getCellIndentifier(), forIndexPath: indexPath) as! MyPhotoGridCell
		
		cell.m_delegate = self
		
		let asset = self.m_fetchResult[indexPath.row] as! PHAsset
		
		self.m_imageManager.requestImageForAsset(asset, targetSize: self.m_assetGridThumbnailSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, nfo) in
			cell.updateCellWithData(MyPhotoItem(image: image!, asset: asset, index: indexPath))
		}
		
		cell.m_selectButton.selected = self.m_selectedIndex.contains(indexPath)

		return cell
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MyPhotoPreviewVC") as! MyPhotoPreviewVC
		vc.m_fetchResult = self.m_fetchResult
		vc.m_curIndexPath = indexPath
		
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
		
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(self.m_collectionTop, self.m_collectionLeft, self.m_collectionBottom, self.m_collectionRight)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		let width = (kScreenWidth-self.m_minItemSpace*3-self.m_collectionLeft-self.m_collectionRight) / 4
		return CGSizeMake(width, width)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return self.m_minLineSpace
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
		return self.m_minItemSpace
	}
}
