import Foundation

public struct BiogramCollectible: Codable, Equatable {
    public let id: String
    public var title: String?
    public var author: String?
    public var assetFilename: String
    public var assetType: String
    public var createdAt: Date
    public var giftSlug: String?
    public var stickerFileId: Int64?

    public init(
        id: String = UUID().uuidString,
        title: String? = nil,
        author: String? = nil,
        assetFilename: String,
        assetType: String,
        createdAt: Date = Date(),
        giftSlug: String? = nil,
        stickerFileId: Int64? = nil
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.assetFilename = assetFilename
        self.assetType = assetType
        self.createdAt = createdAt
        self.giftSlug = giftSlug
        self.stickerFileId = stickerFileId
    }
}

public struct BiogramVirtualNumber: Codable, Equatable {
    public let id: String
    public var label: String?
    public var number: String
    public var createdAt: Date

    public init(
        id: String = UUID().uuidString,
        label: String? = nil,
        number: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.label = label
        self.number = number
        self.createdAt = createdAt
    }
}

public struct BiogramProfileColor: Codable, Equatable {
    /// 0...1 RGB
    public var r: Double
    public var g: Double
    public var b: Double
    /// 0...1 brightness multiplier
    public var brightness: Double
    /// Паттерн: "none", "skulls", "pentagrams", "stars", "crosses", "snowflakes", "frost"
    public var pattern: String
    /// Прозрачность паттерна 0...1
    public var patternOpacity: Double

    public init(
        r: Double,
        g: Double,
        b: Double,
        brightness: Double = 1.0,
        pattern: String = "none",
        patternOpacity: Double = 0.25
    ) {
        self.r = r
        self.g = g
        self.b = b
        self.brightness = brightness
        self.pattern = pattern
        self.patternOpacity = patternOpacity
    }

    public static let presets: [(String, BiogramProfileColor)] = [
        ("Blue", BiogramProfileColor(r: 0.25, g: 0.55, b: 0.95)),
        ("Dark Red", BiogramProfileColor(r: 0.55, g: 0.08, b: 0.12)),
        ("Purple", BiogramProfileColor(r: 0.55, g: 0.25, b: 0.85)),
        ("Green", BiogramProfileColor(r: 0.15, g: 0.65, b: 0.40)),
        ("Orange", BiogramProfileColor(r: 0.95, g: 0.45, b: 0.15)),
        ("Teal", BiogramProfileColor(r: 0.10, g: 0.70, b: 0.70)),
        ("Pink", BiogramProfileColor(r: 0.90, g: 0.30, b: 0.55)),
        ("Gray", BiogramProfileColor(r: 0.45, g: 0.45, b: 0.50)),
        ("Black", BiogramProfileColor(r: 0.08, g: 0.08, b: 0.10)),
        ("White", BiogramProfileColor(r: 0.95, g: 0.95, b: 0.97)),
    ]

    public static let patterns: [(String, String)] = [
        ("None", "none"),
        ("Skulls", "skulls"),
        ("Pentagrams", "pentagrams"),
        ("Stars", "stars"),
        ("Crosses", "crosses"),
        ("Snowflakes", "snowflakes"),
        ("Frost", "frost"),
    ]
}

public struct BiogramCustomizations: Codable, Equatable {
    public var localPremiumEnabled: Bool
    public var showPremiumBadge: Bool
    public var badgeStyle: String?
    public var localAliases: [String]
    public var profileColor: BiogramProfileColor?
    public var profileColorEnabled: Bool

    public init(
        localPremiumEnabled: Bool = false,
        showPremiumBadge: Bool = true,
        badgeStyle: String? = "stars",
        localAliases: [String] = [],
        profileColor: BiogramProfileColor? = nil,
        profileColorEnabled: Bool = false
    ) {
        self.localPremiumEnabled = localPremiumEnabled
        self.showPremiumBadge = showPremiumBadge
        self.badgeStyle = badgeStyle
        self.localAliases = localAliases
        self.profileColor = profileColor
        self.profileColorEnabled = profileColorEnabled
    }
}

public enum BiogramGiftLink {
    public static func slug(from input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        if !trimmed.contains("/"), !trimmed.contains(" ") { return trimmed }
        guard let url = URL(string: trimmed),
              let host = url.host?.lowercased(),
              host == "t.me" || host == "telegram.me" || host.hasSuffix(".t.me")
        else { return nil }
        let parts = url.path.split(separator: "/").map(String.init)
        if parts.count >= 2, parts[0].lowercased() == "nft" {
            let slug = parts[1]
            return slug.isEmpty ? nil : slug
        }
        return nil
    }
}

/// Локальный баннер профиля
public struct BiogramBanner: Codable, Equatable {
    public let id: String
    /// Имя файла внутри Application Support/Biogram/banners/
    public var localFilename: String
    /// "3:1", "16:9", "4:3", "1:1", "free"
    public var aspectRatio: String
    public var createdAt: Date

    public init(
        id: String = UUID().uuidString,
        localFilename: String,
        aspectRatio: String = "free",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.localFilename = localFilename
        self.aspectRatio = aspectRatio
        self.createdAt = createdAt
    }
}
