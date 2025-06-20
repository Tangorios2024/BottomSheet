//
//  FeedbackFormViewController.swift
//  BottomSheet
//
//  Created by 汤振治 on 2025/6/20.
//

import UIKit

// MARK: - Feedback Form Delegate
protocol FeedbackFormViewControllerDelegate: AnyObject {
    func feedbackFormViewController(_ controller: FeedbackFormViewController, didSubmitFeedback feedback: FeedbackData)
    func feedbackFormViewControllerDidCancel(_ controller: FeedbackFormViewController)
}

// MARK: - Feedback Data Model
struct FeedbackData {
    let rating: Int
    let comment: String
    let timestamp: Date
    
    init(rating: Int, comment: String) {
        self.rating = rating
        self.comment = comment
        self.timestamp = Date()
    }
}

// MARK: - Feedback Form View Controller
/// 完整的反馈表单视图控制器
class FeedbackFormViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: FeedbackFormViewControllerDelegate?
    
    private var currentRating: Int = 0
    private var initialRating: Int = 0
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🎉来给老师打个分吧"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var starRatingView: StarRatingView = {
        let view = StarRatingView(
            maxRating: 5,
            starSize: 40,
            spacing: 12,
            fillColor: .systemOrange,
            emptyColor: .systemGray4
        )
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var ratingDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var commentTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "其他补充建议"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var commentTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .label
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "请输入您的建议或意见..."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .placeholderText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("提交", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray2
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializer
    init(initialRating: Int = 0) {
        self.initialRating = initialRating
        self.currentRating = initialRating
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupKeyboardObservers()
        
        // 设置初始评分
        if initialRating > 0 {
            starRatingView.setRating(initialRating, animated: false)
            updateRatingDescription(initialRating)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 如果没有初始评分，自动聚焦到星级评分
        if initialRating == 0 {
            // 添加一个小的延迟来突出显示星级评分
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.highlightStarRating()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Private Methods
private extension FeedbackFormViewController {
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(closeButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(starRatingView)
        contentView.addSubview(ratingDescriptionLabel)
        contentView.addSubview(commentTitleLabel)
        contentView.addSubview(commentTextView)
        contentView.addSubview(submitButton)
        
        // 添加占位符到文本视图
        commentTextView.addSubview(placeholderLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            // Title label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -16),

            // Star rating view
            starRatingView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            starRatingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Rating description label
            ratingDescriptionLabel.topAnchor.constraint(equalTo: starRatingView.bottomAnchor, constant: 10),
            ratingDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ratingDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Comment title label
            commentTitleLabel.topAnchor.constraint(equalTo: ratingDescriptionLabel.bottomAnchor, constant: 24),
            commentTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            commentTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Comment text view
            commentTextView.topAnchor.constraint(equalTo: commentTitleLabel.bottomAnchor, constant: 10),
            commentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            commentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            commentTextView.heightAnchor.constraint(equalToConstant: 100),
            
            // Placeholder label
            placeholderLabel.topAnchor.constraint(equalTo: commentTextView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: commentTextView.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: commentTextView.trailingAnchor, constant: -16),
            
            // Submit button
            submitButton.topAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: 24),
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 48),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    func updateRatingDescription(_ rating: Int) {
        let descriptions = [
            0: "",
            1: "不满意",
            2: "一般",
            3: "满意",
            4: "很满意",
            5: "非常满意"
        ]

        ratingDescriptionLabel.text = descriptions[rating] ?? ""

        // 添加动画效果
        UIView.transition(with: ratingDescriptionLabel, duration: 0.2, options: .transitionCrossDissolve) {
            // 动画在这里自动处理文本变化
        }
    }

    func highlightStarRating() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.starRatingView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.starRatingView.transform = .identity
            }
        }
    }

    func updateSubmitButtonState() {
        let isEnabled = currentRating > 0

        UIView.animate(withDuration: 0.2) {
            self.submitButton.alpha = isEnabled ? 1.0 : 0.6
            self.submitButton.backgroundColor = isEnabled ? .systemBlue : .systemGray4
        }

        submitButton.isEnabled = isEnabled
    }

    @objc func submitButtonTapped() {
        guard currentRating > 0 else { return }

        // 添加提交动画
        UIView.animate(withDuration: 0.1, animations: {
            self.submitButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.submitButton.transform = .identity
            }
        }

        let feedback = FeedbackData(
            rating: currentRating,
            comment: commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        delegate?.feedbackFormViewController(self, didSubmitFeedback: feedback)
    }

    @objc func closeButtonTapped() {
        delegate?.feedbackFormViewControllerDidCancel(self)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        let keyboardHeight = keyboardFrame.height

        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = keyboardHeight
            self.scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
        }

        // 滚动到文本视图
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            let rect = self.commentTextView.frame
            self.scrollView.scrollRectToVisible(rect, animated: true)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = 0
            self.scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
}

// MARK: - StarRatingViewDelegate
extension FeedbackFormViewController: StarRatingViewDelegate {

    func starRatingView(_ view: StarRatingView, didSelectRating rating: Int) {
        currentRating = rating
        updateRatingDescription(rating)
        updateSubmitButtonState()
    }
}

// MARK: - UITextViewDelegate
extension FeedbackFormViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
