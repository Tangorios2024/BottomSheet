//
//  ActionSheetProtocols.swift
//  BottomSheet
//
//  Created by 汤振治 on 2025/6/20.
//

import UIKit

// MARK: - Configuration Protocol
/// 配置协议 - 遵循接口隔离原则
protocol ActionSheetConfigurable {
    var defaultHeight: CGFloat { get }
    var halfScreenHeight: CGFloat { get }
    var maxHeight: CGFloat { get }
    var animationDuration: TimeInterval { get }
    var cornerRadius: CGFloat { get }
    var handleViewHeight: CGFloat { get }
    var backgroundColor: UIColor { get }
    var shadowOpacity: Float { get }
    var shadowRadius: CGFloat { get }
    var shadowOffset: CGSize { get }
    var handleColor: UIColor { get }
    var velocityThreshold: CGFloat { get }
    var extendToSafeArea: Bool { get }
    var safeAreaBackgroundColor: UIColor? { get }
    var sourceViewConfiguration: SourceViewConfigurable? { get }
    var dismissalViewConfiguration: DismissalViewConfigurable { get }
}

// MARK: - Gesture Handling Protocol
/// 手势处理协议 - 遵循接口隔离原则
protocol ActionSheetGestureHandling {
    func handlePanGesture(_ gesture: UIPanGestureRecognizer)
    func shouldTransitionToHeight(_ targetHeight: CGFloat, from currentHeight: CGFloat) -> CGFloat
}

// MARK: - Animation Protocol
/// 动画协议 - 遵循接口隔离原则
protocol ActionSheetAnimatable {
    func animateToHeight(_ height: CGFloat, completion: ((Bool) -> Void)?)
    func animatePresentation(completion: ((Bool) -> Void)?)
    func animateDismissal(completion: ((Bool) -> Void)?)
}

// MARK: - Delegate Protocol
/// 代理协议 - 用于通知外部状态变化
protocol ActionSheetDelegate: AnyObject {
    func actionSheetWillPresent(_ actionSheet: ActionSheetPresentable)
    func actionSheetDidPresent(_ actionSheet: ActionSheetPresentable)
    func actionSheetWillDismiss(_ actionSheet: ActionSheetPresentable)
    func actionSheetDidDismiss(_ actionSheet: ActionSheetPresentable)
    func actionSheet(_ actionSheet: ActionSheetPresentable, didChangeHeight height: CGFloat)
}

// MARK: - Main Protocol
/// 主要协议 - 组合其他协议，遵循依赖倒置原则
protocol ActionSheetPresentable: ActionSheetConfigurable, ActionSheetGestureHandling, ActionSheetAnimatable {
    var delegate: ActionSheetDelegate? { get set }
    var isPresented: Bool { get }
    var currentHeight: CGFloat { get }
    
    func present(from viewController: UIViewController, animated: Bool)
    func present(from viewController: UIViewController, sourceView: UIView?, animated: Bool)
    func dismiss(animated: Bool)
}

// MARK: - Height State Enum
/// 高度状态枚举
enum ActionSheetHeightState {
    case collapsed      // 默认高度
    case halfExpanded   // 一半屏幕高度
    case fullyExpanded  // 最大高度
    
    func height(for configuration: ActionSheetConfigurable) -> CGFloat {
        switch self {
        case .collapsed:
            return configuration.defaultHeight
        case .halfExpanded:
            return configuration.halfScreenHeight
        case .fullyExpanded:
            return configuration.maxHeight
        }
    }
}

// MARK: - Gesture State
/// 手势状态
enum ActionSheetGestureState {
    case idle
    case dragging
    case settling
}
