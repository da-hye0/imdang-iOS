//
//  ExchangeHeaderCell.swift
//  imdang
//
//  Created by daye on 1/9/25.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Then
import ReactorKit

final class ExchangeHeaderCell: UITableViewCell {
    private var disposeBag = DisposeBag()
    
    private let ticketView = TicketView()
    private let segmentControl = UISegmentedControl().then {
        $0.insertSegment(withTitle: "내가 요청한 내역", at: 0, animated: true)
        $0.insertSegment(withTitle: "내가 요청받은 내역", at: 1, animated: true)
        $0.selectedSegmentIndex = 0
        $0.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.grayScale500,
            NSAttributedString.Key.font: UIFont.pretenSemiBold(16)
        ], for: .normal)
        $0.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.grayScale900,
            NSAttributedString.Key.font: UIFont.pretenSemiBold(16)
        ], for: .selected)
        $0.selectedSegmentTintColor = .clear
        $0.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        $0.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        $0.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    private let underLineView = UIView().then {
        $0.backgroundColor = .grayScale900
    }
    private let divideLineView = UIView().then {
        $0.backgroundColor = .grayScale100
    }
    private let exchangeStateButtonView = ExchangeStateButtonView()
    private let noticeScriptView = NoticeScriptView()
    private let analyticsService = AnalyticsService.shared
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // setup
    private func setupView() {
        [ticketView, segmentControl, underLineView, divideLineView, exchangeStateButtonView, noticeScriptView].forEach { contentView.addSubview($0) }
    }
    
    private func setupLayout() {
        ticketView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.height.equalTo(54)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        segmentControl.snp.makeConstraints {
            $0.top.equalTo(ticketView.snp.bottom).offset(28)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(15)
        }
        
        underLineView.snp.makeConstraints {
            $0.top.equalTo(segmentControl.snp.bottom).offset(21)
            $0.width.equalTo(155)
            $0.height.equalTo(2)
            $0.centerX.equalTo(segmentControl.snp.leading).offset(97.5) // width/2 + 패딩20
        }
        
        divideLineView.snp.makeConstraints {
            $0.top.equalTo(underLineView.snp.bottom)
            $0.width.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        exchangeStateButtonView.snp.makeConstraints {
            $0.top.equalTo(divideLineView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        noticeScriptView.snp.makeConstraints {
            $0.top.equalTo(exchangeStateButtonView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    // bind
    func bind(reactor: ExchangeReactor) {
        
        segmentControl.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .map { index in
                ExchangeReactor.Action.selectedRequestSegmentControl(index == 0 ? .request : .receive)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        exchangeStateButtonView.waitingButton.rx.tap
            .map { ExchangeReactor.Action.tapExchangeStateButton(.waiting) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        exchangeStateButtonView.rejectButton.rx.tap
            .map { ExchangeReactor.Action.tapExchangeStateButton(.reject) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        exchangeStateButtonView.doneButton.rx.tap
            .map { ExchangeReactor.Action.tapExchangeStateButton(.done) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { ($0.selectedExchangeState, $0.insights?.count ?? 0) }
            .distinctUntilChanged( {
                return $0 == $1
            })
            .subscribe(onNext: { [weak self] exchangeState, insightsCount in
                guard let self = self else { return }
                self.exchangeStateButtonView.waitingButton.rx.commonButtonState.onNext(exchangeState == .waiting ? .enabled : .unselectedBorderStyle)
                self.exchangeStateButtonView.rejectButton.rx.commonButtonState.onNext(exchangeState == .reject ? .enabled : .unselectedBorderStyle)
                self.exchangeStateButtonView.doneButton.rx.commonButtonState.onNext(exchangeState == .done ? .enabled : .unselectedBorderStyle)
                
                self.updateScript(state: exchangeState, num: insightsCount)
                self.updateButtonTitle(state: exchangeState, num: insightsCount)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedExchangeState }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] exchangeState in
                guard let self = self else { return }
                if reactor.currentSegmentState == .request {
                    self.analyticsService.sendRequestStateClick(state: exchangeState.rawValue.replacingOccurrences(of: "교환 완료", with: "교환완료"))
                } else {
                    self.analyticsService.receivedRequestStateClick(state: exchangeState.rawValue.replacingOccurrences(of: "교환 완료", with: "교환완료"))
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc func segmentChanged() {
        let selectedIndex = segmentControl.selectedSegmentIndex
        UIView.animate(withDuration: 0.2) {
            let segmentWidth = self.segmentControl.bounds.width / CGFloat(self.segmentControl.numberOfSegments) + 1
            let centerXOffset = CGFloat(selectedIndex + 1) * segmentWidth + segmentWidth / 2
            
            self.underLineView.snp.updateConstraints {
                $0.centerX.equalTo(self.segmentControl.snp.leading).offset(centerXOffset - self.segmentControl.bounds.width / 2)
            }
            self.layoutIfNeeded()
        }
    }
    
    private func updateButtonTitle(state: ExchangeState, num: Int) {
        switch state {
        case .waiting:
            exchangeStateButtonView.waitingButton.setButtonTitle(title: "\(ExchangeState.waiting.rawValue) (\(num))")
            exchangeStateButtonView.rejectButton.setButtonTitle(title: "\(ExchangeState.reject.rawValue)")
            exchangeStateButtonView.doneButton.setButtonTitle(title: "\(ExchangeState.done.rawValue)")
        case .reject:
            exchangeStateButtonView.waitingButton.setButtonTitle(title: "\(ExchangeState.waiting.rawValue)")
            exchangeStateButtonView.rejectButton.setButtonTitle(title: "\(ExchangeState.reject.rawValue) (\(num))")
            exchangeStateButtonView.doneButton.setButtonTitle(title: "\(ExchangeState.done.rawValue)")
        case .done:
            exchangeStateButtonView.waitingButton.setButtonTitle(title: "\(ExchangeState.waiting.rawValue)")
            exchangeStateButtonView.rejectButton.setButtonTitle(title: "\(ExchangeState.reject.rawValue)")
            exchangeStateButtonView.doneButton.setButtonTitle(title: "\(ExchangeState.done.rawValue) (\(num))")
        }
    }
    
    private func updateScript(state: ExchangeState, num: Int) {
        if num < 1 {
            switch state {
            case .waiting:
                noticeScriptView.configure(text: "대기 중인 내역이 없어요.")
            case .reject:
                noticeScriptView.configure(text: "거절 내역이 없어요.")
            case .done:
                noticeScriptView.configure(text: "교환 완료 내역이 없어요.")
            }
        } else  {
            switch state {
            case .waiting:
                noticeScriptView.configure(text: "대기 중 내역은 최근 7일간의 기록만 표시돼요.")
            case .reject:
                noticeScriptView.configure(text: "거절 내역은 최근 7일간의 기록만 표시돼요")
            case .done:
                noticeScriptView.configure(text: "교환한 인사이트는 보관함에 저장되며, 완료 내역은\n최근 7일간의 기록만 표시돼요.")
            }
        }
    }
    
    func config(couponCount: Int?) {
        ticketView.configure(couponCount: couponCount)
    }
}
