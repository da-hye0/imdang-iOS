//
//  AddressCell.swift
//  imdang
//
//  Created by daye on 12/29/24.
//

import UIKit
import SnapKit
import Then
import RxSwift

class BaseInfoAddressCell: UICollectionViewCell {
    static let identifier = "AddressCell"
    
    private let firstButton = CommonButton(title: "지번 주소", initialButtonType: .unselectedBorderStyle).then() {
        $0.contentHorizontalAlignment = .left
    }
    
    var buttonAction: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        layout()
        configureActions()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        contentView.addSubview(firstButton)
        
        firstButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(52)
        }
    }
    
    func configure(title: String) {
        firstButton.setTitle(title, for: .normal)
        firstButton.setTitleColor(.grayScale400, for: .normal)
    }
    
    func setData(title: String) {
        firstButton.setTitle(title, for: .normal)
        firstButton.setTitleColor(.grayScale900, for: .normal)
    }
    
    private func configureActions() {
        let webViewURL = "https://da-hye0.github.io/Kakao-Postcode/"
        
        firstButton.addTarget(self, action: #selector(firstButtonTapped), for: .touchUpInside)
    }
    
    @objc private func firstButtonTapped() {
        openWebView(buttonTitle: firstButton.title(for: .normal) ?? "", isSecond: false)
    }
    
    private func openWebView(buttonTitle: String, isSecond: Bool) {
        // 웹뷰 띄우기 로직
        let result = isSecond ? "\(buttonTitle)(두 번째 버튼)" : "\(buttonTitle)(첫 번째 버튼)"
        buttonAction?(result)
    }
}
