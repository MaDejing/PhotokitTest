//
//  MyPhotoPreviewCell.swift
//  PhotoKitTest
//
//  Created by DejingMa on 16/9/9.
//  Copyright © 2016年 DejingMa. All rights reserved.
//

import UIKit
import Photos

protocol MyPhotoPreviewCellDelegate: NSObjectProtocol {
	func afterSingleTap(_ cell: MyPhotoPreviewCell)
}

class MyPhotoPreviewCell: UICollectionViewCell {
	
    lazy var m_actIndicator: UIActivityIndicatorView = {
        var tempAct = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        
        tempAct.center = self.center
        tempAct.hidesWhenStopped = true
        tempAct.startAnimating()
        
        return tempAct
    }()
    
	lazy var m_scrollView: UIScrollView = {
		var tempScrollView = UIScrollView(frame: self.contentView.bounds)
		
		tempScrollView.delegate = self
		tempScrollView.backgroundColor = UIColor.black
		tempScrollView.maximumZoomScale = 2
		tempScrollView.minimumZoomScale = 1
		tempScrollView.showsVerticalScrollIndicator = false
		tempScrollView.showsHorizontalScrollIndicator = false
		
		return tempScrollView
	}()
	
	fileprivate lazy var m_imageView: UIImageView = {
		var tempImgView = UIImageView(frame: self.m_scrollView.bounds)
		
		tempImgView.contentMode = .scaleAspectFit
		tempImgView.isUserInteractionEnabled = true
		
		return tempImgView
	}()
	
	fileprivate var m_data: MyPhotoItem!
	
	weak var m_delegate: MyPhotoPreviewCellDelegate?
    
    override func awakeFromNib() {
        self.m_actIndicator.isHidden = false
        self.m_actIndicator.startAnimating()
    }
    
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.singleTap))
		singleTap.numberOfTapsRequired = 1
		singleTap.numberOfTouchesRequired = 1
		
		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTap))
		doubleTap.numberOfTapsRequired = 2
		doubleTap.numberOfTouchesRequired = 1
		
		singleTap.require(toFail: doubleTap)
		
		self.m_scrollView.addGestureRecognizer(singleTap)
		self.m_scrollView.addGestureRecognizer(doubleTap)
		
		self.m_scrollView.addSubview(self.m_imageView)
		self.contentView.addSubview(self.m_scrollView)
        
        self.contentView.addSubview(self.m_actIndicator)
    }
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	static func getCellIdentifier() -> String {
		return "MyPhotoPreviewCell"
	}
	
	func updateData(_ asset: PHAsset, size: CGSize, indexPath: IndexPath) {
		
		let option = PHImageRequestOptions()
		option.deliveryMode = .opportunistic
		option.isSynchronous = true
		option.progressHandler = { progress, _, _, _ in
			DispatchQueue.main.sync {
				self.m_scrollView.isHidden = true
				self.m_actIndicator.startAnimating()
				self.bringSubview(toFront: self.m_actIndicator)
			}
		}
		
		let _ = MyPhotoImageManager.defaultManager.getPhotoWithAsset(asset, size: size, options: option) { (image, info, isDegraded) in
			let item = MyPhotoItem()
			item.updateWithData(image, asset: asset, index: indexPath)
			self.updateCellWithData(item)
		}
	}
	
	func updateCellWithData(_ data: MyPhotoItem) {
		self.m_data = data
		
		self.m_imageView.image = data.m_img
        
        self.imageResize()
        
        self.m_scrollView.isHidden = false
        self.m_actIndicator.stopAnimating()
        self.bringSubview(toFront: self.m_scrollView)
    }
}

extension MyPhotoPreviewCell {

	func imageResize() {
		self.m_scrollView.zoomScale = 1
		
		guard let img = self.m_imageView.image else { return }
		
		let imgSize = img.size
		let widthRatio = imgSize.width / kScreenWidth
        		
		let newSize = CGSize(width: imgSize.width / widthRatio, height: imgSize.height / widthRatio)
		self.m_imageView.frame.size = newSize
        
        if (newSize.height <= self.m_scrollView.frame.size.height) {
            self.m_imageView.center = self.m_scrollView.center
        } else {
            self.m_imageView.frame.origin = CGPoint.zero
        }
        
        self.m_scrollView.contentOffset = CGPoint.zero
        self.m_scrollView.contentSize = CGSize(width: kScreenWidth, height: max(kScreenHeight, self.m_imageView.frame.size.height))
    }
    
    // 把从scrollView里截取的矩形区域缩放到整个scrollView当前可视的frame里面。获取所要放大的内容的rect，以点击点为中心。因为放大scale倍，所以截取内容宽高为scrollview的1/scale。
    fileprivate func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect: CGRect = CGRect.zero
        
        //大小
        zoomRect.size.height = self.m_scrollView.frame.size.height/scale;
        zoomRect.size.width = self.m_scrollView.frame.size.width/scale;
        //原点
        zoomRect.origin.x = center.x - zoomRect.size.width/2;
        zoomRect.origin.y = center.y - zoomRect.size.height/2;
        
        return zoomRect;
    }
}

extension MyPhotoPreviewCell {
	func singleTap(_ ges: UITapGestureRecognizer) {
		self.m_delegate?.afterSingleTap(self)
	}
	
	func doubleTap(_ ges: UITapGestureRecognizer) {
		let newScale: CGFloat
		
		if self.m_scrollView.zoomScale == 1 {
			newScale = self.m_scrollView.maximumZoomScale
		} else {
			newScale = 1
		}
		
		let newRect = self.zoomRectForScale(newScale, center: ges.location(in: self.m_imageView))
        self.m_scrollView.zoom(to: newRect, animated: true)
	}
}

extension MyPhotoPreviewCell: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.m_imageView
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		var xcenter = scrollView.center.x
		var ycenter = scrollView.center.y
		
		// ScrollView中内容的大小和ScrollView本身的大小，哪个大取哪个的中心
		let contentWidthLarger: Bool = scrollView.contentSize.width > scrollView.frame.size.width
		let contentHeightLarger: Bool = scrollView.contentSize.height > scrollView.frame.size.height
		
		xcenter = contentWidthLarger ? scrollView.contentSize.width/2 : xcenter
		ycenter = contentHeightLarger ? scrollView.contentSize.height/2 : ycenter
		self.m_imageView.center = CGPoint(x: xcenter, y: ycenter)
	}
	
}
