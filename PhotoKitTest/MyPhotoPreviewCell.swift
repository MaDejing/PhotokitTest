//
//  MyPhotoPreviewCell.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/9/9.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import UIKit

protocol MyPhotoPreviewCellDelegate: NSObjectProtocol {
	func afterSingleTap(cell: MyPhotoPreviewCell)
}

class MyPhotoPreviewCell: UICollectionViewCell {
	
	lazy var m_scrollView: UIScrollView = {
		var tempScrollView = UIScrollView(frame: self.contentView.bounds)
		
		tempScrollView.delegate = self
		tempScrollView.backgroundColor = UIColor.blackColor()
		tempScrollView.maximumZoomScale = 2
		tempScrollView.minimumZoomScale = 1
		tempScrollView.showsVerticalScrollIndicator = false
		tempScrollView.showsHorizontalScrollIndicator = false
		
		return tempScrollView
	}()
	
	lazy var m_imageView: UIImageView = {
		var tempImgView = UIImageView(frame: self.m_scrollView.bounds)
		
		tempImgView.contentMode = .ScaleAspectFit
		tempImgView.userInteractionEnabled = true
		
		return tempImgView
	}()
	
	var m_data: MyPhotoItem!
	
	weak var m_delegate: MyPhotoPreviewCellDelegate?
	
	var m_curGes: UIGestureRecognizer!
	var m_originGesLoc: CGPoint!
	var m_originContentSize: CGSize!
	var m_originImage: CGPoint!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		let singleTap = UITapGestureRecognizer(target: self, action: #selector(MyPhotoPreviewCell.singleTap(_:)))
		singleTap.numberOfTapsRequired = 1
		singleTap.numberOfTouchesRequired = 1
		
		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(MyPhotoPreviewCell.doubleTap(_:)))
		doubleTap.numberOfTapsRequired = 2
		doubleTap.numberOfTouchesRequired = 1
		
		singleTap.requireGestureRecognizerToFail(doubleTap)
		
		self.m_scrollView.addGestureRecognizer(singleTap)
		self.m_scrollView.addGestureRecognizer(doubleTap)
		
		self.m_scrollView.addSubview(self.m_imageView)
		self.contentView.addSubview(self.m_scrollView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	static func getCellIdentifier() -> String {
		return "MyPhotoPreviewCell"
	}
	
	func updateCellWithData(data: MyPhotoItem) {
		self.m_data = data
		
		self.m_imageView.image = data.m_img
	}
}

extension MyPhotoPreviewCell {

	func imageResize() {
		self.m_scrollView.zoomScale = 1
		
		guard let img = self.m_imageView.image else { return }
		
		let imgSize = img.size
		let widthRatio = imgSize.width / kScreenWidth
		let heightRatio = imgSize.height / kScreenHeight
		let ratio = max(widthRatio, heightRatio)
		
		let newSize = CGSizeMake(imgSize.width / ratio, imgSize.height / ratio)
		self.m_imageView.frame.size = newSize
		self.m_imageView.center = self.m_scrollView.center
	}
	
	func calContentOffsetAfterZoom(scrollView: UIScrollView, contentWidthDelta: CGFloat, contentHeightDelta: CGFloat) {
		var xOffset: CGFloat = 0.0
		var yOffset: CGFloat = 0.0
		
		if (contentWidthDelta > 0 || contentHeightDelta > 0) {
			let gesLoc = self.m_curGes.locationInView(self.m_curGes.view)
			let gesLocInImage = CGPointMake(self.m_originGesLoc.x - self.m_originImage.x, self.m_originGesLoc.y - self.m_originImage.y)
			
			if contentWidthDelta <= 0 || (gesLocInImage.x <= self.m_originContentSize.width/3) {
				xOffset = 0
			} else if (gesLocInImage.x >= self.m_originContentSize.width*2/3) {
				xOffset = scrollView.contentSize.width - scrollView.frame.size.width
			} else {
				xOffset = abs(gesLoc.x - self.m_originGesLoc.x)
			}
			
			if contentHeightDelta <= 0 || (gesLocInImage.y <= self.m_originContentSize.height/3) {
				yOffset = 0
			} else if (gesLocInImage.y >= self.m_originContentSize.height*2/3) {
				yOffset = scrollView.contentSize.height - scrollView.frame.size.height
			} else {
				yOffset = abs(gesLoc.y - self.m_originGesLoc.y)
			}
		}
		
		scrollView.contentOffset = CGPointMake(xOffset, yOffset)
	}
}

extension MyPhotoPreviewCell {
	func singleTap(ges: UITapGestureRecognizer) {
		self.m_delegate?.afterSingleTap(self)
	}
	
	func doubleTap(ges: UITapGestureRecognizer) {
		self.m_curGes = ges
		self.m_originGesLoc = ges.locationInView(ges.view)
		self.m_originContentSize = self.m_scrollView.contentSize
		self.m_originImage = self.m_imageView.frame.origin
		
		let newScale: CGFloat
		
		if self.m_scrollView.zoomScale == 1 {
			newScale = self.m_scrollView.maximumZoomScale
		} else {
			newScale = 1
		}
		
		UIView.animateWithDuration(0.5, animations: {
			self.m_scrollView.zoomScale = newScale
		})
	}
}

extension MyPhotoPreviewCell: UIScrollViewDelegate {
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return self.m_imageView
	}
	
	func scrollViewDidZoom(scrollView: UIScrollView) {
		var xcenter = scrollView.center.x
		var ycenter = scrollView.center.y
		
		// ScrollView中内容的大小和ScrollView本身的大小，哪个大取哪个的中心
		let contentWidthDelta: CGFloat = scrollView.contentSize.width - scrollView.frame.size.width
		let contentHeightDelta: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
		
		xcenter = contentWidthDelta > 0 ? scrollView.contentSize.width/2 : xcenter
		ycenter = contentHeightDelta > 0 ? scrollView.contentSize.height/2 : ycenter
		self.m_imageView.center = CGPointMake(xcenter, ycenter)
	
		self.calContentOffsetAfterZoom(scrollView, contentWidthDelta: contentWidthDelta, contentHeightDelta: contentHeightDelta)
	}
	
}
