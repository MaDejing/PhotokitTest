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
	func afterChangeSelectedItem(_ vc: MyPhotoPreviewVC, selectedItems: [MySelectedItem], selectedIndex: [IndexPath])
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
        var tempBgView = UIView.init(frame: CGRect(x: kScreenWidth-84, y: (44-self.m_selectedLabelWidth)/2, width: self.m_selectedLabelWidth, height: self.m_selectedLabelWidth))
        tempBgView.backgroundColor = UIColor(red: 31/255.0, green: 183/255.0, blue: 27/255.0, alpha: 1)
        tempBgView.layer.cornerRadius = 15
        tempBgView.layer.masksToBounds = true
        
        return tempBgView
    }()
    
    lazy var m_selectedLabel: UILabel = {
        var tempLabel = UILabel.init(frame: CGRect(x: kScreenWidth-84, y: (44-self.m_selectedLabelWidth)/2, width: self.m_selectedLabelWidth, height: self.m_selectedLabelWidth))
        tempLabel.font = UIFont(name: "PingFang-SC-Regular", size: 15)
        tempLabel.textColor = UIColor.white
        tempLabel.textAlignment = .center
        tempLabel.backgroundColor = UIColor.clear
        
        return tempLabel
    }()
	
	/// 需要上级传递的参数
	/// 需要展示的照片
	var m_assets: [PHAsset]! = []
	/// 所有的照片
    var m_allAssets: [PHAsset]! = []
	/// 首张展示的照片index
	var m_firstIndexPath: IndexPath! = IndexPath.init(item: 0, section: 0)
	
	/// 当前展示的照片index
    var m_curIndexPath: IndexPath!
	
    weak var m_delegate: MyPhotoPreviewVCDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
        self.initSubViews()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        
        self.m_collectionView.layoutIfNeeded()
        self.m_collectionView.scrollToItem(at: IndexPath.init(item: self.m_firstIndexPath.item, section: 0), at: .left, animated: false)
		
		self.navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	override var prefersStatusBarHidden : Bool {
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
        self.m_collectionView.backgroundColor = UIColor.black
        self.m_collectionView.register(MyPhotoPreviewCell.self, forCellWithReuseIdentifier: MyPhotoPreviewCell.getCellIdentifier())
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = self.m_minLineSpace
        collectionViewFlowLayout.minimumInteritemSpacing = self.m_minItemSpace
        collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(self.m_collectionTop, self.m_collectionLeft, self.m_collectionBottom, self.m_collectionRight)
        collectionViewFlowLayout.itemSize = CGSize(width: kScreenWidth, height: kScreenHeight)
        collectionViewFlowLayout.scrollDirection = .horizontal
        self.m_collectionView.collectionViewLayout = collectionViewFlowLayout
    }
    
    func updateBottomView() {
        self.showSelectLabel()
        self.m_doneButton.isEnabled = MyPhotoSelectManager.defaultManager.m_selectedItems.count > 0
    }
    
    func showSelectLabel() {
        self.m_selectedBgView.isHidden = MyPhotoSelectManager.defaultManager.m_selectedItems.count <= 0
        self.m_selectedBgView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: {
            self.m_selectedBgView.transform = CGAffineTransform.identity
            }, completion: nil)
        
        self.m_selectedLabel.text = "\(MyPhotoSelectManager.defaultManager.m_selectedItems.count)"
        self.m_selectedLabel.isHidden = MyPhotoSelectManager.defaultManager.m_selectedItems.count <= 0
    }
    
    func calImageSize(_ asset: PHAsset, scale: CGFloat) -> CGSize {
        // 计算图片大小
        var imageSize: CGSize = CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))
        let aspectRatio: CGFloat = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
        imageSize = CGSize(width: kScreenWidth*scale, height: kScreenWidth/aspectRatio*scale);
        
        return imageSize
    }
}

extension MyPhotoPreviewVC {
	
