//
//  Pui4ViewController.swift
//  Puissance4Projet
//
//  Created by Timothe Vantard on 20/03/2025.
//

import UIKit

class Pui4ViewController: UIViewController {
    
    var currPlayer = 1
    var Grille : [[Int]] =
            [ [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],]
    
    var lastCoin : [Int]=[0,0]
    
    var directions : [(Int,Int)] = [(0, -1), (-1, -1), (-1,0), (1,-1)]
    
    func victoryCheck() -> Bool {
        for (dx,dy) in directions {
            let total = 1 + checkDirections(dir:(dx, dy)) + checkDirections(dir:(-dx, -dy))
            if total >= 4 {
                return true
            }
        }
        return false
    }
    
    func checkDirections(dir:(Int,Int))-> Int {
        var count=0
        var coinX = lastCoin[0]; var coinY = lastCoin[1]
        
        while 0 <= coinX && coinX < Grille[0].count && 0 <= coinY && coinY < Grille.count && Grille[coinY][coinX]==currPlayer{
            count += 1
            coinX += dir.0
            coinY += dir.1
        }
        return count
    }
            
            
            
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
