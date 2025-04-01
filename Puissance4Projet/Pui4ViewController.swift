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
            
            if checkWinner(board: Grille) != nil{
                print("Joueur n°\(currPlayer) a gagné")
                roundLabel.text = "Le joueur \((currPlayer == 1) ? "jaune" : "rouge") a gagné !"
                win = true
                print(Grille)
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
                for i in buttons {
                    i.isEnabled = false
                }
                print(currPlayer)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.iaJouer()
                    
                    if self.checkWinner(board: self.Grille) != nil {
                        print("Joueur n°\(self.currPlayer) a gagné")
                        self.roundLabel.text = "Le joueur \((self.currPlayer == 1) ? "jaune" : "rouge") a gagné !"
                        self.win = true
                        
                        // Jouer l'animation et le son de victoire ou de défaite en fonction du gagnant
                        if self.currPlayer == 2 {
                            self.playSound(csound: "looseSound") //Trouver un son
                        }
                    }
                    
                    if !self.win {
                        self.currPlayer = 1
                        self.roundImg.image = self.contenu[self.currPlayer - 1]
                        self.roundLabel.text = "C'est le tour du joueur \((self.currPlayer == 1) ? "jaune" : "rouge")"
                        for i in self.buttons {
                            i.isEnabled = true
                        }
                    }
                }
            }
            print(lastCoin, lastAiCoin)
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
    
    // FONCTION MIN MAX IA ---------------------------
    
    func iaJouer() {
        let meilleurCoup = findBestMove(board: &Grille, maxDepth: difficulté)
        
        if let colonne = meilleurCoup {
            if let (ligne, _) = self.mettreJeton(x: colonne) {
                lastAiCoin = (ligne, colonne)
                animJeton(colonne: colonne, ligne: ligne, couleur: 2)
            }
        }
    }
    
    // Vérifie s'il reste au moins une colonne où jouer (la case en haut de la colonne est vide)
    func isMovesLeft(board: [[Int]]) -> Bool {
        for col in 0..<board[0].count {
            if board[0][col] == 0 {
                return true
            }
        }
        return false
    }

    // Simule le dépôt d'un jeton dans une colonne pour un joueur donné
    // Retourne la ligne où le jeton a été posé ou nil si la colonne est pleine
    func dropCoin(board: inout [[Int]], col: Int, player: Int) -> Int? {
        for row in (0..<board.count).reversed() {
            if board[row][col] == 0 {
                board[row][col] = player
                return row
            }
        }
        return nil
    }

    // Annule un coup en remettant à zéro la cellule (row, col)
    func removeCoin(board: inout [[Int]], row: Int, col: Int) {
        board[row][col] = 0
    }
    // Vérifie si un joueur a gagné dans la grille optimisée
    // Retourne le numéro du joueur gagnant (1 ou 2) si une combinaison de 4 est trouvée, sinon nil
    
    func checkWinner(board: [[Int]]) -> Int? {
        let rows = board.count, cols = board[0].count
        // On définit les 4 directions de recherche : horizontale, verticale et les 2 diagonales
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        
        // Parcourt chaque cellule de la grille
        for row in 0..<rows {
            for col in 0..<cols {
                let player = board[row][col]
                if player == 0 { continue } // Cellule vide, on passe au suivant
                
                // Pour chaque direction, on compte le nombre de jetons identiques
                for (dx, dy) in directions {
                    // Compte le jeton courant + ceux dans le sens positif et négatif
                    let count = 1 +
                        countDirection(board: board, row: row, col: col, dx: dx, dy: dy, player: player) +
                        countDirection(board: board, row: row, col: col, dx: -dx, dy: -dy, player: player)
                    
                    // Si on atteint 4, le joueur gagne
                    if count >= 4 {
                        return player
                    }
                }
            }
        }
        return nil
    }

    // Compte le nombre de jetons identiques à partir d'une cellule donnée, dans une direction donnée (dx, dy)
    func countDirection(board: [[Int]], row: Int, col: Int, dx: Int, dy: Int, player: Int) -> Int {
        var count = 0
        var currentRow = row + dx
        var currentCol = col + dy
        let rows = board.count, cols = board[0].count
        
        // Tant que l'on reste dans les bornes et que le jeton est identique, on incrémente
        while currentRow >= 0, currentRow < rows, currentCol >= 0, currentCol < cols,
              board[currentRow][currentCol] == player {
            count += 1
            currentRow += dx
            currentCol += dy
        }
        return count
    }
    
    // Fonction d'évaluation de l'état du plateau
    // Renvoie une valeur positive si l'IA (joueur 2) est gagnante, négative si le joueur 1 l'est
    // Le paramètre 'depth' permet d'influencer le score pour favoriser les victoires rapides
    func evaluateBoard(board: [[Int]], depth: Int) -> Int {
        if let winner = checkWinner(board: board) {
            if winner == 2 { // IA gagne
                return 1000 - depth
            } else if winner == 1 { // Humain gagne
                return -1000 + depth
            }
        }
        return 0
    }
    
    // Algorithme Minimax avec élagage Alpha-Bêta
    // - board: grille actuelle
    // - depth: niveau de récursion actuel
    // - maxDepth: profondeur maximale (pour limiter le temps de calcul)
    // - alpha et beta: valeurs pour l'élagage
    // - maximizingPlayer: true si c'est le tour de l'IA (joueur 2), false sinon
    func minimax(board: inout [[Int]], depth: Int, maxDepth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool) -> Int {
        var alpha = alpha
        var beta = beta
        let score = evaluateBoard(board: board, depth: depth)
        
        // Condition d'arrêt : victoire ou profondeur maximale ou plateau plein
        if abs(score) >= (1000 - depth) || depth == maxDepth || !isMovesLeft(board: board) {
            return score
        }
        
        if maximizingPlayer {
            var maxEval = -10000
            for col in 0..<board[0].count {
                // Si la colonne n'est pas pleine
                if board[0][col] == 0 {
                    if let row = dropCoin(board: &board, col: col, player: 2) {
                        let eval = minimax(board: &board, depth: depth + 1, maxDepth: maxDepth, alpha: alpha, beta: beta, maximizingPlayer: false)
                        removeCoin(board: &board, row: row, col: col)
                        maxEval = max(maxEval, eval)
                        alpha = max(alpha, eval)
                        if beta <= alpha { break }
                    }
                }
            }
            return maxEval
        } else {
            var minEval = 10000
            for col in 0..<board[0].count {
                if board[0][col] == 0 {
                    if let row = dropCoin(board: &board, col: col, player: 1) {
                        let eval = minimax(board: &board, depth: depth + 1, maxDepth: maxDepth, alpha: alpha, beta: beta, maximizingPlayer: true)
                        removeCoin(board: &board, row: row, col: col)
                        minEval = min(minEval, eval)
                        beta = min(beta, eval)
                        if beta <= alpha { break }
                    }
                }
            }
            return minEval
        }
    }

    // Trouve le meilleur coup pour l'IA et retourne l'indice de la colonne
    // maxDepth permet de régler la difficulté en limitant la profondeur de recherche
    func findBestMove(board: inout [[Int]], maxDepth: Int) -> Int? {
        var bestScore = -10000
        var bestColumn: Int? = nil
        var alpha = -10000
        var beta = 10000
        
        for col in 0..<board[0].count {
            // On ne teste que les colonnes non pleines
            if board[0][col] == 0 {
                if let row = dropCoin(board: &board, col: col, player: 2) {
                    let score = minimax(board: &board, depth: 0, maxDepth: maxDepth, alpha: alpha, beta: beta, maximizingPlayer: false)
                    removeCoin(board: &board, row: row, col: col)
                    if score > bestScore {
                        bestScore = score
                        bestColumn = col
                    }
                }
            }
        }
        return bestColumn
    }
    
    // fonction pour le style ---------------------------
    
    
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