	@IBAction func backClick(_ sender: AnyObject) {
        self.m_delegate?.afterChangeSelectedItem(self, selectedItems: MyPhotoSelectManager.defaultManager.m_selectedItems, selectedIndex: MyPhotoSelectManager.defaultManager.m_selectedIndex as [IndexPath])
        
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func selectClick(_ sender: AnyObject) {
		let selectedItem = MySelectedItem.init(asset: self.m_allAssets[self.m_curIndexPath.item], index: self.m_curIndexPath)
		MyPhotoSelectManager.defaultManager.updateSelectItems(self, selected: self.m_selectButton.isSelected, button: self.m_selectButton, selectedItem: selectedItem)
		self.updateBottomView()
	}
	
    @IBAction func m_doneClick(_ sender: AnyObject) {
		var hasVideo: Bool = false
		
		for item in MyPhotoSelectManager.defaultManager.m_selectedItems {
			if (item.m_asset.mediaType == .video) {
				hasVideo = true
				break
			}
		}
		
		if hasVideo {
			let alert = UIAlertController(title: nil, message: "您同时选中了照片和视频，视频将作为照片发送", preferredStyle: .alert)
			let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
			let doneAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
				print(MyPhotoSelectManager.defaultManager.m_selectedItems)
				self.dismiss(animated: true, completion: nil)
			})
			
			alert.addAction(cancelAction)
			alert.addAction(doneAction)
			
			self.present(alert, animated: true, completion: nil)
		} else {
			print(MyPhotoSelectManager.defaultManager.m_selectedItems)
			self.dismiss(animated: true, completion: nil)
			MyPhotoSelectManager.defaultManager.clearData()
		}
    }
}

extension MyPhotoPreviewVC: UIScrollViewDelegate {
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		
		if scrollView == self.m_collectionView {
			targetContentOffset.pointee = scrollView.contentOffset
			
			let pageWidth = scrollView.frame.width + self.m_minLineSpace
            			
			var assistanceOffset: CGFloat = pageWidth / 2.0
			
			if velocity.x < 0 {
				assistanceOffset = -assistanceOffset
			}
			
			let assistedScrollPosition = (scrollView.contentOffset.x + assistanceOffset) / pageWidth

			var cellToScroll = Int(round(assistedScrollPosition))
			if (cellToScroll < 0) {
				cellToScroll = 0
			} else if (cellToScroll >= self.m_collectionView.numberOfItems(inSection: 0)) {
				cellToScroll = self.m_collectionView.numberOfItems(inSection: 0) - 1
			}
			
			self.m_collectionView.scrollToItem(at: IndexPath.init(item: cellToScroll, section: 0), at: .left, animated: true)
		}
	}
}

extension MyPhotoPreviewVC: MyPhotoPreviewCellDelegate {
	func afterSingleTap(_ cell: MyPhotoPreviewCell) {
		self.m_topView.isHidden = !self.m_topView.isHidden
        self.m_bottomView.isHidden = !self.m_bottomView.isHidden
	}
}

extension MyPhotoPreviewVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.m_assets.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPhotoPreviewCell.getCellIdentifier(), for: indexPath) as! MyPhotoPreviewCell
		
		cell.m_delegate = self
        cell.m_scrollView.isHidden = true
        cell.m_actIndicator.startAnimating()
        cell.bringSubview(toFront: cell.m_actIndicator)
        
		let asset = self.m_assets[(indexPath as NSIndexPath).item]
        
        self.m_curIndexPath = IndexPath.init(item: self.m_allAssets.index(of: asset)!, section: 0)
        self.m_selectButton.isSelected = MyPhotoSelectManager.defaultManager.m_selectedIndex.contains(self.m_curIndexPath)
		
		cell.updateData(asset, size: self.calImageSize(asset, scale: 2.0), indexPath: indexPath)

//		let option = PHImageRequestOptions()
//		option.deliveryMode = .HighQualityFormat
//		
//        self.m_imageManager.requestImageForAsset(asset, targetSize: self.calImageSize(asset, scale: 1.0), contentMode: PHImageContentMode.AspectFill, options: option) { (image, info) in
//			let item = MyPhotoItem()
//			item.updateWithData(image!, asset: asset, index: indexPath)
//			cell.updateCellWithData(item)
//		}
		
		
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard let cell = cell as? MyPhotoPreviewCell else { return }
		cell.imageResize()
	}
}
