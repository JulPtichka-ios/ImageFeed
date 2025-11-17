//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Воробьева Юлия on 13.11.2025.
//

import ProgressHUD
import UIKit

enum UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }

    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }

    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
