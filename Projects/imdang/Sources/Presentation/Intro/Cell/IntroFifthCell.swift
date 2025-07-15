//
//  IntroFifthCell.swift
//  imdang
//
//  Created by daye on 2/4/25.
//

import UIKit
import SnapKit
import Then

class IntroLastCell: UICollectionViewCell {
    
    private let titleLabel = UILabel().then {
        $0.setTextWithLineHeight(text: "더 궁금한 점이 있다면\n아래 계정으로 문의해주세요", lineHeight: 30)
        $0.font = .pretenSemiBold(20)
        $0.textColor = .grayScale900
        $0.numberOfLines = 0
    }
    
    private let backEffectView = UIView().then {
        $0.backgroundColor = .grayScale50
        $0.layer.cornerRadius = 8
    }

    private let etcScript = UILabel().then {
        $0.text = "imdang904@gmail.com"
        $0.font = .pretenSemiBold(14)
        $0.numberOfLines = 0
        $0.textColor = .grayScale900
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(titleLabel)
        contentView.addSubview(backEffectView)
        backEffectView.addSubview(etcScript)
        
        contentView.backgroundColor = .white
        
        layout()
    }
    
    func layout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.leading.equalToSuperview().inset(20)
        }
        
        backEffectView.snp.makeConstraints{
            $0.height.equalTo(64)
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(40)
        }
        
        etcScript.snp.makeConstraints {
            $0.center.equalTo(backEffectView.snp.center)
        }

    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
