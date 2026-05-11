//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Данил Третьяченко on 12.05.2026.
//

import UIKit

// MARK: - TrackerCellDelegate Protocol
protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackerCollectionViewCell"
    
    // MARK: - Properties
    weak var delegate: TrackerCellDelegate?
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    private var isCompleted: Bool = false
    
    // MARK: - UI Elements
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        // Убираем clipsToBounds, чтобы не резать края эмодзи, если он чуть больше
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let trackerNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 17
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        
        completeButton.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func didTapCompleteButton() {
        guard let trackerId = trackerId, let indexPath = indexPath else { return }
        
        if isCompleted {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
    
    // MARK: - Configuration
    func configure(with tracker: Tracker, isCompleted: Bool, completedDays: Int, indexPath: IndexPath) {
        self.trackerId = tracker.id
        self.isCompleted = isCompleted
        self.indexPath = indexPath
        
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        trackerNameLabel.text = tracker.name
        
        daysLabel.text = "\(completedDays) дней"
        
        updateButtonState()
    }
    
    private func updateButtonState() {
        let imageName = isCompleted ? "checkmark" : "plus"
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let image = UIImage(systemName: imageName, withConfiguration: config)
        
        completeButton.setImage(image, for: .normal)
        completeButton.backgroundColor = isCompleted ? cardView.backgroundColor?.withAlphaComponent(0.3) : cardView.backgroundColor
        completeButton.alpha = isCompleted ? 0.5 : 1.0
    }
    
    // MARK: - Layout
    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiContainerView)
        emojiContainerView.addSubview(emojiLabel)
        cardView.addSubview(trackerNameLabel)
        
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Карточка
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            // Контейнер эмодзи (серый кружок)
            emojiContainerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiContainerView.widthAnchor.constraint(equalToConstant: 24),
            emojiContainerView.heightAnchor.constraint(equalToConstant: 24),

            // Эмодзи (растягиваем по размеру контейнера и центрируем)
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainerView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainerView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalTo: emojiContainerView.widthAnchor),
            emojiLabel.heightAnchor.constraint(equalTo: emojiContainerView.heightAnchor),
            
            // Название трекера
            trackerNameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            trackerNameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            trackerNameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            trackerNameLabel.topAnchor.constraint(greaterThanOrEqualTo: emojiContainerView.bottomAnchor, constant: 8),
            
            // Кнопка
            completeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),
            
            // Счетчик дней
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            daysLabel.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor, constant: -8)
        ])
    }
}
