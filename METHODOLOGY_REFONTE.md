# 📘 DOCUMENT TECHNIQUE DE REFONTE  
## Projet : Muntur AI – Application Mobile  

Stack : Flutter + Django REST Framework  

Orientation : IA-first • Offline-first • Performance-first  

---

# 1. Contexte

Une première version MVP de l’application mobile **Muntur AI** a été développée en Flutter avec un backend en Django REST Framework.

Constats :

- Architecture Flutter non structurée

- Logique métier mélangée à l’UI

- Performances dégradées (rebuilds excessifs, appels réseau mal gérés)

- Absence de véritable stratégie offline

- Dette technique croissante

Une refonte technique est nécessaire afin de stabiliser la base et préparer la montée en charge du produit.

---

# 2. Objectifs de la Refonte

## 🎯 Objectifs principaux

- Mettre en place une architecture propre et scalable

- Améliorer significativement les performances

- Implémenter une stratégie **Offline-first robuste**

- Centraliser la gestion réseau

- Préparer l’intégration avancée de l’IA (audio, image, streaming, etc.)

## 🎯 Contraintes

- Conserver :

  - Les couleurs existantes

  - Les endpoints API Django REST

- Maintenir compatibilité backend

- Éviter interruption longue du produit

---

# 3. Architecture Cible

## 🧠 Pattern retenu

Clean Architecture + Feature-first + Repository Pattern

---

## 📂 Structure globale

```bash
lib/
 ├── app/
 │    ├── router/
 │    └── app.dart
 │
 ├── core/
 │    ├── network/
 │    ├── database/
 │    ├── services/
 │    ├── error/
 │    ├── constants/
 │    └── theme/
 │
 ├── features/
 │    ├── auth/
 │    ├── chatbot/
 │    ├── map/
 │    ├── forum/
 │    └── news/
 ```

---

## 📦 Structure interne d’une feature

Exemple : chatbot

```bash
chatbot/
 ├── data/
 │    ├── models/
 │    ├── datasources/
 │    │     ├── chatbot_remote_datasource.dart
 │    │     └── chatbot_local_datasource.dart
 │    └── repositories_impl/
 │
 ├── domain/
 │    ├── entities/
 │    ├── repositories/
 │    └── usecases/
 │
 └── presentation/
      ├── providers/
      ├── screens/
      └── widgets/
```

---

# 4. Gestion d’État

Solution retenue : Riverpod

## Justification

- Rebuilds granulaires

- Testabilité

- Séparation logique / UI

- Scalabilité à long terme

## Interdictions

- setState global

- Appels API dans build()

- Logique métier dans les widgets

- FutureBuilder pour logique complexe

---

# 5. Couche Réseau

## ApiClient centralisé

Localisation :

```bash
core/network/api_client.dart
```

## Responsabilités

- Gestion JWT

- Refresh automatique token

- Interceptors erreurs

- Timeout

- Retry policy

- Logging debug

- Format réponse backend recommandé

```json
{
  "success": true,
  "data": {},
  "message": ""
}
```

---

# 6. Stratégie Offline-first

## 📦 Base de données locale

Solution recommandée : Isar

Localisation :

```bash
core/database/
```

## 🔁 Principe général

- Lecture prioritaire depuis base locale

- Synchronisation en arrière-plan si réseau disponible

- Mise à jour du cache local

## 🔄 Service de synchronisation

Création :

```bash
core/services/sync_service.dart
```

## Responsabilités

- Détection réseau

- File d’actions offline

- Retry automatique

- Gestion conflits

- Gestion statut pending_sync

## Cas d’usage Offline

### Chatbot

- Historique stocké localement

- Messages marqués pending_sync

- Dataset embarqué minimal pour conseils basiques

### Forum

- Création post offline

- Synchronisation automatique au retour réseau

### Map

- Cache garages consultés

- Favoris locaux

- Extension future : téléchargement zone

# 7. Optimisation Performance

## Bonnes pratiques obligatoires

- const constructors

- Pagination systématique

- Lazy loading

- Compression images

- Mise en cache HTTP

- Séparation fine des providers

- Monitoring

- Flutter DevTools

- Analyse rebuilds

- Profiling mémoire

- Test en conditions réseau faible

# 8. Gestion du Thème

Création :

```bash
core/theme/app_theme.dart
```

## Centralisation

- Primary color (existant)

- Secondary color (existant)

- Typography

- Styles boutons

- Styles inputs

- Spacing system

## Interdiction : 

- Couleurs hardcodées dans les widgets

# 9. Plan de Refonte Progressif

## Phase 1 – Fondation

- Nouveau projet Flutter

- Mise en place architecture cible

- Intégration Riverpod

- Intégration Isar

- Mise en place ApiClient

## Phase 2 – Auth

- Login/Register propre

- Stockage sécurisé token

- Cache profil local

## Phase 3 – Chatbot (Priorité IA)

- Historique local

- Sync différée

- Gestion statut message

- Structure extensible (image/audio)

## Phase 4 – Forum

- Pagination

- Cache local

- Sync offline

## Phase 5 – Map

- Cache garages

- Recherche locale

- Optimisation carte

# 10. Gestion des Risques

| Risque                     | Mitigation                     |
|----------------------------|--------------------------------|
| Complexité architecture    | Documentation interne          |
| Temps long de refonte      | Migration par feature          |
| Conflits sync              | Versioning + timestamps        |
| Problèmes performance DB   | Indexation Isar                |

# 11. Préparation Future

L’architecture doit anticiper :

- WebSocket temps réel

- Streaming IA

- Mode prédictif

- Historique multi-appareils

- B2B flottes

- Assurance automobile

# 12. Résultat Attendu

Après refonte :

- Code maintenable

- Performance fluide

- Application fonctionnelle en réseau faible

- Scalabilité IA garantie

- Réduction drastique dette technique

# Conclusion

Cette refonte constitue la fondation technique stratégique de Muntur AI en tant qu’assistant intelligent automobile pour l’Afrique centrale.

Elle permet de passer d’un MVP expérimental à une base produit robuste, scalable et prête pour une croissance réelle.
