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

// MARK: - MyPhotoPreviewVCDelegate
protocol MyPhotoPreviewVCDelegate: NSObjectProtocol {
	func afterChangeSelectedItem(_ vc: MyPhotoPreviewVC)
}

// MARK: - Class - 预览
class MyPhotoPreviewVC: UIViewController {
	
	/// storyboard 相关
	@IBOutlet weak var m_topView: UIView!
	@IBOutlet weak var m_collectionView: UICollectionView!
    @IBOutlet weak var m_selectButton: UIButton!
    @IBOutlet weak var m_doneButton: UIButton!
    @IBOutlet weak var m_bottomView: UIView!
	
	@IBOutlet weak var m_originButton: UIButton!
	@IBOutlet weak var m_originActIndicator: UIActivityIndicatorView!
	@IBOutlet weak var m_originLabel: UILabel!

    /// UICollectionview 视图相关
    let m_minLineSpace: CGFloat = 10.0
    let m_minItemSpace: CGFloat = 0.0
    let m_collectionTop: CGFloat = 0
    let m_collectionLeft: CGFloat = 0
    let m_collectionBottom: CGFloat = 0
    let m_collectionRight: CGFloat = 0
	
    /// 已选数目 视图相关
    fileprivate lazy var m_selectedBgView: UIView = {
        var tempBgView = UIView.init(frame: CGRect(x: kScreenWidth-84, y: (44-kSelectedLabelWidth)/2, width: kSelectedLabelWidth, height: kSelectedLabelWidth))
        tempBgView.backgroundColor = kThemeColor
        tempBgView.layer.cornerRadius = kSelectedLabelWidth / 2
        tempBgView.layer.masksToBounds = true
        
        return tempBgView
    }()
    
    fileprivate lazy var m_selectedLabel: UILabel = {
        var tempLabel = UILabel.init()
		
		tempLabel.frame = self.m_selectedBgView.frame
        tempLabel.font = kSelectedLabelFont
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
	/// 滑动前展示的照片index
	var m_curIndex: Int!
	/// 滑动后展示的照片index
	var m_nextIndex: Int!
	
    weak var m_delegate: MyPhotoPreviewVCDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		PHPhotoLibrary.shared().register(self)
		
        initSubViews()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        
        m_collectionView.layoutIfNeeded()
        m_collectionView.scrollToItem(at: IndexPath.init(item: m_firstIndexPath.item, section: 0), at: .left, animated: false)
		
		navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	deinit {
		PHPhotoLibrary.shared().unregisterChangeObserver(self)
	}
	
	override var prefersStatusBarHidden : Bool {
		return true
	}
}

// MARK: - Initial & Update Funtions
extension MyPhotoPreviewVC {
    
    func initSubViews() {
        initWithCollectionView()
        
        m_bottomView.addSubview(m_selectedBgView)
        m_bottomView.addSubview(m_selectedLabel)
		
		initWithOriginView()
        updateBottomView()
    }
    
    func initWithCollectionView() {
        m_collectionView.backgroundColor = UIColor.black
        m_collectionView.register(MyPhotoPreviewCell.self, forCellWithReuseIdentifier: MyPhotoPreviewCell.getCellIdentifier())
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = m_minLineSpace
        collectionViewFlowLayout.minimumInteritemSpacing = m_minItemSpace
        collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(m_collectionTop, m_collectionLeft, m_collectionBottom, m_collectionRight)
        collectionViewFlowLayout.itemSize = CGSize(width: kScreenWidth, height: kScreenHeight)
        collectionViewFlowLayout.scrollDirection = .horizontal
        m_collectionView.collectionViewLayout = collectionViewFlowLayout
    }
	
	func initWithOriginView() {
		m_originButton.isSelected = MyPhotoImageManager.defaultManager.m_isAllowOrigin
		
		getImageData(m_firstIndexPath.item)
	}
	
    func updateBottomView() {
        showSelectLabel()
        m_doneButton.isEnabled = MyPhotoSelectManager.defaultManager.m_selectedItems.count > 0
    }
	
