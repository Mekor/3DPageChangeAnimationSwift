//
//  ViewController.swift
//  3DPageChangeAnimation
//
//  Created by Mekor on 2017/11/4.
//  Copyright © 2017年 Citynight. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var navigationBarHeight: CGFloat {
        get {
            return self.navigationController?.navigationBar.frame.height ?? 0
        }
    }
    
    private var stateBarHeight: CGFloat {
        get {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    private let bottomHeight: CGFloat = 110
    private let bottomInset: CGFloat = 6
    
    /// 搭配视图
    fileprivate lazy var showPicView: UIImageView = {
        let showPicView = UIImageView(frame: CGRect(x: 0, y: navigationBarHeight + stateBarHeight, width: UIScreen.main.bounds.width, height: self.view.bounds.height - bottomHeight - navigationBarHeight - stateBarHeight))
        showPicView.isUserInteractionEnabled = true
        showPicView.backgroundColor = .white
        showPicView.clipsToBounds = true
        showPicView.contentMode = .scaleAspectFill
        showPicView.image = UIImage(named: "putao.jpeg")
        return showPicView
    }()
    
    /// 描述文字
    fileprivate lazy var descLabel: UILabel = {
        let descLabel = UILabel()
        descLabel.font = UIFont.systemFont(ofSize: 13.0)
        descLabel.numberOfLines = 2
        descLabel.backgroundColor = .white
        descLabel.shadowColor = .white
        descLabel.shadowOffset = CGSize(width: 0, height: 1)
        descLabel.text = "吃葡萄，不吐葡萄皮"
        descLabel.sizeToFit()
        var frame = descLabel.frame
        frame.origin = CGPoint(x: 12.0, y: self.showPicView.frame.height - 20.0)
        descLabel.frame = frame
        return descLabel
    }()
    
    /// 遮罩图
    fileprivate lazy var maskView: UIView = {
        let maskView = UIView(frame: self.view.bounds)
        maskView.backgroundColor = .black
        maskView.isUserInteractionEnabled = false
        maskView.alpha = 0
        return maskView
    }()
    
    /// 附属内容区域
    fileprivate lazy var showListView: UIView = {
       let showListView = UIView(frame: CGRect(x: 0, y: self.view.bounds.height - bottomHeight, width: self.view.bounds.width, height: self.view.bounds.height - bottomHeight - bottomInset))
        showListView.backgroundColor = .black
        showListView.alpha = 0.8
        return showListView
    }()
    
    /// 最大滑动距离
    fileprivate var showListMaxDt: CGFloat = 0
    
    fileprivate lazy var headerView: UIImageView = {
        let headerView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: self.showListView.frame.width, height: 26)))
        headerView.contentMode = .center
        headerView.image = UIImage(named: "TMWuse_Beacon")
        headerView.isUserInteractionEnabled = true
        
        let showClick = UITapGestureRecognizer(target: self, action: #selector(showListViewClick(_:)))
        headerView.addGestureRecognizer(showClick)
        
        let beaconPan = UIPanGestureRecognizer(target: self, action: #selector(showListViewPan(_:)))
        headerView.addGestureRecognizer(beaconPan)
        
        return headerView
    }()
    
    /// 是否展示
    fileprivate var isShow: Bool = false {
        didSet {
            self.headerView.image = isShow ? UIImage(named: "TMWuse_BeaconDonw") : UIImage(named:"TMWuse_Beacon")
        }
    }
    
    /// 是否完成缩小动画
    fileprivate var narrow: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "推拉动画Demo"
        createShowPicView()
        createShowListView()
    }
}

// MARK: - UI
extension ViewController {
    func createShowPicView() {
        view.addSubview(showPicView)
        showPicView.addSubview(descLabel)
        view.addSubview(maskView)
    }
    
    func createShowListView() {
        view.addSubview(showListView)
        //限定最高滑动区域
        showListMaxDt = self.showListView.frame.origin.y - bottomHeight - bottomInset
        
        showListView.addSubview(headerView)
    }
}

// MARK: - Action
extension ViewController {
    @objc func showListViewClick(_ recognizer: UITapGestureRecognizer) {
        if isShow {
            isShow = false
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.showListView.frame = CGRect(x: 0, y: self.view.bounds.height - self.bottomHeight, width: self.view.bounds.width, height: self.view.bounds.height - self.bottomHeight - self.bottomInset)
                self.maskView.alpha = 0
            })
            
