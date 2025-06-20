//
//  ActionSheetGestureHandler.swift
//  BottomSheet
//
//  Created by 汤振治 on 2025/6/20.
//

import UIKit

// MARK: - Gesture Handler Delegate
protocol ActionSheetGestureHandlerDelegate: AnyObject {
    func gestureHandler(_ handler: ActionSheetGestureHandler, didUpdateHeight height: CGFloat)
    func gestureHandler(_ handler: ActionSheetGestureHandler, didEndWithTargetHeight height: CGFloat)
    func gestureHandlerDidRequestDismissal(_ handler: ActionSheetGestureHandler)
}

// MARK: - Action Sheet Gesture Handler
/// 手势处理器 - 专门处理拖拽手势，遵循单一职责原则
class ActionSheetGestureHandler: NSObject, ActionSheetGestureHandling {
    
    // MARK: - Properties
    weak var delegate: ActionSheetGestureHandlerDelegate?
    private let configuration: ActionSheetConfigurable
    private var gestureState: ActionSheetGestureState = .idle
    private var initialHeight: CGFloat = 0
    private var initialTouchPoint: CGPoint = .zero
    
    // MARK: - Initializer
    init(configuration: ActionSheetConfigurable) {
        self.configuration = configuration
        super.init()
    }
    
    // MARK: - ActionSheetGestureHandling
    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        let velocity = gesture.velocity(in: gesture.view)
        
        switch gesture.state {
        case .began:
            handleGestureBegan(gesture)
            
        case .changed:
            handleGestureChanged(gesture, translation: translation)
            
        case .ended, .cancelled:
            handleGestureEnded(gesture, translation: translation, velocity: velocity)
            
        default:
            break
        }
    }
    
    func shouldTransitionToHeight(_ targetHeight: CGFloat, from currentHeight: CGFloat) -> CGFloat {
        let defaultHeight = configuration.defaultHeight
        let halfHeight = configuration.halfScreenHeight
        let maxHeight = configuration.maxHeight
        
        // 根据当前高度和目标高度决定最终高度
        if targetHeight <= defaultHeight * 0.7 {
            // 如果拖拽到很低，则收起
            return 0 // 表示需要dismiss
        } else if targetHeight <= (defaultHeight + halfHeight) / 2 {
            // 在默认高度和一半高度之间，选择默认高度
            return defaultHeight
        } else if targetHeight <= (halfHeight + maxHeight) / 2 {
            // 在一半高度和最大高度之间，选择一半高度
            return halfHeight
        } else {
            // 超过中点，选择最大高度
            return maxHeight
        }
    }
}

// MARK: - Private Methods
private extension ActionSheetGestureHandler {
    
    func handleGestureBegan(_ gesture: UIPanGestureRecognizer) {
        gestureState = .dragging
        initialTouchPoint = gesture.location(in: gesture.view)
        
        // 获取当前高度（需要从delegate获取）
        if let view = gesture.view {
            initialHeight = view.frame.height
        }
    }
    
    func handleGestureChanged(_ gesture: UIPanGestureRecognizer, translation: CGPoint) {
        guard gestureState == .dragging else { return }
        
        // 计算新的高度（向上拖拽增加高度，向下拖拽减少高度）
        let newHeight = max(0, initialHeight - translation.y)
        
        // 限制最大高度
        let constrainedHeight = min(newHeight, configuration.maxHeight)
        
        delegate?.gestureHandler(self, didUpdateHeight: constrainedHeight)
    }
    
    func handleGestureEnded(_ gesture: UIPanGestureRecognizer, translation: CGPoint, velocity: CGPoint) {
        gestureState = .settling
        
        let currentHeight = max(0, initialHeight - translation.y)
        let velocityThreshold = configuration.velocityThreshold
        
        // 根据速度和位置决定最终状态
        let targetHeight: CGFloat
        
        if velocity.y > velocityThreshold {
            // 快速向下滑动，收起
            targetHeight = 0
        } else if velocity.y < -velocityThreshold {
            // 快速向上滑动，展开到下一个状态
            targetHeight = getNextExpandedHeight(from: currentHeight)
        } else {
            // 根据位置决定
            targetHeight = shouldTransitionToHeight(currentHeight, from: initialHeight)
        }
        
        if targetHeight == 0 {
            delegate?.gestureHandlerDidRequestDismissal(self)
        } else {
            delegate?.gestureHandler(self, didEndWithTargetHeight: targetHeight)
        }
        
        gestureState = .idle
    }
    
    func getNextExpandedHeight(from currentHeight: CGFloat) -> CGFloat {
        let defaultHeight = configuration.defaultHeight
        let halfHeight = configuration.halfScreenHeight
        let maxHeight = configuration.maxHeight
        
        if currentHeight < defaultHeight * 1.2 {
            return halfHeight
        } else if currentHeight < halfHeight * 1.2 {
            return maxHeight
        } else {
            return maxHeight
        }
    }
}

// MARK: - Gesture State Management
extension ActionSheetGestureHandler {
    
    var isDragging: Bool {
        return gestureState == .dragging
    }
    
    var isSettling: Bool {
        return gestureState == .settling
    }
    
    func resetState() {
        gestureState = .idle
        initialHeight = 0
        initialTouchPoint = .zero
    }
}
