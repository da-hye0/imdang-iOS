//
//  InsightDetailEtcFooterView.swift
//  imdang
//
//  Created by 임대진 on 1/13/25.
//

import UIKit

final class InsightDetailEtcFooterView: UICollectionReusableView {
    static let reuseIdentifier = "InsightDetailEtcFooterView"
    
    private let titleLabel = UILabel().then {
        $0.text = "총평"
        $0.font = .pretenMedium(14)
        $0.textColor = .grayScale600
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(22)
        }
    }
    
    override func prepareForReuse() {
        descriptionLabel.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func calculateLabelHeight(text: String) -> CGFloat {
        let width = UIScreen.main.bounds.width
        let lineHeight = 22.4
        let font = UIFont.pretenMedium(16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]

        let boundingSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: boundingSize,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: attributes,
                                            context: nil)

        return ceil(boundingBox.height)
    }
    
    func config(text: String) {
        if text != "" {
            descriptionLabel.setTextWithLineHeight(text: text, lineHeight: 22.4)
            let height = calculateLabelHeight(text: text)
            descriptionLabel.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(4)
                $0.horizontalEdges.equalToSuperview().inset(20)
                $0.height.equalTo(height)
            }
        } else {
            titleLabel.removeFromSuperview()
        }
    }
}


