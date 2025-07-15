//
//  MyPageViewController.swift
//  imdang
//
//  Created by daye on 1/12/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import ReactorKit

final class MyPageViewController: BaseViewController, View {

    private var info: MyPageResponse?
    
    var disposeBag = DisposeBag()
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let deleteAccountButton = CommonButton(title: "계정 탈퇴", initialButtonType: .unselectedBorderStyle).then {
        $0.setButtonTitleColor(color: .grayScale700)
    }
    
    private let navigationTitleLabel = UILabel().then {
        $0.font = .pretenSemiBold(18)
        $0.textColor = .grayScale900
        $0.text = "MY 페이지"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reactor?.action.onNext(.loadInfo)
    }
    
    init(reactor: MyPageReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .grayScale25
        
        configNavigationBarItem()
        setupTableView()
        addSubViews()
        layout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService().screenEvent(ScreenName: .mypage)
    }
   
    private func configNavigationBarItem() {
        customBackButton.isHidden = false
        leftNaviItemView.addSubview(navigationTitleLabel)
        navigationTitleLabel.snp.makeConstraints {
            $0.height.equalTo(20)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
        }
    }
    
    private func addSubViews() {
        [tableView, deleteAccountButton].forEach {view.addSubview($0)}
    }
    
    private func layout() {
        tableView.snp.makeConstraints {
            $0.topEqualToNavigationBottom(vc: self)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(deleteAccountButton.snp.top).offset(10)
        }
        
        deleteAccountButton.snp.makeConstraints {
            $0.height.equalTo(42)
            $0.width.equalTo(100)
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(50)
        }
    }

    private func setupTableView() {
        tableView.backgroundColor = .grayScale25
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none

        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.register(InfoCell.self, forCellReuseIdentifier: "InfoCell")
        tableView.register(TermsCell.self, forCellReuseIdentifier: "TermsCell")
    }
    
    func bind(reactor: MyPageReactor) {
        reactor.state.map { $0.myPageInfo }
            .subscribe(onNext: { [weak self] info in
                self?.info = info
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        deleteAccountButton.rx.tap
            .subscribe(onNext: {
                let vc =  DeleteAccountViewController()
                vc.hidesBottomBarWhenPushed = false
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state
                  .map { $0.isLogout }
                  .distinctUntilChanged()
                  .subscribe(onNext: { success in
                      if success {
                          (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeNavigationRootView(SigninViewController(alertType: .logout), animated: true)
                      } else {
                          print("Logout failed")
                      }
                  })
                  .disposed(by: disposeBag)
    }
}


// MARK: - set table
extension MyPageViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return 3
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.configure(name: info?.nickname ?? "임당님")
            cell.onLogoutButtonTapped = {
                self.showAlert(text: "로그아웃 시 서비스 사용이\n제한돼요. 그래도 로그아웃 할까요?", type: .cancellable) {
                    self.reactor?.action.onNext(.logout)
                } etcAction: { }
            }
            
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as? InfoCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            if indexPath.row == 0 {
                cell.configure(title: "작성한 인사이트", num: "\(info?.insightCount ?? 0)건")
            }
            return cell
            
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TermsCell", for: indexPath) as? TermsCell else {
                return UITableViewCell()
            }
            if indexPath.row == 0 {
                cell.configure(title: "서비스 소개")
            } else if indexPath.row == 1 {
                cell.configure(title: "서비스 이용 약관")
            } else {
                cell.selectionStyle = .none
                cell.configure(title: "버전 정보", version: "현재 버전 1.0.0")
            }
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 103
        case 1: return 62
        case 2: return 64
        default: return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let dividerView = UIView()
            dividerView.backgroundColor = .grayScale50
            return dividerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 2 ? 8 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            return UIView()
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 1 ? 12 : 0
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                let vc =  IntroViewController(type: .intro)
                vc.hidesBottomBarWhenPushed = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if indexPath.row == 1 {
                let vc = TermsViewController()
                vc.hidesBottomBarWhenPushed = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
