//
//  WriteInsightEtcViewController.swift
//  imdang
//
//  Created by 임대진 on 12/30/24.
//

import UIKit
import RxSwift
import RxRelay
import ReactorKit

enum ItemSelectType {
    case one, several
}

class WriteInsightEtcViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    
    private let analyticsService = AnalyticsService.shared
    private let insightSectionInfo: [InsightSectionInfo]
    private let categoryName: String!
    private var selectedSections: Set<Int> = []
    private var collectionView: UICollectionView!
    private var baseInfo = InsightDetail.emptyInsight
    private var checkSectionState = PublishRelay<Set<Int>>()
    private var selectedButtonNames: [Int: Set<String>] = [:]
    private var nextButtonView = NextAndBackButton()
    
    init(info: [InsightSectionInfo], title: String) {
        self.insightSectionInfo = info
        self.categoryName = title
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupNextButtonView()
    }
    
    private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 20, bottom: 16, right: 20)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .grayScale25
        
        collectionView.register(header: InsightEtcHeaderView.self)
        collectionView.register(cell: InsightEtcCollectionCell.self)
        collectionView.register(footer: InsightTotalAppraisalFooterView.self)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setupNextButtonView() {
        view.addSubview(nextButtonView)
        nextButtonView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(96)
        }
        if categoryName == "호재" {
            nextButtonView.config(needBack: false, title: "작성완료 및 업로드")
            presentTooltip()
        } else {
            nextButtonView.config(needBack: true)
        }
    }
    
    func bind(reactor: InsightReactor) {
        baseInfo = reactor.detail
        
        nextButtonView.nextButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                guard owner.nextButtonView.isEnable else {
                    owner.showToast(message: "필수 항목을 모두 작성해주세요")
                    return
                }
                
                switch owner.categoryName {
                case "인프라":
                    owner.reactor?.action.onNext( .tapInfraInfoConfirm(owner.baseInfo.infra) )
                case "단지 환경":
                    owner.reactor?.action.onNext( .tapEnvironmentInfoConfirm(owner.baseInfo.complexEnvironment) )
                case "단지 시설":
                    owner.reactor?.action.onNext( .tapFacilityInfoConfirm(owner.baseInfo.complexFacility) )
                case "호재":
                    owner.nextButtonView.isEnable = false
                    owner.reactor?.action.onNext( .tapFavorableNewsInfoConfirm(owner.baseInfo.favorableNews) )
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        nextButtonView.backButton.rx.tap
            .map { InsightReactor.Action.tapBackButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        checkSectionState
            .subscribe(with: self, onNext: { owner, arr in
                owner.nextButtonView.nextButtonEnable(value: arr.count == owner.insightSectionInfo.count ? true : false)
//                self.nextButtonView.nextButtonEnable(value: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isUploadSuccess }
            .filter { $0 != false }
            .distinctUntilChanged()
            .subscribe(onNext: { result in
                self.showAlert(text: "인사이트 업로드가 완료되었어요.\n작성한 내 인사이트는 보관함에서\n확인할 수 있어요.", type: .moveButton) { [self] in
                    self.analyticsService.insightWrite()
                    let vc = InsightDetailViewController(insight: reactor.detail, mainImage: reactor.mainImage[0], showEditButton: false)
                    self.navigationController?.pushViewController(vc, animated: true)
                    if let firstVC = self.navigationController?.viewControllers.first {
                        self.navigationController?.setViewControllers([firstVC, vc], animated: true)
                    }
                } etcAction: {
                    self.analyticsService.insightWrite()
                    self.navigationController?.popToRootViewController(animated: true)
                    guard let tabBarController = self.tabBarController else { return }
                    tabBarController.selectedIndex = 2
                }
                self.nextButtonView.isEnable = true
            })
            .disposed(by: disposeBag)
    }
    
    private func presentTooltip() {
        let toolTipView = ToolTipView(type: .down)
        view.addSubview(toolTipView)
        toolTipView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension WriteInsightEtcViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return insightSectionInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return insightSectionInfo[section].buttonTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellRedundancyAndUnselectProcessing(collectionView, indexPath: indexPath) // 리로드 처리
        
        let isClear = checkCellAllClear(collectionView, indexPath: indexPath)
        headerCheckIconProcessing(isClear: isClear, collectionView, indexPath: indexPath) // 헤더 체크아이콘 업데이트
        setSectionState(isClear: isClear, index: indexPath.section) // 필수항목 체크
        setInfoData(title: insightSectionInfo[indexPath.section].title, items: Array(selectedButtonNames[indexPath.section, default: []])) // 데이터 저장
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionInfo = insightSectionInfo[indexPath.section]
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: InsightEtcCollectionCell.self)
        
        let buttonTitle = sectionInfo.buttonTitles[indexPath.row]
        cell.config(buttonTitle: buttonTitle)
        
        switch categoryName {
        case "인프라":
            if baseInfo.infra.amenities.isEmpty { break }
            setSectionInfo(arr: baseInfo.infra.conversionArray(), cell: cell, collectionView: collectionView, indexPath: indexPath)
        case "단지 환경":
            if baseInfo.complexEnvironment.security.isEmpty { break }
            setSectionInfo(arr: baseInfo.complexEnvironment.conversionArray(), cell: cell, collectionView: collectionView, indexPath: indexPath)
        case "단지 시설":
            if baseInfo.complexFacility.surroundings.isEmpty { break }
            setSectionInfo(arr: baseInfo.complexFacility.conversionArray(), cell: cell, collectionView: collectionView, indexPath: indexPath)
        case "호재":
            if baseInfo.favorableNews.cultures.isEmpty { break }
            setSectionInfo(arr: baseInfo.favorableNews.conversionArray(), cell: cell, collectionView: collectionView, indexPath: indexPath)
        default:
            break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableHeader(forIndexPath: indexPath, headerType: InsightEtcHeaderView.self)
            let sectionInfo = insightSectionInfo[indexPath.section]
            header.config(title: sectionInfo.title, description: sectionInfo.description, subtitle: sectionInfo.subTitle)
            
            // 리로드 처리
            if selectedSections.contains(indexPath.section) {
                header.addCheckIcon()
            } else {
                header.removeCheckIcon()
            }
            
            return header
        } else if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableFooter(forIndexPath: indexPath, footerType: InsightTotalAppraisalFooterView.self)
            footer.config(title: categoryName + " 총평")
            footer.delegate = self
            
            setFooter(title: categoryName, footer: footer)
            return footer
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: insightSectionInfo[section].subTitle == nil ? 44 : 84)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == insightSectionInfo.count - 1 {
            return CGSize(width: collectionView.bounds.width, height: 300)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalPadding: CGFloat = 20 * 2
        let interItemSpacing: CGFloat = 8
        let totalSpacing = horizontalPadding + interItemSpacing
        
        let itemWidth = (collectionView.bounds.width - totalSpacing) / 2
        
        return CGSize(width: itemWidth, height: 52)
    }
}

extension WriteInsightEtcViewController: TotalAppraisalFootereViewDelegate {
    
    func didTapButton(title: String, text: String) {
        let childVC = CommonTextViewViewComtroller(title: title, text: text)
        
        childVC.onDataSend = { [weak self] data in
            guard let self = self else { return }
            
            setInfoData(title: title, items: [data])
            let lastSection = self.insightSectionInfo.count - 1
            let footerIndexPath = IndexPath(item: 0, section: lastSection)
            collectionView.reloadSections(IndexSet(integer: footerIndexPath.section))
        }
        navigationController?.pushViewController(childVC, animated: true)
    }
}

// Cell UI 관련
extension WriteInsightEtcViewController {
    private func cellRedundancyAndUnselectProcessing(_ collectionView: UICollectionView, indexPath: IndexPath) {
        for visibleIndexPath in collectionView.indexPathsForVisibleItems {
            guard let cell = collectionView.cellForItem(at: visibleIndexPath) as? InsightEtcCollectionCell else { continue }
            
            if categoryName == "단지 환경" {
                if visibleIndexPath.section == indexPath.section {
                    if visibleIndexPath.row == indexPath.row {
                        cell.isClicked = true
                        selectedButtonNames[visibleIndexPath.section] = [cell.label.text!]
                    } else {
                        cell.isClicked = false
                    }
                }
            } else {
                if visibleIndexPath.section == indexPath.section {
                    if visibleIndexPath.row == indexPath.row {
                        
                        let selectedText = cell.label.text ?? ""
                        if selectedText == "해당 없음" || selectedText ==  "잘 모르겠어요" {
                            if cell.isClicked == false {
                                var otherCells: [InsightEtcCollectionCell] = []
                                
                                for otherVisibleIndexPath in collectionView.indexPathsForVisibleItems {
                                    if otherVisibleIndexPath.section == indexPath.section,
                                       otherVisibleIndexPath != visibleIndexPath {
                                        if let otherCell = collectionView.cellForItem(at: otherVisibleIndexPath) as? InsightEtcCollectionCell {
                                            otherCells.append(otherCell)
                                        }
                                    }
                                }
                                
                                // 클릭되어있는 셀 있을시 모달
                                if otherCells.filter({ $0.isClicked == true }).count > 0 {
                                    showAlert(text: "해당 없음, 잘 모르겠어요\n선택시 다른 항목들은\n선택이 해제돼요. 괜찮으신가요?", type: .cancellable) { [self] in
                                        cell.isClicked = true
                                        for otherCell in otherCells {
                                            otherCell.isClicked = false
                                        }
                                        selectedButtonNames[visibleIndexPath.section] = [selectedText]
                                        setInfoData(title: insightSectionInfo[indexPath.section].title, items: Array(selectedButtonNames[indexPath.section, default: []]))
                                    } etcAction: {
                                        cell.isClicked = false
                                    }
                                } else {
                                    cell.isClicked = true
                                    selectedButtonNames[visibleIndexPath.section] = [selectedText]
                                }
                                
                            } else {
                                cell.isClicked = false
                                selectedButtonNames[visibleIndexPath.section]?.remove("해당 없음")
                                selectedButtonNames[visibleIndexPath.section]?.remove("잘 모르겠어요")
                            }
                        } else {
                            cell.isClicked.toggle()
                            if cell.isClicked {
                                selectedButtonNames[visibleIndexPath.section, default: []].insert(selectedText)
                            } else {
                                selectedButtonNames[visibleIndexPath.section, default: []].remove(selectedText)
                            }
                            
                            // 해당없음 셀의 상태 해제
                            for otherVisibleIndexPath in collectionView.indexPathsForVisibleItems {
                                if otherVisibleIndexPath.section == indexPath.section,
                                   otherVisibleIndexPath != visibleIndexPath {
                                    if let otherCell = collectionView.cellForItem(at: otherVisibleIndexPath) as? InsightEtcCollectionCell,
                                       otherCell.label.text == "해당 없음" || otherCell.label.text == "잘 모르겠어요" {
                                        otherCell.isClicked = false
                                        selectedButtonNames[visibleIndexPath.section]?.remove("해당 없음")
                                        selectedButtonNames[visibleIndexPath.section]?.remove("잘 모르겠어요")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func checkCellAllClear(_ collectionView: UICollectionView, indexPath: IndexPath) -> Bool {
        var result = true
        for row in 0..<collectionView.numberOfItems(inSection: indexPath.section) {
            let cellIndexPath = IndexPath(row: row, section: indexPath.section)
            if let cell = collectionView.cellForItem(at: cellIndexPath) as? InsightEtcCollectionCell {
                if cell.isClicked {
                    result = false
                    break
                }
            }
        }
        
        return result
    }
    
    private func headerCheckIconProcessing(isClear: Bool, _ collectionView: UICollectionView, indexPath: IndexPath) {
        if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: indexPath.section)) as? InsightEtcHeaderView {
            if isClear {
                header.removeCheckIcon()
            } else {
                header.addCheckIcon()
            }
        }
    }
    
    private func setSectionState(isClear: Bool, index: Int) {
        if isClear {
            selectedSections.remove(index)
        } else {
            selectedSections.insert(index)
        }
        checkSectionState.accept(selectedSections)
    }
}

// 데이터 매핑
extension WriteInsightEtcViewController {
    
    private func setSectionInfo(arr: [(String, [String])], cell: InsightEtcCollectionCell, collectionView: UICollectionView, indexPath: IndexPath) {
        for (i, section) in arr.enumerated() {
            for item in section.1 {
                if i == indexPath.section && cell.label.text == item.replacingOccurrences(of: "_", with: " ") {
                    cell.isClicked = true
                    setSectionState(isClear: false, index: i)
                    selectedButtonNames[indexPath.section, default: []].insert(cell.label.text ?? "")
                }
            }
            headerCheckIconProcessing(isClear: false, collectionView, indexPath: indexPath)
        }
    }
    
    private func setFooter(title: String, footer: InsightTotalAppraisalFooterView) {
        switch title {
        case "인프라":
            footer.customTextView.text = baseInfo.infra.text
        case "단지 환경":
            footer.customTextView.text = baseInfo.complexEnvironment.text
        case "단지 시설":
            footer.customTextView.text = baseInfo.complexFacility.text
        case "호재":
            footer.customTextView.text = baseInfo.favorableNews.text
        default:
            break
        }
    }
    
    func setInfoData(title: String, items: [String]) {
        var baseInfo = self.baseInfo
        let convertItems = items.map { $0.replacingOccurrences(of: " ", with: "_") }

        let categoryMapping: [String: [String: (inout InsightDetail) -> Void]] = [
            "인프라": [
                "교통*": { $0.infra.transportations = convertItems },
                "학군*": { $0.infra.schoolDistricts = convertItems },
                "생활 편의시설*": { $0.infra.amenities = convertItems },
                "문화 및 여가시설 (단지외부)*": { $0.infra.facilities = convertItems },
                "주변환경*": { $0.infra.surroundings = convertItems },
                "랜드마크*": { $0.infra.landmarks = convertItems },
                "기피시설*": { $0.infra.unpleasantFacilities = convertItems },
                "인프라 총평": { $0.infra.text = (convertItems.first ?? "").replacingOccurrences(of: "_", with: " ") }
            ],
            "단지 환경": [
                "건물*": { $0.complexEnvironment.buildingCondition = convertItems },
                "안전*": { $0.complexEnvironment.security = convertItems },
                "어린이 시설*": { $0.complexEnvironment.childrenFacility = convertItems },
                "경로 시설*": { $0.complexEnvironment.seniorFacility = convertItems },
                "단지 환경 총평": { $0.complexEnvironment.text = (convertItems.first ?? "").replacingOccurrences(of: "_", with: " ") }
            ],
            "단지 시설": [
                "가족*": { $0.complexFacility.familyFacilities = convertItems },
                "다목적*": { $0.complexFacility.multipurposeFacilities = convertItems },
                "여가 (단지내부)*": { $0.complexFacility.leisureFacilities = convertItems },
                "환경*": { $0.complexFacility.surroundings = convertItems },
                "단지 시설 총평": { $0.complexFacility.text = (convertItems.first ?? "").replacingOccurrences(of: "_", with: " ") }
            ],
            "호재": [
                "교통*": { $0.favorableNews.transportations = convertItems },
                "개발*": { $0.favorableNews.developments = convertItems },
                "교육*": { $0.favorableNews.educations = convertItems },
                "자연환경*": { $0.favorableNews.environments = convertItems },
                "문화*": { $0.favorableNews.cultures = convertItems },
                "산업*": { $0.favorableNews.industries = convertItems },
                "정책*": { $0.favorableNews.policies = convertItems },
                "호재 총평": { $0.favorableNews.text = (convertItems.first ?? "").replacingOccurrences(of: "_", with: " ") }
            ]
        ]
        
        if let category = categoryMapping[categoryName], let action = category[title] {
            action(&baseInfo)
        }
        
        self.baseInfo = baseInfo
    }
}
