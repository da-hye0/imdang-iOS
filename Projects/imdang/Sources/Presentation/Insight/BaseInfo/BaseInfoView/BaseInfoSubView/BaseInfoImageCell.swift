//
//  ImageCell.swift
//  imdang
//
//  Created by daye on 12/23/24.
//

import UIKit
import SnapKit
import RxSwift
import ReactorKit
import RxRelay


class BaseInfoImageCell: UICollectionViewCell {
    var disposeBag = DisposeBag()
    static let identifier = "BaseInfoImageCell"
    private let collectionView: UICollectionView
    private var images = [UIImage]()
    let imageTapped = PublishRelay<Void>()
    let imageDeleted = PublishRelay<Int>()

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)

        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ImageItemCell.self, forCellWithReuseIdentifier: ImageItemCell.identifier)
        collectionView.register(ImageAddCell.self, forCellWithReuseIdentifier: ImageAddCell.identifier)

        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }

        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }


    required init?(coder: NSCoder) { fatalError() }

    func setImages(_ images: [UIImage]) {
        self.images = images
        collectionView.reloadData()
    }

    func getImages() -> [UIImage] {
        return images
    }
}

extension BaseInfoImageCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(images.count + 1, 10)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            return CGSize(width: 100, height: 100)
        } else {
            return CGSize(width: 140, height: 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageAddCell.identifier, for: indexPath) as! ImageAddCell
            cell.addButton.rx.tap
                .bind(to: imageTapped)
                .disposed(by: cell.disposeBag)
            return cell
        } else {
            let imageIndex = indexPath.item - 1
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageItemCell.identifier, for: indexPath) as! ImageItemCell
            cell.imageView.image = images[imageIndex]
            
            cell.onDelete = { [weak self, weak collectionView] in
                guard let self, imageIndex < self.images.count else { return }
                self.images.remove(at: imageIndex)
                self.imageDeleted.accept(imageIndex)
                collectionView?.reloadData()
            }
            return cell
        }
    }
}

class ImageItemCell: UICollectionViewCell {
    var disposeBag = DisposeBag()
    static let identifier = "ImageItemCell"
    let imageView = UIImageView()
    let deleteButton = UIButton()

    var onDelete: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.snp.makeConstraints { $0.edges.equalToSuperview()}

        deleteButton.setImage(UIImage(resource: .imdangXmark), for: .normal)

        deleteButton.layer.cornerRadius = 10
        deleteButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(4)
            $0.size.equalTo(20)
        }

        deleteButton.rx.tap
            .bind { [weak self] in self?.onDelete?() }
            .disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) { fatalError() }
    
}

class ImageAddCell: UICollectionViewCell {
    var disposeBag = DisposeBag()
    static let identifier = "ImageAddCell"
    
    let addButton = UIButton(type: .custom)
    private let stackView = UIStackView()
    private let plusImageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupStyle()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints { $0.edges.equalToSuperview() }

        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.distribution = .equalCentering

        plusImageView.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        stackView.addArrangedSubview(plusImageView)
        stackView.addArrangedSubview(titleLabel)

        addButton.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func setupStyle() {
        plusImageView.image = UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        )
        plusImageView.tintColor = .grayScale700

        titleLabel.text = "이미지추가"
        titleLabel.font = .pretenSemiBold(12)
        titleLabel.textColor = .grayScale700

        addButton.layer.cornerRadius = 6
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = UIColor.grayScale100.cgColor
        addButton.backgroundColor = .white
    }
}

