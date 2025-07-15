//
//  BaseInfoViewBottomSheet.swift
//  imdang
//
//  Created by daye on 12/23/24.
//

import UIKit
import SnapKit
import Then
import PhotosUI

class BaseInfoViewBottomSheet: UIViewController, UINavigationControllerDelegate {

    var onPhotosSelected: (([UIImage]) -> Void)?
    var onCameraSelected: ((UIImage) -> Void)?

    private let backgroundView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }

    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }

    private let sheetTitle = UILabel().then {
        $0.text = "이미지 추가"
        $0.textColor = .grayScale900
        $0.font = .pretenSemiBold(18)
    }

    private let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .grayScale900
        $0.frame = .init(x: 0, y: 0, width: 20, height: 20)
    }

    private let photoLibraryButton = UIButton().then {
        $0.setTitle("앨범에서 선택", for: .normal)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.grayScale100.cgColor
        $0.setTitleColor(.grayScale700, for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        $0.titleLabel?.font = .pretenSemiBold(16)
    }

    private let cameraButton = UIButton().then {
        $0.setTitle("사진 촬영", for: .normal)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.grayScale100.cgColor
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        $0.setTitleColor(.grayScale700, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
    }

    private let imagePickerController = UIImagePickerController()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        showBottomSheet()
        setupLayout()
        setupActions()
        imagePickerController.delegate = self
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }

        view.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(237)
        }

        containerView.addSubview(sheetTitle)
        sheetTitle.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().inset(20)
        }

        containerView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(20)
        }

        containerView.addSubview(photoLibraryButton)
        photoLibraryButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(56)
            $0.top.equalTo(closeButton.snp.bottom).offset(24)
        }

        containerView.addSubview(cameraButton)
        cameraButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(40)
            $0.height.equalTo(56)
            $0.top.equalTo(photoLibraryButton.snp.bottom).offset(12)
        }
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(dismissBottomSheet), for: .touchUpInside)
        photoLibraryButton.addTarget(self, action: #selector(photoLibraryButtonTapped), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
    }

    @objc private func photoLibraryButtonTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 10
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    @objc private func cameraButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true, completion: nil)
        }
    }

    private func showBottomSheet() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 1
            self.containerView.frame.origin.y = self.view.frame.height - self.containerView.frame.height
            self.view.layoutIfNeeded()
        })
    }

    @objc private func dismissBottomSheet() {
        UIView.animate(withDuration: 0.1, animations: {
            self.backgroundView.alpha = 0
            self.containerView.frame.origin.y = self.view.frame.height
            self.view.layoutIfNeeded()
        }) { _ in
            self.dismiss(animated: false)
        }
    }
}

extension BaseInfoViewBottomSheet: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        var images: [UIImage] = []
        let dispatchGroup = DispatchGroup()

        for result in results {
            let provider = result.itemProvider
            if provider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                provider.loadObject(ofClass: UIImage.self) { (object, error) in
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.onPhotosSelected?(images)
            self.dismissBottomSheet()
        }
    }
}

extension BaseInfoViewBottomSheet: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            onCameraSelected?(image)
        }
        picker.dismiss(animated: true, completion: nil)
        dismissBottomSheet()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        dismissBottomSheet()
    }
}
