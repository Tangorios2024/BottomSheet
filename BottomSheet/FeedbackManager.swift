//
//  FeedbackManager.swift
//  BottomSheet
//
//  Created by 汤振治 on 2025/6/20.
//

import UIKit

// MARK: - Feedback Manager Delegate
protocol FeedbackManagerDelegate: AnyObject {
    func feedbackManager(_ manager: FeedbackManager, didSubmitFeedback feedback: FeedbackData)
    func feedbackManagerDidCancel(_ manager: FeedbackManager)
}

// MARK: - Feedback State
enum FeedbackState {
    case floating
    case expanded
    case dismissed
}

// MARK: - Feedback Manager
/// 反馈管理器 - 负责协调悬浮视图和完整表单之间的状态切换
class FeedbackManager: NSObject {
    
    // MARK: - Properties
    weak var delegate: FeedbackManagerDelegate?
    
    private(set) var currentState: FeedbackState = .dismissed
    private var currentRating: Int = 0
    
    // MARK: - UI Components
    private var floatingView: FloatingFeedbackView?
    private var actionSheet: ActionSheetViewController?
    private var feedbackFormController: FeedbackFormViewController?
    
    // MARK: - Configuration
    private let floatingViewBottomMargin: CGFloat = 100
    private let animationDuration: TimeInterval = 0.3
    
    // MARK: - Public Methods
    func showFloatingFeedback(in viewController: UIViewController) {
//        guard currentState == .dismissed else { return }
        
        currentState = .floating
        
        // 创建悬浮视图
        let floatingView = FloatingFeedbackView()
        floatingView.delegate = self
        floatingView.translatesAutoresizingMaskIntoConstraints = false
        
        self.floatingView = floatingView
        
        // 添加到视图层次结构
        viewController.view.addSubview(floatingView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            floatingView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            floatingView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            floatingView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -floatingViewBottomMargin)
        ])
        
        // 添加进入动画
        floatingView.alpha = 0
        floatingView.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            floatingView.alpha = 1
            floatingView.transform = .identity
        }
    }
    
    func expandToFullForm(from viewController: UIViewController) {
        guard currentState == .floating, let floatingView = floatingView else { return }

        currentState = .expanded

        // 创建完整表单控制器
        let feedbackFormController = FeedbackFormViewController(initialRating: currentRating)
        feedbackFormController.delegate = self
        self.feedbackFormController = feedbackFormController

        // 创建ActionSheet配置 - 调整为适合反馈表单的尺寸
        let config = ActionSheetConfigurationBuilder()
            .defaultHeight(450)
            .maxHeight(600)
            .animationDuration(0.5)
            .backgroundColor(.systemBackground)
            .build()

        // 创建ActionSheet
        let actionSheet = ActionSheetViewController(configuration: config)
        actionSheet.delegate = self
        actionSheet.setContentViewController(feedbackFormController)
        self.actionSheet = actionSheet

        // 关键：使用悬浮视图作为sourceView，实现从悬浮视图位置展开的效果
        actionSheet.present(from: viewController, sourceView: floatingView, animated: true)

        // 延迟隐藏悬浮视图，让转场动画更自然
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hideFloatingView(animated: true)
        }
    }
    
    func dismissFeedback(animated: Bool = true) {
        switch currentState {
        case .floating:
            hideFloatingView(animated: animated)
        case .expanded:
            actionSheet?.dismiss(animated: animated)
        case .dismissed:
            break
        }
        
        currentState = .dismissed
        currentRating = 0
    }
    
    func updateRating(_ rating: Int) {
        currentRating = rating
        floatingView?.setRating(rating, animated: true)
    }
}

// MARK: - Private Methods
private extension FeedbackManager {
    
    func hideFloatingView(animated: Bool) {
        guard let floatingView = floatingView else { return }
        
        if animated {
            UIView.animate(withDuration: animationDuration, animations: {
                floatingView.alpha = 0
                floatingView.transform = CGAffineTransform(translationX: 0, y: 50)
            }) { _ in
                floatingView.removeFromSuperview()
                self.floatingView = nil
            }
        } else {
            floatingView.removeFromSuperview()
            self.floatingView = nil
        }
    }
    
    func cleanupActionSheet() {
        actionSheet = nil
        feedbackFormController = nil
    }
}

// MARK: - FloatingFeedbackViewDelegate
extension FeedbackManager: FloatingFeedbackViewDelegate {
    
    func floatingFeedbackViewDidTapExpand(_ view: FloatingFeedbackView) {
        guard let viewController = view.findViewController() else { return }
        expandToFullForm(from: viewController)
    }
    
    func floatingFeedbackView(_ view: FloatingFeedbackView, didSelectRating rating: Int) {
        currentRating = rating
    }
    
    func floatingFeedbackViewDidSubmitQuickRating(_ view: FloatingFeedbackView, rating: Int) {
        let feedback = FeedbackData(rating: rating, comment: "")
        delegate?.feedbackManager(self, didSubmitFeedback: feedback)
        dismissFeedback(animated: true)
    }
}

// MARK: - FeedbackFormViewControllerDelegate
extension FeedbackManager: FeedbackFormViewControllerDelegate {
    
    func feedbackFormViewController(_ controller: FeedbackFormViewController, didSubmitFeedback feedback: FeedbackData) {
        delegate?.feedbackManager(self, didSubmitFeedback: feedback)
        dismissFeedback(animated: true)
    }
    
    func feedbackFormViewControllerDidCancel(_ controller: FeedbackFormViewController) {
        // 返回到悬浮状态
        actionSheet?.dismiss(animated: true)
    }
}

// MARK: - ActionSheetDelegate
extension FeedbackManager: ActionSheetDelegate {
    
    func actionSheetWillPresent(_ actionSheet: ActionSheetPresentable) {
        // ActionSheet即将展示
    }
    
    func actionSheetDidPresent(_ actionSheet: ActionSheetPresentable) {
        // ActionSheet已经展示
    }
    
    func actionSheetWillDismiss(_ actionSheet: ActionSheetPresentable) {
        // ActionSheet即将消失
    }
    
    func actionSheetDidDismiss(_ actionSheet: ActionSheetPresentable) {
        // 清理ActionSheet相关资源
        cleanupActionSheet()

        // 如果当前状态是展开状态，返回到悬浮状态
        if currentState == .expanded {
            currentState = .floating

            // 延迟重新显示悬浮视图，让dismissal动画完全完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }

                if let viewController = actionSheet as? UIViewController,
                   let presentingVC = viewController.presentingViewController {
                    self.showFloatingFeedback(in: presentingVC)

                    // 恢复之前的评分
                    if self.currentRating > 0 {
                        self.floatingView?.setRating(self.currentRating, animated: false)
                    }
                }
            }
        }
    }
    
    func actionSheet(_ actionSheet: ActionSheetPresentable, didChangeHeight height: CGFloat) {
        // 高度变化处理
    }
}

// MARK: - UIView Extension
extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
