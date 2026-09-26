import Foundation
import UIKit
import AsyncDisplayKit
import Display
import AccountContext
import TelegramPresentationData
import Biogram

final class PeerInfoScreenBiogramGiftsItem: PeerInfoScreenItem {
    let id: AnyHashable
    let collectibles: [BiogramCollectible]
    
    init(id: AnyHashable, collectibles: [BiogramCollectible]) {
        self.id = id
        self.collectibles = collectibles
    }
    
    func node() -> PeerInfoScreenItemNode {
        return PeerInfoScreenBiogramGiftsItemNode()
    }
}

private final class PeerInfoScreenBiogramGiftsItemNode: PeerInfoScreenItemNode {
    private let maskNode = ASImageNode()
    private let bottomSeparatorNode = ASDisplayNode()
    private var cellNodes: [ASDisplayNode] = []
    private var labelNodes: [ImmediateTextNode] = []
    
    private var item: PeerInfoScreenBiogramGiftsItem?
    
    override init() {
        super.init()
        
        self.maskNode.isUserInteractionEnabled = false
        self.addSubnode(self.maskNode)
        
        self.bottomSeparatorNode.isLayerBacked = true
        self.addSubnode(self.bottomSeparatorNode)
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
        guard let item = item as? PeerInfoScreenBiogramGiftsItem else {
            return 10.0
        }
        self.item = item
        
        let columns = 3
        let spacing: CGFloat = 8.0
        let sideInset: CGFloat = 16.0 + safeInsets.left
        let topInset: CGFloat = 12.0
        let bottomInset: CGFloat = 12.0
        
        let contentWidth = width - sideInset - (16.0 + safeInsets.right)
        let cellSize = floor((contentWidth - spacing * CGFloat(columns - 1)) / CGFloat(columns))
        
        let count = item.collectibles.count
        let rows = max(1, Int(ceil(CGFloat(count) / CGFloat(columns))))
        
        // переиспользуем / создаём ячейки
        while self.cellNodes.count < count {
            let cell = ASDisplayNode()
            cell.clipsToBounds = true
            cell.cornerRadius = 12.0
            self.addSubnode(cell)
            self.cellNodes.append(cell)
            
            let label = ImmediateTextNode()
            label.maximumNumberOfLines = 2
            label.textAlignment = .center
            label.isUserInteractionEnabled = false
            cell.addSubnode(label)
            self.labelNodes.append(label)
        }
        while self.cellNodes.count > count {
            self.cellNodes.removeLast().removeFromSupernode()
            self.labelNodes.removeLast().removeFromSupernode()
        }
        
        for i in 0 ..< count {
            let collectible = item.collectibles[i]
            let title = collectible.title ?? collectible.giftSlug ?? collectible.id
            
            let row = i / columns
            let col = i % columns
            let x = sideInset + CGFloat(col) * (cellSize + spacing)
            let y = topInset + CGFloat(row) * (cellSize + spacing)
            
            let cell = self.cellNodes[i]
            cell.backgroundColor = presentationData.theme.list.itemBlocksBackgroundColor.withMultipliedBrightnessBy(1.15)
            // чуть заметнее на тёмной теме
            if presentationData.theme.overallDarkAppearance {
                cell.backgroundColor = UIColor(white: 1.0, alpha: 0.08)
            } else {
                cell.backgroundColor = UIColor(white: 0.0, alpha: 0.06)
            }
            transition.updateFrame(node: cell, frame: CGRect(x: x, y: y, width: cellSize, height: cellSize))
            
            let label = self.labelNodes[i]
            // временно: emoji-подарок + название (позже — стикер)
            label.attributedText = NSAttributedString(
                string: "🎁\n\(title)",
                font: Font.regular(12.0),
                textColor: presentationData.theme.list.itemPrimaryTextColor,
                paragraphAlignment: .center
            )
            let labelSize = label.updateLayout(CGSize(width: cellSize - 8.0, height: cellSize - 8.0))
            label.frame = CGRect(
                origin: CGPoint(x: floor((cellSize - labelSize.width) / 2.0), y: floor((cellSize - labelSize.height) / 2.0)),
                size: labelSize
            )
        }
        
        let height = topInset + CGFloat(rows) * cellSize + CGFloat(max(0, rows - 1)) * spacing + bottomInset
        
        self.bottomSeparatorNode.backgroundColor = presentationData.theme.list.itemBlocksSeparatorColor
        transition.updateFrame(
            node: self.bottomSeparatorNode,
            frame: CGRect(x: sideInset, y: height - UIScreenPixel, width: width - sideInset - 16.0, height: UIScreenPixel)
        )
        transition.updateAlpha(node: self.bottomSeparatorNode, alpha: bottomItem == nil ? 0.0 : 1.0)
        
        let hasCorners = hasCorners && (topItem == nil || bottomItem == nil)
        let hasTopCorners = hasCorners && topItem == nil
        let hasBottomCorners = hasCorners && bottomItem == nil
        self.maskNode.image = hasCorners
            ? PresentationResourcesItemList.cornersImage(presentationData.theme, top: hasTopCorners, bottom: hasBottomCorners, glass: true)
            : nil
        self.maskNode.frame = CGRect(
            x: safeInsets.left,
            y: 0.0,
            width: width - safeInsets.left - safeInsets.right,
            height: height
        )
        self.bottomSeparatorNode.isHidden = hasBottomCorners
        
        return height
    }
}
