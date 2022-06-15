import UIKit

extension UIColor {

    static let main: UIColor = UIColor(red: 244, green: 244, blue: 244)
    static let textGray: UIColor = UIColor(red: 153, green: 153, blue: 153)
    static let accentGreen: UIColor = UIColor(red: 13, green: 171, blue: 76)

    // MARK: - Private

    private convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: alpha
        )
    }

}
