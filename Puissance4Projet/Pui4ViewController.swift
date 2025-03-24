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
    
    func victoryCheck() {
        
        
    }
    
    func check(coin:[Int])-> Int {
        var cpt = 1
        let x=coin[0];let y=coin[1]
        if x != 0 {
            if y != 0 {
                
            }
            if y != Grille.count{
                
            }
        }
        if x != Grille[0].count {
            if y != 0 {
                
            }
            if y != Grille.count{
                
            }
        }
        return 0
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
