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

// MARK: - Class - 照片
class MyPhotoItem: NSObject {
	var m_img: UIImage! = UIImage()
	var m_asset: PHAsset! = PHAsset()
	var m_index: IndexPath!
	
	func updateWithData(_ image: UIImage, asset: PHAsset, index: IndexPath) {
		m_img = image
		m_asset = asset
		m_index = index
	}
}

// MARK: - Class - 照片展示VC
class MyPhotoGridVC: UIViewController {
	
	/// StoryBoard相关
	@IBOutlet weak var m_collectionView: UICollectionView!
	@IBOutlet weak var m_preview: UIBarButtonItem!
	@IBOutlet weak var m_done: UIBarButtonItem!
	@IBOutlet weak var m_toolBar: UIToolbar!
	
	/// 已选数目展示 相关
	fileprivate lazy var m_selectedBgView: UIView = {
		var tempBgView = UIView.init(frame: CGRect(x: kScreenWidth-56-28, y: (44-kSelectedLabelWidth)/2, width: kSelectedLabelWidth, height: kSelectedLabelWidth))
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
	
	/// Collectionview 视图相关
	fileprivate let m_minLineSpace: CGFloat = 5.0
	fileprivate let m_minItemSpace: CGFloat = 5.0
	fileprivate let m_collectionTop: CGFloat = 0
	fileprivate let m_collectionLeft: CGFloat = 5
	fileprivate let m_collectionBottom: CGFloat = 0
	fileprivate let m_collectionRight: CGFloat = 5
	
	/// 数据相关
	var m_fetchResult: PHFetchResult<PHAsset>!
	
    /// 所有照片资源数组
    fileprivate var m_allAssets: [PHAsset]! = []
	
	/// 加载图片相关
	fileprivate lazy var m_imageManager = PHCachingImageManager()
	fileprivate var m_assetGridThumbnailSize: CGSize!
	fileprivate var m_previousPreheatRect = CGRect.zero
	
	/// 点击返回按钮是pop出去还是进入预览
	fileprivate var m_isPop = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		PHPhotoLibrary.shared().register(self)
		
		initData()
		initSubViews()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		if (m_isPop) {
			MyPhotoSelectManager.defaultManager.clearData()
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
		print("\(classForCoder)内存泄露")
	}
	
	deinit {
		PHPhotoLibrary.shared().unregisterChangeObserver(self)
	}
	
	override var prefersStatusBarHidden : Bool {
		return false
	}

}

// MARK: - Initial Functions
extension MyPhotoGridVC {
	fileprivate func initData() {
		updateAllAssets()
		initWithCollectionView()

		// 计算出小图大小 （ 为targetSize做准备 ）
		let scale: CGFloat = 2.0
		let cellSize = (m_collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        
        m_assetGridThumbnailSize = CGSize(width: cellSize.width*scale, height: cellSize.height*scale)
	}
	
	fileprivate func initSubViews() {
		let rightBarItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.cancel))
		navigationItem.rightBarButtonItem = rightBarItem
        
        scrollToBottom()
						
		m_toolBar.addSubview(m_selectedBgView)
		m_toolBar.addSubview(m_selectedLabel)
		
		updateToolBarView()
	}
    
    fileprivate func initWithCollectionView() {
        m_collectionView.backgroundColor = UIColor.white
        m_collectionView.allowsMultipleSelection = true
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = m_minLineSpace
        collectionViewFlowLayout.minimumInteritemSpacing = m_minItemSpace
        collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(m_collectionTop, m_collectionLeft, m_collectionBottom, m_collectionRight)
        let width = (kScreenWidth - m_minItemSpace*3 - m_collectionLeft - m_collectionRight) / 4
        collectionViewFlowLayout.itemSize = CGSize(width: width, height: width)
        m_collectionView.collectionViewLayout = collectionViewFlowLayout
    }

}

// MARK: - Update Functions
extension MyPhotoGridVC {
	
	fileprivate func enableItems() {
		let enable = MyPhotoSelectManager.defaultManager.m_selectedItems.count > 0
		
		m_preview.isEnabled = enable
		m_done.isEnabled = enable
	}
	
	fileprivate func showSelectLabel() {
		m_selectedBgView.isHidden = MyPhotoSelectManager.defaultManager.m_selectedItems.count <= 0
		m_selectedBgView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
			self.m_selectedBgView.transform = CGAffineTransform.identity
			}, completion: nil)
		
		m_selectedLabel.text = "\(MyPhotoSelectManager.defaultManager.m_selectedItems.count)"
		m_selectedLabel.isHidden = MyPhotoSelectManager.defaultManager.m_selectedItems.count <= 0
	}
	
	fileprivate func updateToolBarView() {
		showSelectLabel()
		enableItems()
	}
	
	fileprivate func scrollToBottom() {
		m_collectionView.layoutIfNeeded()
		
		let contentSize = m_collectionView.contentSize
		let frameSize = m_collectionView.frame.size
		if contentSize.height + 64 > frameSize.height {
			m_collectionView.setContentOffset(CGPoint(x: 0, y: m_collectionView.contentSize.height - m_collectionView.frame.size.height + 64), animated: false)
		}
	}
	
	fileprivate func updateAllAssets() {
		m_allAssets.removeAll()
		
		for i in 0 ..< m_fetchResult.count {
			let asset = m_fetchResult[i]
			m_allAssets.append(asset)
		}
	}
}

