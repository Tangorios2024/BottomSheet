//
//  FloatingFeedbackView.swift
//  BottomSheet
//
//  Created by 汤振治 on 2025/6/20.
//

import UIKit

// MARK: - Floating Feedback Delegate
protocol FloatingFeedbackViewDelegate: AnyObject {
    func floatingFeedbackViewDidTapExpand(_ view: FloatingFeedbackView)
    func floatingFeedbackView(_ view: FloatingFeedbackView, didSelectRating rating: Int)
    func floatingFeedbackViewDidSubmitQuickRating(_ view: FloatingFeedbackView, rating: Int)
}

// MARK: - Floating Feedback View
/// 悬浮反馈视图 - 初始状态的简化评价界面
class FloatingFeedbackView: UIView {
    
    // MARK: - Properties
    weak var delegate: FloatingFeedbackViewDelegate?
    
    private(set) var currentRating: Int = 0
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🎉来给老师打个分吧"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var starRatingView: StarRatingView = {
        let view = StarRatingView(
            maxRating: 5,
            starSize: 24,
            spacing: 6,
            fillColor: .systemOrange,
            emptyColor: .systemGray4
        )
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var expandButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "chevron.up", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray2
        button.addTarget(self, action: #selector(expandButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var quickSubmitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("提交", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.alpha = 0
        button.addTarget(self, action: #selector(quickSubmitTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func setRating(_ rating: Int, animated: Bool = true) {
        starRatingView.setRating(rating, animated: animated)
    }
    
    func showQuickSubmitButton(animated: Bool = true) {
        guard quickSubmitButton.alpha == 0 else { return }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                self.quickSubmitButton.alpha = 1
                self.quickSubmitButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        } else {
            quickSubmitButton.alpha = 1
        }
    }
    
    func hideQuickSubmitButton(animated: Bool = true) {
        guard quickSubmitButton.alpha > 0 else { return }
        
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.quickSubmitButton.alpha = 0
                self.quickSubmitButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        } else {
            quickSubmitButton.alpha = 0
        }
    }
}

// MARK: - Private Methods
private extension FloatingFeedbackView {
    
    func setupUI() {
        backgroundColor = .clear
        addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(starRatingView)
        containerView.addSubview(expandButton)
        containerView.addSubview(quickSubmitButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: expandButton.leadingAnchor, constant: -8),
            
            // Star rating view
            starRatingView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            starRatingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            starRatingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            // Expand button
            expandButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            expandButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            expandButton.widthAnchor.constraint(equalToConstant: 24),
            expandButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Quick submit button
            quickSubmitButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            quickSubmitButton.trailingAnchor.constraint(equalTo: expandButton.leadingAnchor, constant: -12),
            quickSubmitButton.widthAnchor.constraint(equalToConstant: 60),
            quickSubmitButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerTapped))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    @objc func expandButtonTapped() {
        // 添加按钮点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.expandButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.expandButton.transform = .identity
            }
        }
        
        delegate?.floatingFeedbackViewDidTapExpand(self)
    }
    
    @objc func quickSubmitTapped() {
        guard currentRating > 0 else { return }
        
        // 添加提交动画
        UIView.animate(withDuration: 0.1, animations: {
            self.quickSubmitButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.quickSubmitButton.transform = .identity
            }
        }
        
        delegate?.floatingFeedbackViewDidSubmitQuickRating(self, rating: currentRating)
    }
    
    @objc func containerTapped() {
        // 如果没有评分，点击容器也可以展开
        if currentRating == 0 {
            delegate?.floatingFeedbackViewDidTapExpand(self)
        }
    }
}

// MARK: - StarRatingViewDelegate
extension FloatingFeedbackView: StarRatingViewDelegate {
    
    func starRatingView(_ view: StarRatingView, didSelectRating rating: Int) {
        currentRating = rating
        delegate?.floatingFeedbackView(self, didSelectRating: rating)
        
        // 当用户选择评分后，显示快速提交按钮
        if rating > 0 {
            showQuickSubmitButton()
        } else {
            hideQuickSubmitButton()
        }
    }
}
