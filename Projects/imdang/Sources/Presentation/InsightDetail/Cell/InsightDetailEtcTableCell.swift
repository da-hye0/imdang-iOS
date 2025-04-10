//
//  InsightDetailEtcTableCell.swift
//  imdang
//
//  Created by 임대진 on 1/13/25.
//
import UIKit
import Then
import SnapKit

final class InsightDetailEtcTableCell: UITableViewCell {
    static let identifier = "InsightDetailEtcTableCell"
    
    private var stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .grayScale50
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        stackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 4
        }
    }
    
    private func addSubviews() {
        [separatorView, stackView].forEach { contentView.addSubview($0) }
    }
    
    private func makeConstraints() {
        
        separatorView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(8)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(32)
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    func config(info: [(String, [String])], text: String) {
        
        info.forEach { (name, items) in
            let title = UILabel().then {
                $0.text = name
                $0.font = .pretenMedium(14)
                $0.textColor = .grayScale600
            }
            let labelsView = makeLabelsView()
            labelsView.setup(with: items)
            
            let infoView = UIView()
            
            infoView.addSubview(title)
            infoView.addSubview(labelsView)
            stackView.addArrangedSubview(infoView)
            
            title.snp.makeConstraints {
                $0.top.leading.equalToSuperview()
                $0.height.equalTo(22)
            }
            
            labelsView.snp.makeConstraints {
                $0.top.equalTo(title.snp.bottom).offset(4)
                $0.leading.equalToSuperview()
                $0.height.equalTo(labelsView.currentY)
            }
            
            infoView.snp.makeConstraints {
                $0.height.equalTo(26 + labelsView.currentY).priority(999)
            }
        }
    }
}

final class makeLabelsView: UIView {
    var currentY: CGFloat = 36
    func setup(with tags: [String]) {
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0)
        
        var currentX: CGFloat = 0
        let padding: CGFloat = 8    // 라벨 사이 간격
        let lineSpacing: CGFloat = 8 // 줄 간격
        let maxWidth = self.bounds.width
        
        var previousLabel: UILabel? = nil // 이전 라벨을 추적할 변수

        for tag in tags {
            let noneLabel = tag == "해당 없음" || tag == "잘 모르겠어요"
            
            let label = PaddingLabel().then {
                $0.text = tag.replacingOccurrences(of: "_", with: " ")
                $0.font = .pretenSemiBold(14)
                $0.textColor = noneLabel ? .grayScale500 : .mainOrange500
                $0.backgroundColor = noneLabel ? .grayScale50 : .mainOrange50
                $0.textAlignment = .center
                $0.padding = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
                
                $0.layer.cornerRadius = 8
                $0.layer.masksToBounds = true
                $0.layer.borderColor = noneLabel ? UIColor.grayScale100.cgColor : UIColor.mainOrange500.cgColor
                $0.layer.borderWidth = 1
                                $0.sizeToFit()
                                $0.frame.size.width += 32
                                $0.frame.size.height = 36
            }


            // 가로 방향으로 공간 초과 시 새 줄로 이동
            if currentX + label.frame.width > maxWidth {
                currentY += 36 + padding
                currentX = 0
                self.addSubview(label)
                label.snp.makeConstraints { make in
                    make.top.equalTo(previousLabel?.snp.bottom ?? self.snp.top).offset(lineSpacing)
                    make.leading.equalTo(self.snp.leading)
                }
            } else {
                self.addSubview(label)
                label.snp.makeConstraints { make in
                    make.top.equalTo(previousLabel?.snp.top ?? self.snp.top)
                    make.leading.equalTo(previousLabel?.snp.trailing ?? self.snp.leading).offset(previousLabel == nil ? 0 : lineSpacing)
                }
            }

            // 다음 라벨의 x 좌표 업데이트
            previousLabel = label
            currentX += label.frame.width + padding
        }
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: currentY)
    }
}
