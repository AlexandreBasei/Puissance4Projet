//
//  Pui4ViewController.swift
//  Puissance4Projet
//
//  Created by Timothe Vantard on 20/03/2025.
//

import UIKit
import QuartzCore
import AVFoundation

class Pui4ViewController: UIViewController {
    var audioPlayer: AVAudioPlayer? //Initialisation du lecteur de son pour les bruitages

    var nbPlayer = 1
    var currPlayer = 1              //toujours l'humain qui commence
    
    var win = false
    
    var Grille : [[Int]] =
            [ [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],
              [0,0,0,0,0,0,0],]
    
    var contenu : [UIImage] = []
    
    let j1Img = UIImage(named: "CoinJ1.png")!
    let j2Img = UIImage(named: "CoinJ2.png")!
    
    var difficulté : Int = 3        // à modifier avec la page précédente
    var lastCoin : (Int,Int) = (-1,-1)
    var lastAiCoin : (Int,Int) = (-1,-1)
    
    var directions : [(Int,Int)] = [(0, -1), (-1, -1), (-1,0), (1,-1)]      // dans l'ordre gauche, diagonale gh, haut, diagonale droite-haut
    
    
    @IBOutlet weak var roundLabel: UILabel!
    
    
    @IBOutlet weak var roundImg: UIImageView!
    
    
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet var grilleImage: UIImageView!
    
    
    @IBOutlet weak var confettiView: UIView!
    
    
    @IBAction func insertCoin(_ sender: UIButton) {
        let result = mettreJeton(x: sender.tag)
        
        if result != nil {
            lastCoin = result!
            let (row, col) = result!
            
            animJeton(colonne: col, ligne: row, couleur: currPlayer)
            
            if checkCombinaisons(cible: 4, player: currPlayer, coin:lastCoin) != nil {
                print("Joueur n°\(currPlayer) a gagné")
                roundLabel.text = "Le joueur \((currPlayer == 1) ? "jaune" : "rouge") a gagné !"
                win = true
                playSound(csound: "victorySound")
                createConfettiEffect()
                for i in buttons {
                    i.isEnabled = false
                }
            }
            
            if !win {
                currPlayer = (currPlayer == 1) ? 2 : 1
                roundImg.image = contenu[currPlayer - 1]
                roundLabel.text = "C'est le tour du joueur \((currPlayer == 1) ? "jaune" : "rouge")"
            }
            
            if nbPlayer==1 && currPlayer == 2 && !win{
                iaJouer()
                if checkCombinaisons(cible: 4, player: currPlayer, coin:lastCoin) != nil {
                    print("Joueur n°\(currPlayer) a gagné")
                    roundLabel.text = "Le joueur \((currPlayer == 1) ? "jaune" : "rouge") a gagné !"
                    win = true
                    // Jouer l'animation et le son de victoire ou de défaite en fonction du gagnant
                    if currPlayer == 2 {
                        playSound(csound: "loseSound") //Trouver un son
                    }
                    else {
                        playSound(csound: "victorySound")
                        createConfettiEffect()
                    }
                    
                    for i in buttons {
                        i.isEnabled = false
                    }
                }
                
                if !win {
                    currPlayer = 1
                    roundImg.image = contenu[currPlayer - 1]
                    roundLabel.text = "C'est le tour du joueur \((currPlayer == 1) ? "jaune" : "rouge")"
                }
            }
            print(lastCoin, lastAiCoin)
        }
    }
    
    
    func animJeton(colonne: Int, ligne: Int, couleur: Int) {
        playSound()
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
    
    func playSound(csound: String = "") {
        // Tableau contenant les noms des fichiers audio des jetons
        let soundFiles = ["pui4audio1", "pui4audio2", "pui4audio3", "pui4audio4"]
        
        var sound = csound
        
        // Si le son n'est pas custom, jouer un son de jeton aléatoire
        if sound.isEmpty {
            sound = soundFiles.randomElement() ?? "pui4audio1" // son joué par défaut en cas d'erreur
        }
        
        // Utilisation de NSDataAsset pour récupérer le fichier audio dans les assets
        if let audioAsset = NSDataAsset(name: sound) {
            do {
                audioPlayer = try AVAudioPlayer(data: audioAsset.data)
                audioPlayer?.play()
                print("Son joué : \(sound)")
            } catch {
                print("Erreur de lecture du fichier audio: \(error.localizedDescription)")
            }
        } else {
            print("Le fichier audio \(sound) n'a pas été trouvé dans les assets.")
        }
    }


    func createConfettiEffect() {
        let colors: [UIColor] = (currPlayer == 1) ? [.yellow] : [.red] // Couleur des confettis basée sur le joueur
        let numberOfConfettis = 150 // Nombre de confettis à générer
        
        for _ in 0..<numberOfConfettis {
            let confetti = CALayer()
            
            // Définir la taille des confettis
            let size = CGFloat.random(in: 4...17) // Taille aléatoire du confetti
            confetti.frame = CGRect(x: CGFloat.random(in: 0...view.bounds.width), y: 0, width: size, height: size)
            
//            confetti.cornerRadius = size / 2
            confetti.backgroundColor = colors.randomElement()?.cgColor
            
            // Ajoutez les confettis à la vue
            view.layer.addSublayer(confetti)
            
            // Animation de chûte
            let fallAnimation = CAKeyframeAnimation(keyPath: "position")
            fallAnimation.values = [
                NSValue(cgPoint: confetti.position),
                NSValue(cgPoint: CGPoint(x: confetti.position.x + CGFloat.random(in: -100...100), y: view.bounds.height + size)) // Déplacement vers le bas
            ]
            fallAnimation.keyTimes = [0, 1]
            fallAnimation.duration = TimeInterval.random(in: 2.0...4.0) // Durée de la chute aléatoire
            fallAnimation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut)]
            
            // Animation de rotation
            let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
            rotateAnimation.values = [0, CGFloat.random(in: -Double.pi...Double.pi), 0]
            rotateAnimation.keyTimes = [0, 0.5, 1]
            rotateAnimation.duration = fallAnimation.duration
            
            // Groupement des animations
            let group = CAAnimationGroup()
            group.animations = [fallAnimation, rotateAnimation]
            group.duration = fallAnimation.duration
            group.isRemovedOnCompletion = false
            group.fillMode = .forwards
            
            // Appliquer l'animation aux confettis
            confetti.add(group, forKey: "fallingConfetti")
            
            // Enlever les confettis après l'animation
            DispatchQueue.main.asyncAfter(deadline: .now() + group.duration) {
                confetti.removeFromSuperlayer()
            }
        }
    }


            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contenu = [j1Img, j2Img]
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
