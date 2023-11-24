//
//  FTypeBusinessAlert.swift
//  FTypePopAlert
//
//  Created by pulei yu on 2023/10/31.
//

import Foundation
import Kingfisher
import UIKit
import WebKit

public struct FTypeBusinessAlertConfig {
    public static let contentSizeKP = "scrollView.contentSize"
    /// 按钮的高度
    public static var buttonHeight: CGFloat = 49
    /// 视图弹窗的宽度
    public static var containerWidth: CGFloat = 320
    /// 通常为背景的高度
    public static var basicHeight: CGFloat = 140
    /// 分割线的颜色
    public static var buttonSeperatorColor: UIColor = UIColor.lightGray.withAlphaComponent(0.2)
}

open class FTypeBusinessAlert: FTypePopAlert {
    public var model: FTypeBusinessModel!

    open lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = UIColor.lightGray
        btn.addTarget(self, action: #selector(tapClose), for: .touchUpInside)
        return btn
    }()

    open lazy var bgImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()

    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    open lazy var webView: WKWebView = {
        let web = WKWebView()
        web.backgroundColor = .clear
        web.scrollView.showsVerticalScrollIndicator = false
        web.scrollView.showsHorizontalScrollIndicator = false
        web.scrollView.backgroundColor = .clear
        web.scrollView.bounces = false
        web.isOpaque = false
        web.clipsToBounds = true
        web.addObserver(self, forKeyPath: FTypeBusinessAlertConfig.contentSizeKP, options: .new, context: nil)
        return web
    }()

    public lazy var buttonView: UIView = {
        let view = UIView()
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()

    public lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.5
        return view
    }()

    public var buttons: [UIButton] = []

    override open func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        loadWebContent()
    }

    @objc open func tapClose() {
        clearObserver()
        dismiss(animated: true)
    }

    @objc open func tapButton(_ sender: UIButton) {
    }

    @objc open func clearObserver() {
        __timer?.cancel()
        __timer = nil
        webView.removeObserver(self, forKeyPath: FTypeBusinessAlertConfig.contentSizeKP)
    }

    deinit {
        print("------>deinit", self.classForCoder.description())
    }

    private var __webHeight: CGFloat = -1
    private var __timer: DispatchSourceTimer?

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == FTypeBusinessAlertConfig.contentSizeKP else { return }

        let contentH = webView.scrollView.contentSize.height
        guard __webHeight != contentH else { return }

        __webHeight = contentH
        __timer?.cancel()
        let ts = DispatchSource.makeTimerSource()
        ts.schedule(deadline: .now() + 0.1, repeating: .infinity)
        ts.setEventHandler {
            DispatchQueue.main.async {
                self.webView.snp.updateConstraints { $0.height.equalTo(contentH) }
                let h = FTypeBusinessAlertConfig.basicHeight + CGFloat(self.buttons.count) * FTypeBusinessAlertConfig.buttonHeight + contentH
                self.containerView.frame.size.height = h
                if self.isViewLoaded {
                    self.containerView.center = self.view.center
                }
            }
        }
        ts.activate()
        __timer = ts
    }

    open func configureAppearance() {
        containerView.backgroundColor = .clear
        contentView.backgroundColor = .clear

        if let url = URL(string: model.icon) {
            bgImageView.kf.setImage(with: url)
        }
        contentView.addSubview(bgImageView)
        bgImageView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(FTypeBusinessAlertConfig.basicHeight)
        }

        titleLabel.text = model.title
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(80)
        }
        contentView.addSubview(webView)
        webView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.equalTo(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(10)
        }

        var preview: UIView?
        contentView.addSubview(buttonView)
        buttonView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(CGFloat(model.buttons.count) * FTypeBusinessAlertConfig.buttonHeight)
        }
        for btn in model.buttons {
            let button = UIButton()
            buttons.append(button)
            button.setTitleColor(btn.color, for: .normal)
            button.setTitle(btn.title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            button.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside)
            buttonView.addSubview(button)
            button.snp.makeConstraints {
                $0.left.right.equalToSuperview()
                $0.height.equalTo(FTypeBusinessAlertConfig.buttonHeight)
                if preview == nil {
                    $0.bottom.equalToSuperview()
                } else {
                    $0.bottom.equalTo(preview!.snp.top)
                }
            }
            let line = UIView()
            line.backgroundColor = FTypeBusinessAlertConfig.buttonSeperatorColor
            containerView.addSubview(line)
            line.snp.makeConstraints {
                $0.left.right.equalToSuperview()
                $0.bottom.equalTo(button.snp.top)
                $0.height.equalTo(0.5)
            }
            preview = button
        }
        contentView.addSubview(closeButton)
        closeButton.snp.remakeConstraints {
            $0.width.height.equalTo(40)
            $0.top.right.equalToSuperview()
        }
        containerView.frame.size = CGSize(width: FTypeBusinessAlertConfig.containerWidth, height: FTypeBusinessAlertConfig.containerWidth)
    }

    public func loadWebContent() {
        var html = ""
        if model.html.isEmpty == false {
            html = paddingHtml(body: model.html)
        } else if model.webview.isEmpty == false {
            html = model.webview
        }
        webView.loadHTMLString(html, baseURL: nil)
    }

    public func paddingHtml(body: String) -> String {
        let html = """
        <!doctype html>
        <html>
        <head>
        <meta charset="utf-8">
        <title></title>
        <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, width=device-width, user-scalable=0" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <style>
        body{background:rgba(0,0,0,0)}
        </style>
        </head>
        <body>
        \(body)
        </body>
        </html>
        """
        return html
    }
}
