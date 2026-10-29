# Application Service Qualité CANAM — Laravel 10 / Blade / MySQL 8

Cette archive contient le code applicatif à intégrer dans un projet Laravel 10 existant/neuf. Les noms des tables et colonnes applicatives sont alignés sur le schéma SQL fourni par le Service Qualité : `numero_ordre`, `reclamant`, `demandeur`, `responsable_traitement_id`, `echeance_traitement`, `causes_probleme`, etc.

L’interface utilise désormais une palette bleu et blanc inspirée de l’identité CANAM Mali.

## 1. Pré-requis

- PHP 8.1 ou supérieur, extensions Laravel habituelles
- Composer
- MySQL 8.0+
- Node.js / npm (si vous utilisez les assets Breeze)
- Laravel 10

## 2. Installation

1. Créer le projet Laravel :

   ```bash
   composer create-project laravel/laravel:^10.0 canam-service-qualite
   cd canam-service-qualite
   ```

2. Installer l’authentification Blade **avant de copier cette archive** :

   ```bash
   composer require laravel/breeze --dev
   composer require barryvdh/laravel-dompdf:^3.1
   php artisan breeze:install blade
   npm install
   npm run build
   ```

3. Copier ensuite le contenu de cette archive dans le projet Laravel, en fusionnant les répertoires `app`, `routes`, `resources`, `public`, `database`. Cela remplace notamment `routes/auth.php` pour désactiver l’inscription publique.

4. Créer la base MySQL `canam_service_qualite` (si elle n’existe pas) et configurer `.env` :

   ```dotenv
   APP_NAME="CANAM Service Qualité"
   APP_ENV=local
   APP_DEBUG=true
   APP_URL=http://127.0.0.1:8000
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=canam_service_qualite
   DB_USERNAME=root
   DB_PASSWORD=
   ```

5. Vous avez deux possibilités :
   - **Base déjà créée avec votre SQL :** ne réimportez pas le script si la base contient des données à conserver.
   - **Nouvelle base vide :** la migration `2026_10_09_000001_create_canam_schema_from_sql.php` créera la structure depuis `database/sql/canam_service_qualite.sql`.

6. **Important pour conserver votre schéma SQL :** le modèle `users` fourni n'utilise pas la colonne `name` standard de Laravel, mais `nom`, `prenom`, `identifiant`, `email`, `telephone`, `password`, `actif`. Retirez de l'exécution la migration Laravel standard qui crée `users` (souvent `0001_01_01_000000_create_users_table.php`) avant d'exécuter les migrations. Gardez les migrations cache/sessions/jobs si vous en avez besoin.

7. Exécuter les migrations et les données de référence :

   ```bash
   php artisan migrate --seed
   php artisan config:clear
   php artisan route:clear
   php artisan view:clear
   ```

8. Créer le premier compte administrateur avec Tinker :

   ```bash
   php artisan tinker
   ```

   Puis exécuter dans Tinker :

   ```php
   $role = App\Models\Role::where('code', 'ADMIN')->firstOrFail();
   $user = App\Models\User::create([
       'nom' => 'Administrateur',
       'prenom' => 'CANAM',
       'identifiant' => 'admin.canam',
       'email' => 'admin@canam.local',
       'telephone' => null,
       'password' => Illuminate\Support\Facades\Hash::make('RemplacerCeMotDePasse!2026'),
       'actif' => true,
   ]);
   $user->roles()->attach($role->id, ['attribue_par' => $user->id]);
   ```

   Remplacez immédiatement le mot de passe d'exemple par un mot de passe robuste propre à l'environnement. La connexion Breeze par défaut se fait avec l'adresse email.

9. Démarrer :

   ```bash
   php artisan serve
   ```

   Ouvrir `http://127.0.0.1:8000/login`.

## 3. Modules inclus

- Tableau de bord et suivi des retards
- Réclamations : enregistrement, affectation par le RQ, traitement, historique, relances
- Demandes d'assistance : enregistrement, affectation, traitement, relances et journal des tentatives de notification/appel
- Référentiels : régions, localités, OGD, processus, provenances, qualifications
- Utilisateurs et rôles
- Paramétrage des délais : module, qualification, durée en heures/jours, calendrier calendaire/ouvré, point de départ réception/affectation, périodes de validité, paramètres d'alerte et de relance
- Historique des statuts, affectations, relances et activités
- Tables de référence pour les droits de l’assuré et la disponibilité des cartes

