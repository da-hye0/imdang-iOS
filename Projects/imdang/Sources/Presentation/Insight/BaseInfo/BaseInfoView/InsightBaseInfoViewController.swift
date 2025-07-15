//
//  Untitled.swift
//  imdang
//
//  Created by daye on 12/22/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxRelay
import ReactorKit
import Kingfisher

enum ItemType {
    case text
    case image
    case address
    case button

}

class InsightBaseInfoViewController: UIViewController, TotalAppraisalFootereViewDelegate, View {
    
    var disposeBag = DisposeBag()
    
    private let insightService = InsightWriteService()
    private var baseInfo = InsightDetail.emptyInsight
    private var nextButtonView = NextAndBackButton()
    var imageDataList: [UIImage] = []
    
    private var selectedIndexPaths: [BehaviorRelay<Set<IndexPath>>] = [
        BehaviorRelay<Set<IndexPath>>(value: []), // Section 4
        BehaviorRelay<Set<IndexPath>>(value: []), // Section 5
        BehaviorRelay<Set<IndexPath>>(value: [])  // Section 6
    ]
    
    private var checkSectionState = BehaviorRelay<[TextFieldState]>(value: Array(repeating: .normal, count: 8))
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .grayScale25
        $0.register(BaseInfoTextFieldCell.self, forCellWithReuseIdentifier: BaseInfoTextFieldCell.identifier)
        $0.register(BaseInfoButtonCell.self, forCellWithReuseIdentifier: BaseInfoButtonCell.identifier)
        $0.register(BaseInfoImageCell.self, forCellWithReuseIdentifier: BaseInfoImageCell.identifier)
        $0.register(BaseInfoAddressCell.self, forCellWithReuseIdentifier: BaseInfoAddressCell.identifier)
        $0.register(InsightTotalAppraisalFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: InsightTotalAppraisalFooterView.identifier)
        $0.register(BaseInfoHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BaseInfoHeaderCell.identifier)
        $0.dataSource = self
        $0.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }

    private func layout() {
        view.addSubview(collectionView)
        view.addSubview(nextButtonView)
        nextButtonView.config(needBack: false)
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        nextButtonView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(96)
        }
    }

    private let items: [(header: String, script: String, itemType: ItemType, itemData: [String])]
        = [("표시 이미지", "최대 10개 등록 가능", .image, [""]),
            ("제목", "최소1자-최대20자", .text, [""]),
            ("단지 주소", "", .address, ["지번 주소", "단지 아파트 명"]),
            ("다녀온 날짜", "", .text, [""]),
            ("다녀온 시간", "복수 선택 가능", .button, ["아침", "점심", "저녁", "밤"]),
            ("교통 수단", "복수 선택 가능", .button, ["자차", "대중교통", "도보"]),
            ("출입 제한", "하나만 선택", .button, ["제한됨", "허락시 가능", "자유로움"])
        ]
    
    func bind(reactor: InsightReactor) {
        baseInfo = reactor.detail
        collectionView.reloadData()
        
        nextButtonView.nextButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                if owner.nextButtonView.isEnable {
                    owner.reactor?.action.onNext(
                        .tapBaseInfoConfirm(owner.baseInfo, owner.imageDataList)
                    )
                } else {
                    owner.showToast(message: "필수 항목을 모두 작성해주세요")
                }
            })
            .disposed(by: disposeBag)


        checkSectionState
            .subscribe(with: self, onNext: { owner, arr in
                owner.nextButtonView.nextButtonEnable(value: arr.filter { $0 == .done }.count == 8 ? true : false)
                owner.nextButtonView.nextButtonEnable(value: true)
            })
            .disposed(by: disposeBag)

        
     checkSectionState
         .subscribe(onNext: { [weak self] states in
             guard let self = self else { return }
             for section in 0..<states.count {
                 let indexPath = IndexPath(item: 0, section: section)
                 self.headerCheckIconProcessing(self.collectionView, indexPath: indexPath)
             }
         })
         .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.checkSectionState }
            .bind(to: checkSectionState)
            .disposed(by: disposeBag)
    }
    
    private func updateSectionState(index: Int, newState: TextFieldState) {
        self.reactor?.action.onNext(.updateSectionState(index, newState))
    }
    
    private func headerCheckIconProcessing(_ collectionView: UICollectionView, indexPath: IndexPath) {
        if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: indexPath.section)) as? BaseInfoHeaderCell {

            header.headerView.setState(checkSectionState.value[indexPath.section])
            header.configure(title: items[indexPath.section].header,
                                 script: items[indexPath.section].script)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension InsightBaseInfoViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items[section].itemData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.section].itemType
        switch item {
        case .text:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BaseInfoTextFieldCell.identifier, for: indexPath) as! BaseInfoTextFieldCell
            if indexPath.section == 1 {
                cell.setData(text: baseInfo.title)
            } else if indexPath.section == 3 {
                cell.setData(text: baseInfo.visitAt.replacingOccurrences(of: "-", with: "."))
            }
            
            cell.titleTextField.rx.text
                .subscribe(onNext: { [weak self] text in
                    guard let self = self else { return }
                    
                    if indexPath.section == 1 {
                        baseInfo.title = text ?? ""
                        updateSectionState(index: indexPath.section, newState: text != "" ? TextFieldState.done : TextFieldState.normal)
                    } else if indexPath.section == 3 {
                        baseInfo.visitAt = text.map { $0.replacingOccurrences(of: ".", with: "-") } ?? ""
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy.MM.dd"
                        
                        if dateFormatter.date(from: cell.titleTextField.text ?? "") == nil {
                            updateSectionState(index: indexPath.section, newState: TextFieldState.normal)
                        } else {
                            updateSectionState(index: indexPath.section, newState: TextFieldState.done)
                        }
                        
                    }
                })
                .disposed(by: cell.disposeBag)
            
            
            cell.didTappedClearButton = {
                self.updateSectionState(index: indexPath.section, newState: TextFieldState.normal)
            }
            
            if indexPath.section == 3 {
                cell.titleTextField.setConfigure(placeholderText: "예시) \(Date().toString().prefix(10).replacingOccurrences(of: "-", with: "."))", textfieldType: .dateInput)
            }
            
            return cell
            
        case .button:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BaseInfoButtonCell.identifier,
                for: indexPath
            ) as! BaseInfoButtonCell
            
            let itemArray = items[indexPath.section].itemData
            
            cell.configure(title: itemArray[indexPath.row])
            let selectedSetRelay = selectedIndexPaths[indexPath.section - 4]
            
            selectedSetRelay
                .map { selectedSet in
                    selectedSet.contains { $0 == indexPath } ? .selectedBorderStyle : .unselectedBorderStyle
                }
                .bind(to: cell.rx.commonButtonState)
                .disposed(by: disposeBag)
            
            switch indexPath.section {
            case 4:
                let indices = items[4].itemData.enumerated().compactMap { baseInfo.visitTimes.contains($0.element) ? $0.offset : nil }
                selectedSetRelay.accept(Set(indices.map { [4, $0] }))
                updateSectionState(index: indexPath.section, newState: baseInfo.visitTimes.isEmpty == false ? TextFieldState.done : TextFieldState.normal)
            case 5:
                let indices = items[5].itemData.enumerated().compactMap { baseInfo.visitMethods.contains($0.element) ? $0.offset : nil }
                selectedSetRelay.accept(Set(indices.map { [5, $0] }))
                updateSectionState(index: indexPath.section, newState: baseInfo.visitMethods.isEmpty == false ? TextFieldState.done : TextFieldState.normal)
            case 6:
                if let index = items[6].itemData.firstIndex(of: baseInfo.access.replacingOccurrences(of: "_", with: " ")) {
                    selectedSetRelay.accept(Set(arrayLiteral: IndexPath(row: index, section: 6)))
                    updateSectionState(index: indexPath.section, newState: baseInfo.access.isEmpty == false ? TextFieldState.done : TextFieldState.normal)
                }
            default:
                break
            }
            
            cell.buttonView.rx.tap
                .subscribe(onNext: { [weak self] in
                    guard let self else { return }
                    
                    var selectedSet = selectedSetRelay.value
                    
                    if indexPath.section == 6 {
                        // 단일 선택
                        if selectedSet.contains(indexPath) {
                            selectedSet.remove(indexPath) // 선택 해제
                        } else {
                            selectedSet = [indexPath] // 선택 변경
                        }
                    } else {
                        // 다중 선택
                        if selectedSet.contains(indexPath) {
                            selectedSet.remove(indexPath)
                        } else {
                            selectedSet.insert(indexPath)
                        }
                    }
                    
                    selectedSetRelay.accept(selectedSet)
                    
                    switch indexPath.section {
                    case 4:
                        if let visitTimes = reactor?.detail.visitTimes {
                            baseInfo.visitTimes = visitTimes
                        } else {
                            baseInfo.visitTimes = selectedSet.map { itemArray[$0.row] }
                        }
                        baseInfo.visitTimes = selectedSet.map { itemArray[$0.row] }
                        
                        updateSectionState(index: indexPath.section, newState: baseInfo.visitTimes.isEmpty == false ? TextFieldState.done : TextFieldState.normal)
                        
                    case 5:
                        baseInfo.visitMethods = selectedSet.map { itemArray[$0.row] }
                        updateSectionState(index: indexPath.section, newState: baseInfo.visitMethods.isEmpty == false ? TextFieldState.done : TextFieldState.normal)
                        
                    case 6:
                        baseInfo.access = selectedSet.map { itemArray[$0.row] }[safe: 0]?.replacingOccurrences(of: " ", with: "_") ?? ""
                        updateSectionState(index: indexPath.section, newState: baseInfo.access != "" ? TextFieldState.done : TextFieldState.normal)
                        
                        
                    default:
                        break
                    }
                })
                .disposed(by: cell.disposeBag)
            
            return cell
            
        case .image:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BaseInfoImageCell.identifier, for: indexPath) as! BaseInfoImageCell
            
            
            if imageDataList.isEmpty, let url = URL(string: baseInfo.mainImage) {
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    switch result {
                    case .success(let value):
                        Task { @MainActor in
                            self.imageDataList = [value.image]
                            cell.setImages(self.imageDataList)
                            self.updateSectionState(index: indexPath.section, newState: .done)
                        }
                    case .failure:
                        break
                    }
                }
            } else {
                cell.setImages(imageDataList)
            }
            
            cell.imageTapped
                .subscribe(onNext: { [weak self] in
                    guard let self else { return }
                    
                    let imageModal = BaseInfoViewBottomSheet()
                    imageModal.modalPresentationStyle = .overFullScreen
                    self.present(imageModal, animated: false)
                    
                    imageModal.onPhotosSelected = { [weak self] selectedImages in
                        guard let self else { return }

                        for image in selectedImages {
                            if self.imageDataList.count >= 10 { // 10장
                                self.imageDataList.removeLast()
                            }
                            self.imageDataList.insert(image, at: 0)
                        }

                        cell.setImages(self.imageDataList)
                        self.updateSectionState(index: indexPath.section, newState: .done)
                    }

                    imageModal.onCameraSelected = { [weak self] image in
                        guard let self else { return }

                        if self.imageDataList.count >= 10 {
                            self.imageDataList.removeLast()
                        }
                        self.imageDataList.insert(image, at: 0)

                        cell.setImages(self.imageDataList)
                        self.updateSectionState(index: indexPath.section, newState: .done)
                    }

                })
                .disposed(by: disposeBag)
            
            cell.imageDeleted
                .subscribe(onNext: { [weak self] deletedIndex in
                    guard let self else { return }
                    
                    self.imageDataList.remove(at: deletedIndex)
                    cell.setImages(self.imageDataList)
                    
                    let newState: TextFieldState = self.imageDataList.isEmpty ? .normal : .done
                    self.updateSectionState(index: indexPath.section, newState: newState)
                })
                .disposed(by: disposeBag)
            
            return cell
            
        case .address:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BaseInfoAddressCell.identifier, for: indexPath) as! BaseInfoAddressCell
            
            if indexPath.row == 0 {
                baseInfo.address.siDo == ""
                ? cell.configure(title: "지번 주소")
                : cell.setData(title: baseInfo.address.toString())

            } else {
                baseInfo.apartmentComplex.name == ""
                ? cell.configure(title: "아파트 단지 명")
                : cell.setData(title: baseInfo.apartmentComplex.name)
            }
            
            cell.buttonAction = { result in
                let webViewController = WebViewController()
                self.present(webViewController, animated: true, completion: nil)
                
                webViewController.onAddressSelected = { [self] data in
                    
                    if let jibunAddress = (data["jibunAddress"]) as? String {
                        print("jibunAddress: \(jibunAddress)")
                        let splited = jibunAddress.split(separator: " ")
                        baseInfo.address.siDo = String(splited[safe: 0] ?? "")
                        baseInfo.address.siGunGu = String(splited[safe: 1] ?? "")
                        baseInfo.address.eupMyeonDong = String(splited[safe: 2] ?? "")
                        baseInfo.address.buildingNumber = String(splited[safe: 3] ?? "")
                        
                        insightService.getCoordinates(address: jibunAddress) { [self] latitude, longitude in
                            baseInfo.address.latitude = latitude
                            baseInfo.address.longitude = longitude
                            print("Latitude: \(latitude ?? 0), Longitude: \(longitude ?? 0)")
                        }
                    }
                    
                    if self.baseInfo.address.siDo != "서울" {
                        DispatchQueue.main.async {
                            self.showAlert(text: "지금은 서울 지역만 서비스가 가능합니다.", type: .confirmOnly, dimAction: false , comfrimAction: {
                                self.baseInfo.address = Address(siDo: "", siGunGu: "", eupMyeonDong: "", buildingNumber: "")
                                self.baseInfo.apartmentComplex.name = ""
                                collectionView.reloadSections(IndexSet([2]))
                            })
                        }
                        return
                    }
                    
                    if let buildingName = (data["buildingName"]) as? String {
                        baseInfo.apartmentComplex.name = buildingName
                    }

                    DispatchQueue.main.async {
                        self.collectionView.reloadSections(IndexSet(integer: 2))
                    }
                }
            }
            
            updateSectionState(index: indexPath.section, newState: baseInfo.apartmentComplex.name != "" ? TextFieldState.done : TextFieldState.normal)
            
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension InsightBaseInfoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BaseInfoHeaderCell.identifier, for: indexPath) as! BaseInfoHeaderCell

            headerView.headerView.setState(checkSectionState.value[indexPath.section])
            headerView.configure(title: items[indexPath.section].header,
                                 script: items[indexPath.section].script)
            
            return headerView
        } else if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableFooter(forIndexPath: indexPath, footerType: InsightTotalAppraisalFooterView.self)
            footer.config(title: "인사이트 요약*")
            footer.setPlaceHolder(text: "예시)\n지하철역과 도보 10분 거리로 접근성이 좋지만, 근처 공사로 소음 문제가 있을 수 있을 것 같아요. 하지만 단지 내 공원이 잘 조성되어 있어 가족 단위 거주자에게 적합할 것 같아요")
            footer.customTextView.text = baseInfo.summary
            updateSectionState(index: 7, newState: baseInfo.summary != "" ? TextFieldState.done : TextFieldState.normal)
            footer.delegate = self
            
            return footer
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == items.count - 1 {
            return CGSize(width: collectionView.bounds.width, height: 300)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = indexPath.section
        
        switch section {
        case 1, 2, 3:
            let width = collectionView.bounds.width - 40
            return CGSize(width: width, height: 52)
        case 4, 5, 6:
            let width = (collectionView.bounds.width - 40 - 10) / 2
            return CGSize(width: width, height: 52)
        default:
            let width = collectionView.bounds.width - 40
            return CGSize(width: width, height: 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return UIEdgeInsets(top: 28, left: 20, bottom: 40, right: 20)
        case 7:
            return UIEdgeInsets(top: 8, left: 20, bottom: 120, right: 20)
        default:
            return UIEdgeInsets(top: 8, left: 20, bottom: 40, right: 20)
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func didTapButton(title: String, text: String) {
        let childVC = CommonTextViewViewComtroller(title: title, text: text)
        
        childVC.onDataSend = { [weak self] data in
            guard let self = self else { return }
            
            baseInfo.summary = data
            updateSectionState(index: 7, newState: baseInfo.summary != "" ? TextFieldState.done : TextFieldState.normal)
            let lastSection = self.items.count - 1
            let footerIndexPath = IndexPath(item: 0, section: lastSection)
            self.collectionView.reloadSections(IndexSet(integer: footerIndexPath.section))
        }
        navigationController?.pushViewController(childVC, animated: true)
    }
}
