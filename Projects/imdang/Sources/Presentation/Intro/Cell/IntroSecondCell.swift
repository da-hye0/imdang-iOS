//
//  IntroSecondCell.swift
//  imdang
//
//  Created by daye on 2/4/25.
//

import UIKit
import SnapKit
import Then

class SecondCell: UICollectionViewCell {
    
    private let reason = ["내가 작성한 인사이트와 동등한 퀄리티의\n 인사이트를 공유하고 싶어요.",
    "열심히 작성한 인사이트를 아무런 보상 없이\n공유하는 것이 아쉬웠어요.",
                         "지속적으로 양질의\n인사이트를 공유하고 싶어요."]
    
    private let gradientLayer = CAGradientLayer()
    
    private let titleLabel = UILabel().then {
        $0.setTextWithLineHeight(text: "이런 분들을 위해\n손쉬운 가이드라인을 도입했어요", lineHeight: 30)
        $0.font = .pretenSemiBold(20)
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    private let icon = UIImageView().then {
        $0.image = UIImage(named: "Blob")
        $0.contentMode = .scaleAspectFit
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.masksToBounds = true
        contentView.layer.insertSublayer(gradientLayer, at: 0)
        
        [titleLabel, icon, stackView].forEach{contentView.addSubview($0)}
        
        setGradient()
        layout()
        setupScript()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
    }
    
    private func setGradient() {
        gradientLayer.colors = [UIColor.gradientBrown.cgColor, UIColor.black.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }
    
    private func layout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.leading.equalToSuperview().inset(20)
        }
        
        icon.snp.makeConstraints {
            $0.width.height.equalTo(56)
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(titleLabel.snp.centerY)
        }

        stackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.bottom.equalToSuperview().inset(40)
        }
    }
    
    private func setupScript() {
        for i in 0...2 {
            
            let imageView = UIImageView().then {
                $0.image = UIImage(named: "talkBackground")
                $0.contentMode = .scaleAspectFill
                $0.layer.cornerRadius = 8
                $0.layer.masksToBounds = true
            }
            
            let label = UILabel().then {
                $0.setTextWithLineHeight(text: reason[i], lineHeight: 19.6, textAlignment: .center)
                $0.font = .pretenMedium(14)
                $0.textAlignment = .center
                $0.textColor = .white
                $0.numberOfLines = 0
            }

            imageView.addSubview(label)
            label.snp.makeConstraints { $0.center.equalToSuperview() }

            stackView.addArrangedSubview(imageView)

            imageView.snp.makeConstraints {
                $0.height.equalTo(90)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

