//
//  KakaoShareService.swift
//  PayRit
//
//  Created by 임대진 on 4/17/24.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKShare
import KakaoSDKTemplate
import SwiftUI


enum KakaoLinkType {
    case app(url: URL)
    case web(url: URL)
    case err
}

final class KakaoShareService {
    func insightKakaoShare(title: String, insightId: String, imageUrl: String, completion: @escaping (KakaoLinkType) -> ()) {
        let link = Link(webUrl: URL(string: "https://itunes.apple.com/app/id6738302589"))
        let appLink = Link(androidExecutionParams: ["path": "insight", "insightId": insightId],
                           iosExecutionParams: ["path": "insight", "insightId": insightId])
        
        let appButton = Button(title: "앱에서 보기", link: appLink)
        
        let content = Content(title: title,
                              imageUrl: URL(string: imageUrl),
                              imageHeight: 300,
                              link: link)
        
        let template = FeedTemplate(content: content, buttons: [appButton])
        
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(template)) {
            if let templateJsonObject = SdkUtils.toJsonObject(templateJsonData) {
                if ShareApi.isKakaoTalkSharingAvailable() {
                    ShareApi.shared.shareDefault(templateObject: templateJsonObject) {(linkResult, error) in
                        if let error = error {
                            print("error : \(error)")
                            completion(.err)
                        } else {
                            print("defaultLink(templateObject:\(templateJsonObject)) success.")
                            guard let linkResult = linkResult else { return }
                            completion(.app(url: linkResult.url))
                        }
                    }
                    
                } else {
                    print("카카오톡 미설치")
                    if let url = ShareApi.shared.makeDefaultUrl(templateObject: templateJsonObject) {
                        completion(.web(url: url))
                    }
                }
            }
        }
    }
}
