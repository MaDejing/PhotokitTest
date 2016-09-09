//
//  MyPhotoPreviewVC.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/9/8.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import Foundation
import UIKit
import Photos

class MyPhotoPreviewVC: UIViewController {
	
	@IBOutlet weak var m_topView: UIView!
	@IBOutlet weak var m_collectionView: UICollectionView!
	
	var m_fetchResult: PHFetchResult!
	var m_curIndexPath: NSIndexPath!
		
	lazy var m_imageManager: PHCachingImageManager = PHCachingImageManager()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.m_imageManager.stopCachingImagesForAllAssets()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	
		self.m_collectionView.backgroundColor = UIColor.blackColor()
		self.m_collectionView.registerClass(MyPhotoPreviewCell.self, forCellWithReuseIdentifier: MyPhotoPreviewCell.getCellIdentifier())
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController?.setNavigationBarHidden(true, animated: false)
		
//		self.m_collectionView.layoutIfNeeded()
//		self.m_collectionView.scrollToItemAtIndexPath(NSIndexPath.init(forItem: self.m_curIndexPath.row, inSection: 0), atScrollPosition: .Left, animated: false)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
}

extension MyPhotoPreviewVC {
	
	@IBAction func backClick(sender: AnyObject) {
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	@IBAction func selectClick(sender: AnyObject) {
	}
	
}

extension MyPhotoPreviewVC: UIScrollViewDelegate {
	func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		
		if scrollView == self.m_collectionView {
			targetContentOffset.memory = scrollView.contentOffset
			
			let flowLayout = self.m_collectionView.collectionViewLayout as! UICollectionViewFlowLayout
			let pageWidth = CGRectGetWidth(scrollView.frame) + flowLayout.minimumLineSpacing
			
			var assistanceOffset: CGFloat = pageWidth / 2.0
			
			if velocity.x < 0 {
				assistanceOffset = -assistanceOffset
			}
			
			let assistedScrollPosition = (scrollView.contentOffset.x + assistanceOffset) / pageWidth

			var cellToScroll = Int(round(assistedScrollPosition))
			if (cellToScroll < 0) {
				cellToScroll = 0
			} else if (cellToScroll >= self.m_collectionView.numberOfItemsInSection(0)) {
				cellToScroll = self.m_collectionView.numberOfItemsInSection(0) - 1
			}
			
			self.m_collectionView.scrollToItemAtIndexPath(NSIndexPath.init(forItem: cellToScroll, inSection: 0), atScrollPosition: .Left, animated: true)
		}
	}
}

extension MyPhotoPreviewVC: MyPhotoPreviewCellDelegate {
	func afterSingleTap(cell: MyPhotoPreviewCell) {
		self.m_topView.hidden = !self.m_topView.hidden
	}
}

extension MyPhotoPreviewVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.m_fetchResult.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MyPhotoPreviewCell.getCellIdentifier(), forIndexPath: indexPath) as! MyPhotoPreviewCell
		
		cell.m_delegate = self
		
		let asset = self.m_fetchResult[indexPath.row] as! PHAsset
		
		self.m_imageManager.requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, nfo) in
			cell.updateCellWithData(MyPhotoItem(image: image!, asset: asset, index: indexPath))
		}
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
		if let cell = cell as? MyPhotoPreviewCell {
			cell.imageResize()
		}
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return self.m_collectionView.frame.size
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 10.0
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 0.0
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(0, 0, 0, 0)
	}
}
