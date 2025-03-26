//
//  AreaModalViewController.swift
//  imdang
//
//  Created by 임대진 on 12/16/24.
//


import UIKit
import SnapKit
import RxSwift
import RxRelay

class AreaModalViewController: UIViewController {
    let selectedComplex = BehaviorRelay<String?>(value: nil)
    private var tableView: UITableView!
    private var complexes: [AptComplexByDistrict]?
    private let analyticsService = AnalyticsService.shared
    private let grabber = UIButton().then {
        $0.backgroundColor = .grayScale200
        $0.layer.cornerRadius = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.modalPresentationStyle = .pageSheet
        self.modalTransitionStyle = .coverVertical
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let sheetPresentationController = sheetPresentationController {
            sheetPresentationController.detents = [.medium(), .large()]
        }
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.rowHeight = 62
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(cell: AreaModalTableCell.self)
        
        view.addSubview(tableView)
        view.addSubview(grabber)
        
        grabber.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(52)
            $0.height.equalTo(6)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(grabber.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
    
    func config(complexes: [AptComplexByDistrict]?) {
        guard let complexes else { return }
        self.complexes = complexes
        setupTableView()
        tableView.reloadData()
    }
}

extension AreaModalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return complexes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, cellType: AreaModalTableCell.self)
        cell.selectionStyle = .none
        cell.config(apt: complexes?[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let name = complexes?[indexPath.row].apartmentComplexName {
            analyticsService.storagefilterClick(aptName: name)
        }
        selectedComplex.accept(complexes?[indexPath.row].apartmentComplexName)
        self.dismiss(animated: true)
    }
}
