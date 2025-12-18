//
//  WebViewViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Julia Ios on 12.12.2025.
//

import UIKit
import WebKit

protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    
    func setProgressValue(_ value: Float)
    func setProgressHidden(_ isHidden: Bool)
    func load(request: URLRequest)
}

protocol WebViewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didUpdateProgress(_ newValue: Double)
    func decidePolicy(for navigationAction: WKNavigationAction,
                      decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
}
