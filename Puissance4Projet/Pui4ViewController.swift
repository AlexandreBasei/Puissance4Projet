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
    
    var lastCoin : (Int,Int) = (-1,-1)
    
    var directions : [(Int,Int)] = [(0, -1), (-1, -1), (-1,0), (1,-1)]      // dans l'ordre gauche, diagonale gh, haut, diagonale droite-haut
    
    
    @IBAction func insertCoin(_ sender: UIButton) {
        let result = mettreJeton(x: sender.tag)
            
            if result.0 {
                let (row, col) = result.1
                animJeton(colonne: col, ligne: row, couleur: currPlayer)
            }
    }
    
    func animJeton(colonne: Int, ligne: Int, couleur: Int) {
        let tailleJeton: CGFloat = 40  // Taille du jeton
        let startX = CGFloat(colonne) * (tailleJeton + 5) + 20  // Position de départ en X
        let startY: CGFloat = 20  // Position de départ en haut de l'écran
        let finalY = CGFloat(ligne) * (tailleJeton + 5) + 100  // Destination en Y

        // Sélection de l'image selon le joueur
        let jeton = UIImageView(image: UIImage(named: "CoinJ"+String(couleur)))
        jeton.frame = CGRect(x: startX, y: startY, width: tailleJeton, height: tailleJeton)
        
        self.view.addSubview(jeton) // Ajout du jeton à la vue principale

        // Animation de chute
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            jeton.frame.origin.y = finalY
        } completion: { _ in
            print("Jeton inséré en (\(ligne), \(colonne))")
        }
    }
    
    func mettreJeton(x: Int)->(Bool,(Int,Int)) {
        for i in (0..<Grille.count).reversed() {
            // on regarde à quelle ligne, la colonne chosie est libre (donc on part du bas vers le haut car c'est plus simple dans notre esprit)
            
            if Grille[i][x]==0{
                Grille[i][x]=currPlayer
                lastCoin=(i,x)
                print(Grille)
                return (true, lastCoin)
            }
        }
        print(Grille)
        return (false, (-1,-1))
        // si y'a pas de place, ça renvoie false
    }
    
    func victoryCheck() -> Bool {
        for (dx,dy) in directions {
            let total = 1 + checkDirections(dir:(dx, dy)) + checkDirections(dir:(-dx, -dy))
            // on regarde les axes horizontal, diagonal hg->bd, vertical et diagonal hd->bg
            
            if total >= 4 {
                return true
            }
        }
        return false
    }
    
    func checkDirections(dir:(Int,Int))-> Int {
        var count=0
        var coinX = lastCoin.0; var coinY = lastCoin.1
        
        while 0 <= coinX && coinX < Grille[0].count && 0 <= coinY && coinY < Grille.count && Grille[coinY][coinX]==currPlayer {
            // parcours de l'axe jusqu'à une couleur différente.
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
