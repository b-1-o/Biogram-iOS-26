import Foundation

/// Simple local storage using Codable + file persistence.
/// Each Telegram account has its own JSON payload.
public final class BiogramStorage {
    private let queue = DispatchQueue(label: "org.biogram.storage", qos: .utility)
    private let accountsFolder: URL
    private var currentAccountId: String = "default"

    public struct StoragePayload: Codable {
        public var customizations: BiogramCustomizations
        public var aliases: [String]
        public var virtualNumbers: [BiogramVirtualNumber]
        public var collectibles: [BiogramCollectible]
        public var banner: BiogramBanner?

        public init(
            customizations: BiogramCustomizations = BiogramCustomizations(),
            aliases: [String] = [],
            virtualNumbers: [BiogramVirtualNumber] = [],
            collectibles: [BiogramCollectible] = [],
            banner: BiogramBanner? = nil
        ) {
            self.customizations = customizations
            self.aliases = aliases
            self.virtualNumbers = virtualNumbers
            self.collectibles = collectibles
            self.banner = banner
        }
    }

    private var payload: StoragePayload = StoragePayload()

    public init(baseDirectory: URL? = nil) {
        let base = baseDirectory
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())

        let folder = base.appendingPathComponent("Biogram", isDirectory: true)
        let accounts = folder.appendingPathComponent("accounts", isDirectory: true)
        try? FileManager.default.createDirectory(at: accounts, withIntermediateDirectories: true, attributes: nil)
        self.accountsFolder = accounts
    }

    public func setCurrentAccountId(_ id: String) {
        self.queue.async {
            self.currentAccountId = self.safeAccountId(id)
        }
    }

    public func load(for accountId: String, completion: @escaping (StoragePayload) -> Void) {
        let normalizedId = self.safeAccountId(accountId)
        self.queue.async {
            self.currentAccountId = normalizedId

            let url = self.fileURL(for: normalizedId)
            if let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode(StoragePayload.self, from: data) {
                self.payload = decoded
            } else {
                self.payload = StoragePayload()
                self.saveSync()
            }

            completion(self.payload)
        }
    }

    public func setCustomizations(_ custom: BiogramCustomizations, completion: (() -> Void)? = nil) {
        self.queue.async {
            self.payload.customizations = custom
            self.saveSync()
            completion?()
        }
    }

    public func addAlias(_ alias: String, completion: (() -> Void)? = nil) {
        self.queue.async {
            if !self.payload.aliases.contains(alias) {
                self.payload.aliases.append(alias)
                self.saveSync()
            }
            completion?()
        }
    }

    public func removeAlias(_ alias: String, completion: (() -> Void)? = nil) {
        self.queue.async {
            self.payload.aliases.removeAll { $0 == alias }
            self.saveSync()
            completion?()
        }
    }

    public func replaceAliases(_ aliases: [String], completion: (() -> Void)? = nil) {
        self.queue.async {
            self.payload.aliases = aliases
            self.saveSync()
            completion?()
        }
    }

    public func addVirtualNumber(_ number: BiogramVirtualNumber, completion: (() -> Void)? = nil) {
        self.queue.async {
            self.payload.virtualNumbers.append(number)
            self.saveSync()
            completion?()
        }
    }

    public func removeVirtualNumber(id: String, completion: (() -> Void)? = nil) {
        self.queue.async {
            self.payload.virtualNumbers.removeAll { $0.id == id }
            self.saveSync()
            completion?()
        }
    }

    public func replaceVirtualNumbers(_ numbers: [BiogramVirtualNumber], completion: (() -> Void)? = nil) {
        self.queue.async {
            self.payload.virtualNumbers = numbers
            self.saveSync()
            completion?()
        }
    }

    public func addCollectible(_ collectible: BiogramCollectible, completion: (() -> Void)? = nil) {
        self.queue.async {
            self.payload.collectibles.append(collectible)
            self.saveSync()
            completion?()
        }
    }

    public func removeCollectible(id: String, completion: (() -> Void)? = nil) {
        self.queue.async {
            self.payload.collectibles.removeAll { $0.id == id }
            self.saveSync()
            completion?()
        }
    }

    public func replaceCollectibles(_ items: [BiogramCollectible], completion: (() -> Void)? = nil) {
        self.queue.async {
            self.payload.collectibles = items
            self.saveSync()
            completion?()
        }
    }

    /// Metadata only. The actual banner file is owned by BiogramManager's banner I/O queue.
    public func setBanner(_ banner: BiogramBanner?, completion: (() -> Void)? = nil) {
        self.queue.async {
            self.payload.banner = banner
            self.saveSync()
            completion?()
        }
    }

    private func fileURL(for accountId: String) -> URL {
        return self.accountsFolder.appendingPathComponent("\(self.safeAccountId(accountId)).json")
    }

    private func safeAccountId(_ id: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let result = id.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" }
        let value = String(result)
        return value.isEmpty ? "default" : value
    }

    private func saveSync() {
        let url = self.fileURL(for: self.currentAccountId)
        guard let data = try? JSONEncoder().encode(self.payload) else {
            return
        }
        try? data.write(to: url, options: [.atomic])
    }
}
