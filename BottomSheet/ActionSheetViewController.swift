//
//  ActionSheetViewController.swift
//  BottomSheet
//
//  Created by 汤振治 on 2025/6/20.
//

import UIKit

// MARK: - Action Sheet View Controller
/// 主要的Action Sheet视图控制器 - 整合所有组件，遵循依赖倒置原则
class ActionSheetViewController: UIViewController, ActionSheetPresentable {
    
    // MARK: - Properties
    weak var delegate: ActionSheetDelegate?
    private let configuration: ActionSheetConfigurable
    private let animationManager: ActionSheetAnimationManager
    private let gestureHandler: ActionSheetGestureHandler
    
    private(set) var isPresented: Bool = false
    private(set) var currentHeight: CGFloat = 0
    private var currentState: ActionSheetHeightState = .collapsed
    
    // MARK: - UI Components
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = configuration.backgroundColor
        view.layer.cornerRadius = configuration.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = configuration.shadowOpacity
        view.layer.shadowRadius = configuration.shadowRadius
        view.layer.shadowOffset = configuration.shadowOffset
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = configuration.handleColor
        view.layer.cornerRadius = configuration.handleViewHeight / 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var safeAreaBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = configuration.safeAreaBackgroundColor ?? configuration.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Constraints
    private var heightConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var topConstraint: NSLayoutConstraint?

    // MARK: - Source View
    private weak var sourceView: UIView?
    
    // MARK: - Content View Controller
    private var contentViewController: UIViewController?
    
    // MARK: - Initializer
    init(configuration: ActionSheetConfigurable = ActionSheetConfiguration.default) {
        self.configuration = configuration
        self.animationManager = ActionSheetAnimationManager(configuration: configuration)
        self.gestureHandler = ActionSheetGestureHandler(configuration: configuration)
        super.init(nibName: nil, bundle: nil)
        
        setupGestureHandler()
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupGestures()
        setupAnimationManager()

        currentHeight = configuration.defaultHeight
        heightConstraint.constant = currentHeight
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isPresented {
            isPresented = true
            delegate?.actionSheetDidPresent(self)
        }
    }
}

// MARK: - ActionSheetConfigurable
extension ActionSheetViewController {
    var defaultHeight: CGFloat { configuration.defaultHeight }
    var halfScreenHeight: CGFloat { configuration.halfScreenHeight }
    var maxHeight: CGFloat { configuration.maxHeight }
    var animationDuration: TimeInterval { configuration.animationDuration }
    var cornerRadius: CGFloat { configuration.cornerRadius }
    var handleViewHeight: CGFloat { configuration.handleViewHeight }
    var backgroundColor: UIColor { configuration.backgroundColor }
    var shadowOpacity: Float { configuration.shadowOpacity }
    var shadowRadius: CGFloat { configuration.shadowRadius }
    var shadowOffset: CGSize { configuration.shadowOffset }
    var handleColor: UIColor { configuration.handleColor }
    var velocityThreshold: CGFloat { configuration.velocityThreshold }
    var extendToSafeArea: Bool { configuration.extendToSafeArea }
    var safeAreaBackgroundColor: UIColor? { configuration.safeAreaBackgroundColor }
}

// MARK: - ActionSheetPresentable
extension ActionSheetViewController {
    
    func present(from viewController: UIViewController, animated: Bool) {
        present(from: viewController, sourceView: nil, animated: animated)
    }

    func present(from viewController: UIViewController, sourceView: UIView?, animated: Bool) {
        self.sourceView = sourceView
        delegate?.actionSheetWillPresent(self)

        viewController.present(self, animated: false) { [weak self] in
            guard let self = self else { return }

            // 如果有sourceView，更新底部约束
            self.updateBottomConstraintForSourceView()

            if animated {
                self.animationManager.animatePresentation { _ in
                    // Completion handled in viewDidAppear
                }
            } else {
                self.isPresented = true
                self.delegate?.actionSheetDidPresent(self)
            }
        }
    }
    
    func dismiss(animated: Bool) {
        delegate?.actionSheetWillDismiss(self)
        
        if animated {
            animationManager.animateDismissal { [weak self] _ in
                self?.dismissViewController()
            }
        } else {
            dismissViewController()
        }
    }
    
    private func dismissViewController() {
        isPresented = false
        dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
            self.delegate?.actionSheetDidDismiss(self)
        }
    }
}

// MARK: - Content Management
extension ActionSheetViewController {
    
    /// 设置内容视图控制器
    func setContentViewController(_ viewController: UIViewController) {
        // 移除旧的内容视图控制器
        contentViewController?.willMove(toParent: nil)
        contentViewController?.view.removeFromSuperview()
        contentViewController?.removeFromParent()
        
        // 添加新的内容视图控制器
        contentViewController = viewController
        addChild(viewController)
        contentContainerView.addSubview(viewController.view)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
        
        viewController.didMove(toParent: self)
    }
}

