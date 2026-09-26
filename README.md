# MovieVault

Application mobile Flutter de découverte de films, connectée à Supabase Auth et à l’API TMDB.

## Présentation

MovieVault permet de :

- créer un compte, se connecter et se déconnecter ;
- consulter les films populaires ;
- rechercher un film ;
- afficher les détails d’un film, son synopsis, sa note, son casting et sa bande-annonce ;
- conserver les données consultées dans un cache local ;
- continuer à consulter les données disponibles en mode hors-ligne.

L’application utilise une interface sombre adaptée à la consultation de contenus cinématographiques et protège les écrans de films avec l’état d’authentification Supabase.

## Technologies utilisées

| Technologie             | Utilisation                                             |
| :---------------------- | :------------------------------------------------------ |
| Flutter / Dart          | Application mobile multiplateforme                      |
| Supabase Auth           | Inscription, connexion et gestion des sessions          |
| TMDB REST API           | Films populaires, recherche, détails, casting et vidéos |
| Dio                     | Requêtes HTTP vers TMDB                                 |
| Hive                    | Cache local des films et des détails                    |
| Riverpod                | Gestion d’état et injection de dépendances              |
| GoRouter                | Navigation et protection des routes                     |
| connectivity_plus       | Détection de la connexion réseau                        |
| Mocktail / flutter_test | Tests unitaires                                         |

## Fonctionnement

1. L’utilisateur s’inscrit ou se connecte avec Supabase.
2. L’écran principal charge les films populaires depuis TMDB.
3. Les résultats et les détails récupérés sont enregistrés localement avec Hive.
4. Une recherche permet de trouver un film par son titre.
5. En cas de coupure réseau, l’application affiche un bandeau hors-ligne et utilise le cache disponible.
6. La déconnexion invalide la session et renvoie vers l’écran de connexion.

## Architecture

Le code est organisé selon une Clean Architecture :

```text
lib/
├── core/          # Constantes, erreurs, réseau, Supabase et widgets communs
├── data/          # Sources TMDB/Hive et implémentations des repositories
├── domain/        # Modèles métier et interfaces des repositories
├── presentation/ # Écrans, providers Riverpod et widgets métier
├── routing/       # Routes et guard d’authentification
└── main.dart      # Initialisation et point d’entrée de l’application
```

Le `MovieRepository` coordonne les sources distantes et locales. Il utilise TMDB lorsque la connexion est disponible, enregistre les réponses dans Hive et relit le cache lorsque le réseau ou le serveur sont indisponibles.

## Prérequis

- Flutter SDK compatible avec Dart `3.12.2` ou supérieur ;
- un projet Supabase ;
- une clé API TMDB ;
- un appareil ou émulateur compatible Flutter.

## Installation

```bash
git clone <url-de-votre-repo>
cd movie_vault
flutter pub get
```

## Configuration de l’environnement

Créez un fichier `.env` à la racine du projet :

```env
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_ANON_KEY=votre_cle_anon_publique
TMDB_API_KEY=votre_cle_api_tmdb_v3
```

Ne partagez jamais ce fichier avec vos clés réelles dans un dépôt public.

### Supabase Auth

Pour tester la connexion immédiatement après l’inscription, sans validation d’adresse email :

1. ouvrez votre projet dans le [Dashboard Supabase](https://supabase.com/dashboard) ;
2. allez dans **Authentication** → **Providers** → **Email** ;
3. désactivez **Confirm email** ;
4. enregistrez la configuration.

Ce réglage est effectué dans Supabase et non dans le code Flutter. Lorsqu’il est désactivé, l’inscription crée directement une session active.

### TMDB

1. créez ou ouvrez un compte sur [The Movie Database](https://www.themoviedb.org) ;
2. ouvrez **Paramètres** → **API** ;
3. demandez une clé pour un usage personnel ou étudiant ;
4. placez la clé obtenue dans `TMDB_API_KEY`.

## Lancer l’application

```bash
flutter run
```

Pour vérifier le projet avant son lancement :

```bash
flutter analyze
flutter test
```

## Tests

Les tests unitaires se trouvent dans `test/data/repositories/movie_repository_test.dart`. Ils couvrent notamment :

- le chargement des films en ligne ;
- l’écriture et la lecture du cache Hive ;
- le fonctionnement hors-ligne ;
- la gestion d’un cache vide ;
- le chargement des détails et la recherche.

## API utilisées

| Service       | Fonctionnalités                                             |
| :------------ | :---------------------------------------------------------- |
| Supabase Auth | `signUp`, `signInWithPassword`, `signOut`, suivi de session |
| TMDB          | Films populaires, recherche, détails, crédits et vidéos     |

## Licence

Projet sous licence MIT, utilisable et adaptable dans un cadre académique ou professionnel.
