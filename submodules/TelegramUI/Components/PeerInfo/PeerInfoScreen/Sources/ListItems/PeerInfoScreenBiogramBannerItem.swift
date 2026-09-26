import Foundation
import UIKit
import AsyncDisplayKit
import Display
import AccountContext
import TelegramPresentationData
import Biogram

final class PeerInfoScreenBiogramBannerItem: PeerInfoScreenItem {
    let id: AnyHashable
    let image: UIImage?

    init(id: AnyHashable, image: UIImage?) {
        self.id = id
        self.image = image
    }

    func node() -> PeerInfoScreenItemNode {
        return PeerInfoScreenBiogramBannerItemNode()
    }
}

private final class PeerInfoScreenBiogramBannerItemNode: PeerInfoScreenItemNode {
    private let imageNode = ASImageNode()
    private let maskNode = ASImageNode()
    private let bottomSeparatorNode = ASDisplayNode()

    private var item: PeerInfoScreenBiogramBannerItem?

    override init() {
        super.init()

        // Баннер сохраняет оригинальное соотношение сторон.
        // Ширина фиксирована, высота рассчитывается автоматически.
        imageNode.contentMode = .scaleAspectFill
        imageNode.clipsToBounds = true
        imageNode.cornerRadius = 12.0
        imageNode.backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        addSubnode(imageNode)

        maskNode.isUserInteractionEnabled = false
        addSubnode(maskNode)

        bottomSeparatorNode.isLayerBacked = true
        addSubnode(bottomSeparatorNode)
    }

    override func update(
        context: AccountContext,
        width: CGFloat,
        safeInsets: UIEdgeInsets,
        presentationData: PresentationData,
        item: PeerInfoScreenItem,
        topItem: PeerInfoScreenItem?,
        bottomItem: PeerInfoScreenItem?,
        hasCorners: Bool,
        transition: ContainedViewLayoutTransition
    ) -> CGFloat {
        guard let item = item as? PeerInfoScreenBiogramBannerItem else {
            return 10.0
        }

        self.item = item

        let sideInset: CGFloat = 16.0 + safeInsets.left
        let rightInset: CGFloat = 16.0 + safeInsets.right
        let topInset: CGFloat = 8.0
        let bottomInset: CGFloat = 8.0

        let bannerWidth = max(
            1.0,
            width - sideInset - rightInset
        )

        /*
         * MARK: Banner size
         *
         * Width is fixed by the PeerInfo layout.
         * Height is calculated ONLY from the original image size.
         *
         * Examples:
         *
         * 1024 x 1024 -> square
         * 1600 x 900  -> 16:9
         * 900 x 1600  -> 9:16
         *
         * There is no manual height setting.
         * There is no height slider.
         * There is no clamp.
         */
        let bannerHeight: CGFloat

        if let image = item.image,
           image.size.width > 0.0,
           image.size.height > 0.0 {
            let aspectRatio = image.size.height / image.size.width
            bannerHeight = max(
                1.0,
                bannerWidth * aspectRatio
            )
        } else {
            // No image yet.
            // Keep a small placeholder instead of using
            // a stored/custom banner height.
            bannerHeight = 120.0
        }

        imageNode.image = item.image

        transition.updateFrame(
            node: imageNode,
            frame: CGRect(
                x: sideInset,
                y: topInset,
                width: bannerWidth,
                height: bannerHeight
            )
        )

        let height = topInset + bannerHeight + bottomInset

        bottomSeparatorNode.backgroundColor =
            presentationData.theme.list.itemBlocksSeparatorColor

        transition.updateFrame(
            node: bottomSeparatorNode,
            frame: CGRect(
                x: sideInset,
                y: height - UIScreenPixel,
                width: bannerWidth,
                height: UIScreenPixel
            )
        )

        transition.updateAlpha(
            node: bottomSeparatorNode,
            alpha: bottomItem == nil ? 0.0 : 1.0
        )

        let hasTopCorners = hasCorners && topItem == nil
        let hasBottomCorners = hasCorners && bottomItem == nil

        maskNode.image = hasCorners
            ? PresentationResourcesItemList.cornersImage(
                presentationData.theme,
                top: hasTopCorners,
                bottom: hasBottomCorners,
                glass: true
            )
            : nil

        maskNode.frame = CGRect(
            x: safeInsets.left,
            y: 0.0,
            width: width - safeInsets.left - safeInsets.right,
            height: height
        )

        bottomSeparatorNode.isHidden = hasBottomCorners

        return height
    }
}
