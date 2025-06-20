//
//  StarRatingView.swift
//  BottomSheet
//
//  Created by 汤振治 on 2025/6/20.
//

import UIKit

// MARK: - Star Rating Delegate
protocol StarRatingViewDelegate: AnyObject {
    func starRatingView(_ view: StarRatingView, didSelectRating rating: Int)
}

// MARK: - Star Rating View
/// 星级评分组件 - 支持点击选择评分
class StarRatingView: UIView {
    
    // MARK: - Properties
    weak var delegate: StarRatingViewDelegate?
    
    private(set) var rating: Int = 0 {
        didSet {
            updateStarAppearance()
            delegate?.starRatingView(self, didSelectRating: rating)
        }
    }
    
    private let maxRating: Int
    private let starSize: CGFloat
    private let spacing: CGFloat
    private let fillColor: UIColor
    private let emptyColor: UIColor
    
    private var starButtons: [UIButton] = []
    
    // MARK: - Initializer
    init(
        maxRating: Int = 5,
        starSize: CGFloat = 30,
        spacing: CGFloat = 8,
        fillColor: UIColor = .systemOrange,
        emptyColor: UIColor = .systemGray4
    ) {
        self.maxRating = maxRating
        self.starSize = starSize
        self.spacing = spacing
        self.fillColor = fillColor
        self.emptyColor = emptyColor
        
        super.init(frame: .zero)
        setupStars()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func setRating(_ rating: Int, animated: Bool = true) {
        guard rating >= 0 && rating <= maxRating else { return }
        
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.rating = rating
            }
        } else {
            self.rating = rating
        }
    }
    
    func resetRating() {
        setRating(0, animated: true)
    }
}

// MARK: - Private Methods
private extension StarRatingView {
    
    func setupStars() {
        // 创建星星按钮
        for i in 0..<maxRating {
            let button = createStarButton(tag: i + 1)
            starButtons.append(button)
            addSubview(button)
        }
        
        setupConstraints()
        updateStarAppearance()
    }
    
    func createStarButton(tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = tag
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
        
        // 设置星星图标
        let starImage = UIImage(systemName: "star.fill")
        button.setImage(starImage, for: .normal)
        button.tintColor = emptyColor
        
        // 添加触摸反馈
        button.addTarget(self, action: #selector(starTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(starTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    func setupConstraints() {
        guard !starButtons.isEmpty else { return }
        
        // 设置第一个星星的约束
        let firstStar = starButtons[0]
        NSLayoutConstraint.activate([
            firstStar.leadingAnchor.constraint(equalTo: leadingAnchor),
            firstStar.centerYAnchor.constraint(equalTo: centerYAnchor),
            firstStar.widthAnchor.constraint(equalToConstant: starSize),
            firstStar.heightAnchor.constraint(equalToConstant: starSize)
        ])
        
        // 设置其他星星的约束
        for i in 1..<starButtons.count {
            let currentStar = starButtons[i]
            let previousStar = starButtons[i - 1]
            
            NSLayoutConstraint.activate([
                currentStar.leadingAnchor.constraint(equalTo: previousStar.trailingAnchor, constant: spacing),
                currentStar.centerYAnchor.constraint(equalTo: centerYAnchor),
                currentStar.widthAnchor.constraint(equalToConstant: starSize),
                currentStar.heightAnchor.constraint(equalToConstant: starSize)
            ])
        }
        
        // 设置容器视图的约束
        if let lastStar = starButtons.last {
            NSLayoutConstraint.activate([
                trailingAnchor.constraint(equalTo: lastStar.trailingAnchor),
                heightAnchor.constraint(equalToConstant: starSize)
            ])
        }
    }
    
    func updateStarAppearance() {
        for (index, button) in starButtons.enumerated() {
            let starIndex = index + 1
            let isFilled = starIndex <= rating
            
            button.tintColor = isFilled ? fillColor : emptyColor
            
            // 添加缩放动画效果
            if starIndex == rating {
                UIView.animate(withDuration: 0.1, animations: {
                    button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }) { _ in
                    UIView.animate(withDuration: 0.1) {
                        button.transform = .identity
                    }
                }
            }
        }
    }
    
    @objc func starTapped(_ sender: UIButton) {
        let newRating = sender.tag
        rating = newRating
        
        // 触觉反馈
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    @objc func starTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    @objc func starTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
}
