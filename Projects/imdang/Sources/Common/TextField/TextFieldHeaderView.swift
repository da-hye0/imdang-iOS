//
//  SectionHeaderView.swift
//  imdang
//
//  Created by daye on 11/15/24.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Then

// bind > textFieldErrorMessage, textFieldState

class TextFieldHeaderView: UIView {
    
    let title: String
    let isEssential: Bool
    let descriptionText: String?
    var limitNumber: Int?
    
    var titleLabel = UILabel().then {
        $0.font = .pretenSemiBold(14)
        $0.textColor = UIColor.grayScale700
    }
    
    private var EssentialLabel = UILabel().then {
        $0.font = .pretenMedium(14)
        $0.text = "*"
        $0.textColor = UIColor.error
    }
    
    private var signImage = UIImageView()
    
    private var descriptionLabel = UILabel().then {
        $0.font = .pretenMedium(12)
        $0.textColor = UIColor.grayScale500
    }
    
    private var textNumLabel = UILabel().then {
        $0.font = .pretenMedium(12)
        $0.textColor = UIColor.mainOrange500
    }
    
    init(frame: CGRect = .zero, title: String, isEssential: Bool, descriptionText: String? = nil, limitNumber: Int? = nil) {
        self.title = title
        self.isEssential = isEssential
        self.descriptionText = descriptionText
        self.limitNumber = limitNumber
        super.init(frame: frame)
        attribute()
        addSubViews()
        makeUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        titleLabel.text = title
        descriptionLabel.text = descriptionText
    }
    
    private func addSubViews() {
        [titleLabel, EssentialLabel, signImage, descriptionLabel, textNumLabel].forEach { addSubview($0) }
    }
    
    private func makeUI() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
        }
        
        if isEssential {
            EssentialLabel.snp.makeConstraints {
                $0.leading.equalTo(titleLabel.snp.trailing)
                $0.centerY.equalTo(titleLabel)
            }
            signImage.snp.makeConstraints {
                $0.leading.equalTo(EssentialLabel.snp.trailing).offset(4)
                $0.centerY.equalTo(titleLabel)
            }
        } else {
            signImage.snp.makeConstraints {
                $0.leading.equalTo(titleLabel.snp.trailing).offset(6)
                $0.centerY.equalTo(titleLabel)
            }
        }
    
        textNumLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(titleLabel)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.trailing.equalTo(textNumLabel.snp.leading).offset(-4)
            $0.centerY.equalTo(titleLabel)
        }
    }
    
    func setState(_ state: TextFieldState) {
        UIView.animate(withDuration: 0.1) {
            switch state {
            case .normal:
                self.signImage.alpha = 0.0
                self.textNumLabel.text = ""
            case .editing:
                self.signImage.alpha = 0.0
                self.textNumLabel.textColor = UIColor.mainOrange500
            case .done:
                self.signImage.image = UIImage(systemName: "checkmark.circle.fill")
                self.signImage.tintColor = UIColor.mainOrange500
                self.signImage.alpha = 1.0
                self.textNumLabel.textColor = UIColor.mainOrange500
            case .error:
                self.signImage.image = UIImage(systemName: "exclamationmark.circle.fill")
                self.signImage.alpha = 1.0
                self.signImage.tintColor = UIColor.error
                self.textNumLabel.textColor = UIColor.error
            }
            self.layoutIfNeeded()
        }
    }
    
    func setTextNumber(_ num: Int) {
        guard let limitNumber else { return }
        textNumLabel.text = "(\(num)/\(limitNumber))"
    }
    
    func setConfigure(title: String, script: String, limitNumber: Int?) {
        titleLabel.text = title
        descriptionLabel.text = script
        self.limitNumber = limitNumber
    }
}

// 네이밍,, 뭘로하는겨
extension Reactive where Base: TextFieldHeaderView {
    var setTextNumber: Binder<Int> {
        return Binder(self.base) { view, num in
            view.setTextNumber(num)
        }
    }

    var textFieldState: Binder<TextFieldState> {
        return Binder(self.base) { view, state in
            view.setState(state)
        }
    }
}

