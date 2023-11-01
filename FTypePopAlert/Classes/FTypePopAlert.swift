//
//  FTypePopAlert.swift
//  FTypePopAlert
//
//  Created by pulei yu on 2023/10/31.
//

import Foundation
import SnapKit
import UIKit

open class FTypePopAlert: UIViewController {
    public var fromBGColor: UIColor = .clear
    public var toBGColor: UIColor = UIColor.black.withAlphaComponent(0.2)
    public var dismissBlock: (() -> Void)?
    public var tapToDismiss = false

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = self
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open lazy var contentView = UIView()

    open lazy var containerView = UIView()

    public lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapSelf))
        tap.delegate = self
        return tap
    }()

    override open func viewDidLoad() {
        super.viewDidLoad()
        if tapToDismiss {
            view.addGestureRecognizer(tap)
        }
        configureUI()
    }

    open func adjustContainerFrame() {
        fatalError("unimplement \(#function) \(#line)")
    }
}

// MARK: - - Configure UI

extension FTypePopAlert {
    private func configureUI() {
        view.addSubview(containerView)
        containerView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.left.equalTo(containerView.safeAreaLayoutGuide.snp.left)
            $0.right.equalTo(containerView.safeAreaLayoutGuide.snp.right)
            $0.bottom.equalTo(containerView.safeAreaLayoutGuide.snp.bottom)
            $0.top.equalTo(containerView.safeAreaLayoutGuide.snp.top)
        }
    }
}

// MARK: gesture

extension FTypePopAlert: UIGestureRecognizerDelegate {
    @objc open func tapSelf() {
        dismiss(animated: true) {
            self.dismissBlock?()
        }
    }

    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let loc = gestureRecognizer.location(in: view)
        return containerView.frame.contains(loc) == false
    }
}

extension FTypePopAlert: UIViewControllerTransitioningDelegate {
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self
    }

    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self
    }
}

extension FTypePopAlert: UIViewControllerAnimatedTransitioning {
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let isPresenting = view.superview == nil
        if isPresenting {
            transitionContext.containerView.addSubview(view)
            adjustContainerFrame()
            containerView.center.x = view.bounds.width / 2
            containerView.frame.origin.y = view.bounds.height

            view.backgroundColor = fromBGColor
            UIView.animate(withDuration: 0.3) {
                self.view.backgroundColor = self.toBGColor
                self.containerView.center = .init(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            } completion: { _ in
                transitionContext.completeTransition(true)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.containerView.frame.origin.y = self.view.frame.height
            } completion: { _ in
                self.view.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }
}
