import UIKit

public enum BiogramGiftLinkPrompt {
    /// Показать Alert: ввод ссылки t.me/nft/... или slug
    public static func present(from viewController: UIViewController, onResult: ((Bool) -> Void)? = nil) {
        let alert = UIAlertController(
            title: "Добавить gift",
            message: "Вставь ссылку https://t.me/nft/... или slug (VoodooDoll-319)",
            preferredStyle: .alert
        )
        alert.addTextField { tf in
            tf.placeholder = "https://t.me/nft/VoodooDoll-319"
            tf.autocapitalizationType = .none
            tf.autocorrectionType = .no
            tf.keyboardType = .URL
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in
            onResult?(false)
        })
        alert.addAction(UIAlertAction(title: "Добавить", style: .default) { _ in
            let text = alert.textFields?.first?.text ?? ""
            let ok = BiogramManager.shared.addCollectibleFromGiftLink(text) {
                // список обновится после completion
            }
            if !ok {
                let err = UIAlertController(
                    title: "Не добавлено",
                    message: "Неверная ссылка или такой gift уже есть",
                    preferredStyle: .alert
                )
                err.addAction(UIAlertAction(title: "OK", style: .default))
                viewController.present(err, animated: true)
            }
            onResult?(ok)
        })
        viewController.present(alert, animated: true)
    }
}
