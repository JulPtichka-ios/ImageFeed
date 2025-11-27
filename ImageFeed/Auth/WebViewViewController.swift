//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Воробьева Юлия on 23.10.2025.
//

import UIKit
import WebKit

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let clientIDQueryName = "client_id"
    static let redirectURIQueryName = "redirect_uri"
    static let responseTypeQueryName = "response_type"
    static let scopeQueryName = "scope"
    static let responseTypeCode = "code"
    static let authorizeNativePath = "/oauth/authorize/native"
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!

    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        loadAuthView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [],
            changeHandler: { [weak self] _, _ in
                guard let self else { return }
                self.updateProgress()
            }
        )
        updateProgress()
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }

    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: WebViewConstants.clientIDQueryName, value: Constants.accessKey),
            URLQueryItem(name: WebViewConstants.redirectURIQueryName, value: Constants.redirectURI),
            URLQueryItem(name: WebViewConstants.responseTypeQueryName, value: WebViewConstants.responseTypeCode),
            URLQueryItem(name: WebViewConstants.scopeQueryName, value: Constants.accessScope)
        ]

        guard let url = urlComponents.url else {
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)

        updateProgress()
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == WebViewConstants.authorizeNativePath,
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == WebViewConstants.responseTypeCode }) {
            return codeItem.value
        } else {
            return nil
        }
    }
}
