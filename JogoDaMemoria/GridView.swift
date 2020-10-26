//
//  Grid.swift
//  JogoDaMemoria
//
//  Created by Paulo José on 07/10/20.
//

import UIKit
import GLKit

protocol GridViewDelegate {
    func didFinishPlay()
    func didScored()
}

class GridView: UIView {
    
    let margin = 10
    let spaceBetween = 20
    
    let numberOfCards = 12
    let numberOfColumns = 4
    let numberOfRows = 3
    
    let delegate: GridViewDelegate
    
    var cards: [[UIImageView]] = [[UIImageView]]()
    var cardState: [[Bool]] = [[Bool]]()
    var imagesGrid = [[UIImage]]()
    
    var flippedCards: [UIImageView] = []
    
    var isMirrod = false
    
    var isAnimatingCard = false
    
    var hasBeenSetup = false
    
    var images = [
        UIImage(named: "photo1")!,
        UIImage(named: "photo2")!,
        UIImage(named: "photo3")!,
        UIImage(named: "photo4")!,
        UIImage(named: "photo5")!,
        UIImage(named: "photo6")!
    ]

    let emptyImage = UIImage()
    
    var canInteract = false {
        didSet {
            for row in cards {
                for card in row {
                    card.isUserInteractionEnabled = canInteract
                }
            }
        }
    }
    
    init(delegate: GridViewDelegate) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        imagesGrid = self.initImagesGrid(with: images)
        cardState = Array(repeating: Array(repeating: false, count: numberOfColumns), count: numberOfRows)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !hasBeenSetup {
            let gridWidth = self.bounds.width
            
            let remainSpaceWidth = Int(gridWidth) - (spaceBetween * (numberOfColumns - 1))
            let cardWidth =  remainSpaceWidth / numberOfColumns
            let cardHeight = Double(cardWidth) * 1.5
                    
            for row in 0..<numberOfRows {
                var viewRow = [UIImageView]()
                
                for col in 0..<numberOfColumns {
                    let posX = col * (cardWidth + spaceBetween)
                    let posY = row * (Int(cardHeight) + spaceBetween)
                    
                    let cardView = UIImageView(frame: CGRect(x: posX, y: posY, width: cardWidth, height: Int(cardHeight)))
                    
                    cardView.backgroundColor = .red
                    cardView.isUserInteractionEnabled = canInteract
                    cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCardView(sender:))))
                                    
