//
//  InsightHeaderView.swift
//  imdang
//
//  Created by 임대진 on 12/15/24.
//

import UIKit
import Then
import RxSwift
import RxCocoa

protocol ReusableViewDelegate: AnyObject {
    func didTapFullViewButton()
    func didTapAreaSeletButton()
    func disTapSortButton(isOn: Bool)
}

class InsightHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "InsightHeaderView"
    weak var delegate: ReusableViewDelegate?
    private var disposeBag = DisposeBag()
    
    private let myInsightLabel = UILabel().then {
        $0.text = "내 인사이트만 보기"
        $0.textColor = .grayScale700
        $0.font = .pretenMedium(14)
    }
    
    private let insightCount = UILabel().then {
        $0.textColor = .grayScale900
        $0.font = .pretenSemiBold(16)
    }
    
    private var toggleSwitch = CustomSwitch()
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.grayScale100.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        addSubViews()
        makeConstraints()
        bindAction()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubViews() {
        [myInsightLabel, toggleSwitch, insightCount].forEach {
            containerView.addSubview($0)
        }
        [containerView].forEach {
            addSubview($0)
        }
    }
    
    private func makeConstraints() {
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        myInsightLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        toggleSwitch.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(myInsightLabel.snp.trailing).offset(8)
            $0.width.equalTo(32)
            $0.height.equalTo(18)
        }
        
        insightCount.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
    func bindAction() {
        toggleSwitch.valueChanged = { [self] in
            delegate?.disTapSortButton(isOn: $0)
        }
    }
    
    func config(insightCount: Int, toggleState: Bool) {
        self.insightCount.text = "\(insightCount)개"
        self.toggleSwitch.setOn(toggleState)
    }
}
