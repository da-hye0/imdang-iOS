//
//  IntroViewCell.swift
//  imdang
//
//  Created by daye on 2/4/25.
//

import UIKit
import SnapKit
import Then

class FirstCell: UICollectionViewCell {
    
    private let titleLabel = UILabel().then {
        $0.font = .pretenBold(24)
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.textColor = .grayScale900
        $0.setTextWithLineHeight(text: "아파트 임장,\n더 잘 작성할 수 없을까?", lineHeight: 33.6, textAlignment: .center)
    }
    private let titleEdgeLabel = UILabel().then {
        $0.text = "아파트 임당이 도와드릴게요!"
        $0.font = .pretenBold(24)
        $0.textColor = .mainOrange500
    }
    private let scriptLabel = UILabel().then {
        $0.text = "임장 후기 가이드라인으로, 더 깊은 임장 지식을 쌓아보세요."
        $0.font = .pretenMedium(14)
        $0.textColor = .grayScale700
    }
    
    private let icon = UIImageView().then {
        $0.image = UIImage(named: "exchange")
        $0.contentMode = .scaleAspectFit
    }
    
    private let backEffectView = UIView().then {
        $0.backgroundColor = .grayScale50
        $0.layer.cornerRadius = 8
    }
    
    private let etcTitle = UILabel().then {
        $0.text = "인사이트란?"
        $0.font = .pretenSemiBold(14)
        $0.textColor = .grayScale700
    }
    
    private let etcScript = UILabel().then {
        $0.text = "아파트임당에서는 체계화된 가이드라인에 따라 작성된 아파트 임장 후기를 인사이트라고 불러요."
        $0.font = .pretenRegular(14)
        $0.numberOfLines = 0
        $0.textColor = .grayScale700
        $0.setTextWithLineHeight(text: "아파트임당에서는 체계화된 가이드라인에 따라 작성된 아파트 임장 후기를 인사이트라고 불러요.",
                                 lineHeight: 21)
    }
    
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.masksToBounds = true
        
        [etcTitle, etcScript].forEach{ backEffectView.addSubview($0)}
        
        setGradient()
        layout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
    }
    
    private func setGradient() {
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor.mainOrange500.withAlphaComponent(0.1).cgColor
        ]
        
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: -5.0)
        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func layout() {
  
        [titleLabel, titleEdgeLabel, scriptLabel, icon, backEffectView ].forEach{ contentView.addSubview($0)}

        titleLabel.snp.makeConstraints {
            $0.height.equalTo(68)
            $0.top.equalToSuperview().inset(80)
            $0.centerX.equalToSuperview()
        }
        
        titleEdgeLabel.snp.makeConstraints {
            $0.height.equalTo(33)
            $0.top.equalTo(titleLabel.snp.bottom).inset(4)
            $0.centerX.equalToSuperview()
        }
        
        scriptLabel.snp.makeConstraints {
            $0.height.equalTo(20)
            $0.top.equalTo(titleEdgeLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        icon.snp.makeConstraints {
            $0.top.equalTo(scriptLabel.snp.bottom).offset(72)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(124)
        }
        
        backEffectView.snp.makeConstraints {
            $0.top.equalTo(icon.snp.bottom).offset(72)
            $0.horizontalEdges.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(99)
        }
        
        
        etcTitle.snp.makeConstraints {
            $0.top.equalTo(backEffectView.snp.top).inset(16)
            $0.leading.equalTo(backEffectView.snp.leading).inset(16)
        }
        
        etcScript.snp.makeConstraints {
            $0.top.equalTo(etcTitle.snp.bottom).offset(8)
            $0.horizontalEdges.equalTo(backEffectView.snp.horizontalEdges).inset(16)
        }
        
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
