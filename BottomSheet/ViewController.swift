//
//  ViewController.swift
//  BottomSheet
//
//  Created by 汤振治 on 2025/6/20.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Action Sheet Demo"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var defaultButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Default Action Sheet", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(showDefaultActionSheet), for: .touchUpInside)
        return button
    }()

    private lazy var compactButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Compact Action Sheet", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor.systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(showCompactActionSheet), for: .touchUpInside)
        return button
    }()

    private lazy var customButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Custom Action Sheet", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor.systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(showCustomActionSheet), for: .touchUpInside)
        return button
    }()



    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
}

// MARK: - Setup Methods
private extension ViewController {

    func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(titleLabel)
        view.addSubview(stackView)

        stackView.addArrangedSubview(defaultButton)
        stackView.addArrangedSubview(compactButton)
        stackView.addArrangedSubview(customButton)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            defaultButton.heightAnchor.constraint(equalToConstant: 50),
            compactButton.heightAnchor.constraint(equalToConstant: 50),
            customButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

// MARK: - Action Methods
private extension ViewController {

    @objc func showDefaultActionSheet() {
        let actionSheet = ActionSheetViewController(configuration: ActionSheetConfiguration.default)
        actionSheet.delegate = self

        // 创建示例内容
        let contentVC = createSampleContentViewController(title: "Default Action Sheet", color: .systemBlue)
        actionSheet.setContentViewController(contentVC)

        actionSheet.present(from: self, animated: true)
    }

    @objc func showCompactActionSheet() {
        let actionSheet = ActionSheetViewController(configuration: ActionSheetConfiguration.compact)
        actionSheet.delegate = self

        // 创建示例内容
        let contentVC = createSampleContentViewController(title: "Compact Action Sheet", color: .systemGreen)
        actionSheet.setContentViewController(contentVC)

        actionSheet.present(from: self, animated: true)
    }

    @objc func showCustomActionSheet() {
        let customConfig = ActionSheetConfigurationBuilder()
            .defaultHeight(250)
            .maxHeight(600)
            .animationDuration(0.4)
            .backgroundColor(.systemPurple.withAlphaComponent(0.95))
            .build()

        let actionSheet = ActionSheetViewController(configuration: customConfig)
        actionSheet.delegate = self

        // 创建示例内容
        let contentVC = createSampleContentViewController(title: "Custom Action Sheet", color: .systemPurple)
        actionSheet.setContentViewController(contentVC)

        actionSheet.present(from: self, animated: true)
    }



    func createSampleContentViewController(title: String, color: UIColor) -> UIViewController {
        let contentVC = UIViewController()
        contentVC.view.backgroundColor = .clear

        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false

        let descriptionLabel = UILabel()
        descriptionLabel.text = "拖拽顶部区域可以调整高度\n向上拖拽展开，向下拖拽收起\n点击背景区域可以关闭"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        contentVC.view.addSubview(label)
        contentVC.view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentVC.view.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: contentVC.view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: contentVC.view.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentVC.view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentVC.view.trailingAnchor, constant: -20)
        ])

        return contentVC
    }




}

// MARK: - ActionSheetDelegate
extension ViewController: ActionSheetDelegate {

    func actionSheetWillPresent(_ actionSheet: ActionSheetPresentable) {
        print("Action sheet will present")
    }

    func actionSheetDidPresent(_ actionSheet: ActionSheetPresentable) {
        print("Action sheet did present")
    }

    func actionSheetWillDismiss(_ actionSheet: ActionSheetPresentable) {
        print("Action sheet will dismiss")
    }

    func actionSheetDidDismiss(_ actionSheet: ActionSheetPresentable) {
        print("Action sheet did dismiss")
    }

    func actionSheet(_ actionSheet: ActionSheetPresentable, didChangeHeight height: CGFloat) {
        print("Action sheet height changed to: \(height)")
    }
}