            //回复原状
            self.showPicView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.showPicView.frame = CGRect(x: 0, y: navigationBarHeight + stateBarHeight, width: self.showPicView.frame.width, height: self.showPicView.frame.height)
            self.narrow = false
            var rotationAndPerspectiveTransform = CATransform3DIdentity
            rotationAndPerspectiveTransform.m34 = 1.0 / 300
            rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0, -navigationBarHeight * 1.8, 0)
            rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 0.8, 0.8, 1)
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 0, 1, 0, 0)
            self.showPicView.layer.transform = rotationAndPerspectiveTransform
            
            UIView.animate(withDuration: 0.25, animations: {
                let layer = self.showPicView.layer
                layer.zPosition = -200
                var rotationAndPerspectiveTransform = CATransform3DIdentity
                rotationAndPerspectiveTransform.m34 = 1.0 / 300
                rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0,  -self.navigationBarHeight * 0.9 , 0)
                rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 0.9 , 0.9, 1)
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -12.0 * CGFloat(Double.pi)/180.0, 1.0, 0.0, 0.0)
                self.showPicView.layer.transform = rotationAndPerspectiveTransform
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.25, animations: {
                    let layer = self.showPicView.layer
                    layer.zPosition = -200
                    var rotationAndPerspectiveTransform = CATransform3DIdentity
                    rotationAndPerspectiveTransform.m34 = 1.0 / 300
                    rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0,  0 , 0)
                    rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 1.0, 1.0, 1)
                    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 0.0, 1.0, 0.0, 0.0)
                    self.showPicView.layer.transform = rotationAndPerspectiveTransform
                })
            })
        }else {
            isShow = true
            self.navigationController?.setToolbarHidden(true, animated: true)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.showListView.frame = CGRect(x: 0, y: self.bottomHeight + self.bottomInset, width: self.showListView.frame.width, height: self.showListView.frame.height)
                self.maskView.alpha = 0.6
            })
            
            UIView.animate(withDuration: 0.25, animations: {
                let layer = self.showPicView.layer
                layer.zPosition = -200
                var rotationAndPerspectiveTransform = CATransform3DIdentity
                rotationAndPerspectiveTransform.m34 = 1.0 / 300
                rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0, -self.navigationBarHeight * 0.9 , 0)
                rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 0.9 , 0.9, 1)
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -12.0 * CGFloat(Double.pi) / 180.0, 1.0, 0.0, 0.0)
                self.showPicView.layer.transform = rotationAndPerspectiveTransform
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.25, animations: {
                    let layer = self.showPicView.layer
                    layer.zPosition = -200
                    var rotationAndPerspectiveTransform = CATransform3DIdentity
                    rotationAndPerspectiveTransform.m34 = 1.0 / 300
                    rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0,  -self.navigationBarHeight * 1.8 , 0)
                    rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 0.8, 0.8, 1)
                    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 0.0, 1.0, 0.0, 0.0)
                    self.showPicView.layer.transform = rotationAndPerspectiveTransform
                }, completion: { (finished) in
                    //改变原状
                    let top = self.showPicView.frame.origin.y
                    let left = self.showPicView.frame.origin.x
                    var rotationAndPerspectiveTransform = CATransform3DIdentity
                    rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 1, 1, 1)
                    self.showPicView.layer.transform = rotationAndPerspectiveTransform
                    self.showPicView.transform = CGAffineTransform(scaleX: 0.8,y: 0.8)
                    self.showPicView.frame = CGRect(x: left, y: top, width: self.showPicView.frame.width, height: self.showPicView.frame.height)
                    self.narrow = true
                })
            })
        }
    }
    
    @objc func showListViewPan(_ recognizer: UIPanGestureRecognizer) {
        var startPoint_Y: CGFloat = 0
        var changePoint_Y: CGFloat = 0
        var viewPoint_Y: CGFloat = 0
        
        switch recognizer.state {
        case .began:
            startPoint_Y = recognizer.location(in: self.view.window).y
            viewPoint_Y = self.showListView.frame.origin.y
        case .changed:
            changePoint_Y = recognizer.location(in: self.view.window).y
            var move_Y = viewPoint_Y + (changePoint_Y - startPoint_Y)
            if move_Y > self.view.bounds.height - bottomHeight {
                move_Y = self.view.bounds.height - bottomHeight
            } else if move_Y < bottomHeight + bottomInset {
                move_Y = self.bottomHeight + self.bottomInset
            }
            self.showListView.frame = CGRect(x: self.showListView.frame.origin.x, y: move_Y, width: self.showListView.frame.width, height: self.showListView.frame.height)
            let progress = ((self.view.bounds.height - bottomHeight - bottomInset) - self.showListView.frame.origin.y) / self.showListMaxDt
            self.showPicViewChangeProgress(progress)
            recognizer.setTranslation(.zero, in: self.view.window)
        case .ended:
            let progress = ((self.view.bounds.size.height - bottomHeight - bottomInset) - self.showListView.frame.origin.y)/self.showListMaxDt
            self.showPicViewAnimationProgress(progress)
        default:
            break
        }
    }
    
    
    func showPicViewChangeProgress(_ progress: CGFloat) {
        if (progress > 1 || progress < 0) {
            return
        }
        
        if narrow {
            // 恢复原状
            self.showPicView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.showPicView.frame = CGRect(x: 0, y: navigationBarHeight + stateBarHeight, width: self.showPicView.frame.width, height: self.showPicView.frame.height)
            self.narrow = false
        }
        
        self.maskView.alpha = 0.6 * progress
        if progress <= 0.5 {
            if (self.navigationController?.isNavigationBarHidden)! {
                self.navigationController?.setToolbarHidden(false, animated: true)
            }
            let layer = self.showPicView.layer
            layer.zPosition = -200
            var rotationAndPerspectiveTransform = CATransform3DIdentity
            rotationAndPerspectiveTransform.m34 = 1.0 / 300
            rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0,  -navigationBarHeight * progress * 1.8 , 0)
            rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 1.0 - (0.2 * progress) , 1.0 - (0.2 * progress), 1)
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -(24 * progress) * CGFloat(Double.pi) / 180.0, 1.0, 0.0, 0.0)
            self.showPicView.layer.transform = rotationAndPerspectiveTransform
        }else {
            if !(self.navigationController!.isNavigationBarHidden) {
                self.navigationController?.setToolbarHidden(true, animated: true)
            }
            
            let layer = self.showPicView.layer
            layer.zPosition = -200
            var rotationAndPerspectiveTransform = CATransform3DIdentity
            rotationAndPerspectiveTransform.m34 = 1.0 / 300
            rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0,  -navigationBarHeight * progress * 1.8 , 0)
            rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 1.0 - (0.2 * progress), 1.0 - (0.2 * progress), 1)
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -(12.0 - 24*(progress - 0.5)) * CGFloat(Double.pi) / 180.0, 1.0, 0.0, 0.0)
            self.showPicView.layer.transform = rotationAndPerspectiveTransform
        }
    }
    
    
    func showPicViewAnimationProgress(_ progress: CGFloat) {
        if(progress <= 0.5) {
            UIView.animate(withDuration: 0.25, animations: {
                let layer = self.showPicView.layer
                layer.zPosition = -200
                var rotationAndPerspectiveTransform = CATransform3DIdentity
                rotationAndPerspectiveTransform.m34 = 1.0 / 300
                rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0, 0, 0)
                rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 1.0, 1.0, 1)
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 0.0, 1.0, 0.0, 0.0)
                self.showPicView.layer.transform = rotationAndPerspectiveTransform
                self.showListView.frame = CGRect(x: 0, y: self.view.bounds.size.height - self.bottomHeight, width: self.view.bounds.size.width, height: self.view.bounds.size.height - self.bottomHeight - self.bottomInset)
                self.maskView.alpha = 0
            }, completion: { (finished) in
                self.narrow = false
                self.isShow = false
            })
        }else {
            if narrow {
                return
            }
            
            
            UIView.animate(withDuration: 0.25, animations: {
                let layer = self.showPicView.layer
                layer.zPosition = -200
                var rotationAndPerspectiveTransform = CATransform3DIdentity
                rotationAndPerspectiveTransform.m34 = 1.0 / 300
                rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0,  -self.navigationBarHeight * 1.8 , 0)
                rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 0.8 , 0.8, 1)
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 0.0, 1.0, 0.0, 0.0)
                self.showPicView.layer.transform = rotationAndPerspectiveTransform
                self.showListView.frame = CGRect(x: 0, y: self.bottomHeight + self.bottomInset, width: self.showListView.frame.width, height: self.showListView.frame.height)
                self.maskView.alpha = 0.6
            }, completion: { (finished) in
                //改变原状
                let top = self.showPicView.frame.origin.y
                let left = self.showPicView.frame.origin.x
                let layer = self.showPicView.layer
                layer.zPosition = -200
                var rotationAndPerspectiveTransform = CATransform3DIdentity
                rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 1, 1, 1)
                self.showPicView.layer.transform = rotationAndPerspectiveTransform
                self.showPicView.transform = CGAffineTransform(scaleX: 0.8,y: 0.8)
                self.showPicView.frame = CGRect(x: left, y: top, width: self.showPicView.frame.size.width, height: self.showPicView.frame.height)
                self.narrow = true
                self.isShow = true
            })
        }
    }
}
