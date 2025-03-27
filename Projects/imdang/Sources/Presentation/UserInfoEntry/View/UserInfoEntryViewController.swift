//
//  UserInfoEntryViewController.swift
//  imdang
//
//  Created by daye on 11/14/24.
//


import UIKit
import RxSwift
import RxCocoa
import SnapKit
import ReactorKit
import Then

final class UserInfoEntryViewController: BaseViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    private let joinService = ServerJoinService()
    
    private var mainTitle = UILabel().then {
        $0.text = "기본정보입력"
        $0.font = .pretenExtraBold(26)
        $0.textColor = UIColor.grayScale900
    }
    
    private var subTitle = UILabel().then {
        $0.text = "추후 진행할 이벤트를 위해 조사하고 있어요\n개인정보는 유출되지 않으니 걱정 마세요"
        $0.numberOfLines = 2
        $0.font = .pretenMedium(16)
        $0.textColor = UIColor.grayScale700
    }
    
    //nickname
    private var nicknameHeaderView = TextFieldHeaderView(title: "닉네임 (필수)", isEssential: false, descriptionText: "최소 2자-최대10자", limitNumber: 10).then {
        $0.titleLabel.do {
            let attributedString = NSMutableAttributedString(string: "닉네임 (필수)")
            let range = ("닉네임 (필수)" as NSString).range(of: "(필수)")
            attributedString.addAttribute(.foregroundColor, value: UIColor.error, range: range)
            
            $0.attributedText = attributedString
        }
    }
    private var nicknameTextField = CommomTextField(placeholderText: "예시) 임당이", textfieldType: .stringInput)
    private var niknameFooterView = TextFieldFooterView()
    
    //birth
    private var birthHeaderView = TextFieldHeaderView(title: "생년월일", isEssential: false)
    private var birthTextField = CommomTextField(placeholderText: "예시) 2024.01.01", textfieldType: .dateInput)
    private var birthFooterView = TextFieldFooterView()
    
    //gender
    private var genderHeaderView = TextFieldHeaderView(title: "성별", isEssential: false)
    private var selectMaleButton = CommonButton(title: "남자", initialButtonType: .unselectedBorderStyle)
    private var selectFemaleButton = CommonButton(title: "여자", initialButtonType: .unselectedBorderStyle)
    
    //button
    private var submitButton = CommonButton(title: "다음", initialButtonType: .disabled, keyboardEvent: true)
    
    private lazy var stackView = UIStackView().then {
        $0.isUserInteractionEnabled = false
        [mainTitle, subTitle, nicknameHeaderView, nicknameTextField, niknameFooterView, birthHeaderView, birthTextField, birthFooterView, genderHeaderView, selectMaleButton, selectFemaleButton, submitButton].forEach { view.addSubview($0) }
    }
    
    init(reactor: UserInfoEntryReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        reactor.action.onNext(.changeNicknameTextFieldState(.normal))
        reactor.action.onNext(.changeBirthTextFieldState(.normal))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customBackButton.isHidden = false
        navigationViewBottomShadow.isHidden = true
        
        view.backgroundColor = UIColor.grayScale25
        view.addSubview(stackView)
        setup()
        presentModal()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService().screenEvent(ScreenName: .userInfoInput)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func setup() {
        attriubute()
        layout()
    }
    
    func attriubute(){
        
        
    }
    
    func layout(){
        mainTitle.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.top)
            $0.leading.equalTo(stackView.snp.leading)
        }
        
        subTitle.snp.makeConstraints {
            $0.top.equalTo(mainTitle.snp.bottom).offset(16)
            $0.leading.equalTo(stackView.snp.leading)
        }
        
        nicknameHeaderView.snp.makeConstraints {
            $0.top.equalTo(subTitle.snp.bottom).offset(44)
            $0.height.equalTo(20)
            $0.horizontalEdges.equalTo(stackView.snp.horizontalEdges)
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameHeaderView.snp.bottom).offset(8)
            $0.height.equalTo(52)
            $0.horizontalEdges.equalTo(stackView.snp.horizontalEdges)
        }
        
        niknameFooterView.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(8)
            $0.height.equalTo(17)
            $0.horizontalEdges.equalTo(stackView.snp.horizontalEdges)
        }
        
        birthHeaderView.snp.makeConstraints {
            $0.top.equalTo(niknameFooterView.snp.bottom).offset(24)
            $0.height.equalTo(20)
            $0.horizontalEdges.equalTo(stackView.snp.horizontalEdges)
        }
        
        birthTextField.snp.makeConstraints {
            $0.top.equalTo(birthHeaderView.snp.bottom).offset(8)
            $0.height.equalTo(52)
            $0.horizontalEdges.equalTo(stackView.snp.horizontalEdges)
        }
        
        birthFooterView.snp.makeConstraints {
            $0.top.equalTo(birthTextField.snp.bottom).offset(8)
            $0.height.equalTo(17)
            $0.horizontalEdges.equalTo(stackView.snp.horizontalEdges)
        }
        
        genderHeaderView.snp.makeConstraints {
            $0.top.equalTo(birthFooterView.snp.bottom).offset(24)
            $0.height.equalTo(20)
            $0.horizontalEdges.equalTo(stackView.snp.horizontalEdges)
        }
        
        selectMaleButton.snp.makeConstraints {
            $0.top.equalTo(genderHeaderView.snp.bottom).offset(8)
            $0.height.equalTo(52)
            $0.leading.equalTo(stackView.snp.leading)
            $0.width.equalTo(selectFemaleButton)
        }
        
        selectFemaleButton.snp.makeConstraints {
            $0.top.equalTo(genderHeaderView.snp.bottom).offset(8)
            $0.leading.equalTo(selectMaleButton.snp.trailing).offset(8)
            $0.height.equalTo(52)
            $0.trailing.equalTo(stackView.snp.trailing)
            $0.width.equalTo(selectMaleButton)
        }
        
        submitButton.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalTo(stackView.snp.horizontalEdges)
            $0.bottom.equalTo(stackView.snp.bottom)
        }
        
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.topEqualToNavigationBottom(vc: self)
            $0.bottom.equalToSuperview().inset(40)
        }
    }
    
    func bind(reactor: UserInfoEntryReactor) {
        
        //nickname
        nicknameTextField.rx.controlEvent(.primaryActionTriggered)
            .subscribe(onNext: {[weak self] in self?.birthTextField.becomeFirstResponder()})
            .disposed(by: disposeBag)
        
        nicknameTextField.rx.controlEvent([.editingDidBegin])
            .asDriver()
            .map { Reactor.Action.changeNicknameTextFieldState(.editing) }
            .drive(reactor.action)
            .disposed(by: disposeBag)
        
        nicknameTextField.rx.text
            .orEmpty
            .bind { [weak self] text in
                self?.nicknameHeaderView.setTextNumber(text.count)
            }
            .disposed(by: disposeBag)
        
        nicknameTextField.rx.controlEvent([.editingDidEnd])
            .asDriver()
            .map { [weak self] in
                self?.validateNicknameInput(text: self?.nicknameTextField.text) ?? .changeNicknameTextFieldState(.normal)
            }
            .drive(reactor.action)
            .disposed(by: disposeBag)
        
        nicknameTextField.isClearButtonTapped
            .asDriver(onErrorJustReturn: false)
            .map { [weak self] _ in
                guard let self = self else { return .changeNicknameTextFieldState(.normal) }
                self.nicknameHeaderView.setTextNumber(0)
                return self.validateNicknameInput(text: self.nicknameTextField.text)
            }
            .drive(reactor.action)
            .disposed(by: disposeBag)
        
        // birth
        birthTextField.rx.controlEvent(.primaryActionTriggered)
            .subscribe(onNext: {[weak self] in self?.birthTextField.resignFirstResponder()})
            .disposed(by: disposeBag)
        
        birthTextField.rx.controlEvent([.editingDidBegin])
            .asDriver()
            .map { .changeBirthTextFieldState(.editing) }
            .drive(reactor.action)
            .disposed(by: disposeBag)
        
        birthTextField.rx.controlEvent([.editingDidEnd])
            .asDriver()
            .map { [weak self] in
                self?.validateBirthInput(text: self?.birthTextField.text) ?? .changeBirthTextFieldState(.normal)
            }
            .drive(reactor.action)
            .disposed(by: disposeBag)

        birthTextField.isClearButtonTapped
            .asDriver(onErrorJustReturn: false)
            .map { [weak self] _ in
                guard let self = self else { return .changeBirthTextFieldState(.normal) }
                self.birthHeaderView.setTextNumber(0)
                return self.validateBirthInput(text: self.birthTextField.text)
            }
            .drive(reactor.action)
            .disposed(by: disposeBag)

        // gender
        selectMaleButton.rx.tap
            .map{ Reactor.Action.tapGenderButton( reactor.currentState.selectedGender == .male ? .none : .male )}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        selectFemaleButton.rx.tap
            .map{ Reactor.Action.tapGenderButton( reactor.currentState.selectedGender == .female ? .none : .female )}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        submitButton.rx.tap.subscribe(onNext: { [self] in
            guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
                print("nickname empty")
                return
            }
                
            joinService.joinImdang(nickname: nickname, birthDate: birthTextField.text, gender: reactor.currentState.selectedGender)
                    .subscribe { success in
                        if success {
                            let vc = JoinCompletedViewController()
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            self.showAlert(text: "이미 등록된 닉네임입니다.", type: .confirmOnly)
                        }
                    }
                    .disposed(by: disposeBag)
        }).disposed(by: disposeBag)
        
        reactor.state
            .map { $0.nicknameTextFieldState }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                self?.nicknameHeaderView.rx.textFieldState.onNext(state)
                self?.nicknameTextField.setState(state)
                self?.niknameFooterView.setState(state)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.birthTextFieldState }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                self?.birthHeaderView.rx.textFieldState.onNext(state)
                self?.birthTextField.setState(state)
                self?.birthFooterView.setState(state)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map {$0.selectedGender}
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                self?.selectMaleButton.rx.commonButtonState.onNext(state == .male ? .selectedBorderStyle : .unselectedBorderStyle)
                self?.selectFemaleButton.rx.commonButtonState.onNext(state == .female ? .selectedBorderStyle : .unselectedBorderStyle)
                self?.genderHeaderView.rx.textFieldState.onNext(state == .none ? .normal : .done)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { state in
                let isNicknameValid = (state.nicknameTextFieldState == .done)
                
                return isNicknameValid
            }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isEnableSubmitButton in
                self?.reactor?.action.onNext(.checkEnableSubmitButton(isEnableSubmitButton))
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.submitButtonEnabled }
            .subscribe(onNext: { [weak self] isEnabled in
                self?.submitButton.rx.commonButtonState.onNext(isEnabled ? .enabled : .disabled)
            })
            .disposed(by: disposeBag)
    }
    
    private func presentModal() {
        let modalVC = TermsModalViewController()
        modalVC.modalPresentationStyle = .overFullScreen
        modalVC.modalTransitionStyle = .crossDissolve
        self.present(modalVC, animated: true, completion: nil)
    }
    
    
    private func validateNicknameInput(text: String?) -> UserInfoEntryReactor.Action {
        // 닉네임 미입력 오류 처리
        guard let text = self.nicknameTextField.text, !text.isEmpty else {
            self.niknameFooterView.rx.textFieldErrorMessage.onNext("닉네임을 입력해주세요.")
            return .changeNicknameTextFieldState(.error)
        }
        
        // 닉네임 글자 수 오류 처리
        guard text.count >= 2 && text.count <= 10 else {
            self.niknameFooterView.rx.textFieldErrorMessage.onNext("2자~10자로 입력해주세요.")
            return .changeNicknameTextFieldState(.error)
        }
        
        // 닉네임 입력 완료 상태
        return .changeNicknameTextFieldState(.done)
    }
    
    private func validateBirthInput(text: String?) -> UserInfoEntryReactor.Action {
        guard let text = text, !text.isEmpty else {
//            birthFooterView.rx.textFieldErrorMessage.onNext("생년월일을 입력해주세요.")
            return .changeBirthTextFieldState(.normal) // 필수입력이 아니라서 빈값일때 normal로 변경
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"

        if dateFormatter.date(from: text) == nil {
            birthFooterView.rx.textFieldErrorMessage.onNext("잘못된 생년월일을 입력하셨어요.")
            return .changeBirthTextFieldState(.error)
        }

        let currentDate = Date()
        if let inputDate = dateFormatter.date(from: text), inputDate > currentDate {
            birthFooterView.rx.textFieldErrorMessage.onNext("과거 또는 오늘 날짜를 입력해주세요.")
            return .changeBirthTextFieldState(.error)
        }

        return .changeBirthTextFieldState(.done)
    }
}
