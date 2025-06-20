//
//  ActionSheetUsageExamples.swift
//  BottomSheet
//
//  Created by 汤振治 on 2025/6/20.
//

import UIKit

// MARK: - Usage Examples
/// 展示如何使用ActionSheet组件的不同配置场景
class ActionSheetUsageExamples {
    
    // MARK: - Example 1: Feedback Scenario
    /// 反馈场景 - 从悬浮反馈视图展开到详细表单
    static func createFeedbackActionSheet() -> ActionSheetConfiguration {
        let dismissalContent = DismissalViewContent(
            text: "感谢您的反馈",
            emoji: "✅",
            textColor: .systemGreen,
            font: .systemFont(ofSize: 16, weight: .semibold)
        )
        
        let dismissalConfig = DismissalViewConfigurationBuilder()
            .content(dismissalContent)
            .build()
        
        return ActionSheetConfigurationBuilder()
            .defaultHeight(450)
            .maxHeight(600)
            .animationDuration(0.5)
            .backgroundColor(.systemBackground)
            .build()
    }
    
    // MARK: - Example 2: Shopping Cart Scenario
    /// 购物车场景 - 从购物车按钮展开到订单详情
    static func createShoppingCartActionSheet() -> ActionSheetConfiguration {
        let dismissalContent = DismissalViewContent(
            text: "订单已提交",
            emoji: "🛒",
            textColor: .systemBlue,
            font: .systemFont(ofSize: 16, weight: .semibold)
        )
        
        let dismissalStyle = DismissalViewStyle(
            backgroundColor: .systemBackground,
            cornerRadius: 16,
            shadowConfig: ShadowConfiguration(
                color: .black,
                opacity: 0.2,
                offset: CGSize(width: 0, height: 6),
                radius: 15
            ),
            padding: UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        )
        
        let animationConfig = DismissalAnimationConfiguration(
            contentHideDuration: 0.3,
            tempViewShowDuration: 0.2,
            shrinkDuration: 0.8,
            finalFadeDuration: 0.4,
            pauseDuration: 0.2
        )
        
        let dismissalConfig = DismissalViewConfigurationBuilder()
            .content(dismissalContent)
            .style(dismissalStyle)
            .animationConfig(animationConfig)
            .build()
        
        return ActionSheetConfigurationBuilder()
            .defaultHeight(400)
            .maxHeight(700)
            .animationDuration(0.6)
            .backgroundColor(.systemBackground)
            .build()
    }
    
    // MARK: - Example 3: Settings Scenario
    /// 设置场景 - 从设置按钮展开到详细设置
    static func createSettingsActionSheet() -> ActionSheetConfiguration {
        let dismissalContent = DismissalViewContent(
            text: "设置已保存",
            emoji: "⚙️",
            textColor: .systemOrange,
            font: .systemFont(ofSize: 15, weight: .medium)
        )
        
        let compactStyle = DismissalViewStyle(
            backgroundColor: .secondarySystemBackground,
            cornerRadius: 12,
            shadowConfig: ShadowConfiguration(
                color: .black,
                opacity: 0.1,
                offset: CGSize(width: 0, height: 2),
                radius: 8
            ),
            padding: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        )
        
        let quickAnimation = DismissalAnimationConfiguration(
            contentHideDuration: 0.2,
            tempViewShowDuration: 0.1,
            shrinkDuration: 0.4,
            finalFadeDuration: 0.2,
            pauseDuration: 0.05
        )
        
        let dismissalConfig = DismissalViewConfigurationBuilder()
            .content(dismissalContent)
            .style(compactStyle)
            .animationConfig(quickAnimation)
            .build()
        
        return ActionSheetConfigurationBuilder()
            .defaultHeight(300)
            .maxHeight(500)
            .animationDuration(0.3)
            .backgroundColor(.systemBackground)
            .build()
    }
    
