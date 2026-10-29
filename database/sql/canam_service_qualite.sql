-- =====================================================================
-- CANAM - APPLICATION DU SERVICE QUALITE
-- Base de donnees MySQL 8.0+
-- Modules : Reclamations et Demandes d'assistance
-- Encodage : utf8mb4
--
-- IMPORTANT :
-- 1. Executer dans un environnement de developpement/recette d'abord.
-- 2. Ce script cree la base canam_service_qualite si les droits le permettent.
-- 3. Les utilisateurs et mots de passe applicatifs doivent etre geres par Laravel.
-- 4. Les delais, statuts et regles ci-dessous sont des valeurs initiales
--    a valider par le Service Qualite.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS canam_service_qualite
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE canam_service_qualite;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Suppression dans l'ordre inverse des dependances pour faciliter une
-- reinstallation en environnement de test. Retirer ce bloc en production.
DROP VIEW IF EXISTS v_dossiers_en_retard;
DROP VIEW IF EXISTS v_tableau_bord_qualite;
DROP TABLE IF EXISTS journal_activites;
DROP TABLE IF EXISTS pieces_jointes;
DROP TABLE IF EXISTS notifications_assistance;
DROP TABLE IF EXISTS relances;
DROP TABLE IF EXISTS historique_statuts;
DROP TABLE IF EXISTS affectations;
DROP TABLE IF EXISTS demandes_assistance;
DROP TABLE IF EXISTS reclamations;
DROP TABLE IF EXISTS disponibilite_cartes;
DROP TABLE IF EXISTS droits_assures;
DROP TABLE IF EXISTS delais_traitement;
DROP TABLE IF EXISTS qualifications;
DROP TABLE IF EXISTS provenances;
DROP TABLE IF EXISTS processus;
DROP TABLE IF EXISTS ogds;
DROP TABLE IF EXISTS localites;
DROP TABLE IF EXISTS regions;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- 1. UTILISATEURS ET ROLES
-- En production Laravel, ces tables peuvent etre remplacees/alimentees
-- par users et les tables d'autorisations deja en place dans le projet.
-- =====================================================================

CREATE TABLE users (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NULL,
    identifiant VARCHAR(100) NOT NULL,
    email VARCHAR(190) NULL,
    telephone VARCHAR(30) NULL,
    password VARCHAR(255) NOT NULL COMMENT 'Hash Laravel uniquement, jamais le mot de passe en clair',
    actif TINYINT(1) NOT NULL DEFAULT 1,
    derniere_connexion DATETIME NULL,
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_users_identifiant (identifiant),
    UNIQUE KEY uq_users_email (email),
    KEY idx_users_actif (actif)
) ENGINE=InnoDB;

CREATE TABLE roles (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(50) NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_roles_code (code)
) ENGINE=InnoDB;

CREATE TABLE user_roles (
    user_id BIGINT UNSIGNED NOT NULL,
    role_id BIGINT UNSIGNED NOT NULL,
    attribue_par BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_user_roles_attribue FOREIGN KEY (attribue_par) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =====================================================================
-- 2. REFERENTIELS
-- =====================================================================

CREATE TABLE regions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(20) NULL,
    nom VARCHAR(120) NOT NULL,
    actif TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_regions_code (code),
    UNIQUE KEY uq_regions_nom (nom)
) ENGINE=InnoDB;

