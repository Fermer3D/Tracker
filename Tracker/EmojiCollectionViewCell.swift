import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    static let identifier = "EmojiCollectionViewCell"
    
    let emojiLabel: UILabel = {
        let label = UILabel()
        // Изменение 1: Попробуем явно задать размер через системный шрифт без лишних весов
        label.font = UIFont.systemFont(ofSize: 38)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        // Изменение 2: Запрещаем лейблу пытаться "сжимать" эмодзи
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            // Изменение 3: Растягиваем лейбл по всему размеру ячейки, чтобы ему было просторно
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Изменение 4: Обнуляем текст при переиспользовании (на всякий случай)
    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = nil
    }
}
