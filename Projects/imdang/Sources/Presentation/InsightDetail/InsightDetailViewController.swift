////
////  InsightDetailViewController.swift
////  imdang
////
////  Created by 임대진 on 1/8/25.
////
//
import UIKit
import SnapKit
import Then
import RxSwift
import RxRelay

final class InsightDetailViewController: BaseViewController {

    private var insight: InsightDetail!
    private var mainImage: UIImage?
    private var tableView: UITableView!
    private var showEditButton: Bool
    private var exchangeState: DetailExchangeState
    private var disposeBag = DisposeBag()
    private var myInsights: [Insight]?
    private var coupon: CouponsResponse?
    private let couponService = CouponService.shared
    private let analyticsService = AnalyticsService.shared
    private let kakaoShareService = KakaoShareService()
    private let insightDetailViewModel = InsightDetailViewModel()
    private let selectedIndex = BehaviorRelay<Int?>(value: nil)
    private let accused = BehaviorRelay<Bool>(value: false)
    
    private let reportButton = UIButton().then {
        $0.setImage(ImdangImages.Image(resource: .report), for: .normal)
    }
    
    private let shareButton = UIButton().then {
        $0.setImage(ImdangImages.Image(resource: .share), for: .normal)
    }
    
    private let requestButton = CommonButton(title: "교환 요청", initialButtonType: .enabled)
    private let degreeButton = CommonButton(title: "거절", initialButtonType: .whiteBackBorderStyle)
    private let agreeButton = CommonButton(title: "수락", initialButtonType: .enabled)
    private let waitButton = CommonButton(title: "대기중", initialButtonType: .disabled)
    private let doneButton = CommonButton(title: "교환 완료", initialButtonType: .disabled)
    private let editButton = CommonButton(title: "수정하기", initialButtonType: .whiteBackBorderStyle)
    private let buttonBackView = UIView().then { $0.backgroundColor = .white }.then { $0.applyTopBlur() }
    private let headerView = InsightDetailCategoryTapView()
    private let categoryTapView = InsightDetailCategoryTapView().then {
        $0.isHidden = true
    }
    
    
    init(insight: InsightDetail, mainImage: UIImage? = nil, showEditButton: Bool = true) {
        exchangeState = insight.exchangeRequestStatus
        self.insight = insight
        self.mainImage = mainImage
        self.showEditButton = showEditButton
        self.accused.accept(insight.accused)
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalDismiss), name: .detailModalDidDismiss, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .detailModalDidDismiss, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customBackButton.isHidden = false
        navigationViewBottomShadow.isHidden = true
        
        setNavigationItem()
        configureTableView()
        addSubviews()
        makeConstraints()
        bindActions()
        loadData()
        
        view.addSubview(categoryTapView)
        categoryTapView.snp.makeConstraints {
            $0.topEqualToNavigationBottom(vc: self)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(44)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService().screenEvent(ScreenName: .insightDetail)
    }
    
    @objc private func handleModalDismiss() {
        self.navigationController?.popToRootViewController(animated: true)
        self.navigationController?.viewControllers.forEach {
            if let homeVC = $0 as? HomeContainerViewController {
                homeVC.changeView(showView: .exchange)
            }
        }
    }
    
    private func setNavigationItem() {
        [reportButton, shareButton].forEach { rightNaviItemView.addSubview($0) }
        
        shareButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(10)
        }
        
        reportButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(shareButton.snp.leading).offset(-12)
        }
    }
    
    private func configureTableView() {
        tableView = UITableView(frame: self.view.bounds, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 1
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        
        tableView.register(cell: UITableViewCell.self)
        tableView.register(cell: InsightDetailImageCell.self)
        tableView.register(cell: InsightDetailEtcTableCell.self)
        tableView.register(cell: InsightDetailTitleTableCell.self)
        tableView.register(cell: InsightDetailDefaultInfoTableCell.self)
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.topEqualToNavigationBottom(vc: self)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-96)
        }
    }
    
    private func addSubviews() {
        [buttonBackView, requestButton, waitButton, doneButton, degreeButton, agreeButton, editButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func makeConstraints() {
        buttonBackView.snp.makeConstraints() {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(96)
            $0.bottom.equalToSuperview()
        }
        
        [requestButton, waitButton, doneButton, editButton].forEach {
            $0.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview().inset(20)
                $0.height.equalTo(56)
                $0.bottom.equalToSuperview().offset(-40)
            }
        }
        
        degreeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(buttonBackView.snp.centerX).offset(-5)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview().offset(-40)
        }
        
        agreeButton.snp.makeConstraints {
            $0.leading.equalTo(buttonBackView.snp.centerX).offset(5)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview().offset(-40)
        }
        
        updateButton()
    }
    
    private func updateButton() {
        [requestButton, waitButton, doneButton, degreeButton, agreeButton, editButton].forEach {
            $0.isHidden = true
        }
        
        switch exchangeState {
        case .null:
            if insight.memberId == UserdefaultKey.memberId {
                if showEditButton {
                    editButton.isHidden = false
                } else {
                    buttonBackView.isHidden = true
                    tableView.snp.updateConstraints {
                        $0.bottom.equalToSuperview()
                    }
                }
            } else {
                requestButton.isHidden = false
            }
        case .pending:
            if let state = insight.exchangeRequestCreatedByMe {
                if state {
                    waitButton.isHidden = false
                } else {
                    degreeButton.isHidden = false
                    agreeButton.isHidden = false
                }
            } else {
                waitButton.isHidden = false
            }
        case .rejected:
            if insight.memberId == UserdefaultKey.memberId {
                editButton.isHidden = false
            } else {
                requestButton.isHidden = false
            }
        case .accepted:
            if let state = insight.exchangeRequestCreatedByMe {
                if state {
                    editButton.isHidden = false
                } else {
                    doneButton.isHidden = false
                }
            } else {
                doneButton.isHidden = false
            }
        }
    }
    
    private func reloadInsight() {
        insightDetailViewModel.loadInsightDetail(id: self.insight.insightId)
            .subscribe { [self] data in
                if let data = data {
                    self.insight = data
                    self.tableView.reloadData()
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bindActions() {
        requestButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                //                owner.showReportAlert(title: "인사이트 교환 불가", description: "신고로 인해 3일간\n인사이트 교환이 불가능해요.\n문의 사항은 아래 메일로 남겨주세요.", highligshtText: "3일간", type: .confirmOnly)
                //                owner.showReportAlert(title: "이미 신고한 인사이트에요", description: "신고로 인해 5일간\n인사이트 교환이 불가능해요.\n문의 사항은 아래 메일로 남겨주세요.", highligshtText: "5일간", type: .confirmOnly)
                //                owner.showReportAlert(title: "인사이트 교환 불가", description: "해당 인사이트는 신고로 인해\n교환이 불가능해요.\n문의 사항은 아래 메일로 남겨주세요.", type: .confirmOnly)
                
                if (owner.myInsights?.isEmpty == false) || (owner.coupon?.couponCount ?? 0 > 0) {
                    let vc = MyInsightsModalViewController(insightId: owner.insight.insightId, myInsights: owner.myInsights, coupon: owner.coupon)
                    
                    vc.resultSend = {
                        if $0 {
                            owner.exchangeState = .pending
                            owner.updateButton()
                            owner.tableView.reloadData()
                        }
                    }
                    
                    vc.modalPresentationStyle = .pageSheet
                    vc.modalTransitionStyle = .coverVertical
                    self.present(vc, animated: true, completion: nil)
                } else {
                    owner.showAlert(text: "교환할 인사이트가 없어요.\n임장을 다녀온 후 인사이트를\n작성해주세요.", type: .confirmOnly, imageType: .circleCheck)
                }
            })
            .disposed(by: disposeBag)
        
        agreeButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.insightDetailViewModel.acceptInsight(exchangeRequestId: owner.insight.exchangeRequestId ?? "")
                    .subscribe(onNext: {
                        if $0 {
                            owner.analyticsService.insightExchangeState(state: "수락")
                            owner.showAlert(text: "교환을 수락했어요.\n교환한 인사이트는 보관함에서\n확인할 수 있어요.", type: .moveButton, imageType: .circleCheck) {
                                owner.exchangeState = .accepted
                                owner.updateButton()
                                owner.reloadInsight()
                            } etcAction: {
                                self.dismiss(animated: true)
                                self.navigationController?.popToRootViewController(animated: true)
                                guard let tabBarController = self.tabBarController else { return }
                                UIView.animate(withDuration: 5) {
                                    tabBarController.selectedIndex = 2
                                }
                            }
                        }
                    })
                    .disposed(by: owner.disposeBag)
            })
            .disposed(by: disposeBag)
        
        degreeButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.insightDetailViewModel.rejecttInsight(exchangeRequestId: owner.insight.exchangeRequestId ?? "")
                    .subscribe(onNext: {
                        if $0 {
                            owner.analyticsService.insightExchangeState(state: "거절")
                            owner.showAlert(text: "교환을 거절했어요.", type: .confirmOnly, imageType: .circleCheck)
                            owner.navigationController?.popViewController(animated: true)
                        }
                    })
                    .disposed(by: owner.disposeBag)
            })
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                let vc = InsightViewController()
                let reactor = InsightReactor()
                reactor.detail = owner.insight
                reactor.detail.score = 0
                reactor.updateInsightId = owner.insight.insightId
                vc.reactor = reactor
                owner.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        reportButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                if !owner.accused.value {
                    owner.showReportAlert(title: "이 인사이트를 신고할까요?", description: "허위, 과다 신고시 불이익이\n발생할 수 있어요", type: .cancellable, comfrimAction: {
                        
                        owner.insightDetailViewModel.accueInsight(insightId: owner.insight.insightId)
                            .subscribe(with: self) { owner, result in
                                if result {
                                    owner.accused.accept(true)
                                    owner.showAlert(text: "신고가 완료되었어요.", type: .confirmOnly)
                                }
                            }
                            .disposed(by: owner.disposeBag)
                    })
                } else {
                    owner.showReportAlert(title: "이미 신고한 인사이트에요", description: "동일한 인사이트를 중복으로\n신고할 수 없어요", type: .confirmOnly)
                }
            })
            .disposed(by: disposeBag)
        
        shareButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.kakaoShareService.insightKakaoShare(title: owner.insight.title, insightId: owner.insight.insightId, imageUrl: owner.insight.mainImage) { linkType in
                    owner.openKakaoLink(kakaoLinkType: linkType)
                }
            })
            .disposed(by: disposeBag)
        
        headerView.selectedIndex
            .compactMap { $0 }
            .distinctUntilChanged()
            .subscribe(with: self, onNext: { owner, index in
                owner.selectedIndex.accept(index)
            })
            .disposed(by: disposeBag)
        
        categoryTapView.selectedIndex
            .compactMap { $0 }
            .distinctUntilChanged()
            .subscribe(with: self, onNext: { owner, index in
                owner.selectedIndex.accept(index)
            })
            .disposed(by: disposeBag)
        
        selectedIndex
            .compactMap { $0 }
            .distinctUntilChanged()
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, index in
                owner.headerView.selectedIndex.accept(index)
                owner.categoryTapView.selectedIndex.accept(index)
                if owner.insight.memberId == UserdefaultKey.memberId {
                    owner.tableView.scrollToRow(at: IndexPath(row: 0, section: index + 2), at: .top, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func scrollToSection(index: Int) {
        let indexPath = IndexPath(row: 0, section: index + 2)
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let cellTopY = cell.frame.origin.y
        
        let targetOffsetY = cellTopY - 70
        
        var offset = tableView.contentOffset
        offset.y = targetOffsetY
        
        tableView.setContentOffset(offset, animated: true)
    }

    private func loadData() {
        insightDetailViewModel.loadMyInsights()
            .subscribe(with: self, onNext: { owner, result in
                owner.myInsights = result
            })
            .disposed(by: disposeBag)
        
        couponService.getCoupons()
            .subscribe { result in
                self.coupon = result
            }.disposed(by: self.disposeBag)
    }
}

extension InsightDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return insight.memberId == UserdefaultKey.memberId ? 7 : exchangeState == .accepted ? 7 : 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let etcCell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: InsightDetailEtcTableCell.self)
        etcCell.selectionStyle = .none
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: InsightDetailImageCell.self)
            cell.config(url: insight.mainImage, mainImage: mainImage)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: InsightDetailTitleTableCell.self)
            cell.config(info: insight)
            cell.selectionStyle = .none
            
            cell.likeButton.rx.tap
                .subscribe(with: self) { owner, _ in
                    owner.insightDetailViewModel.recommendInsight(insightId: owner.insight.insightId)
                        .subscribe(with: self) { owner, result in
                            switch result {
                            case .success:
                                cell.likeInsight()
                                owner.analyticsService.insightLike(isOn: true)
                            case .failure:
                                break
                            case .recommended:
                                owner.showAlert(text: "이미 추천한 인사이트입니다", type: .confirmOnly)
                            case .beforeExchange:
                                owner.showAlert(text: "인사이트 추천은 교환 후 가능해요", type: .confirmOnly)
                            }
                        }
                        .disposed(by: owner.disposeBag)
                }
                .disposed(by: disposeBag)
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: InsightDetailDefaultInfoTableCell.self)
            cell.config(info: insight, state: exchangeState, isMyInsight: insight.memberId == UserdefaultKey.memberId)
            cell.selectionStyle = .none
            return cell
        case 3:
            etcCell.config(info: insight.infra.conversionArray(), text: insight.infra.text)
            return etcCell
        case 4:
            etcCell.config(info: insight.complexEnvironment.conversionArray(), text: insight.complexEnvironment.text)
            return etcCell
        case 5:
            etcCell.config(info: insight.complexFacility.conversionArray(), text: insight.complexFacility.text)
            return etcCell
        case 6:
            etcCell.config(info: insight.favorableNews.conversionArray(), text: insight.favorableNews.text)
            return etcCell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 2:
            return 44
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 2:
            return headerView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0,1,2:
            return 0
        default:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = InsightDetailEtcFooterView()
        switch section {
        case 3:
            footerView.config(text: insight.infra.text)
            return footerView
        case 4:
            footerView.config(text: insight.complexEnvironment.text)
            return footerView
        case 5:
            footerView.config(text: insight.complexFacility.text)
            return footerView
        case 6:
            footerView.config(text: insight.favorableNews.text)
            footerView.separatorView.isHidden = true
            return footerView
        default:
            return nil
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerHeight: CGFloat = 423
        let sectionHeaderYOffset = scrollView.contentOffset.y
        
        if sectionHeaderYOffset >= headerHeight {
            categoryTapView.isHidden = false
        } else {
            categoryTapView.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
            case 2,3,4,5,6:
            if indexPath.row == 0 {
                categoryTapView.setCurrentIndex.accept(indexPath.section - 2)
                headerView.setCurrentIndex.accept(indexPath.section - 2)
            }
        default:
            return
        }
    }

}
