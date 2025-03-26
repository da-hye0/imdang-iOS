//
//  TabBarController.swift
//  imdang
//
//  Created by 임대진 on 11/13/24.
//

import UIKit
import SnapKit

class TabBarController: UITabBarController {
    private let analyticsService = AnalyticsService.shared
    private var lastSelectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setValue(CustomTabBar(), forKey: "tabBar")
        UITabBar.appearance().backgroundColor = .white
        self.navigationItem.hidesBackButton = true
        delegate = self
        lastSelectedIndex = 0
        
        configureTabBar()
        makeBoundaryLine()
        
        if let items = tabBar.items {
            for (index, item) in items.enumerated() {
                if index == 1 {
                    item.imageInsets = UIEdgeInsets(top: UIDevice.current.haveTouchId ? 6 : 16, left: 0, bottom: UIDevice.current.haveTouchId ? -6 : -16, right: 0)
                } else {
                    item.titlePositionAdjustment = UIOffset(horizontal: index == 0 ? 20 : -20, vertical: UIDevice.current.haveTouchId ? -20 : 6)
                    item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: UIDevice.current.haveTouchId ? 0 : -19.5, right: 0)
                    item.setTitleTextAttributes([.font: UIFont.pretenRegular(12)], for: .normal)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func configureTabBar() {
        let firstViewController = HomeContainerViewController()
        let secondViewController = UIViewController()
        let thirdViewController = StorageBoxContainerViewController()
        
        let firstNav = UINavigationController(rootViewController: firstViewController)
        let secondNav = UINavigationController(rootViewController: secondViewController)
        let thirdNav = UINavigationController(rootViewController: thirdViewController)
        
        firstNav.tabBarItem = UITabBarItem(title: "홈", image: ImdangImages.Image(resource: .tabHomeIcon), tag: 0)
        secondNav.tabBarItem = UITabBarItem(title: "", image: ImdangImages.Image(resource: .tabWritingIcon).withRenderingMode(.alwaysOriginal), tag: 1)
        thirdNav.tabBarItem = UITabBarItem(title: "보관함", image: ImdangImages.Image(resource: .tabSavedIcon), tag: 2)
        
        firstNav.navigationBar.prefersLargeTitles = false
        secondNav.navigationBar.prefersLargeTitles = false
        thirdNav.navigationBar.prefersLargeTitles = false
        
        viewControllers = [firstNav, secondNav, thirdNav]
        
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .gray
        tabBar.isTranslucent = false
    }
    
    private func makeBoundaryLine() {
        if UIDevice.current.haveTouchId {
            tabBar.shadowImage = UIImage()
            tabBar.backgroundImage = UIImage()
        }
        
        let topBorder = UIView()
        topBorder.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        
        tabBar.addSubview(topBorder)
        
        topBorder.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}

class CustomTabBar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = 92
        return size
    }
}



extension TabBarController: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedViewController == viewController { return false }
        guard let fromView = tabBarController.selectedViewController?.view,
              let toView = viewController.view else { return false }
        let index = self.viewControllers?.firstIndex(of: viewController)
        let clickedItem = index == 0 ? "홈" : index == 1 ? "작성" : "보관함"
        
        switch lastSelectedIndex {
        case 0:
            if let selectedNavController = tabBarController.selectedViewController as? UINavigationController, let homeVC = selectedNavController.topViewController as? HomeContainerViewController {
                if homeVC.homeTapState.value == .search {
                    analyticsService.fromSearchTabbarClick(label: clickedItem)
                } else {
                    analyticsService.fromExchangeTabbarClick(label: clickedItem)
                }
            } else {
                print("home not found")
            }
        case 1:
            break
        case 2:
            analyticsService.fromStorageTabbarClick(label: clickedItem)
        default:
            break
        }
        
        lastSelectedIndex = index
        
        
        print("탭 \(index ?? -1) 선택됨")
        
        
        if fromView == toView {
            return false
        } else if index == 1{
            let vc = InsightViewController()
            let reactor = InsightReactor()
            vc.reactor = reactor
            vc.hidesBottomBarWhenPushed = true
            
            if let fromView = selectedViewController as? UINavigationController {
                fromView.pushViewController(vc, animated: true)
            }
            return false
        } else {
            UIView.transition(from: fromView, to: toView, duration: 0, options: .transitionCrossDissolve)
            return true
        }
    }
}