// MARK: - ActionSheetGestureHandling
extension ActionSheetViewController {
    
    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        gestureHandler.handlePanGesture(gesture)
    }
    
    func shouldTransitionToHeight(_ targetHeight: CGFloat, from currentHeight: CGFloat) -> CGFloat {
        return gestureHandler.shouldTransitionToHeight(targetHeight, from: currentHeight)
    }
}

// MARK: - ActionSheetAnimatable
extension ActionSheetViewController {
    
    func animateToHeight(_ height: CGFloat, completion: ((Bool) -> Void)?) {
        currentHeight = height
        updateHeightState(for: height)
        animationManager.animateToHeight(height, completion: completion)
        delegate?.actionSheet(self, didChangeHeight: height)
    }
    
    func animatePresentation(completion: ((Bool) -> Void)?) {
        animationManager.animatePresentation(completion: completion)
    }
    
    func animateDismissal(completion: ((Bool) -> Void)?) {
        animationManager.animateDismissal(completion: completion)
    }
}

// MARK: - Private Setup Methods
private extension ActionSheetViewController {
    
    func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(contentView)

        // 添加安全区域背景视图（如果需要）
        if configuration.extendToSafeArea {
            view.addSubview(safeAreaBackgroundView)
        }

        contentView.addSubview(handleView)
        contentView.addSubview(contentContainerView)
    }
    
    func setupConstraints() {
        heightConstraint = contentView.heightAnchor.constraint(equalToConstant: configuration.defaultHeight)
        bottomConstraint = contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        var constraints: [NSLayoutConstraint] = [
            // Background view
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content view
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
            heightConstraint,

            // Handle view
            handleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            handleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: configuration.handleViewHeight),

            // Content container view
            contentContainerView.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 16),
            contentContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]

        // 添加安全区域背景视图约束（如果需要）
        if configuration.extendToSafeArea {
            constraints.append(contentsOf: [
                // 让安全区域背景视图紧贴contentView，没有间隙
                safeAreaBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                safeAreaBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                safeAreaBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                safeAreaBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

        NSLayoutConstraint.activate(constraints)
    }
    
    func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        contentView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    func setupGestureHandler() {
        gestureHandler.delegate = self
    }

    func setupAnimationManager() {
        animationManager.setupViews(
            containerView: view,
            contentView: contentView,
            backgroundView: backgroundView,
            heightConstraint: heightConstraint
        )
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        handlePanGesture(gesture)
    }
    
    @objc func handleBackgroundTap() {
        dismiss(animated: true)
    }
    
    func updateHeightState(for height: CGFloat) {
        let defaultHeight = configuration.defaultHeight
        let halfHeight = configuration.halfScreenHeight
        let maxHeight = configuration.maxHeight

        if abs(height - defaultHeight) < 50 {
            currentState = .collapsed
        } else if abs(height - halfHeight) < 50 {
            currentState = .halfExpanded
        } else if abs(height - maxHeight) < 50 {
            currentState = .fullyExpanded
        }
    }

    func updateBottomConstraintForSourceView() {
        guard let sourceView = sourceView,
              let sourceSuperview = sourceView.superview else { return }

        // 将sourceView的坐标转换到当前view的坐标系
        let sourceFrame = sourceSuperview.convert(sourceView.frame, to: view)

        // 移除旧的约束
        bottomConstraint.isActive = false

        // 计算新的底部约束值：让sheet的底部位于sourceView的顶部
        // 这样sheet就会从sourceView上方开始，不覆盖sourceView
        let newBottomConstant = sourceFrame.minY - view.bounds.height
        bottomConstraint = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: newBottomConstant)
        bottomConstraint.isActive = true

        // 更新动画管理器的约束引用
        animationManager.updateBottomConstraint(bottomConstraint)
    }
}

// MARK: - ActionSheetGestureHandlerDelegate
extension ActionSheetViewController: ActionSheetGestureHandlerDelegate {
    
    func gestureHandler(_ handler: ActionSheetGestureHandler, didUpdateHeight height: CGFloat) {
        animationManager.updateHeightImmediately(height)
        currentHeight = height
        delegate?.actionSheet(self, didChangeHeight: height)
    }
    
    func gestureHandler(_ handler: ActionSheetGestureHandler, didEndWithTargetHeight height: CGFloat) {
        animateToHeight(height, completion: nil)
    }
    
    func gestureHandlerDidRequestDismissal(_ handler: ActionSheetGestureHandler) {
        dismiss(animated: true)
    }
}
