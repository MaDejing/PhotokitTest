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

protocol MyPhotoPreviewVCDelegate: NSObjectProtocol {
	func afterChangeSelectedItem(vc: MyPhotoPreviewVC, selectedItems: [MySelectedItem], selectedIndex: [NSIndexPath])
}

class MyPhotoPreviewVC: UIViewController {
	
	@IBOutlet weak var m_topView: UIView!
	@IBOutlet weak var m_collectionView: UICollectionView!
    @IBOutlet weak var m_selectButton: UIButton!
    @IBOutlet weak var m_doneButton: UIButton!
    @IBOutlet weak var m_bottomView: UIView!
    
    let m_minLineSpace: CGFloat = 10.0
    let m_minItemSpace: CGFloat = 0.0
    let m_collectionTop: CGFloat = 0
    let m_collectionLeft: CGFloat = 0
    let m_collectionBottom: CGFloat = 0
    let m_collectionRight: CGFloat = 0
    
    let m_selectedLabelWidth: CGFloat = 30
    
    lazy var m_selectedBgView: UIView = {
        var tempBgView = UIView.init(frame: CGRectMake(kScreenWidth-84, (44-self.m_selectedLabelWidth)/2, self.m_selectedLabelWidth, self.m_selectedLabelWidth))
        tempBgView.backgroundColor = UIColor(red: 31/255.0, green: 183/255.0, blue: 27/255.0, alpha: 1)
        tempBgView.layer.cornerRadius = 15
        tempBgView.layer.masksToBounds = true
        
        return tempBgView
    }()
    
    lazy var m_selectedLabel: UILabel = {
        var tempLabel = UILabel.init(frame: CGRectMake(kScreenWidth-84, (44-self.m_selectedLabelWidth)/2, self.m_selectedLabelWidth, self.m_selectedLabelWidth))
        tempLabel.font = UIFont(name: "PingFang-SC-Regular", size: 15)
        tempLabel.textColor = UIColor.whiteColor()
        tempLabel.textAlignment = .Center
        tempLabel.backgroundColor = UIColor.clearColor()
        
        return tempLabel
    }()
    
	var m_assets: [PHAsset]! = []
    var m_allAssets: [PHAsset]! = []
	var m_firstIndexPath: NSIndexPath! = NSIndexPath.init(forItem: 0, inSection: 0)
//    var m_selectedIndex: [NSIndexPath]! = []
//	var m_selectedItems: [MySelectedItem] = []
	
    var m_curIndexPath: NSIndexPath!
    
	lazy var m_imageManager: PHCachingImageManager = PHCachingImageManager()
    
    weak var m_delegate: MyPhotoPreviewVCDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.m_imageManager.stopCachingImagesForAllAssets()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	
		self.title = "预览"
		
        self.initSubViews()
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
        
        self.m_collectionView.layoutIfNeeded()
        self.m_collectionView.scrollToItemAtIndexPath(NSIndexPath.init(forItem: self.m_firstIndexPath.item, inSection: 0), atScrollPosition: .Left, animated: false)
		
		self.navigationController?.setNavigationBarHidden(true, animated: false)
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
    
    func initSubViews() {
        self.initWithCollectionView()
        
        self.m_bottomView.addSubview(self.m_selectedBgView)
        self.m_bottomView.addSubview(self.m_selectedLabel)
        
        self.updateBottomView()
    }
    
    func initWithCollectionView() {
        self.m_collectionView.backgroundColor = UIColor.blackColor()
        self.m_collectionView.registerClass(MyPhotoPreviewCell.self, forCellWithReuseIdentifier: MyPhotoPreviewCell.getCellIdentifier())
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = self.m_minLineSpace
        collectionViewFlowLayout.minimumInteritemSpacing = self.m_minItemSpace
        collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(self.m_collectionTop, self.m_collectionLeft, self.m_collectionBottom, self.m_collectionRight)
        collectionViewFlowLayout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight)
        collectionViewFlowLayout.scrollDirection = .Horizontal
        self.m_collectionView.collectionViewLayout = collectionViewFlowLayout
    }
    
    func updateBottomView() {
        self.showSelectLabel()
        self.m_doneButton.enabled = MyPhotoSelectManager.defaultManager.m_selectedItems.count > 0
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
    
    func calImageSize(asset: PHAsset, scale: CGFloat) -> CGSize {
        // 计算图片大小
        var imageSize: CGSize = CGSizeMake(CGFloat(asset.pixelWidth), CGFloat(asset.pixelHeight))
        let aspectRatio: CGFloat = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
        imageSize = CGSizeMake(kScreenWidth*scale, kScreenWidth/aspectRatio*scale);
        
        return imageSize
    }
}

