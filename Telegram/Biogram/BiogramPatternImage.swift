import UIKit

public enum BiogramPatternImage {
    /// Dense Telegram-style pattern across the full cover.
    /// No clear zone — symbols fill the entire area.
    public static func make(
        pattern: String,
        color: UIColor,
        opacity: CGFloat,
        canvasSize: CGSize = CGSize(width: 420.0, height: 420.0),
        avatarCenter: CGPoint? = nil,
        avatarSize: CGSize? = nil
    ) -> UIImage? {
        guard pattern != "none",
              canvasSize.width > 1.0,
              canvasSize.height > 1.0 else {
            return nil
        }

        let symbol: String
        switch pattern {
        case "skulls":
            symbol = "𐕣"
        case "pentagrams":
            symbol = "⛧"
        case "stars":
            symbol = "✦"
        case "crosses":
            symbol = "✠"
        case "snowflakes":
            symbol = "❆"
        case "frost":
            symbol = "❅"
        default:
            return nil
        }

        let clampedOpacity = max(0.0, min(1.0, opacity))
        guard clampedOpacity > 0.0 else {
            return nil
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false

        return UIGraphicsImageRenderer(size: canvasSize, format: format).image { rendererContext in
            let context = rendererContext.cgContext

            let minDimension = min(canvasSize.width, canvasSize.height)

            let symbolSize = max(14.0, min(28.0, minDimension * 0.055))
            let horizontalSpacing = symbolSize * 1.55
            let verticalSpacing = symbolSize * 1.40

            let font = UIFont.systemFont(ofSize: symbolSize, weight: .regular)
            let text = symbol as NSString
            let textSize = text.size(withAttributes: [
                .font: font,
                .foregroundColor: color.withAlphaComponent(clampedOpacity)
            ])

            func variation(x: Int, y: Int) -> CGFloat {
                let value = sin(Double(x * 127 + y * 311)) * 43758.5453
                return CGFloat(value - floor(value))
            }

            let startY = -verticalSpacing
            let endY = canvasSize.height + verticalSpacing
            let startX = -horizontalSpacing
            let endX = canvasSize.width + horizontalSpacing

            var row = 0
            var y = startY

            while y <= endY {
                let rowOffset = (row % 2 == 0) ? 0.0 : horizontalSpacing * 0.5
                var column = 0
                var x = startX + rowOffset

                while x <= endX {
                    let jitterX = (variation(x: column, y: row) - 0.5) * symbolSize * 0.20
                    let jitterY = (variation(x: column + 71, y: row + 17) - 0.5) * symbolSize * 0.16
                    let finalPoint = CGPoint(x: x + jitterX, y: y + jitterY)
                    let rotation = (variation(x: column + 19, y: row + 53) - 0.5) * 0.22
                    let scale = 0.78 + variation(x: column + 37, y: row + 101) * 0.30

                    let drawAttributes: [NSAttributedString.Key: Any] = [
                        .font: font,
                        .foregroundColor: color.withAlphaComponent(clampedOpacity)
                    ]

                    context.saveGState()
                    context.translateBy(x: finalPoint.x, y: finalPoint.y)
                    context.rotate(by: rotation)
                    context.scaleBy(x: scale, y: scale)
                    text.draw(
                        at: CGPoint(x: -textSize.width * 0.5, y: -textSize.height * 0.5),
                        withAttributes: drawAttributes
                    )
                    context.restoreGState()

                    column += 1
                    x += horizontalSpacing
                }

                row += 1
                y += verticalSpacing
            }
        }
    }

    public static func uiColor(from profileColor: BiogramProfileColor) -> UIColor {
        let brightness = max(0.1, min(1.5, profileColor.brightness))
        return UIColor(
            red: CGFloat(max(0.0, min(1.0, profileColor.r * brightness))),
            green: CGFloat(max(0.0, min(1.0, profileColor.g * brightness))),
            blue: CGFloat(max(0.0, min(1.0, profileColor.b * brightness))),
            alpha: 1.0
        )
    }
}
