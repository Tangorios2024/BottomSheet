//
//  ActionSheetViewConfiguration.swift
//  BottomSheet
//
//  Created by 汤振治 on 2025/6/20.
//

import UIKit

// MARK: - Source View Configuration Protocol
/// 源视图配置协议 - 遵循接口隔离原则
protocol SourceViewConfigurable {
    var sourceViewFrame: CGRect { get }
    var sourceViewCornerRadius: CGFloat { get }
    var sourceViewBackgroundColor: UIColor { get }
    var sourceViewShadowConfig: ShadowConfiguration { get }
}

// MARK: - Dismissal View Configuration Protocol
/// 结束视图配置协议 - 遵循接口隔离原则
protocol DismissalViewConfigurable {
    var dismissalViewContent: DismissalViewContent { get }
    var dismissalViewStyle: DismissalViewStyle { get }
    var dismissalAnimationConfig: DismissalAnimationConfiguration { get }
}

// MARK: - View Provider Protocols
/// 源视图提供协议 - 遵循依赖倒置原则
protocol SourceViewProvider: AnyObject {
    func createSourceView() -> UIView
    func getSourceViewConfiguration() -> SourceViewConfigurable
}

/// 结束视图提供协议 - 遵循依赖倒置原则
protocol DismissalViewProvider: AnyObject {
    func createDismissalView() -> UIView
    func getDismissalViewConfiguration() -> DismissalViewConfigurable
}

// MARK: - Configuration Data Structures
/// 阴影配置
struct ShadowConfiguration {
    let color: UIColor
    let opacity: Float
    let offset: CGSize
    let radius: CGFloat
    
    static let `default` = ShadowConfiguration(
        color: .black,
        opacity: 0.15,
        offset: CGSize(width: 0, height: 4),
        radius: 12
    )
}

/// 结束视图内容
struct DismissalViewContent {
    let text: String
    let emoji: String?
    let textColor: UIColor
    let font: UIFont
    
    static let thankYou = DismissalViewContent(
        text: "感谢您的反馈",
        emoji: "✅",
        textColor: .systemGreen,
        font: .systemFont(ofSize: 16, weight: .semibold)
    )
    
    static let completed = DismissalViewContent(
        text: "操作完成",
        emoji: "🎉",
        textColor: .systemBlue,
        font: .systemFont(ofSize: 16, weight: .semibold)
    )
}

/// 结束视图样式
struct DismissalViewStyle {
    let backgroundColor: UIColor
    let cornerRadius: CGFloat
    let shadowConfig: ShadowConfiguration
    let padding: UIEdgeInsets
    
    static let `default` = DismissalViewStyle(
        backgroundColor: .systemBackground,
        cornerRadius: 20,
        shadowConfig: .default,
        padding: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    )
}

/// 结束动画配置
struct DismissalAnimationConfiguration {
    let contentHideDuration: TimeInterval
    let tempViewShowDuration: TimeInterval
    let shrinkDuration: TimeInterval
    let finalFadeDuration: TimeInterval
    let pauseDuration: TimeInterval
    
    static let `default` = DismissalAnimationConfiguration(
        contentHideDuration: 0.4,
        tempViewShowDuration: 0.2,
        shrinkDuration: 0.6,
        finalFadeDuration: 0.3,
        pauseDuration: 0.1
    )
}

// MARK: - Default Implementations
/// 默认源视图配置
struct DefaultSourceViewConfiguration: SourceViewConfigurable {
    let sourceViewFrame: CGRect
    let sourceViewCornerRadius: CGFloat
    let sourceViewBackgroundColor: UIColor
    let sourceViewShadowConfig: ShadowConfiguration
    
    init(frame: CGRect) {
        self.sourceViewFrame = frame
        self.sourceViewCornerRadius = 20
        self.sourceViewBackgroundColor = .systemBackground
        self.sourceViewShadowConfig = .default
    }
}

/// 默认结束视图配置
struct DefaultDismissalViewConfiguration: DismissalViewConfigurable {
    let dismissalViewContent: DismissalViewContent
    let dismissalViewStyle: DismissalViewStyle
    let dismissalAnimationConfig: DismissalAnimationConfiguration
    
    init(content: DismissalViewContent = .thankYou) {
        self.dismissalViewContent = content
        self.dismissalViewStyle = .default
        self.dismissalAnimationConfig = .default
    }
}

// MARK: - Builder Pattern for Configuration
/// 结束视图配置构建器 - 遵循开闭原则
class DismissalViewConfigurationBuilder {
    private var content: DismissalViewContent = .thankYou
    private var style: DismissalViewStyle = .default
    private var animationConfig: DismissalAnimationConfiguration = .default
    
    func content(_ content: DismissalViewContent) -> Self {
        self.content = content
        return self
    }
    
    func style(_ style: DismissalViewStyle) -> Self {
        self.style = style
        return self
    }
    
    func animationConfig(_ config: DismissalAnimationConfiguration) -> Self {
        self.animationConfig = config
        return self
    }
    
    func build() -> DismissalViewConfigurable {
        return DefaultDismissalViewConfiguration(content: content)
    }
}
