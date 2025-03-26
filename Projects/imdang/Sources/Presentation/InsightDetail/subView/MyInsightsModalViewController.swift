//
//  MyInsightsModalViewController.swift
//  imdang
//
//  Created by 임대진 on 1/26/25.
//


import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MyInsightsModalViewController: UIViewController {
    var resultSend: ((Bool) -> Void)?
    private var tableView: UITableView!
    private var insightId: String
    private var selectedInsightId: String?
    private var coupon: CouponsResponse?
    private var myInsights: [Insight]?
    private let disposeBag = DisposeBag()
    private let couponService = CouponService.shared
    private let analyticsService = AnalyticsService.shared
    private let insightDetailViewModel = InsightDetailViewModel()
    
    private let grabber = UIButton().then {
        $0.backgroundColor = .grayScale200
        $0.layer.cornerRadius = 3
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "어떤 인사이트와 교환할까요?"
        $0.font = .pretenSemiBold(20)
        $0.textColor = .grayScale900
    }
    
    private let configButton = CommonButton(title: "확인", initialButtonType: .enabled).then {
        $0.applyTopBlur()
    }
    
    init(insightId: String, myInsights: [Insight]?, coupon: CouponsResponse?) {
        self.insightId = insightId
        self.myInsights = myInsights
        self.coupon = coupon
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTableView()
        bindAction()
        
        if let sheetPresentationController = sheetPresentationController {
            sheetPresentationController.detents = [.medium(), .large()]
        }
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.rowHeight = 91
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
        tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        
        tableView.register(cell: MyInsightsTableCell.self)
        
        let footerView = UIView()
        footerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 20)
        tableView.tableFooterView = footerView
        
        view.addSubview(tableView)
        view.addSubview(grabber)
        view.addSubview(titleLabel)
        view.addSubview(configButton)
        
        grabber.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(52)
            $0.height.equalTo(6)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(grabber.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(configButton.snp.top)
        }
        
        configButton.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-40)
        }
    }
    
    private func bindAction() {
        configButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                
                if let selectedInsightId = owner.selectedInsightId {
                    
                    owner.insightDetailViewModel.requestInsight(thisInsightId: owner.insightId, myInsightId: selectedInsightId)
                        .subscribe(onNext: {
                            if $0 {
                                owner.analyticsService.insightExchangeState(state: "요청")
                                owner.showAlert(text: "교환 요청을 완료했어요.\n교환 내역은 교환소에서 확인해보세요.", moveButtonTitle: "교환소 확인하기", type: .moveButton) {
                                    owner.dismiss(animated: true)
                                    owner.resultSend?(true)
                                } etcAction: {
                                    owner.dismiss(animated: true)
                                    NotificationCenter.default.post(name: .detailModalDidDismiss, object: nil)
                                }
                            }
                        })
                        .disposed(by: owner.disposeBag)
                } else if let couponId = owner.coupon?.memberCouponId {
                    
                    owner.insightDetailViewModel.requestInsight(thisInsightId: owner.insightId, couponId: "\(couponId)")
                        .subscribe(onNext: {
                            if $0 {
                                owner.analyticsService.insightExchangeState(state: "요청")
                                owner.showAlert(text: "교환 요청을 완료했어요.\n교환 내역은 교환소에서 확인해보세요.", moveButtonTitle: "교환소 확인하기", type: .moveButton) {
                                    owner.dismiss(animated: true)
                                    owner.resultSend?(true)
                                } etcAction: {
                                    owner.dismiss(animated: true)
                                    NotificationCenter.default.post(name: .detailModalDidDismiss, object: nil)
                                }
                            }
                        })
                        .disposed(by: owner.disposeBag)
                } else {
                    owner.showAlert(text: "교환 요청에 실패했어요", type: .confirmOnly)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension MyInsightsModalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (myInsights?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: MyInsightsTableCell.self)
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.config(type: .ticket, ticketCount: coupon?.couponCount)
        default:
            guard let myInsights = myInsights else { return cell }
            cell.config(type: .insight, insight: myInsights[indexPath.row - 1])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            selectedInsightId = nil
        default:
            guard let myInsights = myInsights else { return }
            selectedInsightId = myInsights[indexPath.row - 1].insightId
        }
    }
}
