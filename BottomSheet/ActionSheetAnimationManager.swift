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
    private var sourceViewFrame: CGRect = .zero
    
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

    func updateConstraintsForSourceView(topConstraint: NSLayoutConstraint?, heightConstraint: NSLayoutConstraint?, sourceFrame: CGRect = .zero) {
        self.topConstraint = topConstraint
        self.heightConstraint = heightConstraint
        self.sourceViewFrame = sourceFrame
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

        // 检查是否使用了topConstraint（表示从sourceView位置启动）
        if isUsingTopConstraint {
            animatePresentationFromSourceView(completion: completion)
        } else {
            animateStandardPresentation(completion: completion)
        }
    }

    private func animateStandardPresentation(completion: ((Bool) -> Void)?) {
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

    private func animatePresentationFromSourceView(completion: ((Bool) -> Void)?) {
        guard let containerView = containerView,
              let contentView = contentView,
              let backgroundView = backgroundView,
              let heightConstraint = heightConstraint,
              let topConstraint = topConstraint else {
            completion?(false)
            return
        }

        // 初始状态设置
        backgroundView.alpha = 0

        // 执行扩展动画：同时改变位置、高度和背景透明度
        UIView.animate(
            withDuration: configuration.animationDuration * 1.2, // 稍微延长动画时间
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.3,
            options: [.curveEaseOut],
            animations: {
                // 背景渐入
                backgroundView.alpha = 1

                // 移动到底部位置
                topConstraint.constant = containerView.bounds.height - self.configuration.defaultHeight

                // 高度扩展到目标尺寸
                heightConstraint.constant = self.configuration.defaultHeight
                containerView.layoutIfNeeded()

                // 安全区域背景视图也一起动画
                if let safeAreaView = self.safeAreaBackgroundView {
                    safeAreaView.alpha = 1
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

        // 检查是否使用topConstraint（从sourceView启动）
        if isUsingTopConstraint {
            animateDismissalToSourceView(completion: completion)
        } else {
            animateStandardDismissal(completion: completion)
        }
    }

    private func animateStandardDismissal(completion: ((Bool) -> Void)?) {
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

    private func animateDismissalToSourceView(completion: ((Bool) -> Void)?) {
        guard let containerView = containerView,
              let contentView = contentView,
              let backgroundView = backgroundView,
              let topConstraint = topConstraint,
              let heightConstraint = heightConstraint else {
            completion?(false)
            return
        }

        // 创建一个临时的floating view样式视图
        let tempFloatingView = createTempFloatingView()
        tempFloatingView.alpha = 0
        containerView.addSubview(tempFloatingView)

        // 设置临时视图的约束，初始位置在ActionSheet内容区域
        tempFloatingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tempFloatingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tempFloatingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tempFloatingView.widthAnchor.constraint(equalToConstant: sourceViewFrame.width),
            tempFloatingView.heightAnchor.constraint(equalToConstant: sourceViewFrame.height)
        ])

        containerView.layoutIfNeeded()

        let animConfig = configuration.dismissalViewConfiguration.dismissalAnimationConfig

        // 第一阶段：隐藏ActionSheet内容，显示临时floating view
        UIView.animate(
            withDuration: animConfig.contentHideDuration,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                // 隐藏ActionSheet的内容
                contentView.subviews.forEach { subview in
                    if subview != tempFloatingView {
                        subview.alpha = 0
                    }
                }

                // 显示临时floating view
                tempFloatingView.alpha = 1
            },
            completion: { _ in
                // 第二阶段：收缩到sourceView位置和大小
                UIView.animate(
                    withDuration: animConfig.shrinkDuration,
                    delay: 0,
                    usingSpringWithDamping: 0.8,
                    initialSpringVelocity: 0.3,
                    options: [.curveEaseIn],
                    animations: {
                        // 背景渐出
                        backgroundView.alpha = 0

                        // 动画回到sourceView的原始位置和大小
                        topConstraint.constant = self.sourceViewFrame.minY
                        heightConstraint.constant = self.sourceViewFrame.height
                        containerView.layoutIfNeeded()

                        // 安全区域背景视图也一起动画
                        if let safeAreaView = self.safeAreaBackgroundView {
                            safeAreaView.alpha = 0
                        }
                    },
                    completion: { _ in
                        // 第三阶段：短暂停留，然后完全消失
                        UIView.animate(
                            withDuration: animConfig.finalFadeDuration,
                            delay: animConfig.pauseDuration,
                            options: [.curveEaseIn],
                            animations: {
                                tempFloatingView.alpha = 0
                                tempFloatingView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                            },
                            completion: completion
                        )
                    }
                )
            }
        )
    }

    private func createTempFloatingView() -> UIView {
        let dismissalConfig = configuration.dismissalViewConfiguration
        let content = dismissalConfig.dismissalViewContent
        let style = dismissalConfig.dismissalViewStyle

        let container = UIView()
        container.backgroundColor = style.backgroundColor
        container.layer.cornerRadius = style.cornerRadius
        container.layer.shadowColor = style.shadowConfig.color.cgColor
        container.layer.shadowOpacity = style.shadowConfig.opacity
        container.layer.shadowOffset = style.shadowConfig.offset
        container.layer.shadowRadius = style.shadowConfig.radius

        // 创建内容标签
        let label = UILabel()
        if let emoji = content.emoji {
            label.text = "\(emoji) \(content.text)"
        } else {
            label.text = content.text
        }
        label.font = content.font
        label.textColor = content.textColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: style.padding.left),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -style.padding.right),
            label.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: style.padding.top),
            label.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -style.padding.bottom)
        ])

        return container
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