                    viewRow.append(cardView)
                    self.addSubview(cardView)
                }
                cards.append(viewRow)
            }
            
            hasBeenSetup = true
        }
    
    }
    
    
    @objc func didTapCardView(sender: UITapGestureRecognizer?) {
        if flippedCards.count < 2 {
            guard let cardView = sender?.view as? UIImageView else {
                return
            }
            
            guard let (row, col) = self.getImageViewPositionIn(matrix: cards, imageView: cardView) else {
                return
            }
            
            let isCardFlipped = cardState[row][col]
            
            if !isCardFlipped && !isAnimatingCard {
                cardState[row][col] = true
                flippedCards.append(cardView)
                flipImageView(imageView: cardView, toImage: imagesGrid[row][col], duration: 0.3)
            }
            
        }
    }
    
    private func initImagesGrid(with source: [UIImage]) -> [[UIImage]] {
        var imagesMatrix = Array(repeating: Array(repeating: emptyImage, count: numberOfColumns), count: numberOfRows)
                
        for (index, image) in source.enumerated() {
//            var count = 0
//            insert(image: image, on: &imagesMatrix, count: &count)
            switch index {
            case 0:
                imagesMatrix[0][0] = image
                imagesMatrix[0][1] = image
            case 1:
                imagesMatrix[0][2] = image
                imagesMatrix[0][3] = image
            case 2:
                imagesMatrix[1][0] = image
                imagesMatrix[1][1] = image
            case 3:
                imagesMatrix[1][2] = image
                imagesMatrix[1][3] = image
            case 4:
                imagesMatrix[2][0] = image
                imagesMatrix[2][1] = image
            case 5:
                imagesMatrix[2][2] = image
                imagesMatrix[2][3] = image
            default:
                print()
            }
        }
        
        return imagesMatrix
    }
    
    
    private func check(flipperCards: [UIImageView]) {
        if flippedCards.count == 2 {
            if flippedCards.first?.image != flippedCards.last?.image {
                flipImageBack(imageView: flippedCards[0], duration: 0.3)
                flipImageBack(imageView: flippedCards[1], duration: 0.3)
                
                for card in flippedCards {
                    guard let (row, col) = getImageViewPositionIn(matrix: cards, imageView: card) else {
                        break
                    }
                    
                    cardState[row][col] = false
                }
                
                flippedCards = []
                delegate.didFinishPlay()
            } else {
                flippedCards = []
                delegate.didScored()
            }
        }
    }
    
    private func getImageViewPositionIn(matrix: [[UIImageView]], imageView: UIImageView) -> (Int, Int)? {
        
        for (indexRow, row) in matrix.enumerated() {
            if (row.contains(imageView)) {
                guard let col = row.firstIndex(of: imageView) else {
                    return nil
                }
                return (indexRow, col)
            }
        }
        
        return nil
    }
    
    private func flipImageView(imageView: UIImageView, toImage: UIImage, duration: TimeInterval, delay: TimeInterval = 0)
    {
        let t = duration / 2
        
        isAnimatingCard = true

        UIView.animate(withDuration: t, delay: delay, options: .curveEaseIn, animations: { () -> Void in

            // Rotate view by 90 degrees
            let p = CATransform3DMakeRotation(CGFloat(GLKMathDegreesToRadians(90)), 0.0, 1.0, 0.0)
            imageView.layer.transform = p

        }, completion: { (Bool) -> Void in

            // New image
            imageView.image = toImage

            // Rotate view to initial position
            // We have to start from 270 degrees otherwise the image will be flipped (mirrored) around Y axis
            let p = CATransform3DMakeRotation(CGFloat(GLKMathDegreesToRadians(270)), 0.0, 1.0, 0.0)
            imageView.layer.transform = p

            UIView.animate(withDuration: t, delay: 0, options: .curveEaseOut, animations: { () -> Void in

                // Back to initial position
                let p = CATransform3DMakeRotation(CGFloat(GLKMathDegreesToRadians(0)), 0.0, 1.0, 0.0)
                imageView.layer.transform = p

            }, completion: { [weak self] (Bool) -> Void in
                self?.check(flipperCards: self?.flippedCards ?? [])
                self?.isAnimatingCard = false
            })
        })
    }
    
    private func flipImageBack(imageView: UIImageView, duration: TimeInterval, delay: TimeInterval = 0)
    {
        let t = duration / 2

        UIView.animate(withDuration: t, delay: delay, options: .curveEaseIn, animations: { () -> Void in

            // Rotate view by 90 degrees
            let p = CATransform3DMakeRotation(CGFloat(GLKMathDegreesToRadians(90)), 0.0, 1.0, 0.0)
            imageView.layer.transform = p

        }, completion: { (Bool) -> Void in

            // New image
            imageView.image = self.emptyImage

            // Rotate view to initial position
            // We have to start from 270 degrees otherwise the image will be flipped (mirrored) around Y axis
            let p = CATransform3DMakeRotation(CGFloat(GLKMathDegreesToRadians(270)), 0.0, 1.0, 0.0)
            imageView.layer.transform = p

            UIView.animate(withDuration: t, delay: 0, options: .curveEaseOut, animations: { () -> Void in

                // Back to initial position
                let p = CATransform3DMakeRotation(CGFloat(GLKMathDegreesToRadians(0)), 0.0, 1.0, 0.0)
                imageView.layer.transform = p

            }, completion: { (Bool) -> Void in
            })
        })
    }

}
