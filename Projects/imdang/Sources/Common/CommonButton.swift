//
//  WideButton.swift
//  imdang
//
//  Created by daye on 11/14/24.
//


import UIKit
import RxSwift
import SnapKit
import RxCocoa

// add View > width, height
// add Reactor > commonButtonTitle, commonButtonState, tap

enum CommonButtonType {
    case enabled
    case disabled
    case selectedBorderStyle
    case unselectedBorderStyle
    case whiteBackBorderStyle
}

class CommonButton: UIButton {

    private let disposeBag = DisposeBag()
    var title: String
    var initialButtonType: CommonButtonType
    var radius: CGFloat?

    init(frame: CGRect = .zero, title: String, initialButtonType: CommonButtonType, radius: CGFloat? = 8, keyboardEvent: Bool = false) {
        self.title = title
        self.initialButtonType = initialButtonType
        self.radius = radius
        super.init(frame: frame)
        setupButton()
        
        if keyboardEvent {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupButton() {
        setTitle(title, for: .normal)
        titleLabel?.font = .pretenSemiBold(16)
        layer.cornerRadius = radius ?? 8
        clipsToBounds = true

        contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        setState(initialButtonType)
    }
    
    func setState(_ state: CommonButtonType, title: String? = nil) {
        UIView.animate(withDuration: 0.1) {
            if let title = title {
                self.setTitle(title, for: .normal)
            }
            
            switch state {
            case .enabled:
                self.isEnabled = true
                self.backgroundColor = .mainOrange500
                self.layer.borderWidth = 0
                self.setTitleColor(.white, for: .normal)
            case .disabled:
                self.isEnabled = false
                self.backgroundColor = .grayScale100
                self.layer.borderWidth = 0
                self.setTitleColor(.grayScale500, for: .normal)
            case .selectedBorderStyle:
                self.isEnabled = true
                self.backgroundColor = .mainOrange50
                self.setTitleColor(.mainOrange500, for: .normal)
                self.layer.borderWidth = 1
                self.layer.borderColor = UIColor.mainOrange500.cgColor
            case .unselectedBorderStyle:
                self.isEnabled = true
                self.backgroundColor = .white
                self.setTitleColor(.grayScale200, for: .normal)
                self.layer.borderWidth = 1
                self.layer.borderColor = UIColor.grayScale100.cgColor
            case .whiteBackBorderStyle:
                self.isEnabled = true
                self.backgroundColor = .white
                self.setTitleColor(.mainOrange500, for: .normal)
                self.layer.borderWidth = 1
                self.layer.borderColor = UIColor.mainOrange500.cgColor
            }
        }
    }
    
    func setButtonTitle(title: String) {
        setTitle(title, for: .normal)
    }
    
    func setButtonTitleColor(color: UIColor) {
        self.setTitleColor(color, for: .normal)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            
            UIView.animate(withDuration: duration) {
                self.layer.cornerRadius = 0
                
                self.snp.remakeConstraints {
                    $0.horizontalEdges.equalToSuperview()
                    $0.bottom.equalToSuperview().inset(keyboardFrame.height)
                    $0.height.equalTo(56)
                }
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            
            UIView.animate(withDuration: duration) {
                self.layer.cornerRadius = self.radius ?? 8
                
                self.snp.remakeConstraints {
                    $0.horizontalEdges.equalToSuperview().inset(20)
                    $0.bottom.equalToSuperview().inset(40)
                    $0.height.equalTo(56)
                }
            }
        }
    }
}

extension Reactive where Base: CommonButton {
    var commonButtonState: Binder<CommonButtonType> {
        return Binder(self.base) { button, state in
            button.setState(state)
        }
    }
}
