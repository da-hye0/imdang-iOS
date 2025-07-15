//
//  IntroThirdCell.swift
//  imdang
//
//  Created by daye on 2/4/25.
//

import UIKit
import SnapKit

class ThirdCell: UICollectionViewCell {
        
        private let comments = [
            ("인사이트 가이드라인", "가이드라인으로 체계화된 인사이트를\n작성할 수 있어요."),
            ("자유로운 인사이트 교류", "양질의 인사이트를 주고받으며, 임장 지식을\n넓힐 수 있어요."),
            ("인사이트 보관함", "추천한 인사이트를 편리하게\n관리할 수 있어요."),
        ]
        
        private let titleLabel = UILabel().then {
            $0.setTextWithLineHeight(text: "아파트임당에서는\n이런 서비스를 제공해요", lineHeight: 30)
            $0.font = .pretenSemiBold(20)
            $0.textColor = .grayScale900
            $0.numberOfLines = 0
        }
        
        private let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 24
            $0.alignment = .leading
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            [titleLabel, stackView].forEach{contentView.addSubview($0)}
            
            layout()
            setupScript()
        }
        
        private func layout() {
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().inset(40)
                $0.leading.equalToSuperview().inset(20)
            }
            
            stackView.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(40)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().inset(20)
                $0.bottom.equalToSuperview().inset(40)
            }
        }
        
        private func setupScript() {
            for (index, (title, comment)) in comments.enumerated() {
                let container = UIView()
                
                let img = UIImageView(image: UIImage(named: "introService\(index+1)")).then {
                    $0.contentMode = .scaleAspectFit
                }
                
                let titleLabel = UILabel().then {
                    $0.text = title
                    $0.font = .pretenSemiBold(16)
                    $0.textColor = .grayScale900
                }
                
                let scriptLabel = UILabel().then {
                    $0.setTextWithLineHeight(text: comment, lineHeight: 19.6)
                    $0.font = .pretenRegular(14)
                    $0.textColor = .grayScale700
                    $0.numberOfLines = 0
                }
                
                [img, titleLabel, scriptLabel].forEach{container.addSubview($0)}

                img.snp.makeConstraints {
                    $0.top.leading.equalToSuperview()
                    $0.width.height.equalTo(52)
                }
                
                titleLabel.snp.makeConstraints {
                    $0.leading.equalTo(img.snp.trailing).offset(16)
                    $0.top.equalToSuperview()
                }
                
                scriptLabel.snp.makeConstraints {
                    $0.leading.equalTo(titleLabel)
                    $0.trailing.equalToSuperview()
                    $0.top.equalTo(titleLabel.snp.bottom).offset(4)
                    $0.bottom.equalToSuperview()
                }
                
                stackView.addArrangedSubview(container)
                
                if index < comments.count - 1 {
                    let separator = UIView().then {
                        $0.backgroundColor = .grayScale100
                    }
                    
                    stackView.addArrangedSubview(separator)
                    
                    separator.snp.makeConstraints {
                        $0.height.equalTo(1)
                        $0.leading.trailing.equalToSuperview()
                    }
                }
            }
        }
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
