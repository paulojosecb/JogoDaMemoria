//
//  ViewController.swift
//  JogoDaMemoria
//
//  Created by Paulo José on 30/09/20.
//

import UIKit

class ViewController: UIViewController {
    
    var gameState: GameState?
        
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
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 48)
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
        timerLabel.centerYAnchor.constraint(equalTo: playerOneLabel.centerYAnchor, constant: 0).isActive = true
        timerLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
        timerLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true
                
        startButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        startButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 8).isActive = true
        startButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        restartButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        restartButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 8).isActive = true
        restartButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        restartButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        gameState = GameState(delegate: self)
        
        self.resetPlayersLabels()
    }
    
    @objc func didStartButtonPressed(_ sender: UITapGestureRecognizer?) {
        gameState?.begin()
    }
    
    @objc func didRestartButtonPressed(_ sender: UITapGestureRecognizer?) {
        gameState?.restart()
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
        
        playerOneLabel.text = "\(gameState?.yourPlayer == GameState.Player.playerOne ? "You" : "Player One"): 0"
        playerTwoLabel.text = "\(gameState?.yourPlayer == GameState.Player.playerTwo ? "You" : "Player Two"): 0"
    }
    
    private func presentAlertFor(winner: GameState.Player) {
        let alertController = UIAlertController(title: "Winner", message: winner.rawValue, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
            self.resetPlayersLabels()
        }
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

}

//Extensão para receber notificações do GameState
extension ViewController: GameStateDelegate {
    func didOtherPlayerFlippedWrongCard(card1: (Int, Int), card2: (Int, Int)) {
        self.grid.flipBackCardOn(row: card1.0, col: card2.1)
        self.grid.flipBackCardOn(row: card2.0, col: card2.1)
    }
    
    func didConnected(with player: GameState.Player) {
        self.resetPlayersLabels()
    }
    
    func didOtherPlayerFlipped(row: Int, col: Int) {
        self.grid.flipCardOn(row: row, col: col)
    }
    
    func didPlayerScored(player: GameState.Player, points: Int) {
        switch player {
        case .playerOne:
            playerOneLabel.text = "\(gameState?.yourPlayer == GameState.Player.playerOne ? "You" : "Player One"): \(points)"
        case .playerTwo:
            playerTwoLabel.text = "\(gameState?.yourPlayer == GameState.Player.playerTwo ? "You" : "Player Two"): \(points)"
        case .server:
            break
        }
    }
    
    func didStartInitialCountdown() {
        
    }
    
    func didRestartGame() {
        self.resetPlayersLabels()
        self.timerLabel.text = "0"
        
        self.grid.flipbackAll()
    }
    
    func didStartGame(with player: GameState.Player) {
        updateLabelsWithSignifierFor(player: player)
        self.timerLabel.text = "10"
        
        grid.canInteract = gameState?.canInteract ?? false
    }
    
    func didEndGame(winner: GameState.Player) {
        self.presentAlertFor(winner: winner)
    }
    
    func didSwitchTurn(with player: GameState.Player) {
        updateLabelsWithSignifierFor(player: player)
        self.timerLabel.text = "10"
        
        grid.canInteract = gameState?.canInteract ?? false
    }
    
    func clockTicked(timeProgress: Int, for countdown: GameState.Countdown) {
        self.timerLabel.text = "\(timeProgress)"
    }
    
}

// Extensao de GridViewDelegate para receber notificações de ações no GridView
extension ViewController: GridViewDelegate {
    func didFinishPlay(card1Pos: (row: Int, col: Int), card2Pos: (row: Int, col: Int)) {
        self.gameState?.playerHasChosenWrongCards(card1: card1Pos, card2: card2Pos)
    }
    
    func didFlipped(row: Int, col: Int) {
        self.gameState?.playerHasFlipped(row: row, col: col)
    }
    
    func didScored() {
        guard let gameState = gameState else { return }
        gameState.playerHasScore(gameState.currentPlayer!)
    }
}


