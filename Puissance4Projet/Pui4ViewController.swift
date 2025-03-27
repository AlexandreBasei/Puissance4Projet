//
//  Pui4ViewController.swift
//  Puissance4Projet
//
//  Created by Timothe Vantard on 20/03/2025.
//

import UIKit

class Pui4ViewController: UIViewController {
    var nbPlayer = 1
    var currPlayer = 1              //toujours l'humain qui commence
    var Grille : [[Int]] =
            [ [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],]
    
    var difficulté : Int = 3        // à modifier avec la page précédente
    var lastCoin : (Int,Int) = (-1,-1)
    var lastAiCoin : (Int,Int) = (-1,-1)
    
    var directions : [(Int,Int)] = [(0, -1), (-1, -1), (-1,0), (1,-1)]      // dans l'ordre gauche, diagonale gh, haut, diagonale droite-haut
    
    
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet var grilleImage: UIImageView!
    
    
    @IBAction func insertCoin(_ sender: UIButton) {
        let result = mettreJeton(x: sender.tag)
        
        if result != nil {
            lastCoin = result!
            let (row, col) = result!
            
            animJeton(colonne: col, ligne: row, couleur: currPlayer)
            
            if checkCombinaisons(cible: 4, player: currPlayer, coin:lastCoin) != nil {
                print("Joueur n°\(currPlayer) a gagné")
                for i in buttons {
                    i.isEnabled = false
                }
            }
            currPlayer = (currPlayer == 1) ? 2 : 1
            
            if nbPlayer==1 && currPlayer == 2 {
                iaJouer()
                if checkCombinaisons(cible: 4, player: currPlayer, coin:lastCoin) != nil {
                    print("Joueur n°\(currPlayer) a gagné")
                    for i in buttons {
                        i.isEnabled = false
                    }
                }
                currPlayer = 1
            }
            print(lastCoin, lastAiCoin)
        }
    }
    
    
    func animJeton(colonne: Int, ligne: Int, couleur: Int) {
        let tailleJeton: CGFloat = 40  // Taille du jeton
        let startX = CGFloat(colonne) * (tailleJeton + 5.8) + 40 // Position de départ en X
        let startY: CGFloat = 260  // Position de départ en haut de l'écran

        // Sélection de l'image selon le joueur
        let jeton = UIImageView(image: UIImage(named: "CoinJ"+String(couleur)))
        jeton.frame = CGRect(x: startX, y: startY, width: tailleJeton, height: tailleJeton)
        
        // Assurer que le jeton est ajouté sous la grille
        self.view.insertSubview(jeton, belowSubview: grilleImage)
            
        // Position finale en fonction de la ligne de la grille
        let finalY = CGFloat(ligne) * (tailleJeton + 6) + 308
            

        // Animation de chute
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut) {
            jeton.frame.origin.y = finalY
        } completion: { _ in
            print("Jeton inséré en (\(ligne), \(colonne))")
        }
    }
    
    
    
    func mettreJeton(x: Int)->(Int,Int)? {
        for y in (0..<Grille.count).reversed() {
            // on regarde à quelle ligne, la colonne chosie est libre (donc on part du bas vers le haut car c'est plus simple dans notre esprit)
            
            if Grille[y][x]==0{
                Grille[y][x]=currPlayer
                lastCoin=(y,x)
                return (y,x)
            }
        }
        return nil
        // si y'a pas de place, ça renvoie nil
    }
    
    func checkCombinaisons(cible: Int, player: Int, coin: (Int,Int)) -> (Int,Int)? {
        for (dx,dy) in directions {
            let total = 1 + checkDirections(dir:(dx, dy), player:player, coin:coin) + checkDirections(dir:(-dx, -dy), player:player, coin:coin)
            // on regarde les axes horizontal, diagonal hg->bd, vertical et diagonal hd->bg
            
            if total >= cible {
                return (dx,dy)
            }
        }
        return nil
    }
    func scanTableau(player: Int) -> [(Int, Int)]? {
        for y in 0..<Grille.count {
            for x in 0..<Grille[y].count {
                if Grille[y][x] == player {  // Si on trouve un jeton du joueur actuel
                    // Vérifier dans toutes les directions
                    for (dx, dy) in directions {
                        if checkDirections(dir:(dx,dy), player: player, coin : (y,x)) >= 4 {
                            return [(dx, dy)]  // Renvoie la direction si une combinaison est trouvée
                        }
                    }
                }
            }
        }
        return nil  // Aucune combinaison trouvée
    }
    
    func checkDirections(dir:(Int,Int), player: Int, coin: (Int,Int))-> Int {
        var count=0
        var (coinY, coinX) = coin
        
        while 0 <= coinX && coinX < Grille[0].count && 0 <= coinY && coinY < Grille.count && Grille[coinY][coinX]==player {
            // parcours de l'axe jusqu'à une couleur différente.
            count += 1
            coinX += dir.0
            coinY += dir.1
        }
        return count - 1 //On soustrait 1 car on a compté le jeton actuel deux fois
    }
    
    // fonctions min-max pour IA
    
    func iaJouer() {
        var bestVal = -Int.max
        var bestMove = -1
        for col in 0..<Grille[0].count {
            let resultat = mettreJeton(x: col)
            if let _ = resultat {
                let (y, x) = resultat!
                let moveVal = minimax(board: Grille, depth: difficulté, isMaximizingPlayer: false)
                if moveVal > bestVal {
                    bestVal = moveVal
                    bestMove = col
                }
                Grille[y][x] = 0  // Annule le mouvement
            }
        }
        if bestMove != -1 {
            let result = mettreJeton(x: bestMove)
            lastCoin = result!
            animJeton(colonne: bestMove, ligne: lastCoin.0, couleur: 2)  // L'IA joue
        }
    }
    
    func evaluer(board: [[Int]], coinjoue: (Int,Int)) -> Int {
        // Vérifier les combinaisons de 4 jetons
        if checkCombinaisons(cible: 4, player: 2, coin: coinjoue) != nil {
            return 1000  // L'IA gagne
        }
        if checkCombinaisons(cible: 4, player: 1, coin: coinjoue) != nil {
            return -1000  // L'humain gagne
        }

        // Vérifier les combinaisons de 3 jetons
        if checkCombinaisons(cible: 3, player: 2, coin: coinjoue) != nil {
            return 500  // L'IA peut gagner dans les prochains tours
        }
        if checkCombinaisons(cible: 3, player: 1, coin: coinjoue) != nil {
            return -500  // L'humain peut gagner, il faut bloquer
        }

        return 0  // Aucune combinaison trouvée
    }

    func minimax(board: [[Int]], depth: Int, isMaximizingPlayer: Bool) -> Int {
        let score = evaluer(board: board, coinjoue: lastCoin)

        // Terminer si un joueur a gagné ou si la profondeur maximale est atteinte
        if score == 1000 || score == -1000 || depth == 0 {
            return score
        }

        var best: Int
        if isMaximizingPlayer {
            best = -Int.max
            for col in 0..<board[0].count {
                let resultat = mettreJeton(x: col)
                if let _ = resultat {
                    let (y, x) = resultat!
                    let moveVal = minimax(board: board, depth: depth - 1, isMaximizingPlayer: false)
                    best = max(best, moveVal)
                    Grille[y][x] = 0  // Annule le mouvement après évaluation
                }
            }
        } else {
            best = Int.max
            for col in 0..<board[0].count {
                let resultat = mettreJeton(x: col)
                if let _ = resultat {
                    let (y, x) = resultat!
                    let moveVal = minimax(board: board, depth: depth - 1, isMaximizingPlayer: true)
                    best = min(best, moveVal)
                    Grille[y][x] = 0  // Annule le mouvement après évaluation
                }
            }
        }
        return best
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
