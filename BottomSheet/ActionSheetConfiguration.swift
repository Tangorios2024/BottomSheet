//
//  ActionSheetConfiguration.swift
//  BottomSheet
//
//  Created by 汤振治 on 2025/6/20.
//

import UIKit

// MARK: - Action Sheet Configuration
/// Action Sheet配置模型 - 遵循单一职责原则
struct ActionSheetConfiguration: ActionSheetConfigurable {
    
    // MARK: - Height Configuration
    let defaultHeight: CGFloat
    let halfScreenHeight: CGFloat
    let maxHeight: CGFloat
    
    // MARK: - Animation Configuration
    let animationDuration: TimeInterval
    let springDamping: CGFloat
    let springVelocity: CGFloat
    
    // MARK: - Appearance Configuration
    let cornerRadius: CGFloat
    let handleViewHeight: CGFloat
    let handleViewWidth: CGFloat
    let backgroundColor: UIColor
    let handleColor: UIColor
    let shadowOpacity: Float
    let shadowRadius: CGFloat
    let shadowOffset: CGSize
    
    // MARK: - Gesture Configuration
    let velocityThreshold: CGFloat
    let dismissThreshold: CGFloat

    // MARK: - Safe Area Configuration
    let extendToSafeArea: Bool
    let safeAreaBackgroundColor: UIColor?
    
    // MARK: - Initializer
    init(
        defaultHeight: CGFloat = 300,
        halfScreenHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil,
        animationDuration: TimeInterval = 0.3,
        springDamping: CGFloat = 0.8,
        springVelocity: CGFloat = 0.5,
        cornerRadius: CGFloat = 16,
        handleViewHeight: CGFloat = 5,
        handleViewWidth: CGFloat = 40,
        backgroundColor: UIColor = .systemBackground,
        handleColor: UIColor = .systemGray3,
        shadowOpacity: Float = 0.3,
        shadowRadius: CGFloat = 10,
        shadowOffset: CGSize = CGSize(width: 0, height: -2),
        velocityThreshold: CGFloat = 500,
        dismissThreshold: CGFloat = 0.3,
        extendToSafeArea: Bool = true,
        safeAreaBackgroundColor: UIColor? = nil
    ) {
        self.defaultHeight = defaultHeight
        
        // 计算屏幕相关高度
        let screenHeight = UIScreen.main.bounds.height
        let safeAreaBottom: CGFloat
        if #available(iOS 13.0, *) {
            safeAreaBottom = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?.safeAreaInsets.bottom ?? 0
        } else {
            safeAreaBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        let availableHeight = screenHeight - safeAreaBottom - 100 // 预留顶部空间
        
        self.halfScreenHeight = halfScreenHeight ?? (availableHeight * 0.5)
        self.maxHeight = maxHeight ?? (availableHeight * 0.9)
        
        self.animationDuration = animationDuration
        self.springDamping = springDamping
        self.springVelocity = springVelocity
        self.cornerRadius = cornerRadius
        self.handleViewHeight = handleViewHeight
        self.handleViewWidth = handleViewWidth
        self.backgroundColor = backgroundColor
        self.handleColor = handleColor
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
        self.velocityThreshold = velocityThreshold
        self.dismissThreshold = dismissThreshold
        self.extendToSafeArea = extendToSafeArea
        self.safeAreaBackgroundColor = safeAreaBackgroundColor
    }
}

// MARK: - Default Configurations
extension ActionSheetConfiguration {
    
    /// 默认配置
    static let `default` = ActionSheetConfiguration()
    
    /// 紧凑配置 - 适用于较小的内容
    static let compact = ActionSheetConfiguration(
        defaultHeight: 200,
        animationDuration: 0.25,
        cornerRadius: 12
    )
    
    /// 全屏配置 - 适用于大量内容
    static let fullScreen = ActionSheetConfiguration(
        defaultHeight: 400,
        animationDuration: 0.4,
        springDamping: 0.9
    )
}

// MARK: - Configuration Builder
/// 配置构建器 - 提供链式调用方式创建配置
class ActionSheetConfigurationBuilder {
    private var configuration = ActionSheetConfiguration()
    
    func defaultHeight(_ height: CGFloat) -> ActionSheetConfigurationBuilder {
        configuration = ActionSheetConfiguration(
            defaultHeight: height,
            halfScreenHeight: configuration.halfScreenHeight,
            maxHeight: configuration.maxHeight,
            animationDuration: configuration.animationDuration,
            springDamping: configuration.springDamping,
            springVelocity: configuration.springVelocity,
            cornerRadius: configuration.cornerRadius,
            handleViewHeight: configuration.handleViewHeight,
            handleViewWidth: configuration.handleViewWidth,
            backgroundColor: configuration.backgroundColor,
            handleColor: configuration.handleColor,
            shadowOpacity: configuration.shadowOpacity,
            shadowRadius: configuration.shadowRadius,
            shadowOffset: configuration.shadowOffset,
            velocityThreshold: configuration.velocityThreshold,
            dismissThreshold: configuration.dismissThreshold,
            extendToSafeArea: configuration.extendToSafeArea,
            safeAreaBackgroundColor: configuration.safeAreaBackgroundColor
        )
        return self
    }
    