    func showSelectLabel() {
        m_selectedBgView.isHidden = MyPhotoSelectManager.defaultManager.m_selectedItems.count <= 0
        m_selectedBgView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
            self.m_selectedBgView.transform = CGAffineTransform.identity
            })
        
        m_selectedLabel.text = "\(MyPhotoSelectManager.defaultManager.m_selectedItems.count)"
        m_selectedLabel.isHidden = MyPhotoSelectManager.defaultManager.m_selectedItems.count <= 0
    }
}

// MARK: - 方法
extension MyPhotoPreviewVC {
	fileprivate func calImageSize(_ asset: PHAsset, scale: CGFloat) -> CGSize {
		// 计算图片大小
		var imageSize: CGSize = CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))
		let aspectRatio: CGFloat = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
		imageSize = CGSize(width: kScreenWidth*scale, height: kScreenWidth/aspectRatio*scale);
		
		return imageSize
	}
	
	fileprivate func getBytesFromDataLength(_ dataLength: Int) -> String {
		var bytes = ""
		if (CGFloat(dataLength) >= 0.1 * 1024 * 1024) {
			bytes = String(format: "(%0.1fM)", CGFloat(dataLength)/1024/1024.0)
		} else if (dataLength >= 1024) {
			bytes = String(format: "(%0.0fK)", CGFloat(dataLength)/1024.0)
		} else {
			bytes = "(\(dataLength)B)"
		}
		
		return bytes
	}
	
	fileprivate func getImageData(_ assetIndex: Int) {
		m_originLabel.isHidden = true
		if (MyPhotoImageManager.defaultManager.m_isAllowOrigin) {
			m_originActIndicator.startAnimating()
			
			PHImageManager.default().requestImageData(for: m_allAssets[assetIndex], options: nil) {
				[weak self] (imageData, _, _, _) in
				
				guard let weakSelf = self else { return }
				let byteStr = weakSelf.getBytesFromDataLength((imageData?.count)!)
				
				DispatchQueue.main.asyncAfter(deadline: .now()+0.15, execute: {
					weakSelf.m_originLabel.text = byteStr
					weakSelf.m_originActIndicator.stopAnimating()
					weakSelf.m_originLabel.isHidden = false
				})
			}
		} else {
			m_originActIndicator.stopAnimating()
			m_originLabel.isHidden = true
		}
	}
}

// MARK: - IBActions
extension MyPhotoPreviewVC {
	
	@IBAction func backClick(_ sender: AnyObject) {
        m_delegate?.afterChangeSelectedItem(self)
        
		_ = navigationController?.popViewController(animated: true)
	}
	
	@IBAction func selectClick(_ sender: AnyObject) {
		let selectedItem = MySelectedItem.init(asset: m_allAssets[m_curIndexPath.item], index: m_curIndexPath)
		MyPhotoSelectManager.defaultManager.updateSelectItems(vcToShowAlert: self, button: m_selectButton, selectedItem: selectedItem)
		updateBottomView()
	}
	
	@IBAction func originClick(_ sender: AnyObject) {
		if !MyPhotoSelectManager.defaultManager.m_selectedIndex.contains(m_curIndexPath) && !m_originButton.isSelected {
			selectClick(m_selectButton)
		}
		
		m_originButton.isSelected = !m_originButton.isSelected
		MyPhotoImageManager.defaultManager.m_isAllowOrigin = m_originButton.isSelected
		
		getImageData(m_curIndexPath.item)
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
				MyPhotoSelectManager.defaultManager.doSend(vcToDismiss: self)
			})
			
			alert.addAction(cancelAction)
			alert.addAction(doneAction)
			
			present(alert, animated: true, completion: nil)
		} else {
			MyPhotoSelectManager.defaultManager.doSend(vcToDismiss: self)
		}
    }
	
}

