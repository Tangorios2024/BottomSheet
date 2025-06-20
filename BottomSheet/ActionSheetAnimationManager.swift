//
//  ActionSheetAnimationManager.swift
//  BottomSheet
//
//  Created by 汤振治 on 2025/6/20.
//

import UIKit

// MARK: - Animation Manager
/// 动画管理器 - 专门处理Action Sheet的动画，遵循单一职责原则
class ActionSheetAnimationManager: NSObject, ActionSheetAnimatable {
    
    // MARK: - Properties
    private let configuration: ActionSheetConfigurable
    private weak var containerView: UIView?
    private weak var contentView: UIView?
    private weak var backgroundView: UIView?
    private var heightConstraint: NSLayoutConstraint?
    private weak var topConstraint: NSLayoutConstraint?
    private var isUsingTopConstraint: Bool = false
    
    // MARK: - Initializer
    init(configuration: ActionSheetConfigurable) {
        self.configuration = configuration
        super.init()
    }
    
    // MARK: - Setup
    func setupViews(containerView: UIView, contentView: UIView, backgroundView: UIView, heightConstraint: NSLayoutConstraint) {
        self.containerView = containerView
        self.contentView = contentView
        self.backgroundView = backgroundView
        self.heightConstraint = heightConstraint
    }

    // 获取安全区域背景视图
    private var safeAreaBackgroundView: UIView? {
        return containerView?.subviews.first { view in
            // 查找不是backgroundView和contentView的其他视图，很可能是safeAreaBackgroundView
            view != backgroundView && view != contentView && view.backgroundColor != UIColor.black.withAlphaComponent(0.5)
        }
    }

    func updateBottomConstraint(_ constraint: NSLayoutConstraint) {
        // 这个方法用于更新底部约束的引用，如果需要的话
        // 目前动画管理器主要使用heightConstraint，所以这里暂时不需要存储bottomConstraint
    }

    func updateConstraintsForSourceView(topConstraint: NSLayoutConstraint?, heightConstraint: NSLayoutConstraint?) {
        self.topConstraint = topConstraint
        self.heightConstraint = heightConstraint
        self.isUsingTopConstraint = topConstraint != nil
    }
    
    // MARK: - ActionSheetAnimatable
    func animateToHeight(_ height: CGFloat, completion: ((Bool) -> Void)?) {
        guard let heightConstraint = heightConstraint else {
            completion?(false)
            return
        }
        
        heightConstraint.constant = height
        
        UIView.animate(
            withDuration: configuration.animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                self.containerView?.layoutIfNeeded()
            },
            completion: completion
        )
    }
    
    func animatePresentation(completion: ((Bool) -> Void)?) {
        guard let containerView = containerView,
              let contentView = contentView,
              let backgroundView = backgroundView else {
            completion?(false)
            return
        }

        // 初始状态设置
        backgroundView.alpha = 0
        contentView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)

        // 如果有安全区域背景视图，也设置初始状态
        if let safeAreaView = safeAreaBackgroundView {
            safeAreaView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
        }

        // 执行展示动画
        UIView.animate(
            withDuration: configuration.animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut],
            animations: {
                backgroundView.alpha = 1
                contentView.transform = .identity

                // 安全区域背景视图也一起动画
                if let safeAreaView = self.safeAreaBackgroundView {
                    safeAreaView.transform = .identity
                }
            },
            completion: completion
        )
    }
    
    func animateDismissal(completion: ((Bool) -> Void)?) {
        guard let containerView = containerView,
              let contentView = contentView,
              let backgroundView = backgroundView else {
            completion?(false)
            return
        }

        UIView.animate(
            withDuration: configuration.animationDuration,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.3,
            options: [.curveEaseIn],
            animations: {
                backgroundView.alpha = 0
                contentView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)

                // 安全区域背景视图也一起动画
                if let safeAreaView = self.safeAreaBackgroundView {
                    safeAreaView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
                }
            },
            completion: completion
        )
    }
}

// MARK: - Additional Animation Methods
extension ActionSheetAnimationManager {
    
    /// 带有弹性效果的高度动画
    func animateToHeightWithBounce(_ height: CGFloat, completion: ((Bool) -> Void)?) {
        guard let heightConstraint = heightConstraint else {
            completion?(false)
            return
        }
        
        heightConstraint.constant = height
        
        UIView.animate(
            withDuration: configuration.animationDuration * 1.2,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                self.containerView?.layoutIfNeeded()
            },
            completion: completion
        )
    }
    
    /// 快速动画（用于手势跟随）
    func animateToHeightQuickly(_ height: CGFloat, completion: ((Bool) -> Void)?) {
        guard let heightConstraint = heightConstraint else {
            completion?(false)
            return
        }
        
        heightConstraint.constant = height
        
        UIView.animate(
            withDuration: configuration.animationDuration * 0.5,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.containerView?.layoutIfNeeded()
            },
            completion: completion
        )
    }
    
    /// 立即更新高度（无动画，用于手势拖拽过程中）
    func updateHeightImmediately(_ height: CGFloat) {
        heightConstraint?.constant = height
        containerView?.layoutIfNeeded()
    }
    
    /// 添加阴影动画
    func animateShadow(show: Bool) {
        guard let contentView = contentView else { return }
        
        let targetOpacity: Float = show ? configuration.shadowOpacity : 0
        
        UIView.animate(withDuration: configuration.animationDuration * 0.5) {
            contentView.layer.shadowOpacity = targetOpacity
        }
    }
}

// MARK: - Animation State
extension ActionSheetAnimationManager {
    
    /// 检查是否正在执行动画
    var isAnimating: Bool {
        return contentView?.layer.animationKeys()?.isEmpty == false
    }
    
    /// 停止所有动画
    func stopAllAnimations() {
        containerView?.layer.removeAllAnimations()
        contentView?.layer.removeAllAnimations()
        backgroundView?.layer.removeAllAnimations()
    }
}
