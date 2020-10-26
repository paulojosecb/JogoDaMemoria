//
//  ViewController.swift
//  JogoDaMemoria
//
//  Created by Paulo José on 30/09/20.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var gameState = GameState(delegate: self)
        
    lazy var grid: GridView = {
        let view = GridView(delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var playerOneLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Player 1: 0"
        return label
    }()
    
    lazy var playerTwoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Player 2: 0"
        return label
    }()
    
    lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        return label
    }()
    
    lazy var startButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didStartButtonPressed(_:))))
        return button
    }()
    
    lazy var restartButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Restart", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didRestartButtonPressed(_:))))
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(grid)
        self.view.addSubview(playerOneLabel)
        self.view.addSubview(playerTwoLabel)
        self.view.addSubview(timerLabel)
        
        self.view.addSubview(startButton)
        self.view.addSubview(restartButton)
        
        grid.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        grid.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        grid.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        grid.heightAnchor.constraint(equalTo: grid.widthAnchor, constant: 1.5).isActive = true
        
        playerOneLabel.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
        playerOneLabel.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 24).isActive = true
        
        playerTwoLabel.centerYAnchor.constraint(equalTo: playerOneLabel.centerYAnchor).isActive = true
        playerTwoLabel.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor).isActive = true
        
        timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        timerLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
        timerLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
        timerLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        startButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        startButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 8).isActive = true
        startButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        restartButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        restartButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 8).isActive = true
        restartButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        restartButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    @objc func didStartButtonPressed(_ sender: UITapGestureRecognizer?) {
        gameState.begin()
    }
    
    @objc func didRestartButtonPressed(_ sender: UITapGestureRecognizer?) {
        gameState.restart()
    }
    
    private func updateLabelsWithSignifierFor(player: GameState.Player) {
        switch player {
        case .playerOne:
            playerOneLabel.textColor = .green
            playerTwoLabel.textColor = .black
        case .playerTwo:
            playerOneLabel.textColor = .black
            playerTwoLabel.textColor = .green
        case .server:
            print("Server");
        }
    }
    
    private func resetPlayersLabels() {
        playerOneLabel.textColor = .black
        playerTwoLabel.textColor = .black
        
        playerOneLabel.text = "Player 1: 0"
        playerTwoLabel.text = "Player 2: 0"
    }
    
    private func presentAlertFor(winner: GameState.Player) {
        let alertController = UIAlertController(title: "Winner", message: winner.rawValue, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
            self.resetPlayersLabels()
        }
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

//    private func insert(image: UIImage, on matrix: inout [[UIImage]], count: inout Int) {
//        
//        if isMatrixComplete(&matrix) {
//            return
//        }
//        
//        let row = Int.random(in: 0..<numberOfRows)
//        let col = Int.random(in: 0..<numberOfColumns)
//        
//        if matrix[row][col] == emptyImage {
//            matrix[row].remove(at: col)
//            matrix[row].insert(image, at: col)
//            count += 1
//        } else {
//            insert(image: image, on: &matrix, count: &count)
//        }
//        
//        if (count < 2) {
//            insert(image: image, on: &matrix, count: &count)
//        } else {
//            return
//        }
//        
//    }
//    
//    func isMatrixComplete(_ matrix: inout [[UIImage]]) -> Bool {
//        let isEmptyImagePresent = matrix.reduce(false) { (previousResult, row) -> Bool in
//            row.contains(emptyImage) || previousResult
//        }
//        
//        //Se a imagem vazia estiver presente, não está completa
//        return !isEmptyImagePresent
//    }
        
}

extension ViewController: GameStateDelegate {
    func didOtherPlayerFlipped(row: Int, col: Int) {
        
    }
    
    func didPlayerScored(player: GameState.Player, points: Int) {
        switch player {
        case .playerOne:
            playerOneLabel.text = "Player One: \(points)"
        case .playerTwo:
            playerTwoLabel.text = "Player Two: \(points)"
        case .server:
            break
        }
    }
    
    func didStartInitialCountdown() {
        
    }
    
    func didRestartGame() {
        self.resetPlayersLabels()
        self.timerLabel.text = "0"
    }
    
    func didStartGame(with player: GameState.Player) {
        updateLabelsWithSignifierFor(player: player)
        self.timerLabel.text = "10"
        
        grid.canInteract = gameState.canInteract
    }
    
    func didEndGame(winner: GameState.Player) {
        self.presentAlertFor(winner: winner)
    }
    
    func didSwitchTurn(with player: GameState.Player) {
        updateLabelsWithSignifierFor(player: player)
        self.timerLabel.text = "10"
        
        grid.canInteract = gameState.canInteract
    }
    
    func clockTicked(timeProgress: Int, for countdown: GameState.Countdown) {
        self.timerLabel.text = "\(timeProgress)"
    }
    
}

extension ViewController: GridViewDelegate {
    func didFinishPlay() {
        self.gameState.playerHasChosenWrongCards()
    }
    
    func didScored() {
        self.gameState.playerHasScore(gameState.currentPlayer)
    }
}


