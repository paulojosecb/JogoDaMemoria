//
//  Grid.swift
//  JogoDaMemoria
//
//  Created by Paulo José on 07/10/20.
//

import UIKit
import GLKit

protocol GridViewDelegate {
    func didFinishPlay(card1Pos: (row: Int, col: Int), card2Pos: (row: Int, col: Int))
    func didScored()
    func didFlipped(row: Int, col: Int)
}

// Classe responsável por gerenciar os cartões na tela, assim como as ações realizadas e as animações das mesmas

/* O grid consiste em uma matrix de UIImageViews que pode ser rotacionadas e ter uma imagem associadas a elas
    Tais imagens são guardadas no imagesGrid e associadas a posição da matrix cards no momento da rotação. Além disso,
    existe outra matrix, cardState, que guarda as informações se uma determinada carta está virada ou não
 */

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
        
        // Prepara o grid após o auto-layout da tela estiver calculado
        
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
            
            self.delegate.didFlipped(row: row, col: col)
            let isCardFlipped = cardState[row][col]
            
            if !isCardFlipped && !isAnimatingCard {
                cardState[row][col] = true
                flippedCards.append(cardView)
                flipImageView(imageView: cardView, toImage: imagesGrid[row][col], duration: 0.3)
            }
            
        }
    }
    
    //Inicializa a matrix de imagens
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
    
    // Checa para determinar se as cardas viradas são iguais ou não. Caso sim, notifica o delegate que houve um acerto,
    // Caso não, notifica o delegate que houve um erro e anima as cartas de volta a posição inicial
    private func check(flipperCards: [UIImageView]) {
        if flippedCards.count == 2 {
            if flippedCards.first?.image != flippedCards.last?.image {
                flipImageBack(imageView: flippedCards[0], duration: 0.3)
                flipImageBack(imageView: flippedCards[1], duration: 0.3)
                
                var card1Pos = (0, 0)
                var card2Pos = (0, 0)
                
                for (index, card) in flippedCards.enumerated() {
                    guard let (row, col) = getImageViewPositionIn(matrix: cards, imageView: card) else {
                        break
                    }
                    
                    cardState[row][col] = false
                    
                    if (index == 0) {
                        card1Pos = (row, col)
                    } else {
                        card2Pos = (row, col)
                    }
                }
                
                flippedCards = []
                delegate.didFinishPlay(card1Pos: card1Pos, card2Pos: card2Pos)
            } else {
                flippedCards = []
                delegate.didScored()
            }
        }
    }
    
    //Retorna a posição na matrix de uma determina imagem
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
    
    //Método público para virar uma determinada carta
    public func flipCardOn(row: Int, col: Int) {
        self.flipImageView(imageView: cards[row][col], toImage: imagesGrid[row][col], duration: 0.3)
    }
    
    //Método público para retornar uma carta a posição inicial
    public func flipBackCardOn(row: Int, col: Int) {
        let card = cards[row][col]
        self.flipImageBack(imageView: card, duration: 0.1)
    }
    
    //Métodos de animação de virada das cartas
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
    
    public func flipbackAll() {
        for (indexRow, row) in cards.enumerated() {
            for (indexCol, card) in row.enumerated() {
                cardState[indexRow][indexCol] = false
                flipImageBack(imageView: card, duration: 0.1)
            }
        }
    }

}
