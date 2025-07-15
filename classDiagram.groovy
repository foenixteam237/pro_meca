classDiagram
    direction BT

    class Utilisateur {
        +id: int
        +nom: string
        +email: string
        +password: string
        +dateInscription: DateTime
        +historiqueActions: string[]
        +seConnecter()
        +resetPassword()
    }

    class Role {
        +id: int
        +nom: string (Admin, Technicien, Réceptionniste)
        +permissions: string[]
    }

    class Client {
        +id: int
        +nom: string
        +email: string
        +telephone: string
        +vehicules: Véhicule[]
    }

    class Véhicule {
        +id: int
        +immatriculation: string
        +marque: string
        +modele: string
        +historiqueVisites: Visite[]
    }

    class Visite {
        +id: int
        +dateArrivee: DateTime
        +dateSortie: DateTime?
        +dysfonctionnements: string
        +demandeClient: string
        +satisfaction: Évaluation?
    }

    class Intervention {
        +id: int
        +type: string
        +dateDebut: DateTime
        +dateFin: DateTime?
        +etat: string (EN_ATTENTE, EN_COURS, TERMINE)
        +diagnostic: string
        +remarques: string[]
        +technicien: Utilisateur
        +vehicule: Vehicule
    }

    class Pièce {
        +id: int
        +référence: string
        +désignation: string
        +marque: string
        +quantitéStock: int
        +seuilCritique: int
        +compatibilités: string[]
        +historiqueMouvements(): List<MouvementStock>
        +recherche(reference: string): Piece
    }

    class MouvementStock {
        +id: int
        +type: string (ENTREE, SORTIE)
        +quantité: int
        +date: DateTime
        +utilisateur: Utilisateur
        +vehiculeAssocie: Vehicule?
    }

    class Action {
        +id: int
        +type: string (CREATION, MODIFICATION, SUPPRESSION)
        +date: DateTime
        +utilisateur: Utilisateur
        +description: string
    }

    class Évaluation {
        +id: int
        +noteGlobale: int (1-5)
        +commentaires: string
        +date: DateTime
        +lienUnique: string
    }

    class Notification {
        +id: int
        +type: string (RETARD, PRET, STOCK)
        +message: string
        +dateEnvoi: DateTime
        +statut: string (ENVOYÉ, EN_ATTENTE)
        +vehiculeAssocie: Vehicule?
    }

    class TableauBord {
        +indicateursStocks(): Map<string, int>
        +interventionsRetard(): List<Intervention>
        +satisfactionClient(): Map<string, float>
        +statistiquesInterventions(): Map<string, int>
        +performancesUtilisateurs(): Map<string, float>
        +genererRapports()
    }

    class Technicien {
        +specialité: string
        +interventions: Intervention[]
    }

    class Réceptionniste {
        +creerVisite()
    }

    "Utilisateur" "1" *-- "1" "Role" : Possède
    "Utilisateur" "1" *-- "*" "Action" : Effectue
    "Client" "1" *-- "*" "Véhicule" : Possède
    "Véhicule" "1" *-- "*" "Visite" : Historique
    "Visite" "1" *-- "*" "Intervention" : Contient
    "Visite" "1" *-- "0..1" "Évaluation" : Génère
    "Intervention" "1" *-- "*" "Pièce" : Utilise
    "Pièce" "1" *-- "*" "MouvementStock" : Historique
    "Intervention" "1" *-- "1" "Technicien" : Attribuée à
    "TableauBord" *-- "*" "Intervention" : Suivi
    "TableauBord" *-- "*" "Pièce" : Stocks
    "TableauBord" *-- "*" "Évaluation" : Satisfaction
    "Notification" *-- "1" "Intervention" : Alertes
    "Notification" *-- "1" "Pièce" : Alertes stock
    "Utilisateur" <|-- "Technicien"
    "Utilisateur" <|-- "Réceptionniste"
    "Réceptionniste" *-- "1" "Visite" : Crée