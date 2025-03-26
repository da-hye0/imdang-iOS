//
//  TicketView.swift
//  imdang
//
//  Created by daye on 12/4/24.
//

import UIKit
import SnapKit
import Then

final class TicketView: UIView {
    
    private let iconImageView = UIImageView().then {
        $0.image = UIImage(named: "Ticket")
        $0.contentMode = .scaleAspectFit
    }
    
    private let textLabel = UILabel().then {
        $0.text = "보유 패스권"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .grayScale900
        $0.numberOfLines = 0
    }
    
    private let ticketNumberLabel = UILabel().then {
        $0.text = "0개"
        $0.font = .pretenSemiBold(16)
        $0.textColor = .mainOrange500
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .mainOrange50
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        [iconImageView, textLabel, ticketNumberLabel].forEach { addSubview($0) }
        
         iconImageView.snp.makeConstraints {
             $0.size.equalTo(CGSize(width: 20, height: 20))
             $0.centerY.equalToSuperview()
             $0.leading.equalToSuperview().inset(20)
         }
         
         textLabel.snp.makeConstraints {
             $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
             $0.centerY.equalToSuperview()
         }
      
        ticketNumberLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(couponCount: Int?) {
        ticketNumberLabel.text = "\(couponCount ?? 0)개"
    }
}
