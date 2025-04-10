//
//  InsightDetailDefaultInfoTableCell.swift
//  imdang
//
//  Created by 임대진 on 1/13/25.
//
import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import NMapsMap

final class InsightDetailDefaultInfoTableCell: UITableViewCell {
    static let identifier = "InsightDetailDefaultInfoTableCell"
    
    private var address = ""
    
    private let naverMapView = NMFNaverMapView()
        
    private let addressTitleLabel = ImageTextLabel(horizonPadding: 0, spacing: 4).then {
        $0.customText.text = "단지 주소"
        $0.customText.textColor = .grayScale600
        $0.customText.font = .pretenMedium(14)
        
        $0.customImage.image = ImdangImages.Image(resource: .location)
        $0.customImage.tintColor = .grayScale600
        $0.imageSize = 16
    }
    
    private let addressLabel = UILabel().then {
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
        $0.numberOfLines = 0
    }
    
    private let dateTitleLabel = ImageTextLabel(horizonPadding: 0, spacing: 4).then {
        $0.customText.text = "임장 날짜 및 시간"
        $0.customText.textColor = .grayScale600
        $0.customText.font = .pretenMedium(14)
        
        $0.customImage.image = ImdangImages.Image(resource: .calendar)
        $0.customImage.tintColor = .grayScale600
        $0.imageSize = 16
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
    }
    
    private let transTitleLabel = ImageTextLabel(horizonPadding: 0, spacing: 4).then {
        $0.customText.text = "교통 수단"
        $0.customText.textColor = .grayScale600
        $0.customText.font = .pretenMedium(14)
        
        $0.customImage.image = ImdangImages.Image(resource: .car)
        $0.customImage.tintColor = .grayScale600
        $0.imageSize = 16
    }
    
    private let transLabel = UILabel().then {
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
    }
    
    private let accessTitleLabel = ImageTextLabel(horizonPadding: 0, spacing: 4).then {
        $0.customText.text = "출입 제한"
        $0.customText.textColor = .grayScale600
        $0.customText.font = .pretenMedium(14)
        
        $0.customImage.image = ImdangImages.Image(resource: .warning)
        $0.customImage.tintColor = .grayScale600
        $0.imageSize = 16
    }
    
    private let accessLabel = UILabel().then {
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
    }
    
    private let summaryTitleLabel = UILabel().then {
        $0.text = "인사이트 요약"
        $0.font = .pretenMedium(14)
        $0.textColor = .grayScale600
    }
    
    private let summaryLabel = UILabel().then {
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
        $0.numberOfLines = 0
    }
    
    private let descriptionImageView = UIImageView().then {
        $0.image = ImdangImages.Image(resource: .detailExchangeRequest)
        $0.contentMode = .scaleAspectFit
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
        makeConstraints()
        naverMapView.mapView.touchDelegate = self
    }
    
    override func prepareForReuse() {
        descriptionImageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        [addressTitleLabel, addressLabel, naverMapView, dateTitleLabel, dateLabel, transTitleLabel, transLabel, accessTitleLabel, accessLabel, summaryTitleLabel, summaryLabel, descriptionImageView].forEach { contentView.addSubview($0) }
    }
    
    private func makeConstraints() {
        addressTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(20)
        }
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(addressTitleLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        naverMapView.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        dateTitleLabel.snp.makeConstraints {
            $0.top.equalTo(naverMapView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(20)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(dateTitleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(20)
        }
        
        transTitleLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(20)
        }
        transLabel.snp.makeConstraints {
            $0.top.equalTo(transTitleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(20)
        }
        
        accessTitleLabel.snp.makeConstraints {
            $0.top.equalTo(transLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(20)
        }
        accessLabel.snp.makeConstraints {
            $0.top.equalTo(accessTitleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(20)
        }
        
        summaryTitleLabel.snp.makeConstraints {
            $0.top.equalTo(accessLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(20)
        }
        summaryLabel.snp.makeConstraints {
            $0.top.equalTo(summaryTitleLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    private func calculateLabelHeight(text: String) -> CGFloat {
        let width = UIScreen.main.bounds.width - 40
        let lineHeight = 22.4
        let font = UIFont.pretenMedium(16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]

        let boundingSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: boundingSize,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: attributes,
                                            context: nil)

        return ceil(boundingBox.height)
    }
    
    func config(info: InsightDetail, state: DetailExchangeState, isMyInsight: Bool) {
        address = "\(info.address.toString())"
        addressLabel.text = "\(info.address.toString())\n(\(info.apartmentComplex.name))"
        dateLabel.text = "\(info.visitAt) / \(info.visitTimes.joined(separator: ","))"
        transLabel.text = info.visitMethods.joined(separator: " ")
        accessLabel.text = info.access.replacingOccurrences(of: "_", with: " ")
        summaryLabel.setTextWithLineHeight(text: info.summary, lineHeight: 22.4)
        
        if let latitude = info.address.latitude, let longitude = info.address.longitude {
            setMapCenterAndAddMarker(latitude: latitude, longitude: longitude)
        }
        
        switch state {
        case .null:
            if isMyInsight {
                descriptionImageView.isHidden = true
            } else {
                descriptionImageView.image = ImdangImages.Image(resource: .detailExchangeRequest)
            }
        case .pending:
            if isMyInsight {
                descriptionImageView.image = ImdangImages.Image(resource: .detailWaiting)
            } else {
                descriptionImageView.image = ImdangImages.Image(resource: .detailRequestReply)
            }
        default:
            break
        }
        
        if state == .accepted || state == .null && isMyInsight {
            contentView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(608 + calculateLabelHeight(text: info.summary))
            }
        } else {
            contentView.snp.remakeConstraints {
                $0.top.equalToSuperview()
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(608 + calculateLabelHeight(text: info.summary) + 312).priority(999)
            }
            descriptionImageView.snp.makeConstraints {
                $0.top.equalTo(summaryLabel.snp.bottom).offset(32)
                $0.horizontalEdges.equalToSuperview()
            }
        }
    }
}

extension InsightDetailDefaultInfoTableCell: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        openNaverMapApp()
    }

    func mapView(_ mapView: NMFMapView, didLongTapMap latlng: NMGLatLng, point: CGPoint) {
    }
    
    private func setMapCenterAndAddMarker(latitude: Double, longitude: Double) {
        let latLng = NMGLatLng(lat: latitude, lng: longitude)
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: latLng)
        naverMapView.mapView.moveCamera(cameraUpdate)
        
        let marker = NMFMarker()
        marker.position = latLng
        marker.iconImage = NMFOverlayImage(image: ImdangImages.Image(resource: .mapMarker))
        marker.mapView = naverMapView.mapView
    }
    
    private func openNaverMapApp() {
        let urlStr = "nmap://search?query=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("네이버 지도 앱이 설치되어 있지 않습니다.")
            let appStoreURL = URL(string: "http://itunes.apple.com/app/id311867728?mt=8")!
            UIApplication.shared.open(appStoreURL)
        }
    }
}
