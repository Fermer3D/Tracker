import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
    func pinTracker(at indexPath: IndexPath)
    func editTracker(at indexPath: IndexPath)
    func deleteTracker(at indexPath: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackerCollectionViewCell"
    
    // MARK: - Properties
    weak var delegate: TrackerCellDelegate?
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    private var isCompleted: Bool = false
    private var isPinned: Bool = false
    
    // MARK: - UI Elements
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let emojiContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
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
    
    private let pinImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "pin.fill"))
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
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
        // ИСПРАВЛЕНИЕ: Используем .label для автоматического переключения черный/белый
        label.textColor = .label
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
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cardView.addInteraction(interaction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackerId = nil
        indexPath = nil
        isCompleted = false
        isPinned = false
        pinImageView.isHidden = true
        daysLabel.text = nil
        completeButton.setImage(nil, for: .normal)
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
    func configure(with tracker: Tracker, isCompleted: Bool, completedDaysString: String, indexPath: IndexPath) {
        self.trackerId = tracker.id
        self.isCompleted = isCompleted
        self.isPinned = tracker.isPinned
        self.indexPath = indexPath
        
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        trackerNameLabel.text = tracker.name
        daysLabel.text = completedDaysString.contains("(null)") ? "0 дней" : completedDaysString
        
        pinImageView.isHidden = !tracker.isPinned
        
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
    
    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiContainerView)
        emojiContainerView.addSubview(emojiLabel)
        cardView.addSubview(pinImageView)
        cardView.addSubview(trackerNameLabel)
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            emojiContainerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiContainerView.widthAnchor.constraint(equalToConstant: 24),
            emojiContainerView.heightAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainerView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainerView.centerYAnchor),
            
            pinImageView.centerYAnchor.constraint(equalTo: emojiContainerView.centerYAnchor),
            pinImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            pinImageView.widthAnchor.constraint(equalToConstant: 24),
            pinImageView.heightAnchor.constraint(equalToConstant: 24),
            
            trackerNameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            trackerNameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            trackerNameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            completeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor)
        ])
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPath else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            
            let pinTitle = self.isPinned ? NSLocalizedString("unpin_action", comment: "") : NSLocalizedString("pin_action", comment: "")
            
            let pinAction = UIAction(title: pinTitle) { _ in
                self.delegate?.pinTracker(at: indexPath)
            }
            let editAction = UIAction(title: NSLocalizedString("edit_action", comment: "")) { _ in
                self.delegate?.editTracker(at: indexPath)
            }
            let deleteAction = UIAction(title: NSLocalizedString("delete_action", comment: ""), attributes: .destructive) { _ in
                self.delegate?.deleteTracker(at: indexPath)
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}
