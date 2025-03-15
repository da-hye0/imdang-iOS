//
//  TicketModalViewController.swift
//  imdang
//
//  Created by 임대진 on 12/4/24.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

class TicketModalViewController: UIViewController {
    private let couponService = CouponService.shared
    private let disposeBag = DisposeBag()
    
    private let dimView = UIView().then {
        $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    }
    
    private let modalView = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    }
    
    private let ticketImageView = UIImageView().then {
        $0.image = ImdangImages.Image(resource: .passTicket)
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "무료 패스권 도착!"
        $0.font = .pretenBold(24)
        $0.textColor = .grayScale900
        $0.textAlignment = .center
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale700
        $0.numberOfLines = 2
        $0.setTextWithLineHeight(text: "처음 아파트 임당을 사용하시는 분들을 위해\n무료 패스권을 제공해요", lineHeight: 22.4, textAlignment: .center)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .pretenMedium(14)
        $0.textColor = .mainOrange500
        $0.backgroundColor = .mainOrange50
        $0.numberOfLines = 2
        $0.setTextWithLineHeight(text: "무료 패스권 사용시 다른 사람들도\n길동님의 인사이트를 무료 패스권으로 볼 수 있어요", lineHeight: 19.6, textAlignment: .center)
        
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let acceptButton = UIButton().then {
        $0.setTitle("동의하고 받기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.backgroundColor = .mainOrange500
        
        $0.layer.cornerRadius = 8
    }
    
    private let closeButton = UIButton().then {
        $0.setTitle("오늘 그만보기", for: .normal)
        $0.setTitleColor(.grayScale700, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.grayScale200.cgColor
    }
    
    private let xButton = UIButton().then {
        $0.setImage(ImdangImages.Image(resource: .cancle), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubViews()
        makeConstraints()
        bindActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    private func addSubViews() {
        [dimView, modalView, ticketImageView, titleLabel, subTitleLabel, descriptionLabel, acceptButton, closeButton, xButton].forEach { view.addSubview($0) }
    }
    
    private func makeConstraints() {
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        modalView.snp.makeConstraints {
            $0.height.equalTo(534)
            $0.width.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        xButton.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.top.equalTo(modalView).offset(24)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        ticketImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
            $0.top.equalTo(modalView.snp.top).offset(82)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(ticketImageView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.height.equalTo(72)
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        acceptButton.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            $0.leading.equalTo(view.snp.centerX).offset(4)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        closeButton.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            $0.trailing.equalTo(view.snp.centerX).offset(-4)
            $0.leading.equalToSuperview().offset(20)
        }
    }
    
    private func bindActions() {
        xButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let today = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let todayString = formatter.string(from: today)
                
                UserdefaultKey.dontSeeToday = todayString
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        acceptButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                couponService.issueCoupons()
                    .subscribe { success in
                        if success {
                            UserdefaultKey.couponReceived = true
                        } else {
                            print("쿠폰 발급 실패")
                        }
                    }
                    .disposed(by: disposeBag)
                dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