CREATE TABLE localites (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    region_id BIGINT UNSIGNED NOT NULL,
    nom VARCHAR(150) NOT NULL,
    actif TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_localite_region_nom (region_id, nom),
    CONSTRAINT fk_localites_region FOREIGN KEY (region_id) REFERENCES regions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE ogds (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(30) NULL,
    nom VARCHAR(180) NOT NULL,
    description VARCHAR(255) NULL,
    actif TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_ogds_code (code),
    UNIQUE KEY uq_ogds_nom (nom)
) ENGINE=InnoDB;

CREATE TABLE processus (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(40) NOT NULL,
    libelle VARCHAR(160) NOT NULL,
    description TEXT NULL,
    actif TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_processus_code (code),
    UNIQUE KEY uq_processus_libelle (libelle)
) ENGINE=InnoDB;

CREATE TABLE provenances (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    module ENUM('reclamation','assistance','commun') NOT NULL DEFAULT 'commun',
    libelle VARCHAR(150) NOT NULL,
    actif TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_provenance_module_libelle (module, libelle)
) ENGINE=InnoDB;

CREATE TABLE qualifications (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    module ENUM('reclamation','assistance') NOT NULL,
    code VARCHAR(40) NULL,
    libelle VARCHAR(180) NOT NULL,
    description TEXT NULL,
    actif TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_qualification_module_code (module, code),
    UNIQUE KEY uq_qualification_module_libelle (module, libelle)
) ENGINE=InnoDB;

-- =====================================================================
-- 3. PARAMETRAGE DES DELAIS
-- Une regle peut cibler un module et, facultativement, une qualification.
-- Une duree en heures permet de modeliser un delai court ; le calendrier
-- ouvre/calendaire doit etre defini par le Service Qualite.
-- =====================================================================

CREATE TABLE delais_traitement (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    module ENUM('reclamation','assistance') NOT NULL,
    qualification_id BIGINT UNSIGNED NULL,
    libelle VARCHAR(180) NOT NULL,
    duree INT UNSIGNED NOT NULL,
    unite ENUM('heures','jours') NOT NULL DEFAULT 'jours',
    calendrier ENUM('calendaire','ouvre') NOT NULL DEFAULT 'calendaire',
    point_depart ENUM('reception','affectation') NOT NULL DEFAULT 'affectation',
    alerte_avant INT UNSIGNED NOT NULL DEFAULT 1,
    unite_alerte ENUM('heures','jours') NOT NULL DEFAULT 'jours',
    frequence_relance INT UNSIGNED NULL,
    unite_frequence_relance ENUM('heures','jours') NOT NULL DEFAULT 'jours',
    escalade_apres INT UNSIGNED NULL,
    actif TINYINT(1) NOT NULL DEFAULT 1,
    date_debut DATE NOT NULL,
    date_fin DATE NULL,
    cree_par BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_delais_module_actif (module, actif, date_debut, date_fin),
    KEY idx_delais_qualification (qualification_id),
    CONSTRAINT fk_delais_qualification FOREIGN KEY (qualification_id) REFERENCES qualifications(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_delais_user FOREIGN KEY (cree_par) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_delais_duree CHECK (duree > 0),
    CONSTRAINT chk_delais_dates CHECK (date_fin IS NULL OR date_fin >= date_debut)
) ENGINE=InnoDB;

-- =====================================================================
-- 3 bis. DONNEES DE REFERENCE POUR LES CONTROLES ASSURE / CARTE
-- Une ligne de droits par numéro AMO/récépissé. La table cartes conserve
-- une ligne par carte et permet plusieurs cartes par numéro AMO/récépissé.
-- =====================================================================

CREATE TABLE droits_assures (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    numero_amo_recepisse VARCHAR(100) NULL,
    statut ENUM('ouverts','suspendus','fermes','inconnu') NOT NULL DEFAULT 'inconnu',
    date_debut DATE NULL,
    date_fin DATE NULL,
    verifie_le DATETIME NULL,
    observations TEXT NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_droits_assures_amo (numero_amo_recepisse),
    KEY idx_droits_assures_statut (statut)
) ENGINE=InnoDB;

CREATE TABLE disponibilite_cartes (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    numero_amo_recepisse VARCHAR(100) NULL,
    numero_carte VARCHAR(100) NULL,
    disponibilite ENUM('disponible','en_preparation','emise','indisponible','inconnue') NOT NULL DEFAULT 'inconnue',
    date_mise_a_jour DATETIME NULL,
    observations TEXT NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_disponibilite_cartes_numero (numero_carte),
    KEY idx_disponibilite_cartes_amo (numero_amo_recepisse),
    KEY idx_disponibilite_cartes_etat (disponibilite)
) ENGINE=InnoDB;

-- =====================================================================
-- 4. MODULE RECLAMATIONS
-- Le numero d'ordre est unique. L'identifiant AMO/recepisse et le matricule
-- sont des champs texte pour conserver les zeros initiaux.
-- =====================================================================

CREATE TABLE reclamations (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    numero_ordre VARCHAR(40) NOT NULL,
    date_reception DATE NOT NULL,
    reclamant VARCHAR(180) NOT NULL,
    region_id BIGINT UNSIGNED NULL,
    localite_id BIGINT UNSIGNED NULL,
    numero_amo_recepisse VARCHAR(100) NULL,
    numero_matricule VARCHAR(100) NULL,
    contact VARCHAR(80) NULL,
    ogd_id BIGINT UNSIGNED NULL,
    objet TEXT NOT NULL,
    provenance_id BIGINT UNSIGNED NULL,
    qualification_id BIGINT UNSIGNED NULL,
    processus_id BIGINT UNSIGNED NULL,
    responsable_traitement_id BIGINT UNSIGNED NULL,
    date_affectation DATETIME NULL,
    delai_traitement_id BIGINT UNSIGNED NULL,
    echeance_traitement DATETIME NULL,
    causes_probleme TEXT NULL,
    action_entreprise TEXT NULL,
    date_emission_carte DATE NULL,
    date_traitement DATETIME NULL,
    statut ENUM(
        'brouillon','recu','a_affecter','affecte','en_cours',
        'en_attente_information','traite','cloture','annule'
    ) NOT NULL DEFAULT 'recu',
    priorite ENUM('basse','normale','haute','urgente') NOT NULL DEFAULT 'normale',
    observations TEXT NULL,
    cree_par BIGINT UNSIGNED NULL,
    cloture_par BIGINT UNSIGNED NULL,
    date_cloture DATETIME NULL,
    motif_annulation TEXT NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_reclamations_numero_ordre (numero_ordre),
    KEY idx_reclamations_date_reception (date_reception),
    KEY idx_reclamations_statut_echeance (statut, echeance_traitement),
    KEY idx_reclamations_responsable (responsable_traitement_id),
    KEY idx_reclamations_amo (numero_amo_recepisse),
    KEY idx_reclamations_matricule (numero_matricule),
    KEY idx_reclamations_region (region_id),
    KEY idx_reclamations_ogd (ogd_id),
    KEY idx_reclamations_qualification (qualification_id),
    CONSTRAINT fk_reclamations_region FOREIGN KEY (region_id) REFERENCES regions(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_reclamations_localite FOREIGN KEY (localite_id) REFERENCES localites(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_reclamations_ogd FOREIGN KEY (ogd_id) REFERENCES ogds(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_reclamations_provenance FOREIGN KEY (provenance_id) REFERENCES provenances(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_reclamations_qualification FOREIGN KEY (qualification_id) REFERENCES qualifications(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_reclamations_processus FOREIGN KEY (processus_id) REFERENCES processus(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_reclamations_responsable FOREIGN KEY (responsable_traitement_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_reclamations_delai FOREIGN KEY (delai_traitement_id) REFERENCES delais_traitement(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_reclamations_createur FOREIGN KEY (cree_par) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_reclamations_clotureur FOREIGN KEY (cloture_par) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_reclamations_dates CHECK (date_cloture IS NULL OR statut = 'cloture')
) ENGINE=InnoDB;

-- =====================================================================
-- 5. MODULE DEMANDES D'ASSISTANCE
-- La notification est separee du traitement : un dossier traite peut
-- rester a notifier.
-- =====================================================================

CREATE TABLE demandes_assistance (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    numero_ordre VARCHAR(40) NOT NULL,
    date_reception DATE NOT NULL,
    demandeur VARCHAR(180) NOT NULL,
    region_id BIGINT UNSIGNED NULL,
    localite_id BIGINT UNSIGNED NULL,
    numero_amo_recepisse VARCHAR(100) NULL,
    numero_matricule VARCHAR(100) NULL,
    contact VARCHAR(80) NULL,
    ogd_id BIGINT UNSIGNED NULL,
    objet TEXT NOT NULL,
    provenance_id BIGINT UNSIGNED NULL,
    qualification_id BIGINT UNSIGNED NULL,
    processus_id BIGINT UNSIGNED NULL,
    responsable_traitement_id BIGINT UNSIGNED NULL,
    date_affectation DATETIME NULL,
    delai_traitement_id BIGINT UNSIGNED NULL,
    echeance_traitement DATETIME NULL,
    causes_probleme TEXT NULL,
    action_entreprise TEXT NULL,
    date_traitement DATETIME NULL,
    statut ENUM(
        'brouillon','recu','a_affecter','affecte','en_cours',
        'en_attente_information','traite','a_notifier','cloture','annule'
    ) NOT NULL DEFAULT 'recu',
    priorite ENUM('basse','normale','haute','urgente') NOT NULL DEFAULT 'normale',
    statut_notification ENUM(
        'non_requise','a_notifier','appele_informe','injoignable',
        'rappel_necessaire','notification_effectuee'
    ) NOT NULL DEFAULT 'a_notifier',
    date_appel DATETIME NULL,
    responsable_notification_id BIGINT UNSIGNED NULL,
    observations TEXT NULL,
    cree_par BIGINT UNSIGNED NULL,
    cloture_par BIGINT UNSIGNED NULL,
    date_cloture DATETIME NULL,
    motif_annulation TEXT NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_assistance_numero_ordre (numero_ordre),
    KEY idx_assistance_date_reception (date_reception),
    KEY idx_assistance_statut_echeance (statut, echeance_traitement),
    KEY idx_assistance_responsable (responsable_traitement_id),
    KEY idx_assistance_notification (statut_notification, date_appel),
    KEY idx_assistance_amo (numero_amo_recepisse),
    KEY idx_assistance_matricule (numero_matricule),
    KEY idx_assistance_region (region_id),
    KEY idx_assistance_ogd (ogd_id),
    KEY idx_assistance_qualification (qualification_id),
    CONSTRAINT fk_assistance_region FOREIGN KEY (region_id) REFERENCES regions(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_assistance_localite FOREIGN KEY (localite_id) REFERENCES localites(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_assistance_ogd FOREIGN KEY (ogd_id) REFERENCES ogds(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_assistance_provenance FOREIGN KEY (provenance_id) REFERENCES provenances(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_assistance_qualification FOREIGN KEY (qualification_id) REFERENCES qualifications(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_assistance_processus FOREIGN KEY (processus_id) REFERENCES processus(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_assistance_responsable FOREIGN KEY (responsable_traitement_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_assistance_delai FOREIGN KEY (delai_traitement_id) REFERENCES delais_traitement(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_assistance_notification_user FOREIGN KEY (responsable_notification_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_assistance_createur FOREIGN KEY (cree_par) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_assistance_clotureur FOREIGN KEY (cloture_par) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_assistance_dates CHECK (date_cloture IS NULL OR statut = 'cloture')
) ENGINE=InnoDB;

-- =====================================================================
-- 6. HISTORIQUE DES AFFECTATIONS
-- Le dossier est rattache a l'un des deux modules.
-- Les FK metier sont validees par l'application car un seul champ FK
-- polymorphe ne peut pas pointer vers deux tables.
-- =====================================================================

CREATE TABLE affectations (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    module ENUM('reclamation','assistance') NOT NULL,
    reclamation_id BIGINT UNSIGNED NULL,
    demande_assistance_id BIGINT UNSIGNED NULL,
    responsable_precedent_id BIGINT UNSIGNED NULL,
    responsable_nouveau_id BIGINT UNSIGNED NOT NULL,
    affecte_par BIGINT UNSIGNED NULL,
    date_affectation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motif TEXT NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_affectations_reclamation (reclamation_id, date_affectation),
    KEY idx_affectations_assistance (demande_assistance_id, date_affectation),
    KEY idx_affectations_responsable (responsable_nouveau_id, date_affectation),
    CONSTRAINT fk_affectations_reclamation FOREIGN KEY (reclamation_id) REFERENCES reclamations(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_affectations_assistance FOREIGN KEY (demande_assistance_id) REFERENCES demandes_assistance(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_affectations_ancien FOREIGN KEY (responsable_precedent_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_affectations_nouveau FOREIGN KEY (responsable_nouveau_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_affectations_auteur FOREIGN KEY (affecte_par) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_affectations_un_dossier CHECK (
        (module = 'reclamation' AND reclamation_id IS NOT NULL AND demande_assistance_id IS NULL)
        OR
        (module = 'assistance' AND demande_assistance_id IS NOT NULL AND reclamation_id IS NULL)
    )
) ENGINE=InnoDB;

-- =====================================================================
-- 7. RELANCES : plusieurs relances possibles par dossier
-- =====================================================================

CREATE TABLE relances (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    module ENUM('reclamation','assistance') NOT NULL,
    reclamation_id BIGINT UNSIGNED NULL,
    demande_assistance_id BIGINT UNSIGNED NULL,
    date_relance DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    responsable_relance_id BIGINT UNSIGNED NOT NULL,
    destinataire_id BIGINT UNSIGNED NULL,
    canal ENUM('interne','telephone','email','courrier','autre') NOT NULL DEFAULT 'interne',
    motif TEXT NULL,
    resultat TEXT NULL,
    prochaine_action DATETIME NULL,
    statut ENUM('effectuee','en_attente','sans_suite') NOT NULL DEFAULT 'effectuee',
    cree_par BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_relances_reclamation (reclamation_id, date_relance),
    KEY idx_relances_assistance (demande_assistance_id, date_relance),
    KEY idx_relances_responsable (responsable_relance_id, date_relance),
    CONSTRAINT fk_relances_reclamation FOREIGN KEY (reclamation_id) REFERENCES reclamations(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_relances_assistance FOREIGN KEY (demande_assistance_id) REFERENCES demandes_assistance(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_relances_responsable FOREIGN KEY (responsable_relance_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_relances_destinataire FOREIGN KEY (destinataire_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_relances_createur FOREIGN KEY (cree_par) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_relances_un_dossier CHECK (
        (module = 'reclamation' AND reclamation_id IS NOT NULL AND demande_assistance_id IS NULL)
        OR
        (module = 'assistance' AND demande_assistance_id IS NOT NULL AND reclamation_id IS NULL)
    )
) ENGINE=InnoDB;

-- =====================================================================
-- 8. NOTIFICATIONS / APPELS DU MODULE ASSISTANCE
-- Historise chaque tentative d'appel, pas uniquement le dernier resultat.
-- =====================================================================

CREATE TABLE notifications_assistance (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    demande_assistance_id BIGINT UNSIGNED NOT NULL,
    date_appel DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    responsable_notification_id BIGINT UNSIGNED NOT NULL,
    canal ENUM('telephone','email','sms','courrier','autre') NOT NULL DEFAULT 'telephone',
    statut ENUM(
        'appele_informe','injoignable','rappel_necessaire',
        'notification_effectuee','echec','non_requise'
    ) NOT NULL,
    commentaire TEXT NULL,
    prochaine_tentative DATETIME NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_notifications_demande (demande_assistance_id, date_appel),
    KEY idx_notifications_responsable (responsable_notification_id, date_appel),
    CONSTRAINT fk_notifications_demande FOREIGN KEY (demande_assistance_id) REFERENCES demandes_assistance(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_notifications_responsable FOREIGN KEY (responsable_notification_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================================
-- 9. HISTORIQUE DES STATUTS
-- =====================================================================

CREATE TABLE historique_statuts (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    module ENUM('reclamation','assistance') NOT NULL,
    reclamation_id BIGINT UNSIGNED NULL,
    demande_assistance_id BIGINT UNSIGNED NULL,
    ancien_statut VARCHAR(50) NULL,
    nouveau_statut VARCHAR(50) NOT NULL,
    commentaire TEXT NULL,
    modifie_par BIGINT UNSIGNED NULL,
    date_changement DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_hist_statut_reclamation (reclamation_id, date_changement),
    KEY idx_hist_statut_assistance (demande_assistance_id, date_changement),
    CONSTRAINT fk_hist_statut_reclamation FOREIGN KEY (reclamation_id) REFERENCES reclamations(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_hist_statut_assistance FOREIGN KEY (demande_assistance_id) REFERENCES demandes_assistance(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_hist_statut_user FOREIGN KEY (modifie_par) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_hist_statut_un_dossier CHECK (
        (module = 'reclamation' AND reclamation_id IS NOT NULL AND demande_assistance_id IS NULL)
        OR
        (module = 'assistance' AND demande_assistance_id IS NOT NULL AND reclamation_id IS NULL)
    )
) ENGINE=InnoDB;

-- =====================================================================
-- 10. PIECES JOINTES (OPTIONNEL)
-- Stocker uniquement le chemin/nom, pas le contenu binaire dans la table.
-- Le stockage doit etre prive et controle par Laravel.
-- =====================================================================

CREATE TABLE pieces_jointes (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    module ENUM('reclamation','assistance') NOT NULL,
    reclamation_id BIGINT UNSIGNED NULL,
    demande_assistance_id BIGINT UNSIGNED NULL,
    nom_original VARCHAR(255) NOT NULL,
    chemin_stockage VARCHAR(500) NOT NULL,
    type_mime VARCHAR(150) NULL,
    taille_octets BIGINT UNSIGNED NULL,
    ajoute_par BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_pj_reclamation (reclamation_id),
    KEY idx_pj_assistance (demande_assistance_id),
    CONSTRAINT fk_pj_reclamation FOREIGN KEY (reclamation_id) REFERENCES reclamations(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_pj_assistance FOREIGN KEY (demande_assistance_id) REFERENCES demandes_assistance(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_pj_user FOREIGN KEY (ajoute_par) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_pj_un_dossier CHECK (
        (module = 'reclamation' AND reclamation_id IS NOT NULL AND demande_assistance_id IS NULL)
        OR
        (module = 'assistance' AND demande_assistance_id IS NOT NULL AND reclamation_id IS NULL)
    )
) ENGINE=InnoDB;

-- =====================================================================
-- 11. JOURNAL D'ACTIVITES
-- =====================================================================

CREATE TABLE journal_activites (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NULL,
    module VARCHAR(40) NULL,
    dossier_id BIGINT UNSIGNED NULL,
    action VARCHAR(100) NOT NULL,
    description TEXT NULL,
    adresse_ip VARCHAR(45) NULL,
    user_agent VARCHAR(500) NULL,
    donnees_avant JSON NULL,
    donnees_apres JSON NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_journal_user_date (user_id, created_at),
    KEY idx_journal_module_dossier (module, dossier_id, created_at),
    CONSTRAINT fk_journal_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =====================================================================
-- 12. VUES DE SUIVI
-- Attention : un dossier sans echeance (NULL) n'est pas declare en retard.
-- Le calcul de l'echeance doit etre fait par Laravel selon le calendrier
-- parametre, notamment si les jours ouvres et jours feries sont utilises.
-- =====================================================================

CREATE OR REPLACE VIEW v_dossiers_en_retard AS
SELECT
    'reclamation' AS module,
    r.id AS dossier_id,
    r.numero_ordre,
    r.date_reception,
    r.objet,
    r.statut,
    r.responsable_traitement_id,
    r.echeance_traitement,
    TIMESTAMPDIFF(HOUR, r.echeance_traitement, NOW()) AS retard_heures
FROM reclamations r
WHERE r.echeance_traitement IS NOT NULL
  AND r.echeance_traitement < NOW()
  AND r.statut NOT IN ('traite','cloture','annule')
UNION ALL
SELECT
    'assistance' AS module,
    d.id AS dossier_id,
    d.numero_ordre,
    d.date_reception,
    d.objet,
    d.statut,
    d.responsable_traitement_id,
    d.echeance_traitement,
    TIMESTAMPDIFF(HOUR, d.echeance_traitement, NOW()) AS retard_heures
FROM demandes_assistance d
WHERE d.echeance_traitement IS NOT NULL
  AND d.echeance_traitement < NOW()
  AND d.statut NOT IN ('traite','a_notifier','cloture','annule');

CREATE OR REPLACE VIEW v_tableau_bord_qualite AS
SELECT
    'reclamation' AS module,
    statut,
    COUNT(*) AS nombre
FROM reclamations
GROUP BY statut
UNION ALL
SELECT
    'assistance' AS module,
    statut,
    COUNT(*) AS nombre
FROM demandes_assistance
GROUP BY statut;

-- =====================================================================
-- 13. DONNEES INITIALES
-- Completer les regions, localites, OGD, provenances, qualifications et
-- processus avec les listes officielles validees par le Service Qualite.
-- Aucun compte utilisateur n'est cree ici : utiliser php artisan make:user
-- ou le seeder Laravel pour creer un compte avec un hash de mot de passe.
-- =====================================================================

INSERT INTO roles (code, libelle, description) VALUES
('ADMIN', 'Administrateur', 'Administration technique et gestion des habilitations'),
('RQ', 'Responsable Qualite', 'Affectation, suivi des delais et pilotage'),
('ENREGISTREMENT', 'Agent d''enregistrement', 'Enregistrement des dossiers'),
('TRAITEMENT', 'Responsable de traitement', 'Traitement des dossiers affectes'),
('RELANCE', 'Responsable de relance', 'Enregistrement et suivi des relances'),
('NOTIFICATION', 'Responsable de notification', 'Appels et notifications des demandes d''assistance'),
('CONSULTATION', 'Consultation', 'Consultation et rapports sans modification');

INSERT INTO provenances (module, libelle) VALUES
('commun', 'Courrier'),
('commun', 'Telephone'),
('commun', 'Email'),
('commun', 'Accueil physique'),
('commun', 'Direction / service interne'),
('commun', 'Autre');

INSERT INTO processus (code, libelle, description) VALUES
('CARTE_AMO', 'Gestion de la carte AMO', 'Processus lie a la carte AMO'),
('IMMATRICULATION', 'Immatriculation', 'Processus d''immatriculation'),
('PRISE_EN_CHARGE', 'Prise en charge', 'Processus de prise en charge'),
('PRESTATIONS', 'Prestations', 'Gestion des prestations'),
('AUTRE', 'Autre processus', 'A preciser par le Service Qualite');

-- Exemple de qualifications initiales, a adapter au catalogue officiel.
INSERT INTO qualifications (module, code, libelle) VALUES
('reclamation', 'CARTE_NON_RECUE', 'Carte AMO non reçue'),
('reclamation', 'ERREUR_CARTE', 'Erreur sur la carte AMO'),
('reclamation', 'DOSSIER_BLOQUE', 'Dossier bloqué'),
('reclamation', 'AUTRE', 'Autre réclamation'),
('assistance', 'INFORMATION', 'Demande d’information'),
('assistance', 'AIDE_UTILISATION', 'Aide à l’utilisation'),
('assistance', 'INCIDENT', 'Incident ou anomalie'),
('assistance', 'AUTRE', 'Autre demande d’assistance');

-- Exemple de delais initiaux : valeurs a faire valider et a modifier par le RQ.
-- Ici, 5 jours calendaires a compter de l'affectation pour chaque module,
-- sans qualification specifique (qualification_id NULL).
INSERT INTO delais_traitement
(module, qualification_id, libelle, duree, unite, calendrier, point_depart,
 alerte_avant, unite_alerte, frequence_relance, unite_frequence_relance,
 escalade_apres, actif, date_debut)
VALUES
('reclamation', NULL, 'Delai general reclamation - A VALIDER', 5, 'jours', 'calendaire',
 'affectation', 1, 'jours', 2, 'jours', 5, 1, CURRENT_DATE()),
('assistance', NULL, 'Delai general assistance - A VALIDER', 5, 'jours', 'calendaire',
 'affectation', 1, 'jours', 2, 'jours', 5, 1, CURRENT_DATE());

-- Fin du script.
