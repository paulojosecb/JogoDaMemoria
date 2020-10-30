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
    func didConnected(with player: GameState.Player)
    func didOtherPlayerFlippedWrongCard(card1: (Int, Int), card2: (Int, Int))
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
    case connection = "connection"
    case disconnection = "disconnection"
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

//Classe que gerencia o estado do jogo. Na atual implementação, o estado do jogo é recebido através de conexão socket.
// Logo, é necessário utilizar uma classe que seja responsável pela conexão para realizar as ações e receber as mensagens do GameState
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
    
    var yourPlayer: Player?
    
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
    var currentPlayer: Player? = nil
    var canStart: Bool {
        get {
            return false
        }
    }
    
    var playerOneConnected = false
    var playerTwoConnected = false
    
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
        manager.send(Command(type: CommandType.begin, value: "", player: yourPlayer!))
    }
    
    public func playerHasScore(_ player: Player) {
        manager.send(Command(type: CommandType.scored, value: "1", player: yourPlayer!))
    }
    
    public func playerHasChosenWrongCards(card1: (row: Int, col: Int), card2: (row: Int, col: Int)) {
        let card1Pos = self.convertToPos(row: card1.row, col: card1.col)
        let card2Pos = self.convertToPos(row: card2.row, col: card2.col)
        manager.send(Command(type: CommandType.wrongCard, value: "\(card1Pos)!\(card2Pos)", player: yourPlayer!))
    }
    
    public func restart() {
        manager.send(Command(type: CommandType.restart, value: "", player: yourPlayer!))
    }
    
    public func playerHasFlipped(row: Int, col: Int) {
        manager.send(Command(type: CommandType.playerHasFlipped, value: "\(self.convertToPos(row: row, col: col))", player: yourPlayer!))
    }
    
}

//Extensão para receber notificãoes do SocketManager quanto aos comandos recebidos do servidor
extension GameState: SocketManagerDelegate {
    func didReceived(_ command: Command) {
        self.parse(command)
    }
    
    //Método para direcionar o comando certo para o delegate
    private func parse(_ command: Command) {
        switch command.type {
        case .begin:
            self.delegate.didStartInitialCountdown()
            
        case .restart:
            self.delegate.didRestartGame()
            
        case .scored:
            guard let valueString = command.value as? String else {
                return
            }
            
            let value = valueString.components(separatedBy: ":")[1]
            
            self.delegate.didPlayerScored(player: command.player, points: Int(value) ?? 0)
            
        case .wrongCard:
            if (command.player != yourPlayer) {
                guard let valueString = command.value as? String else {
                    return
                }
                
                let valueTuple = valueString.components(separatedBy: ":")[1]
                let card1Pos = valueTuple.components(separatedBy: "!")[0]
                let card2Pos = valueTuple.components(separatedBy: "!")[1]
                
                self.delegate.didOtherPlayerFlippedWrongCard(card1: self.convert(pos: Int(card1Pos)!), card2: self.convert(pos: Int(card2Pos)!))
                
            }

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
            self.currentPlayer = command.player
            self.delegate.didStartGame(with: command.player)
            
        case .endGame:
            self.delegate.didEndGame(winner: command.player)
            
        case .switchTurn:
            self.currentPlayer = command.player
            self.delegate.didSwitchTurn(with: command.player)
            
        case .playerHasFlipped:
            if (command.player != yourPlayer) {
                guard let value = command.value as? String else {
                    fatalError()
                }
                let (r, c) = self.convert(pos: Int(value.components(separatedBy: ":")[1])!)
                self.delegate.didOtherPlayerFlipped(row: r, col: c)
            }
        case .connection:
            print("Connected")
            if (currentPlayer == nil) {
                self.yourPlayer = command.player
            }
            
            switch command.player {
            case .playerOne:
                playerOneConnected = true
            case .playerTwo:
                playerTwoConnected = true
            default:
                break
            }
            
            self.delegate.didConnected(with: command.player)
            
        case .disconnection:
            break
        }
    }
    
    //Converte uma posição da matrix para posição em vetor
    private func convertToPos(row: Int, col: Int) -> Int {
        let pos = (row * numberOfColumns) + col
        return pos
    }
    
    //Convere uma posição de vetor para posição de matrix
    private func convert(pos: Int) -> (Int, Int) {
        if (pos == 0) {
            return (0, 0)
        } else {
            let row = pos / numberOfColumns
            let col = pos % numberOfColumns
            
            return (row, col)
        }
    }

}
