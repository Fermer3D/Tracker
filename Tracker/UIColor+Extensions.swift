import UIKit

extension UIColor {
    static var ypBlack: UIColor { UIColor(named: "YP Black") ?? .black }
    static var ypGray: UIColor { UIColor(named: "YP Gray") ?? .gray }
    static var ypRed: UIColor { UIColor(named: "YP Red") ?? .red }
    static var ypBlue: UIColor { UIColor(named: "YP Blue") ?? .blue }
    static var ypBg: UIColor { UIColor(named: "YP Background") ?? .systemBackground }
    
    // Добавили префикс 'app', чтобы 100% избежать конфликтов
    static var appButtonBg: UIColor { UIColor(named: "YP ButtonBg") ?? .black }
    static var appButtonText: UIColor { UIColor(named: "YP ButtonText") ?? .white }
}
