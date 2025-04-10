//
//  CommonTextViewComtroller.swift
//  imdang
//
//  Created by 임대진 on 1/5/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

/*
     let childVC = CommonTextViewViewComtroller(title: title, text: text)
     
     childVC.onDataSend = { [weak self] data in
         guard let self = self else { return }
         
         text = data
     }
     navigationController?.pushViewController(childVC, animated: true)
 */

class CommonTextViewViewComtroller: BaseViewController {
    var onDataSend: ((String) -> Void)?
    private var disposeBag = DisposeBag()
    
    private let textCountstackView = UIStackView().then {
        $0.spacing = 2
        $0.alignment = .trailing
    }
    
    private let NavigationTitleLabel = UILabel().then {
        $0.font = .pretenSemiBold(18)
        $0.textColor = .grayScale900
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .pretenSemiBold(14)
        $0.textColor = .grayScale700
    }
    
    private let descriptionLabel = PaddingLabel().then {
        $0.font = .pretenMedium(14)
        $0.textColor = .grayScale600
        $0.backgroundColor = .grayScale50
        $0.padding = UIEdgeInsets(top: 16, left: 40, bottom: 20, right: 16)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private var descriptionText = ""
    
    private var icon = UIImageView().then {
        $0.image = ImdangImages.Image(resource: .warning)
    }
    
    private let textCountLabel = UILabel().then {
        $0.text = "최소30자-최대200자"
        $0.font = .pretenMedium(12)
        $0.textColor = .grayScale500
    }
    
    private var currentTextCountLabel = UILabel().then {
        $0.font = .pretenMedium(12)
        $0.textColor = .mainOrange500
    }
    
    
    private let textFieldBackground = UIButton().then {
        $0.backgroundColor = .white
        
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.grayScale100.cgColor
        $0.layer.cornerRadius = 8
    }
    
    private let textView = UITextView().then {
        $0.backgroundColor = .white
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
        $0.autocapitalizationType = .none // 자동 대문자 비활성화
        $0.autocorrectionType = .no // 자동 수정 비활성화
    }
    
    private let placeholderLabel = UILabel().then {
        $0.textColor = .grayScale400
        $0.font = .pretenMedium(16)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private let configButton = CommonButton(title: "확인", initialButtonType: .enabled, keyboardEvent: true)

    init(title: String, text: String, placeHolder: String? = "", description: String? = "") {
        super.init(nibName: nil, bundle: nil)
        
        titleLabel.text = title
        let attributedString = NSMutableAttributedString(string: title)
        let range = (title as NSString).range(of: "*")
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: range)
        
        titleLabel.attributedText = attributedString
        textView.text = text
        NavigationTitleLabel.text = title.replacingOccurrences(of: "*", with: "")
        self.descriptionText = description ?? ""
        
        if text.isEmpty {
            placeholderLabel.text = placeHolder
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customBackButton.isHidden = false
        textView.delegate = self
        
        addsubViews()
        makeConstraints()
        bindActions()
        
        if descriptionText != "" {
            descriptionLabel.text = descriptionText
            updateConstraints()
        }
        
        if !textView.text.isEmpty {
            updateCurrentTextCount()
        }
        
        if NavigationTitleLabel.text == "인사이트 요약" {
            AnalyticsService().screenEvent(ScreenName: .basicInfoSummary)
        } else if NavigationTitleLabel.text == "인프라 총평" {
            AnalyticsService().screenEvent(ScreenName: .infraSummary)
        } else if NavigationTitleLabel.text == "단지 환경 총평" {
            AnalyticsService().screenEvent(ScreenName: .environmentSummary)
        } else if NavigationTitleLabel.text == "단지 시설 총평" {
            AnalyticsService().screenEvent(ScreenName: .FacilitySummary)
        } else if NavigationTitleLabel.text == "호재 총평" {
            AnalyticsService().screenEvent(ScreenName: .FavoriteNewsSummary)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }

    private func addsubViews() {
        leftNaviItemView.addSubview(NavigationTitleLabel)
        textFieldBackground.addSubview(textView)
        textCountstackView.addArrangedSubview(textCountLabel)
        [titleLabel, descriptionLabel, icon, textFieldBackground, configButton, placeholderLabel, textCountstackView].forEach { view.addSubview($0) }
    }
    
    private func updateConstraints() {
        descriptionLabel.snp.makeConstraints {
            $0.topEqualToNavigationBottom(vc: self).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(92)
        }
        
        icon.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.top).offset(18)
            $0.leading.equalTo(descriptionLabel.snp.leading).offset(20)
            $0.width.equalTo(16)
            $0.height.equalTo(18)
        }
        
        titleLabel.snp.remakeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        textCountstackView.snp.remakeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
    private func makeConstraints() {
        
        NavigationTitleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
        }
        
        titleLabel.snp.makeConstraints {
            $0.topEqualToNavigationBottom(vc: self).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        textCountstackView.snp.makeConstraints {
            $0.topEqualToNavigationBottom(vc: self).offset(24)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        textFieldBackground.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(180)
        }
        
        textView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(textFieldBackground).offset(16)
            $0.horizontalEdges.equalTo(textFieldBackground).inset(16)
        }
        
        configButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(40)
            $0.height.equalTo(56)
        }
    }
    
    private func updateCurrentTextCount() {
        if textCountstackView.subviews.count == 1 {
            textCountstackView.addArrangedSubview(currentTextCountLabel)
        }
        currentTextCountLabel.text = "(\(textView.text.count)/200)"
    }
    
    func bindActions() {
        configButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.sendDataToParent()
            })
            .disposed(by: disposeBag)
    }
    
    func sendDataToParent() {
        onDataSend?(textView.text)
        navigationController?.popViewController(animated: true)
    }
}

extension CommonTextViewViewComtroller: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textFieldBackground.layer.borderColor = UIColor.mainOrange500.cgColor
        placeholderLabel.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textFieldBackground.layer.borderColor = UIColor.grayScale100.cgColor
        if textView.text.isEmpty {
            placeholderLabel.isHidden = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            if textView.text.count > 0 && textView.text.count < 30 {
                configButton.setState(.disabled)
            } else {
                configButton.setState(.enabled)
            }
            
            updateCurrentTextCount()
        } else {
            configButton.setState(.enabled)
            currentTextCountLabel.removeFromSuperview()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        return updatedText.count <= 200
    }
}
