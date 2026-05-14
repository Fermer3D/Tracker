import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    static let identifier = "ColorCollectionViewCell"
    
    private let colorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Настройка рамки выбора вокруг ячейки
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 3
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // МЕТОД 1: Установка основного цвета квадратика
    func setViewColor(_ color: UIColor) {
        colorView.backgroundColor = color
    }
    
    // МЕТОД 2: Логика отрисовки выделения (рамки)
    func setSelected(_ isSelected: Bool, with color: UIColor) {
        if isSelected {
            contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            contentView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
