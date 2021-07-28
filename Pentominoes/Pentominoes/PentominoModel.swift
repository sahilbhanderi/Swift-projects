//
//  Model.swift
//  Pentominoes
//
//  Created by John Hannan on 8/28/18.
//  Copyright (c) 2018 John Hannan. All rights reserved.
//

import Foundation

// identifies placement of a single pentomino on a board
struct Position : Codable {
    var x : Int
    var y : Int
    var isFlipped : Bool
    var rotations : Int
}

// A solution is a dictionary mapping piece names ("T", "F", etc) to positions
// All solutions are read in and maintained in an array
typealias Solution = [String:Position]
typealias Solutions = [Solution]

class Model {
    let allSolutions : Solutions //[[String:[String:Int]]]
    private let boards : [String]
    private let boardCount = 6
    private let numberOfPieces = 12
    private let pieceLetters = ["F", "I", "L", "N", "P", "T", "U", "V", "W", "X", "Y", "Z"]
    private let pieces : [String]
    
    init () {
        let mainBundle = Bundle.main
        let solutionURL = mainBundle.url(forResource: "Solutions", withExtension: "plist")
        var _boards = [String]()
        var _pieces = [String]()

        do {
            let data = try Data(contentsOf: solutionURL!)
            let decoder = PropertyListDecoder()
            allSolutions = try decoder.decode(Solutions.self, from: data)
        } catch {
            print(error)
            allSolutions = []
        }
        
        for i in 0..<boardCount {
            _boards.append("Board\(i)")
        }
        boards = _boards
        
        for i in 0..<numberOfPieces {
            _pieces.append("Piece\(pieceLetters[i])")
        }
        pieces = _pieces
    }
    
    func boardName(tag i: Int) -> String {
        return boards[i%boardCount]
    }
    
    func numberPieces() -> Int {
        return numberOfPieces
    }
    
    func pieceName(index i: Int) -> String {
        return pieces[i%numberOfPieces]
    }

    func getSolutionPosition(tag t: Int, index i: Int) -> Position{
        let boardSolution = allSolutions[t-1]
        let pieceSolution = boardSolution[pieceLetters[i]]!
        return pieceSolution
    }
    
}