    func maxHeight(_ height: CGFloat) -> ActionSheetConfigurationBuilder {
        configuration = ActionSheetConfiguration(
            defaultHeight: configuration.defaultHeight,
            halfScreenHeight: configuration.halfScreenHeight,
            maxHeight: height,
            animationDuration: configuration.animationDuration,
            springDamping: configuration.springDamping,
            springVelocity: configuration.springVelocity,
            cornerRadius: configuration.cornerRadius,
            handleViewHeight: configuration.handleViewHeight,
            handleViewWidth: configuration.handleViewWidth,
            backgroundColor: configuration.backgroundColor,
            handleColor: configuration.handleColor,
            shadowOpacity: configuration.shadowOpacity,
            shadowRadius: configuration.shadowRadius,
            shadowOffset: configuration.shadowOffset,
            velocityThreshold: configuration.velocityThreshold,
            dismissThreshold: configuration.dismissThreshold,
            extendToSafeArea: configuration.extendToSafeArea,
            safeAreaBackgroundColor: configuration.safeAreaBackgroundColor
        )
        return self
    }
    
    func animationDuration(_ duration: TimeInterval) -> ActionSheetConfigurationBuilder {
        configuration = ActionSheetConfiguration(
            defaultHeight: configuration.defaultHeight,
            halfScreenHeight: configuration.halfScreenHeight,
            maxHeight: configuration.maxHeight,
            animationDuration: duration,
            springDamping: configuration.springDamping,
            springVelocity: configuration.springVelocity,
            cornerRadius: configuration.cornerRadius,
            handleViewHeight: configuration.handleViewHeight,
            handleViewWidth: configuration.handleViewWidth,
            backgroundColor: configuration.backgroundColor,
            handleColor: configuration.handleColor,
            shadowOpacity: configuration.shadowOpacity,
            shadowRadius: configuration.shadowRadius,
            shadowOffset: configuration.shadowOffset,
            velocityThreshold: configuration.velocityThreshold,
            dismissThreshold: configuration.dismissThreshold,
            extendToSafeArea: configuration.extendToSafeArea,
            safeAreaBackgroundColor: configuration.safeAreaBackgroundColor
        )
        return self
    }
    
    func backgroundColor(_ color: UIColor) -> ActionSheetConfigurationBuilder {
        configuration = ActionSheetConfiguration(
            defaultHeight: configuration.defaultHeight,
            halfScreenHeight: configuration.halfScreenHeight,
            maxHeight: configuration.maxHeight,
            animationDuration: configuration.animationDuration,
            springDamping: configuration.springDamping,
            springVelocity: configuration.springVelocity,
            cornerRadius: configuration.cornerRadius,
            handleViewHeight: configuration.handleViewHeight,
            handleViewWidth: configuration.handleViewWidth,
            backgroundColor: color,
            handleColor: configuration.handleColor,
            shadowOpacity: configuration.shadowOpacity,
            shadowRadius: configuration.shadowRadius,
            shadowOffset: configuration.shadowOffset,
            velocityThreshold: configuration.velocityThreshold,
            dismissThreshold: configuration.dismissThreshold,
            extendToSafeArea: configuration.extendToSafeArea,
            safeAreaBackgroundColor: configuration.safeAreaBackgroundColor
        )
        return self
    }

    func extendToSafeArea(_ extend: Bool) -> ActionSheetConfigurationBuilder {
        configuration = ActionSheetConfiguration(
            defaultHeight: configuration.defaultHeight,
            halfScreenHeight: configuration.halfScreenHeight,
            maxHeight: configuration.maxHeight,
            animationDuration: configuration.animationDuration,
            springDamping: configuration.springDamping,
            springVelocity: configuration.springVelocity,
            cornerRadius: configuration.cornerRadius,
            handleViewHeight: configuration.handleViewHeight,
            handleViewWidth: configuration.handleViewWidth,
            backgroundColor: configuration.backgroundColor,
            handleColor: configuration.handleColor,
            shadowOpacity: configuration.shadowOpacity,
            shadowRadius: configuration.shadowRadius,
            shadowOffset: configuration.shadowOffset,
            velocityThreshold: configuration.velocityThreshold,
            dismissThreshold: configuration.dismissThreshold,
            extendToSafeArea: extend,
            safeAreaBackgroundColor: configuration.safeAreaBackgroundColor
        )
        return self
    }

    func safeAreaBackgroundColor(_ color: UIColor?) -> ActionSheetConfigurationBuilder {
        configuration = ActionSheetConfiguration(
            defaultHeight: configuration.defaultHeight,
            halfScreenHeight: configuration.halfScreenHeight,
            maxHeight: configuration.maxHeight,
            animationDuration: configuration.animationDuration,
            springDamping: configuration.springDamping,
            springVelocity: configuration.springVelocity,
            cornerRadius: configuration.cornerRadius,
            handleViewHeight: configuration.handleViewHeight,
            handleViewWidth: configuration.handleViewWidth,
            backgroundColor: configuration.backgroundColor,
            handleColor: configuration.handleColor,
            shadowOpacity: configuration.shadowOpacity,
            shadowRadius: configuration.shadowRadius,
            shadowOffset: configuration.shadowOffset,
            velocityThreshold: configuration.velocityThreshold,
            dismissThreshold: configuration.dismissThreshold,
            extendToSafeArea: configuration.extendToSafeArea,
            safeAreaBackgroundColor: color
        )
        return self
    }

    func build() -> ActionSheetConfiguration {
        return configuration
    }
}