    // MARK: - Example 4: Media Player Scenario
    /// 媒体播放器场景 - 从播放按钮展开到播放列表
    static func createMediaPlayerActionSheet() -> ActionSheetConfiguration {
        let dismissalContent = DismissalViewContent(
            text: "正在播放",
            emoji: "🎵",
            textColor: .systemPurple,
            font: .systemFont(ofSize: 17, weight: .bold)
        )
        
        let mediaStyle = DismissalViewStyle(
            backgroundColor: .systemBackground,
            cornerRadius: 25,
            shadowConfig: ShadowConfiguration(
                color: .systemPurple,
                opacity: 0.3,
                offset: CGSize(width: 0, height: 8),
                radius: 20
            ),
            padding: UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24)
        )
        
        let smoothAnimation = DismissalAnimationConfiguration(
            contentHideDuration: 0.5,
            tempViewShowDuration: 0.3,
            shrinkDuration: 1.0,
            finalFadeDuration: 0.5,
            pauseDuration: 0.3
        )
        
        let dismissalConfig = DismissalViewConfigurationBuilder()
            .content(dismissalContent)
            .style(mediaStyle)
            .animationConfig(smoothAnimation)
            .build()
        
        return ActionSheetConfigurationBuilder()
            .defaultHeight(500)
            .maxHeight(800)
            .animationDuration(0.7)
            .backgroundColor(.systemBackground)
            .build()
    }
}

// MARK: - Custom Source View Provider Example
/// 自定义源视图提供者示例
class CustomFloatingButtonProvider: SourceViewProvider {
    private let buttonFrame: CGRect
    private let buttonStyle: ButtonStyle
    
    enum ButtonStyle {
        case circular
        case rounded
        case pill
    }
    
    init(frame: CGRect, style: ButtonStyle = .circular) {
        self.buttonFrame = frame
        self.buttonStyle = style
    }
    
    func createSourceView() -> UIView {
        let button = UIButton(type: .system)
        button.frame = buttonFrame
        
        switch buttonStyle {
        case .circular:
            button.layer.cornerRadius = min(buttonFrame.width, buttonFrame.height) / 2
        case .rounded:
            button.layer.cornerRadius = 12
        case .pill:
            button.layer.cornerRadius = buttonFrame.height / 2
        }
        
        button.backgroundColor = .systemBlue
        button.setTitle("点击", for: .normal)
        button.setTitleColor(.white, for: .normal)
        
        return button
    }
    
    func getSourceViewConfiguration() -> SourceViewConfigurable {
        let cornerRadius: CGFloat
        switch buttonStyle {
        case .circular:
            cornerRadius = min(buttonFrame.width, buttonFrame.height) / 2
        case .rounded:
            cornerRadius = 12
        case .pill:
            cornerRadius = buttonFrame.height / 2
        }
        
        return DefaultSourceViewConfiguration(frame: buttonFrame)
    }
}

// MARK: - Custom Dismissal View Provider Example
/// 自定义结束视图提供者示例
class CustomDismissalViewProvider: DismissalViewProvider {
    private let message: String
    private let icon: String
    private let theme: Theme
    
    enum Theme {
        case success
        case warning
        case info
        case error
    }
    
    init(message: String, icon: String, theme: Theme = .success) {
        self.message = message
        self.icon = icon
        self.theme = theme
    }
    
    func createDismissalView() -> UIView {
        let container = UIView()
        let config = getDismissalViewConfiguration()
        let style = config.dismissalViewStyle
        
        container.backgroundColor = style.backgroundColor
        container.layer.cornerRadius = style.cornerRadius
        
        // 添加图标和文本
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 20)
        
        let textLabel = UILabel()
        textLabel.text = message
        textLabel.font = config.dismissalViewContent.font
        textLabel.textColor = config.dismissalViewContent.textColor
        
        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(textLabel)
        
        container.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: style.padding.left),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -style.padding.right)
        ])
        
        return container
    }
    
    func getDismissalViewConfiguration() -> DismissalViewConfigurable {
        let color: UIColor
        switch theme {
        case .success:
            color = .systemGreen
        case .warning:
            color = .systemOrange
        case .info:
            color = .systemBlue
        case .error:
            color = .systemRed
        }
        
        let content = DismissalViewContent(
            text: message,
            emoji: icon,
            textColor: color,
            font: .systemFont(ofSize: 16, weight: .semibold)
        )
        
        return DefaultDismissalViewConfiguration(content: content)
    }
}
