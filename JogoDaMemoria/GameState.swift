//
//  GameState.swift
//  JogoDaMemoria
//
//  Created by Paulo José on 07/10/20.
//

import Foundation

protocol GameStateDelegate {
    func didStartInitialCountdown()
    func didStartGame(with player: GameState.Player)
    func didEndGame(winner: GameState.Player)
    func didPlayerScored(player: GameState.Player, points: Int)
    func didSwitchTurn(with player: GameState.Player)
    func didRestartGame()
    func clockTicked(timeProgress: Int, for countdown: GameState.Countdown)
    func didOtherPlayerFlipped(row: Int, col: Int) 
}

protocol SocketManagerDelegate {
    func didReceived(_ command: Command)
}

struct Command {
    let type: CommandType
    let value: Any
    let player: GameState.Player
}

enum CommandType: String {
    case begin = "begin"
    case scored = "scored"
    case wrongCard = "wrondCard"
    case restart = "restart"
    case clockTicked = "clockTicked"
    case startGame = "startGame"
    case endGame = "endGame"
    case switchTurn = "switchTurn"
    case playerHasFlipped = "playerHasFlipped"
}

class GameState {
    
    enum Player : String {
        case playerOne = "Player One"
        case playerTwo = "Player Two"
        case server = "Server"
    }
        
    enum Countdown: Int {
        case startCountdown = 3
        case turnCountdown = 10
    }
    
    enum GameStateError: Error {
        case invalidPlayer
        case cannotEndTurn
    }
    
    let numberOfPairs = 5
    
    let numberOfColumns = 4
    let numberOfRows = 3
    
    let delegate: GameStateDelegate
    
    let yourPlayer = Player.playerOne
    
    let manager: SocketManager
    
    var canInteract: Bool {
        get {
            return currentPlayer == yourPlayer
        }
    }
    
    var timer: Timer?
    var startCounter = Countdown.startCountdown.rawValue
    var turnCounter = Countdown.turnCountdown.rawValue
    
    var currentCountdown: Countdown = .startCountdown
    
    var isGamePlaying = false
    var currentPlayer: Player = .playerOne
    
    private var playerOnePoints = 0 {
        didSet {
            delegate.didPlayerScored(player: .playerOne, points: playerOnePoints)
        }
    }
    
    private var playerTwoPoints = 0 {
        didSet {
            delegate.didPlayerScored(player: .playerTwo, points: playerTwoPoints)
        }
    }
    
    init(delegate: GameStateDelegate) {
        self.delegate = delegate
        manager = SocketManager()
        manager.setupNetworkCommunication()
        manager.delegate = self
    }
    
    public func begin() {
        manager.send(Command(type: CommandType.begin, value: "", player: yourPlayer))
    }
    
    public func playerHasScore(_ player: Player) {
        manager.send(Command(type: CommandType.scored, value: "1", player: yourPlayer))
    }
    
    public func playerHasChosenWrongCards() {
        manager.send(Command(type: CommandType.wrongCard, value: "", player: yourPlayer))
    }
    
    public func restart() {
        manager.send(Command(type: CommandType.restart, value: "", player: yourPlayer))
    }
    
    public func playerHasFlipped(row: Int, col: Int) {
        manager.send(Command(type: CommandType.playerHasFlipped, value: "\(self.convertToPos(row: row, col: col))", player: yourPlayer))
    }
    
}

extension GameState: SocketManagerDelegate {
    func didReceived(_ command: Command) {
        self.parse(command)
    }
    
    private func parse(_ command: Command) {
        switch command.type {
        case .begin:
            self.delegate.didStartInitialCountdown()
            
        case .restart:
            self.delegate.didRestartGame()
            
        case .scored:
            self.delegate.didPlayerScored(player: command.player, points: 0)
            
        case .wrongCard:
            break
            
        case .clockTicked:
            guard let valueString = command.value as? String else {
                return
            }
            
            let valueTuple = valueString.components(separatedBy: ":")[1]
            let value = valueTuple.components(separatedBy: "!")[0]
            let countdownType = valueTuple.components(separatedBy: "!")[1]
            
            guard let countdown = Countdown(rawValue: Int(countdownType) ?? 0),
                  let valueAsInt = Int(value) else {
                return
            }
            
            self.delegate.clockTicked(timeProgress: valueAsInt, for: countdown)
            
        case .startGame:
            self.delegate.didStartGame(with: command.player)
            
        case .endGame:
            self.delegate.didEndGame(winner: command.player)
            
        case .switchTurn:
            self.delegate.didSwitchTurn(with: command.player)
            
        case .playerHasFlipped:
            if (command.player != yourPlayer) {
                let (r, c) = self.convert(pos: command.value as! Int)
                self.delegate.didOtherPlayerFlipped(row: r, col: c)
            }
        }
    }
    
    private func convertToPos(row: Int, col: Int) -> Int {
        let pos = (row * numberOfColumns) + col
        return pos
    }
    
    private func convert(pos: Int) -> (Int, Int) {
        return (0, 0)
    }

}