// MARK: - Functions
extension MyPhotoGridVC {

	func cancel() {
		navigationController?.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func previewClick(_ sender: AnyObject) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MyPhotoPreviewVC") as! MyPhotoPreviewVC
        
        var assets: [PHAsset] = []
        for item in MyPhotoSelectManager.defaultManager.m_selectedItems {
            assets.append(item.m_asset)
        }
        vc.m_assets = assets
        vc.m_allAssets = m_allAssets
        vc.m_firstIndexPath = IndexPath.init(item: 0, section: 0)
        vc.m_delegate = self
		
		m_isPop = false
		
        navigationController?.pushViewController(vc, animated: true)
	}
	
	@IBAction func doneClick(_ sender: AnyObject) {
		var hasVideo: Bool = false
		
		for item in MyPhotoSelectManager.defaultManager.m_selectedItems {
			if (item.m_asset.mediaType == .video) {
				hasVideo = true
				break
			}
		}
		
		if hasVideo {
			let alert = UIAlertController(title: "视频将作为照片发送", message: "如需发送视频，请取消所有选择，点击视频进入视频预览进行发送", preferredStyle: .alert)
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

// MARK: - MyPhotoGridCellDelegate, MyPhotoPreviewVCDelegate
extension MyPhotoGridVC: MyPhotoGridCellDelegate, MyPhotoPreviewVCDelegate {
	func myPhotoGridCellButtonSelect(cell: MyPhotoGridCell) {
		
		let selectedItem = MySelectedItem.init(asset: cell.m_data.m_asset, index: cell.m_data.m_index)
		MyPhotoSelectManager.defaultManager.updateSelectItems(vcToShowAlert: self, button: cell.m_selectButton, selectedItem: selectedItem)
		
		updateToolBarView()
	}
	
	func afterChangeSelectedItem(_ vc: MyPhotoPreviewVC) {
		
        m_collectionView.reloadData()
		updateToolBarView()
		m_isPop = true
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MyPhotoGridVC: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return m_fetchResult.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPhotoGridCell.getCellIndentifier(), for: indexPath) as! MyPhotoGridCell
		
		cell.m_delegate = self
		
		let asset = m_fetchResult[indexPath.item]
		
		cell.updateData(asset, size: m_assetGridThumbnailSize, indexPath: indexPath)
		
		cell.m_selectButton.isSelected = MyPhotoSelectManager.defaultManager.m_selectedIndex.contains(indexPath)

		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		
		let asset = m_fetchResult[indexPath.item]

		if (asset.mediaType == .video) {
			if MyPhotoSelectManager.defaultManager.m_selectedItems.count > 0 {
				let alert = UIAlertController(title: "已选择时不能预览单个视频", message: "取消所有选择，点击视频可进行视频预览", preferredStyle: .alert)
				let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
				alert.addAction(cancelAction)
				
				present(alert, animated: true, completion: nil)
			} else {
				let vc = storyboard?.instantiateViewController(withIdentifier: "MyVideoPreviewVC") as! MyVideoPreviewVC
				
				vc.m_asset = asset
				
				navigationController?.pushViewController(vc, animated: true)
			}
			
		} else {
			let vc = storyboard?.instantiateViewController(withIdentifier: "MyPhotoPreviewVC") as! MyPhotoPreviewVC
			
			vc.m_assets = m_allAssets
			vc.m_allAssets = m_allAssets
			vc.m_firstIndexPath = indexPath
			vc.m_delegate = self
			
			m_isPop = false
			
			navigationController?.pushViewController(vc, animated: true)
		}
	}
}

// MARK: - PHPhotoLibraryChangeObserver
extension MyPhotoGridVC: PHPhotoLibraryChangeObserver {
	
	func photoLibraryDidChange(_ changeInstance: PHChange) {
		guard let changes = changeInstance.changeDetails(for: m_fetchResult) else { return }
		
		DispatchQueue.main.sync {
			// 更新已选数据和视图
			MyPhotoSelectManager.defaultManager.clearData()
			updateToolBarView()

			m_fetchResult = changes.fetchResultAfterChanges
			updateAllAssets()
			
//			if changes.hasIncrementalChanges {
//				// If we have incremental diffs, animate them in the collection view.
//				guard let collectionView = self.m_collectionView else { fatalError() }
//				collectionView.performBatchUpdates({
//					// For indexes to make sense, updates must be in this order:
//					// delete, insert, reload, move
//					if let removed = changes.removedIndexes, removed.count > 0 {
//						collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
//					}
//					if let inserted = changes.insertedIndexes, inserted.count > 0 {
//						collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
//					}
//					if let changed = changes.changedIndexes, changed.count > 0 {
//						collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
//					}
//					changes.enumerateMoves { fromIndex, toIndex in
//						collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
//						                        to: IndexPath(item: toIndex, section: 0))
//					}
//				})
//			} else {
				// Reload the collection view if incremental diffs are not available.
				m_collectionView!.reloadData()
//			}
			
		}
	}
}
