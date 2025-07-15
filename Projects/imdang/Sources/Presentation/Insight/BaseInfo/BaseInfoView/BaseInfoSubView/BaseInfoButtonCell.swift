//
//  BaseInfoButtonCell.swift
//  imdang
//
//  Created by daye on 12/29/24.
//
import UIKit
import RxSwift

class BaseInfoButtonCell: UICollectionViewCell {
    static let identifier = "BaseInfoButtonCell"
    
    let buttonView = CommonButton(title: ""
                                          ,initialButtonType: .unselectedBorderStyle
                                          ,radius: 8)
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        layout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        contentView.addSubview(buttonView)
        buttonView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(title: String) {
        buttonView.setButtonTitle(title: title)
    }    
}

extension Reactive where Base: BaseInfoButtonCell {
    var commonButtonState: Binder<CommonButtonType> {
        return Binder(self.base) { cell, state in
            cell.buttonView.setState(state)
        }
    }
}
