//
//  IntroViewController.swift
//  imdang
//
//  Created by daye on 2/4/25.
//


import UIKit
import SnapKit

enum CollectionViewType {
    case intro
    case normal
}

class IntroViewController: BaseViewController {
    
    private let collectionView: UICollectionView
    private let type: CollectionViewType
    
    private let navigationTitleLabel = UILabel().then {
        $0.font = .pretenSemiBold(18)
        $0.textColor = .grayScale900
        $0.text = "서비스 소개"
    }
    
    init(type: CollectionViewType) {
           self.type = type

           let layout = UICollectionViewFlowLayout()
           layout.scrollDirection = .vertical

           self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

           super.init(nibName: nil, bundle: nil)
       }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        configNavigationBarItem()
        
        collectionView.snp.makeConstraints {
            $0.topEqualToNavigationBottom(vc: self)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(FirstCell.self, forCellWithReuseIdentifier: "FirstCell")
        collectionView.register(SecondCell.self, forCellWithReuseIdentifier: "SecondCell")
        collectionView.register(ThirdCell.self, forCellWithReuseIdentifier: "ThirdCell")
        collectionView.register(IntroLastCell.self, forCellWithReuseIdentifier: "LastCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService().screenEvent(ScreenName: .serviceIntroduction)

        DispatchQueue.main.async {
            if self.type == .intro {
                let indexPath = IndexPath(item: 0, section: 1)
                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configNavigationBarItem() {
        customBackButton.isHidden = false
        leftNaviItemView.addSubview(navigationTitleLabel)
        navigationTitleLabel.snp.makeConstraints {
            $0.height.equalTo(20)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
        }
    }
}

extension IntroViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "FirstCell", for: indexPath) as! FirstCell
        case 1:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "SecondCell", for: indexPath) as! SecondCell
        case 2:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "ThirdCell", for: indexPath) as! ThirdCell
        case 3:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "LastCell", for: indexPath) as! IntroLastCell
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        if indexPath.section == 0 {
            return CGSize(width: width, height: 621)
        } else if indexPath.section == 1 {
            return CGSize(width: width, height: 450)
        } else if indexPath.section == 2 {
            return CGSize(width: width, height: 465)
        } else {
            return CGSize(width: width, height: 244)
        }
    }
}