extension MyPhotoPreviewVC {
	
	@IBAction func backClick(sender: AnyObject) {
        self.m_delegate?.afterChangeSelectedItem(self, selectedItems: MyPhotoSelectManager.defaultManager.m_selectedItems, selectedIndex: MyPhotoSelectManager.defaultManager.m_selectedIndex)
        
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	@IBAction func selectClick(sender: AnyObject) {
//		if self.m_selectedItems.count >= 9 && !self.m_selectButton.selected {
//			let alert = UIAlertController(title: nil, message: "最多可选择9张照片", preferredStyle: .Alert)
//			let cancelAction = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
//			
//			alert.addAction(cancelAction)
//			
//			self.presentViewController(alert, animated: true, completion: nil)
//		} else {
//		
//			self.m_selectButton.selected = !self.m_selectButton.selected
//					
//			let selectedItem = MySelectedItem.init(asset: self.m_allAssets[self.m_curIndexPath.item], index: self.m_curIndexPath)
//			
//			if self.m_selectButton.selected {
//				self.m_selectedItems.append(selectedItem)
//			} else {
//				let index = self.m_selectedIndex.indexOf(self.m_curIndexPath)
//				
//				if (index != nil) {
//					self.m_selectedItems.removeAtIndex(index!)
//				}
//			}
//			
//			self.m_selectedItems.sortInPlace { (item1, item2) -> Bool in
//				return item1.m_index.item < item2.m_index.item
//			}
//			
//			self.m_selectedIndex.removeAll()
//			for asset in self.m_selectedItems {
//				self.m_selectedIndex.append(asset.m_index)
//			}
//		}
		
		let selectedItem = MySelectedItem.init(asset: self.m_allAssets[self.m_curIndexPath.item], index: self.m_curIndexPath)
		MyPhotoSelectManager.defaultManager.updateSelectItems(self, selected: self.m_selectButton.selected, button: self.m_selectButton, selectedItem: selectedItem)
		self.updateBottomView()
	}
	
    @IBAction func m_doneClick(sender: AnyObject) {
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

extension MyPhotoPreviewVC: UIScrollViewDelegate {
	func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		
		if scrollView == self.m_collectionView {
			targetContentOffset.memory = scrollView.contentOffset
			
			let pageWidth = CGRectGetWidth(scrollView.frame) + self.m_minLineSpace
            			
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
        self.m_bottomView.hidden = !self.m_bottomView.hidden
	}
}

extension MyPhotoPreviewVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.m_assets.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MyPhotoPreviewCell.getCellIdentifier(), forIndexPath: indexPath) as! MyPhotoPreviewCell
		
		cell.m_delegate = self
        cell.m_scrollView.hidden = true
        cell.m_actIndicator.startAnimating()
        cell.bringSubviewToFront(cell.m_actIndicator)
        
		let asset = self.m_assets[indexPath.item]
        
        self.m_curIndexPath = NSIndexPath.init(forItem: self.m_allAssets.indexOf(asset)!, inSection: 0)
        self.m_selectButton.selected = MyPhotoSelectManager.defaultManager.m_selectedIndex.contains(self.m_curIndexPath)

		let option = PHImageRequestOptions()
//		option.resizeMode = .Fast
		option.deliveryMode = .HighQualityFormat
		option.synchronous = true
		
        self.m_imageManager.requestImageForAsset(asset, targetSize: self.calImageSize(asset, scale: 1.5), contentMode: PHImageContentMode.AspectFill, options: option) { (image, info) in
			let item = MyPhotoItem()
			item.updateWithData(image!, asset: asset, index: indexPath)
			cell.updateCellWithData(item)
		}
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
		guard let cell = cell as? MyPhotoPreviewCell else { return }
		cell.imageResize()
	}
//	
//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//		return self.m_collectionView.frame.size
//	}
//	
//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
//		return self.m_minLineSpace
//	}
//	
//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
//		return self.m_minItemSpace
//	}
//	
//	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//		return UIEdgeInsetsMake(self.m_collectionTop, self.m_collectionLeft, self.m_collectionBottom, self.m_collectionRight)
//	}
}
