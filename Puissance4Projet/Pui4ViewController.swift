//
//  Pui4ViewController.swift
//  Puissance4Projet
//
//  Created by Timothe Vantard on 20/03/2025.
//

import UIKit

class Pui4ViewController: UIViewController {
    var nbPlayer = 1
    var currPlayer = 1
    var Grille : [[Int]] =
            [ [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],]
    
    var lastCoin : (Int,Int) = (-1,-1)
    var lastAiCoin : (Int,Int) = (-1,-1)
    
    var directions : [(Int,Int)] = [(0, -1), (-1, -1), (-1,0), (1,-1)]      // dans l'ordre gauche, diagonale gh, haut, diagonale droite-haut
    
    
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet var grilleImage: UIImageView!
    
    
    @IBAction func insertCoin(_ sender: UIButton) {
        let result = mettreJeton(x: sender.tag)
        
        if result.0 {
            let (row, col) = result.1
            
            animJeton(colonne: col, ligne: row, couleur: currPlayer)
            
            if checkCombinaisons(cible: 4, player: currPlayer, coin:lastCoin).0 {
                print("Joueur n°\(currPlayer) a gagné")
                for i in buttons {
                    i.isEnabled = false
                }
            }
            currPlayer = (currPlayer == 1) ? 2 : 1
            
            if nbPlayer==1 && currPlayer == 2 {
                iaJouer()
                
            }
            print(lastCoin, lastAiCoin)
        }
    }
    
    func iaJouer() {
        var door = true
        // Désactiver tous les boutons avant que l'IA joue
        for i in buttons {
            i.isEnabled = false
        }
        //Attendre 3s avant la suite du code pour simuler la réflexion de l'IA
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
        //Tour de l'IA
            if checkCombinaisons(cible: 3, player: 2, coin:lastAiCoin).0 {
                print("3 alignés pour l'ia")
                
                let res = checkIaAxe(player: 2, dir: checkCombinaisons(cible: 3, player: 1,coin:lastAiCoin).1,coin:lastAiCoin)
                
                print(res)
                
                
                if res.0 {
                    door = false
                    let result = mettreJeton(x: res.1.1)
                    if result.0 {
                        let (row, col) = result.1
                        animJeton(colonne: col, ligne: row, couleur: currPlayer)
                        lastAiCoin = lastCoin
                        currPlayer = (self.currPlayer == 1) ? 2 : 1
                    }
                }
                
            }
            if checkCombinaisons(cible: 3, player: 1, coin:lastCoin).0 && door == true{
                print("3 alignés pour le joueur")
                
                let res = checkIaAxe(player: 1, dir: checkCombinaisons(cible: 3, player: 1, coin:lastCoin).1, coin:lastCoin)
                print(res)
                
                if res.0 {
                    door = false
                    let result = mettreJeton(x: res.1.1)
                    if result.0 {
                        let (row, col) = result.1
                        animJeton(colonne: col, ligne: row, couleur: currPlayer)
                        lastAiCoin = lastCoin
                        currPlayer = (self.currPlayer == 1) ? 2 : 1
                    }
                }
            }
            if checkCombinaisons(cible: 2, player: 2, coin:lastAiCoin).0 && door               == true{
                print("2 alignés pour l'ia")
            }
            if checkCombinaisons(cible: 1, player: 2, coin:lastAiCoin).0 && door == true{
                print("1 aligné pour l'ia")
            }
            if door == true {
                let randomX = Int.random(in: 0...6)
                let result = mettreJeton(x: randomX)
                
                if result.0 {
                    let (row, col) = result.1
                    animJeton(colonne: col, ligne: row, couleur: currPlayer)
                    lastAiCoin = lastCoin
                    currPlayer = (self.currPlayer == 1) ? 2 : 1
            
                }
            }
            //Réactiver tous les boutons après que l'IA ait joué
            for i in buttons {
                i.isEnabled = true
            }
            print(lastCoin,lastAiCoin)
        }
    }
    
    func checkIaAxe(player: Int, dir: (Int, Int), coin: (Int,Int)) -> (Bool, (Int,Int))  {
        let (dirX,dirY)=dir
        
        let checkDirMin = checkIaDirection(player: player, dir: (-dirX,-dirY),
                                           coin: coin)
        let checkDirPos = checkIaDirection(player: player, dir: (dirX,dirY),
                                           coin: coin)
        
        if checkDirMin.0{
            return checkDirMin
        } else if checkDirPos.0 {
            return checkDirPos
        } else {
            return checkDirMin
        }
    }
    
    func checkIaDirection(player: Int, dir: (Int, Int), coin: (Int,Int)) -> (Bool, (Int,Int)) {
        var (coinY, coinX) = coin
        
        while 0 <= coinX && coinX < Grille[0].count && 0 <= coinY && coinY < Grille.count && Grille[coinY][coinX]==player {
            // parcours de l'axe jusqu'à une couleur différente.
            coinX += dir.0
            coinY += dir.1
        }
        if 0 <= coinX && coinX < Grille[0].count && 0 <= coinY && coinY < Grille.count {
            if Grille[coinY][coinX]==0{
                return (true,(coinY,coinX))
            }
        }
        return (false,(-1,-1))
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
    
    func mettreJeton(x: Int)->(Bool,(Int,Int)) {
        for i in (0..<Grille.count).reversed() {
            // on regarde à quelle ligne, la colonne chosie est libre (donc on part du bas vers le haut car c'est plus simple dans notre esprit)
            
            if Grille[i][x]==0{
                Grille[i][x]=currPlayer
                lastCoin=(i,x)
                return (true, lastCoin)
            }
        }
        return (false, (-1,-1))
        // si y'a pas de place, ça renvoie false
    }
    
    func checkCombinaisons(cible: Int, player: Int, coin: (Int,Int)) -> (Bool,(Int,Int)) {
        for (dx,dy) in directions {
            let total = 1 + checkDirections(dir:(dx, dy), player:player, coin:coin) + checkDirections(dir:(-dx, -dy), player:player, coin:coin)
            // on regarde les axes horizontal, diagonal hg->bd, vertical et diagonal hd->bg
            
            if total >= cible {
                return (true,(dx,dy))
            }
        }
        return (false,(0,0))
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