## 3 bis. Tables de contrôle Assuré / Carte

Deux tables complètent le schéma CANAM :

- `droits_assures` conserve le N° AMO/récépissé, le statut des droits (`ouverts`, `suspendus`, `fermes` ou `inconnu`), les dates de validité, la date de vérification et les observations. Elle contient une fiche par N° AMO/récépissé.
- `disponibilite_cartes` conserve le N° AMO/récépissé, le statut de la carte (`disponible`, `en_preparation`, `emise`, `indisponible` ou `inconnue`), le numéro de carte, la date de mise à jour et les observations. Elle peut contenir plusieurs cartes par N° AMO/récépissé.

Les nouvelles tables sont définies dans `database/sql/canam_service_qualite.sql` et créées par la migration `2026_10_29_000002_create_assure_rights_and_card_availability_tables.php`. Le fichier `database/sql/canam_service_qualite_complet.sql` reprend le SQL complet fourni et y ajoute les deux tables.

Dans le formulaire de création ou de modification d’une réclamation ou d’une demande d’assistance, la saisie du N° AMO ou du récépissé déclenche automatiquement une recherche dans ces deux tables. Le formulaire affiche les droits et toutes les cartes connues pour ce numéro, ou indique si aucune fiche n’est trouvée. Le contrôle informe l’agent et ne déclenche pas d’affectation automatique. Les tables doivent être alimentées avec les données de référence CANAM ; aucune connexion à un système externe n’est fournie.

## Changement de mot de passe

Chaque utilisateur connecté peut ouvrir **Mon mot de passe** dans la barre de navigation. Le formulaire demande le mot de passe actuel, un nouveau mot de passe d’au moins 8 caractères et sa confirmation. Le nouveau mot de passe est enregistré sous forme de hash Laravel.

## Tableau de bord et rapport PDF

Le tableau de bord présente le nombre de fiches par statut des droits et de disponibilité des cartes. Les filtres permettent de choisir un statut des droits, un statut de carte et de rechercher par N° AMO/récépissé, nom, matricule ou contact. Le bouton **Télécharger le rapport PDF filtré** exporte les lignes correspondant aux filtres, avec les informations d’assuré, les droits, les cartes, les dates et les observations. Le rapport PDF utilise `barryvdh/laravel-dompdf`, installé pendant la préparation Laravel.

Les champs d’identité et de contact du rapport sont repris du dossier CANAM le plus récent associé au N° AMO/récépissé. Si aucun dossier n’est associé, le rapport affiche les informations de droits et de carte disponibles et signale les champs d’identité absents.

Les listes **Réclamations** et **Demandes d’assistance** proposent également un export PDF. Le rapport reprend les filtres actifs de recherche et de statut et inclut les détails des dossiers correspondants.

## 4. Calcul automatique de l'échéance

`app/Services/EcheanceService.php` cherche la règle active qui correspond au module et à la qualification. La règle spécifique à une qualification est prioritaire ; sinon, la règle générale du module (`qualification_id = NULL`) est utilisée. Les dates de début et de fin sont vérifiées.

- `point_depart = reception` : l'échéance est calculée à l'enregistrement.
- `point_depart = affectation` : l'échéance est calculée au moment de l'affectation du responsable.
- `unite = heures` : ajoute le nombre d'heures configuré.
- `unite = jours`, `calendrier = calendaire` : ajoute des jours calendaires.
- `unite = jours`, `calendrier = ouvre` : ignore le samedi et le dimanche.

Les jours fériés ne sont pas intégrés à cette version. Les champs d'alerte/fréquence/escalade sont enregistrés dans le paramétrage, mais l'envoi automatique de rappels nécessitera une commande planifiée et une configuration de notification (mail/SMS) validée par la CANAM.

## 5. Notes de sécurité et de déploiement

- Le délai d'exemple de 5 jours doit être validé par le Service Qualité.
- Les rôles sont dans `roles` et `user_roles` ; aucun rôle n'est stocké dans `users.role`.
- N'utilisez pas `APP_DEBUG=true` en production.
- Les pièces jointes doivent être stockées sur un disque privé et servies via un contrôleur autorisé.
- Cette archive a été vérifiée pour la syntaxe PHP. Elle n'a pas été exécutée sur votre serveur CANAM ni testée contre une instance MySQL réelle ; faites les essais sur une copie de recette.