// MARK: - UIScrollViewDelegate
extension MyPhotoPreviewVC: UIScrollViewDelegate {
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		if scrollView == m_collectionView {
			let pageWidth = scrollView.frame.width + m_minLineSpace
			m_curIndex = Int((scrollView.contentOffset.x + m_minLineSpace) / pageWidth)
		}
	}
	
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		
		if scrollView == m_collectionView {
			targetContentOffset.pointee = scrollView.contentOffset
			
			let pageWidth = scrollView.frame.width + m_minLineSpace
			
			if (velocity.x == 0) {
				m_nextIndex = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
			} else {
//				var assistanceOffset: CGFloat = pageWidth / 3.0
//				
//				if velocity.x < 0 {
//					assistanceOffset = -assistanceOffset
//				}
//				
//				let assistedScrollPosition = (scrollView.contentOffset.x + assistanceOffset) / pageWidth
//				
//				m_nextIndex = Int(round(assistedScrollPosition))
				m_nextIndex = velocity.x > 0 ? m_curIndex + 1 : m_curIndex - 1
			}
			
			if (m_nextIndex < 0) {
				m_nextIndex = 0
			} else if (m_nextIndex >= m_collectionView.numberOfItems(inSection: 0)) {
				m_nextIndex = m_collectionView.numberOfItems(inSection: 0) - 1
			}
			
			m_collectionView.scrollToItem(at: IndexPath.init(item: m_nextIndex, section: 0), at: .left, animated: true)
		}
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if (scrollView == m_collectionView && m_nextIndex != m_curIndex) {
			getImageData(m_nextIndex)
		}
	}
}

// MARK: - MyPhotoPreviewCellDelegate
extension MyPhotoPreviewVC: MyPhotoPreviewCellDelegate {
	func afterSingleTap(_ cell: MyPhotoPreviewCell) {
		m_topView.isHidden = !m_topView.isHidden
        m_bottomView.isHidden = !m_bottomView.isHidden
	}
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MyPhotoPreviewVC: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return m_assets.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPhotoPreviewCell.getCellIdentifier(), for: indexPath) as! MyPhotoPreviewCell
		
		cell.m_delegate = self
        
		let asset = m_assets[indexPath.item]
        
        m_curIndexPath = IndexPath.init(item: m_allAssets.index(of: asset)!, section: 0)
        m_selectButton.isSelected = MyPhotoSelectManager.defaultManager.m_selectedIndex.contains(m_curIndexPath)
		
		cell.updateData(asset, size: calImageSize(asset, scale: 2.0), indexPath: indexPath)

		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard let cell = cell as? MyPhotoPreviewCell else { return }
		cell.imageResize()
	}
}

// MARK: - PHPhotoLibraryChangeObserver
extension MyPhotoPreviewVC: PHPhotoLibraryChangeObserver {
	
	func photoLibraryDidChange(_ changeInstance: PHChange) {

		DispatchQueue.main.sync {
			// 更新已选数据和视图
			MyPhotoSelectManager.defaultManager.clearData()
			updateBottomView()
			m_selectButton.isSelected = false

			let asset = m_allAssets[m_curIndexPath.item]
			
			guard let details = changeInstance.changeDetails(for: asset) else { return }
			
			if details.objectWasDeleted {
				m_allAssets.remove(at: m_curIndexPath.item)
				if let index = m_assets.index(of: asset) {
					m_assets.remove(at: index)
				}
				
				let alert = UIAlertController.init(title: "您之前预览的照片已被删除", message: "", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: { (alertAction) in
					if self.m_assets.isEmpty {
						_ = self.navigationController?.popViewController(animated: true)
					}
				}))

				present(alert, animated: true, completion: nil)
				
			} else {
				let assetAfterChange = details.objectAfterChanges as! PHAsset
				m_allAssets[m_curIndexPath.item] = assetAfterChange
				if let index = m_assets.index(of: asset) {
					m_assets[index] = assetAfterChange
				}
				
				if details.assetContentChanged {
					let cell = m_collectionView.cellForItem(at: m_curIndexPath) as! MyPhotoPreviewCell
					cell.updateData(assetAfterChange, size: calImageSize(asset, scale: 2.0), indexPath: m_curIndexPath)
				}
			}
			
			m_collectionView.reloadData()
		}
	}
}

