//
//  Network.swift
//  NetworkKit
//
//  Created by 임대진 on 11/25/24.
//

import Foundation
import RxSwift

internal import Alamofire

protocol Network {
    var session: Session { get }
    
    func request<E: Requestable>(with endpoint: E) -> Observable<E.Response>
    func requestOptional<E: Requestable>(with endpoint: E) -> Observable<E.Response?>
    func upload<E: MultipartRequestable>(with endpoint: E) -> Observable<Bool>
}
