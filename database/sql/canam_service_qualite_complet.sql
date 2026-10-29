-- --------------------------------------------------------
-- Hôte :                        localhost
-- Version du serveur:           8.0.46 - MySQL Community Server - GPL
-- SE du serveur:                Win64
-- HeidiSQL Version:             10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Listage de la structure de la base pour canam_service_qualite
CREATE DATABASE IF NOT EXISTS `canam_service_qualite` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `canam_service_qualite`;

-- Listage de la structure de la table canam_service_qualite. affectations
CREATE TABLE IF NOT EXISTS `affectations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `module` enum('reclamation','assistance') COLLATE utf8mb4_unicode_ci NOT NULL,
  `reclamation_id` bigint unsigned DEFAULT NULL,
  `demande_assistance_id` bigint unsigned DEFAULT NULL,
  `responsable_precedent_id` bigint unsigned DEFAULT NULL,
  `responsable_nouveau_id` bigint unsigned NOT NULL,
  `affecte_par` bigint unsigned DEFAULT NULL,
  `date_affectation` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `motif` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_affectations_reclamation` (`reclamation_id`,`date_affectation`),
  KEY `idx_affectations_assistance` (`demande_assistance_id`,`date_affectation`),
  KEY `idx_affectations_responsable` (`responsable_nouveau_id`,`date_affectation`),
  KEY `fk_affectations_ancien` (`responsable_precedent_id`),
  KEY `fk_affectations_auteur` (`affecte_par`),
  CONSTRAINT `fk_affectations_ancien` FOREIGN KEY (`responsable_precedent_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_affectations_assistance` FOREIGN KEY (`demande_assistance_id`) REFERENCES `demandes_assistance` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_affectations_auteur` FOREIGN KEY (`affecte_par`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_affectations_nouveau` FOREIGN KEY (`responsable_nouveau_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_affectations_reclamation` FOREIGN KEY (`reclamation_id`) REFERENCES `reclamations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `chk_affectations_un_dossier` CHECK ((((`module` = _utf8mb4'reclamation') and (`reclamation_id` is not null) and (`demande_assistance_id` is null)) or ((`module` = _utf8mb4'assistance') and (`demande_assistance_id` is not null) and (`reclamation_id` is null))))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.affectations : ~2 rows (environ)
/*!40000 ALTER TABLE `affectations` DISABLE KEYS */;
INSERT INTO `affectations` (`id`, `module`, `reclamation_id`, `demande_assistance_id`, `responsable_precedent_id`, `responsable_nouveau_id`, `affecte_par`, `date_affectation`, `motif`, `created_at`) VALUES
	(1, 'reclamation', 1, NULL, NULL, 1, 1, '2026-10-09 21:31:46', 'TEST', '2026-10-09 21:31:46'),
	(2, 'reclamation', 1, NULL, 1, 2, 1, '2026-10-09 21:43:53', NULL, '2026-10-09 21:43:53');
/*!40000 ALTER TABLE `affectations` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. delais_traitement
CREATE TABLE IF NOT EXISTS `delais_traitement` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `module` enum('reclamation','assistance') COLLATE utf8mb4_unicode_ci NOT NULL,
  `qualification_id` bigint unsigned DEFAULT NULL,
  `libelle` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `duree` int unsigned NOT NULL,
  `unite` enum('heures','jours') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'jours',
  `calendrier` enum('calendaire','ouvre') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'calendaire',
  `point_depart` enum('reception','affectation') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'affectation',
  `alerte_avant` int unsigned NOT NULL DEFAULT '1',
  `unite_alerte` enum('heures','jours') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'jours',
  `frequence_relance` int unsigned DEFAULT NULL,
  `unite_frequence_relance` enum('heures','jours') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'jours',
  `escalade_apres` int unsigned DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT '1',
  `date_debut` date NOT NULL,
  `date_fin` date DEFAULT NULL,
  `cree_par` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_delais_module_actif` (`module`,`actif`,`date_debut`,`date_fin`),
  KEY `idx_delais_qualification` (`qualification_id`),
  KEY `fk_delais_user` (`cree_par`),
  CONSTRAINT `fk_delais_qualification` FOREIGN KEY (`qualification_id`) REFERENCES `qualifications` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_delais_user` FOREIGN KEY (`cree_par`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_delais_dates` CHECK (((`date_fin` is null) or (`date_fin` >= `date_debut`))),
  CONSTRAINT `chk_delais_duree` CHECK ((`duree` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.delais_traitement : ~2 rows (environ)
/*!40000 ALTER TABLE `delais_traitement` DISABLE KEYS */;
INSERT INTO `delais_traitement` (`id`, `module`, `qualification_id`, `libelle`, `duree`, `unite`, `calendrier`, `point_depart`, `alerte_avant`, `unite_alerte`, `frequence_relance`, `unite_frequence_relance`, `escalade_apres`, `actif`, `date_debut`, `date_fin`, `cree_par`, `created_at`, `updated_at`) VALUES
	(1, 'reclamation', NULL, 'Delai general reclamation - A VALIDER', 5, 'jours', 'calendaire', 'affectation', 1, 'jours', 2, 'jours', 5, 1, '2026-10-09', NULL, NULL, '2026-10-09 17:18:19', '2026-10-09 17:18:19'),
	(2, 'assistance', NULL, 'Delai general assistance - A VALIDER', 5, 'jours', 'calendaire', 'affectation', 1, 'jours', 2, 'jours', 5, 1, '2026-10-09', NULL, NULL, '2026-10-09 17:18:19', '2026-10-09 17:18:19');
/*!40000 ALTER TABLE `delais_traitement` ENABLE KEYS */;

-- Tables de contrôle des droits de l'assuré et de disponibilité des cartes.
-- Les données sont rattachées au numéro de matricule utilisé dans les dossiers.
CREATE TABLE IF NOT EXISTS `droits_assures` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `numero_amo_recepisse` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `statut` enum('ouverts','suspendus','fermes','inconnu') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'inconnu',
  `date_debut` date DEFAULT NULL,
  `date_fin` date DEFAULT NULL,
  `verifie_le` datetime DEFAULT NULL,
  `observations` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_droits_assures_amo` (`numero_amo_recepisse`),
  KEY `idx_droits_assures_statut` (`statut`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `disponibilite_cartes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `numero_amo_recepisse` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `numero_carte` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `disponibilite` enum('disponible','en_preparation','emise','indisponible','inconnue') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'inconnue',
  `date_mise_a_jour` datetime DEFAULT NULL,
  `observations` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_disponibilite_cartes_numero` (`numero_carte`),
  KEY `idx_disponibilite_cartes_amo` (`numero_amo_recepisse`),
  KEY `idx_disponibilite_cartes_etat` (`disponibilite`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage de la structure de la table canam_service_qualite. demandes_assistance
CREATE TABLE IF NOT EXISTS `demandes_assistance` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `numero_ordre` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_reception` date NOT NULL,
  `demandeur` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `region_id` bigint unsigned DEFAULT NULL,
  `localite_id` bigint unsigned DEFAULT NULL,
  `numero_amo_recepisse` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `numero_matricule` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ogd_id` bigint unsigned DEFAULT NULL,
  `objet` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `provenance_id` bigint unsigned DEFAULT NULL,
  `qualification_id` bigint unsigned DEFAULT NULL,
  `processus_id` bigint unsigned DEFAULT NULL,
  `responsable_traitement_id` bigint unsigned DEFAULT NULL,
  `date_affectation` datetime DEFAULT NULL,
  `delai_traitement_id` bigint unsigned DEFAULT NULL,
  `echeance_traitement` datetime DEFAULT NULL,
  `causes_probleme` text COLLATE utf8mb4_unicode_ci,
  `action_entreprise` text COLLATE utf8mb4_unicode_ci,
  `date_traitement` datetime DEFAULT NULL,
  `statut` enum('brouillon','recu','a_affecter','affecte','en_cours','en_attente_information','traite','a_notifier','cloture','annule') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'recu',
  `priorite` enum('basse','normale','haute','urgente') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'normale',
  `statut_notification` enum('non_requise','a_notifier','appele_informe','injoignable','rappel_necessaire','notification_effectuee') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'a_notifier',
  `date_appel` datetime DEFAULT NULL,
  `responsable_notification_id` bigint unsigned DEFAULT NULL,
  `observations` text COLLATE utf8mb4_unicode_ci,
  `cree_par` bigint unsigned DEFAULT NULL,
  `cloture_par` bigint unsigned DEFAULT NULL,
  `date_cloture` datetime DEFAULT NULL,
  `motif_annulation` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_assistance_numero_ordre` (`numero_ordre`),
  KEY `idx_assistance_date_reception` (`date_reception`),
  KEY `idx_assistance_statut_echeance` (`statut`,`echeance_traitement`),
  KEY `idx_assistance_responsable` (`responsable_traitement_id`),
  KEY `idx_assistance_notification` (`statut_notification`,`date_appel`),
  KEY `idx_assistance_amo` (`numero_amo_recepisse`),
  KEY `idx_assistance_matricule` (`numero_matricule`),
  KEY `idx_assistance_region` (`region_id`),
  KEY `idx_assistance_ogd` (`ogd_id`),
  KEY `idx_assistance_qualification` (`qualification_id`),
  KEY `fk_assistance_localite` (`localite_id`),
  KEY `fk_assistance_provenance` (`provenance_id`),
  KEY `fk_assistance_processus` (`processus_id`),
  KEY `fk_assistance_delai` (`delai_traitement_id`),
  KEY `fk_assistance_notification_user` (`responsable_notification_id`),
  KEY `fk_assistance_createur` (`cree_par`),
  KEY `fk_assistance_clotureur` (`cloture_par`),
  CONSTRAINT `fk_assistance_clotureur` FOREIGN KEY (`cloture_par`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_assistance_createur` FOREIGN KEY (`cree_par`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_assistance_delai` FOREIGN KEY (`delai_traitement_id`) REFERENCES `delais_traitement` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_assistance_localite` FOREIGN KEY (`localite_id`) REFERENCES `localites` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_assistance_notification_user` FOREIGN KEY (`responsable_notification_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_assistance_ogd` FOREIGN KEY (`ogd_id`) REFERENCES `ogds` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_assistance_processus` FOREIGN KEY (`processus_id`) REFERENCES `processus` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_assistance_provenance` FOREIGN KEY (`provenance_id`) REFERENCES `provenances` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_assistance_qualification` FOREIGN KEY (`qualification_id`) REFERENCES `qualifications` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_assistance_region` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_assistance_responsable` FOREIGN KEY (`responsable_traitement_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_assistance_dates` CHECK (((`date_cloture` is null) or (`statut` = _utf8mb4'cloture')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.demandes_assistance : ~0 rows (environ)
/*!40000 ALTER TABLE `demandes_assistance` DISABLE KEYS */;
/*!40000 ALTER TABLE `demandes_assistance` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. historique_statuts
CREATE TABLE IF NOT EXISTS `historique_statuts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `module` enum('reclamation','assistance') COLLATE utf8mb4_unicode_ci NOT NULL,
  `reclamation_id` bigint unsigned DEFAULT NULL,
  `demande_assistance_id` bigint unsigned DEFAULT NULL,
  `ancien_statut` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nouveau_statut` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `commentaire` text COLLATE utf8mb4_unicode_ci,
  `modifie_par` bigint unsigned DEFAULT NULL,
  `date_changement` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_hist_statut_reclamation` (`reclamation_id`,`date_changement`),
  KEY `idx_hist_statut_assistance` (`demande_assistance_id`,`date_changement`),
  KEY `fk_hist_statut_user` (`modifie_par`),
  CONSTRAINT `fk_hist_statut_assistance` FOREIGN KEY (`demande_assistance_id`) REFERENCES `demandes_assistance` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_hist_statut_reclamation` FOREIGN KEY (`reclamation_id`) REFERENCES `reclamations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_hist_statut_user` FOREIGN KEY (`modifie_par`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_hist_statut_un_dossier` CHECK ((((`module` = _utf8mb4'reclamation') and (`reclamation_id` is not null) and (`demande_assistance_id` is null)) or ((`module` = _utf8mb4'assistance') and (`demande_assistance_id` is not null) and (`reclamation_id` is null))))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.historique_statuts : ~7 rows (environ)
/*!40000 ALTER TABLE `historique_statuts` DISABLE KEYS */;
INSERT INTO `historique_statuts` (`id`, `module`, `reclamation_id`, `demande_assistance_id`, `ancien_statut`, `nouveau_statut`, `commentaire`, `modifie_par`, `date_changement`, `created_at`) VALUES
	(1, 'reclamation', 1, NULL, NULL, 'recu', 'Enregistrement du dossier', 1, '2026-10-09 21:30:52', '2026-10-09 21:30:52'),
	(2, 'reclamation', 1, NULL, 'recu', 'affecte', 'Affectation du dossier', 1, '2026-10-09 21:31:46', '2026-10-09 21:31:46'),
	(3, 'reclamation', 1, NULL, 'affecte', 'affecte', 'Affectation du dossier', 1, '2026-10-09 21:43:53', '2026-10-09 21:43:53'),
	(4, 'reclamation', 1, NULL, 'affecte', 'en_attente_information', NULL, 2, '2026-10-09 21:56:36', '2026-10-09 21:56:36'),
	(5, 'reclamation', 1, NULL, 'en_attente_information', 'cloture', NULL, 2, '2026-10-09 21:59:31', '2026-10-09 21:59:31'),
	(6, 'reclamation', 2, NULL, NULL, 'recu', 'Enregistrement du dossier', 3, '2026-10-09 22:08:01', '2026-10-09 22:08:01'),
	(7, 'reclamation', 2, NULL, 'recu', 'en_attente_information', NULL, 7, '2026-10-09 22:19:37', '2026-10-09 22:19:37');
/*!40000 ALTER TABLE `historique_statuts` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. journal_activites
CREATE TABLE IF NOT EXISTS `journal_activites` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `module` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dossier_id` bigint unsigned DEFAULT NULL,
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `adresse_ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `donnees_avant` json DEFAULT NULL,
  `donnees_apres` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_journal_user_date` (`user_id`,`created_at`),
  KEY `idx_journal_module_dossier` (`module`,`dossier_id`,`created_at`),
  CONSTRAINT `fk_journal_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.journal_activites : ~7 rows (environ)
/*!40000 ALTER TABLE `journal_activites` DISABLE KEYS */;
INSERT INTO `journal_activites` (`id`, `user_id`, `module`, `dossier_id`, `action`, `description`, `adresse_ip`, `user_agent`, `donnees_avant`, `donnees_apres`, `created_at`) VALUES
	(1, 1, 'reclamation', 1, 'statut_recu', 'Enregistrement du dossier', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', NULL, '{"statut": "recu"}', '2026-10-09 21:30:52'),
	(2, 1, 'reclamation', 1, 'statut_affecte', 'Affectation du dossier', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', NULL, '{"statut": "affecte"}', '2026-10-09 21:31:46'),
	(3, 1, 'reclamation', 1, 'statut_affecte', 'Affectation du dossier', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', NULL, '{"statut": "affecte"}', '2026-10-09 21:43:53'),
	(4, 2, 'reclamation', 1, 'statut_en_attente_information', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', NULL, '{"statut": "en_attente_information"}', '2026-10-09 21:56:36'),
	(5, 2, 'reclamation', 1, 'statut_cloture', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', NULL, '{"statut": "cloture"}', '2026-10-09 21:59:31'),
	(6, 3, 'reclamation', 2, 'statut_recu', 'Enregistrement du dossier', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', NULL, '{"statut": "recu"}', '2026-10-09 22:08:01'),
	(7, 7, 'reclamation', 2, 'statut_en_attente_information', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', NULL, '{"statut": "en_attente_information"}', '2026-10-09 22:19:37');
/*!40000 ALTER TABLE `journal_activites` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. localites
CREATE TABLE IF NOT EXISTS `localites` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `region_id` bigint unsigned NOT NULL,
  `nom` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_localite_region_nom` (`region_id`,`nom`),
  CONSTRAINT `fk_localites_region` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.localites : ~1 rows (environ)
/*!40000 ALTER TABLE `localites` DISABLE KEYS */;
INSERT INTO `localites` (`id`, `region_id`, `nom`, `actif`, `created_at`, `updated_at`) VALUES
	(1, 1, 'Kati', 1, '2026-10-09 21:25:44', '2026-10-09 21:25:44');
/*!40000 ALTER TABLE `localites` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. migrations
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.migrations : ~2 rows (environ)
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
	(1, '2019_12_14_000001_create_personal_access_tokens_table', 1),
	(2, '2026_10_09_000001_create_canam_schema_from_sql', 1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. notifications_assistance
CREATE TABLE IF NOT EXISTS `notifications_assistance` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `demande_assistance_id` bigint unsigned NOT NULL,
  `date_appel` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `responsable_notification_id` bigint unsigned NOT NULL,
  `canal` enum('telephone','email','sms','courrier','autre') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'telephone',
  `statut` enum('appele_informe','injoignable','rappel_necessaire','notification_effectuee','echec','non_requise') COLLATE utf8mb4_unicode_ci NOT NULL,
  `commentaire` text COLLATE utf8mb4_unicode_ci,
  `prochaine_tentative` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notifications_demande` (`demande_assistance_id`,`date_appel`),
  KEY `idx_notifications_responsable` (`responsable_notification_id`,`date_appel`),
  CONSTRAINT `fk_notifications_demande` FOREIGN KEY (`demande_assistance_id`) REFERENCES `demandes_assistance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_notifications_responsable` FOREIGN KEY (`responsable_notification_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.notifications_assistance : ~0 rows (environ)
/*!40000 ALTER TABLE `notifications_assistance` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications_assistance` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. ogds
CREATE TABLE IF NOT EXISTS `ogds` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nom` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ogds_nom` (`nom`),
  UNIQUE KEY `uq_ogds_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.ogds : ~2 rows (environ)
/*!40000 ALTER TABLE `ogds` DISABLE KEYS */;
INSERT INTO `ogds` (`id`, `code`, `nom`, `description`, `actif`, `created_at`, `updated_at`) VALUES
	(1, NULL, 'INPS', NULL, 1, '2026-10-09 21:26:39', '2026-10-09 21:26:39'),
	(2, NULL, 'CMSS', NULL, 1, '2026-10-09 21:27:25', '2026-10-09 21:27:25');
/*!40000 ALTER TABLE `ogds` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. personal_access_tokens
CREATE TABLE IF NOT EXISTS `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.personal_access_tokens : ~0 rows (environ)
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. pieces_jointes
CREATE TABLE IF NOT EXISTS `pieces_jointes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `module` enum('reclamation','assistance') COLLATE utf8mb4_unicode_ci NOT NULL,
  `reclamation_id` bigint unsigned DEFAULT NULL,
  `demande_assistance_id` bigint unsigned DEFAULT NULL,
  `nom_original` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `chemin_stockage` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type_mime` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `taille_octets` bigint unsigned DEFAULT NULL,
  `ajoute_par` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pj_reclamation` (`reclamation_id`),
  KEY `idx_pj_assistance` (`demande_assistance_id`),
  KEY `fk_pj_user` (`ajoute_par`),
  CONSTRAINT `fk_pj_assistance` FOREIGN KEY (`demande_assistance_id`) REFERENCES `demandes_assistance` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_pj_reclamation` FOREIGN KEY (`reclamation_id`) REFERENCES `reclamations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_pj_user` FOREIGN KEY (`ajoute_par`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_pj_un_dossier` CHECK ((((`module` = _utf8mb4'reclamation') and (`reclamation_id` is not null) and (`demande_assistance_id` is null)) or ((`module` = _utf8mb4'assistance') and (`demande_assistance_id` is not null) and (`reclamation_id` is null))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.pieces_jointes : ~0 rows (environ)
/*!40000 ALTER TABLE `pieces_jointes` DISABLE KEYS */;
/*!40000 ALTER TABLE `pieces_jointes` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. processus
CREATE TABLE IF NOT EXISTS `processus` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `libelle` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `actif` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_processus_code` (`code`),
  UNIQUE KEY `uq_processus_libelle` (`libelle`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.processus : ~5 rows (environ)
/*!40000 ALTER TABLE `processus` DISABLE KEYS */;
INSERT INTO `processus` (`id`, `code`, `libelle`, `description`, `actif`, `created_at`, `updated_at`) VALUES
	(1, 'CARTE_AMO', 'Gestion de la carte AMO', 'Processus lie a la carte AMO', 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(2, 'IMMATRICULATION', 'Immatriculation', 'Processus d\'immatriculation', 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(3, 'PRISE_EN_CHARGE', 'Prise en charge', 'Processus de prise en charge', 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(4, 'PRESTATIONS', 'Prestations', 'Gestion des prestations', 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(5, 'AUTRE', 'Autre processus', 'A preciser par le Service Qualite', 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12');
/*!40000 ALTER TABLE `processus` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. provenances
CREATE TABLE IF NOT EXISTS `provenances` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `module` enum('reclamation','assistance','commun') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'commun',
  `libelle` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_provenance_module_libelle` (`module`,`libelle`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.provenances : ~6 rows (environ)
/*!40000 ALTER TABLE `provenances` DISABLE KEYS */;
INSERT INTO `provenances` (`id`, `module`, `libelle`, `actif`, `created_at`, `updated_at`) VALUES
	(1, 'commun', 'Courrier', 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(2, 'commun', 'Telephone', 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(3, 'commun', 'Email', 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(4, 'commun', 'Accueil physique', 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(5, 'commun', 'Direction / service interne', 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(6, 'commun', 'Autre', 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12');
/*!40000 ALTER TABLE `provenances` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. qualifications
CREATE TABLE IF NOT EXISTS `qualifications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `module` enum('reclamation','assistance') COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `libelle` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `actif` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_qualification_module_libelle` (`module`,`libelle`),
  UNIQUE KEY `uq_qualification_module_code` (`module`,`code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.qualifications : ~8 rows (environ)
/*!40000 ALTER TABLE `qualifications` DISABLE KEYS */;
INSERT INTO `qualifications` (`id`, `module`, `code`, `libelle`, `description`, `actif`, `created_at`, `updated_at`) VALUES
	(1, 'reclamation', 'CARTE_NON_RECUE', 'Carte AMO non reçue', NULL, 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(2, 'reclamation', 'ERREUR_CARTE', 'Erreur sur la carte AMO', NULL, 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(3, 'reclamation', 'DOSSIER_BLOQUE', 'Dossier bloqué', NULL, 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(4, 'reclamation', 'AUTRE', 'Autre réclamation', NULL, 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(5, 'assistance', 'INFORMATION', 'Demande d’information', NULL, 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(6, 'assistance', 'AIDE_UTILISATION', 'Aide à l’utilisation', NULL, 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(7, 'assistance', 'INCIDENT', 'Incident ou anomalie', NULL, 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(8, 'assistance', 'AUTRE', 'Autre demande d’assistance', NULL, 1, '2026-10-09 18:53:12', '2026-10-09 18:53:12');
/*!40000 ALTER TABLE `qualifications` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. reclamations
CREATE TABLE IF NOT EXISTS `reclamations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `numero_ordre` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_reception` date NOT NULL,
  `reclamant` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `region_id` bigint unsigned DEFAULT NULL,
  `localite_id` bigint unsigned DEFAULT NULL,
  `numero_amo_recepisse` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `numero_matricule` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ogd_id` bigint unsigned DEFAULT NULL,
  `objet` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `provenance_id` bigint unsigned DEFAULT NULL,
  `qualification_id` bigint unsigned DEFAULT NULL,
  `processus_id` bigint unsigned DEFAULT NULL,
  `responsable_traitement_id` bigint unsigned DEFAULT NULL,
  `date_affectation` datetime DEFAULT NULL,
  `delai_traitement_id` bigint unsigned DEFAULT NULL,
  `echeance_traitement` datetime DEFAULT NULL,
  `causes_probleme` text COLLATE utf8mb4_unicode_ci,
  `action_entreprise` text COLLATE utf8mb4_unicode_ci,
  `date_emission_carte` date DEFAULT NULL,
  `date_traitement` datetime DEFAULT NULL,
  `statut` enum('brouillon','recu','a_affecter','affecte','en_cours','en_attente_information','traite','cloture','annule') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'recu',
  `priorite` enum('basse','normale','haute','urgente') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'normale',
  `observations` text COLLATE utf8mb4_unicode_ci,
  `cree_par` bigint unsigned DEFAULT NULL,
  `cloture_par` bigint unsigned DEFAULT NULL,
  `date_cloture` datetime DEFAULT NULL,
  `motif_annulation` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_reclamations_numero_ordre` (`numero_ordre`),
  KEY `idx_reclamations_date_reception` (`date_reception`),
  KEY `idx_reclamations_statut_echeance` (`statut`,`echeance_traitement`),
  KEY `idx_reclamations_responsable` (`responsable_traitement_id`),
  KEY `idx_reclamations_amo` (`numero_amo_recepisse`),
  KEY `idx_reclamations_matricule` (`numero_matricule`),
  KEY `idx_reclamations_region` (`region_id`),
  KEY `idx_reclamations_ogd` (`ogd_id`),
  KEY `idx_reclamations_qualification` (`qualification_id`),
  KEY `fk_reclamations_localite` (`localite_id`),
  KEY `fk_reclamations_provenance` (`provenance_id`),
  KEY `fk_reclamations_processus` (`processus_id`),
  KEY `fk_reclamations_delai` (`delai_traitement_id`),
  KEY `fk_reclamations_createur` (`cree_par`),
  KEY `fk_reclamations_clotureur` (`cloture_par`),
  CONSTRAINT `fk_reclamations_clotureur` FOREIGN KEY (`cloture_par`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_reclamations_createur` FOREIGN KEY (`cree_par`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_reclamations_delai` FOREIGN KEY (`delai_traitement_id`) REFERENCES `delais_traitement` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_reclamations_localite` FOREIGN KEY (`localite_id`) REFERENCES `localites` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_reclamations_ogd` FOREIGN KEY (`ogd_id`) REFERENCES `ogds` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_reclamations_processus` FOREIGN KEY (`processus_id`) REFERENCES `processus` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_reclamations_provenance` FOREIGN KEY (`provenance_id`) REFERENCES `provenances` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_reclamations_qualification` FOREIGN KEY (`qualification_id`) REFERENCES `qualifications` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_reclamations_region` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_reclamations_responsable` FOREIGN KEY (`responsable_traitement_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_reclamations_dates` CHECK (((`date_cloture` is null) or (`statut` = _utf8mb4'cloture')))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.reclamations : ~2 rows (environ)
/*!40000 ALTER TABLE `reclamations` DISABLE KEYS */;
INSERT INTO `reclamations` (`id`, `numero_ordre`, `date_reception`, `reclamant`, `region_id`, `localite_id`, `numero_amo_recepisse`, `numero_matricule`, `contact`, `ogd_id`, `objet`, `provenance_id`, `qualification_id`, `processus_id`, `responsable_traitement_id`, `date_affectation`, `delai_traitement_id`, `echeance_traitement`, `causes_probleme`, `action_entreprise`, `date_emission_carte`, `date_traitement`, `statut`, `priorite`, `observations`, `cree_par`, `cloture_par`, `date_cloture`, `motif_annulation`, `created_at`, `updated_at`) VALUES
	(1, 'REC-20261009-69CF4', '2026-10-09', 'Mahamane Amar MAIGA', 1, 1, '1234567891234', NULL, '78859432', 1, 'TEST', 2, 2, 1, 2, '2026-10-09 21:43:53', 1, '2026-10-14 21:43:53', 'TEST', 'TEST', '2023-01-09', '2026-10-09 21:59:31', 'cloture', 'urgente', 'TEST', 1, 2, '2026-10-09 21:59:31', NULL, '2026-10-09 21:30:52', '2026-10-09 21:59:31'),
	(2, 'REC-20261009-FZNGL', '2026-10-09', 'Mahamane Amar MAIGA', 1, 1, '1234567891234', NULL, '78859432', 2, 'TEST2', 3, 1, 2, NULL, NULL, 1, NULL, 'DEST', 'DEST', '2025-12-29', NULL, 'en_attente_information', 'normale', 'DEST', 3, NULL, NULL, NULL, '2026-10-09 22:08:01', '2026-10-09 22:19:37');
/*!40000 ALTER TABLE `reclamations` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. regions
CREATE TABLE IF NOT EXISTS `regions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nom` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_regions_nom` (`nom`),
  UNIQUE KEY `uq_regions_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.regions : ~1 rows (environ)
/*!40000 ALTER TABLE `regions` DISABLE KEYS */;
INSERT INTO `regions` (`id`, `code`, `nom`, `actif`, `created_at`, `updated_at`) VALUES
	(1, NULL, 'Koulikoro', 1, '2026-10-09 21:22:31', '2026-10-09 21:22:31');
/*!40000 ALTER TABLE `regions` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. relances
CREATE TABLE IF NOT EXISTS `relances` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `module` enum('reclamation','assistance') COLLATE utf8mb4_unicode_ci NOT NULL,
  `reclamation_id` bigint unsigned DEFAULT NULL,
  `demande_assistance_id` bigint unsigned DEFAULT NULL,
  `date_relance` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `responsable_relance_id` bigint unsigned NOT NULL,
  `destinataire_id` bigint unsigned DEFAULT NULL,
  `canal` enum('interne','telephone','email','courrier','autre') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'interne',
  `motif` text COLLATE utf8mb4_unicode_ci,
  `resultat` text COLLATE utf8mb4_unicode_ci,
  `prochaine_action` datetime DEFAULT NULL,
  `statut` enum('effectuee','en_attente','sans_suite') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'effectuee',
  `cree_par` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_relances_reclamation` (`reclamation_id`,`date_relance`),
  KEY `idx_relances_assistance` (`demande_assistance_id`,`date_relance`),
  KEY `idx_relances_responsable` (`responsable_relance_id`,`date_relance`),
  KEY `fk_relances_destinataire` (`destinataire_id`),
  KEY `fk_relances_createur` (`cree_par`),
  CONSTRAINT `fk_relances_assistance` FOREIGN KEY (`demande_assistance_id`) REFERENCES `demandes_assistance` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_relances_createur` FOREIGN KEY (`cree_par`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_relances_destinataire` FOREIGN KEY (`destinataire_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_relances_reclamation` FOREIGN KEY (`reclamation_id`) REFERENCES `reclamations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_relances_responsable` FOREIGN KEY (`responsable_relance_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_relances_un_dossier` CHECK ((((`module` = _utf8mb4'reclamation') and (`reclamation_id` is not null) and (`demande_assistance_id` is null)) or ((`module` = _utf8mb4'assistance') and (`demande_assistance_id` is not null) and (`reclamation_id` is null))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.relances : ~0 rows (environ)
/*!40000 ALTER TABLE `relances` DISABLE KEYS */;
/*!40000 ALTER TABLE `relances` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. roles
CREATE TABLE IF NOT EXISTS `roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `libelle` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_roles_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.roles : ~7 rows (environ)
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` (`id`, `code`, `libelle`, `description`, `created_at`, `updated_at`) VALUES
	(1, 'ADMIN', 'Administrateur', 'Administration technique et gestion des habilitations', '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(2, 'RQ', 'Responsable Qualité', 'Affectation, suivi des delais et pilotage', '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(3, 'ENREGISTREMENT', 'Agent d’enregistrement', 'Enregistrement des dossiers', '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(4, 'TRAITEMENT', 'Responsable de traitement', 'Traitement des dossiers affectes', '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(5, 'RELANCE', 'Responsable de relance', 'Enregistrement et suivi des relances', '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(6, 'NOTIFICATION', 'Responsable de notification', 'Appels et notifications des demandes d\'assistance', '2026-10-09 18:53:12', '2026-10-09 18:53:12'),
	(7, 'CONSULTATION', 'Consultation', 'Consultation et rapports sans modification', '2026-10-09 18:53:12', '2026-10-09 18:53:12');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. users
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `nom` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prenom` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `identifiant` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(190) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telephone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Hash Laravel uniquement',
  `actif` tinyint(1) NOT NULL DEFAULT '1',
  `derniere_connexion` datetime DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_identifiant` (`identifiant`),
  UNIQUE KEY `uq_users_email` (`email`),
  KEY `idx_users_actif` (`actif`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.users : ~7 rows (environ)
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`id`, `nom`, `prenom`, `identifiant`, `email`, `telephone`, `password`, `actif`, `derniere_connexion`, `remember_token`, `created_at`, `updated_at`) VALUES
	(1, 'Administrateur', 'CANAM', 'admin', 'admin@canam.ml', '78859432', '$2y$10$f/sA1MFn5Qh7rMVwyyi0oeS48sb/aqHZPE4BOw7PI3FhBEkek5epa', 1, NULL, NULL, '2026-10-09 18:55:43', '2026-10-09 18:58:57'),
	(2, 'Responsable Qualité', 'CANAM', 'RQ', 'rq@canam.ml', NULL, '$2y$10$Zf0v6GIw.Hx.75b6niOq/O/DkR7nWkNAdy3.8hCrEJGBqczIxjZzW', 1, NULL, NULL, '2026-10-09 21:40:45', '2026-10-09 21:40:45'),
	(3, 'Agent d’enregistrement', 'CANAM', 'ENREGISTREMENT', 'enregistrement@canam.ml', 'rq@canam.ml', '$2y$10$eCBLzIKIUEke1iyBd/g1Cu6Jplc27tM2cjZU44VqUP1EXeYCn62OK', 1, NULL, NULL, '2026-10-09 22:04:48', '2026-10-09 22:04:48'),
	(4, 'Responsable de traitement', 'CANAM', 'TRAITEMENT', 'traitement@canam.ml', 'rq@canam.ml', '$2y$10$f0OItbg0TBQYFwwJZVo2XOkmCrddkcwbsMS83.0CepWoFkNV.dOaq', 1, NULL, NULL, '2026-10-09 22:13:10', '2026-10-09 22:13:10'),
	(5, 'Responsable de relance', 'CANAM', 'RELANCE', 'relance@canam.ml', 'rq@canam.ml', '$2y$10$/s.eQGzxJimx/GNklakTt.Wtwo8fqM6i5lWbukfzrkv2JaBpELuBu', 1, NULL, NULL, '2026-10-09 22:14:45', '2026-10-09 22:14:45'),
	(6, 'Responsable de notification', 'CANAM', 'NOTIFICATION', 'notification@canam.ml', 'rq@canam.ml', '$2y$10$EzjqPSr8f93XpB0rLhfmKuyL5jRo0jQHOT14509NDkk6uoO2CAN/6', 1, NULL, NULL, '2026-10-09 22:16:05', '2026-10-09 22:16:05'),
	(7, 'Consultation', 'CANAM', 'CONSULTATION', 'consultation@canam.ml', 'rq@canam.ml', '$2y$10$rjNrNi5HelkIOkcIGlYDAOAxLMyRBkd9JB4FSWOII1bidKM8DpOP2', 1, NULL, NULL, '2026-10-09 22:17:39', '2026-10-09 22:17:39');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;

-- Listage de la structure de la table canam_service_qualite. user_roles
CREATE TABLE IF NOT EXISTS `user_roles` (
  `user_id` bigint unsigned NOT NULL,
  `role_id` bigint unsigned NOT NULL,
  `attribue_par` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `fk_user_roles_role` (`role_id`),
  KEY `fk_user_roles_attribue` (`attribue_par`),
  CONSTRAINT `fk_user_roles_attribue` FOREIGN KEY (`attribue_par`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_user_roles_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_user_roles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Listage des données de la table canam_service_qualite.user_roles : ~7 rows (environ)
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` (`user_id`, `role_id`, `attribue_par`, `created_at`, `updated_at`) VALUES
	(1, 1, 1, '2026-10-09 19:15:46', '2026-10-09 19:21:39'),
	(2, 2, 1, '2026-10-09 21:40:45', '2026-10-09 21:40:45'),
	(3, 3, 1, '2026-10-09 22:04:48', '2026-10-09 22:04:48'),
	(4, 4, 1, '2026-10-09 22:13:10', '2026-10-09 22:13:10'),
	(5, 5, 1, '2026-10-09 22:14:45', '2026-10-09 22:14:45'),
	(6, 6, 1, '2026-10-09 22:16:05', '2026-10-09 22:16:05'),
	(7, 7, 1, '2026-10-09 22:17:39', '2026-10-09 22:17:39');
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;

-- Listage de la structure de la vue canam_service_qualite. v_dossiers_en_retard
-- Création d'une table temporaire pour palier aux erreurs de dépendances de VIEW
CREATE TABLE `v_dossiers_en_retard` (
	`module` VARCHAR(11) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`dossier_id` BIGINT NOT NULL,
	`numero_ordre` VARCHAR(40) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`date_reception` DATE NOT NULL,
	`objet` MEDIUMTEXT NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`statut` VARCHAR(22) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`responsable_traitement_id` BIGINT NULL,
	`echeance_traitement` DATETIME NULL,
	`retard_heures` BIGINT NULL
) ENGINE=MyISAM;

-- Listage de la structure de la vue canam_service_qualite. v_tableau_bord_qualite
-- Création d'une table temporaire pour palier aux erreurs de dépendances de VIEW
CREATE TABLE `v_tableau_bord_qualite` (
	`module` VARCHAR(11) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`statut` VARCHAR(22) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`nombre` BIGINT NOT NULL
) ENGINE=MyISAM;

-- Listage de la structure de la vue canam_service_qualite. v_dossiers_en_retard
-- Suppression de la table temporaire et création finale de la structure d'une vue
DROP TABLE IF EXISTS `v_dossiers_en_retard`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_dossiers_en_retard` AS select 'reclamation' AS `module`,`r`.`id` AS `dossier_id`,`r`.`numero_ordre` AS `numero_ordre`,`r`.`date_reception` AS `date_reception`,`r`.`objet` AS `objet`,`r`.`statut` AS `statut`,`r`.`responsable_traitement_id` AS `responsable_traitement_id`,`r`.`echeance_traitement` AS `echeance_traitement`,timestampdiff(HOUR,`r`.`echeance_traitement`,now()) AS `retard_heures` from `reclamations` `r` where ((`r`.`echeance_traitement` is not null) and (`r`.`echeance_traitement` < now()) and (`r`.`statut` not in ('traite','cloture','annule'))) union all select 'assistance' AS `module`,`d`.`id` AS `dossier_id`,`d`.`numero_ordre` AS `numero_ordre`,`d`.`date_reception` AS `date_reception`,`d`.`objet` AS `objet`,`d`.`statut` AS `statut`,`d`.`responsable_traitement_id` AS `responsable_traitement_id`,`d`.`echeance_traitement` AS `echeance_traitement`,timestampdiff(HOUR,`d`.`echeance_traitement`,now()) AS `retard_heures` from `demandes_assistance` `d` where ((`d`.`echeance_traitement` is not null) and (`d`.`echeance_traitement` < now()) and (`d`.`statut` not in ('traite','a_notifier','cloture','annule')));

-- Listage de la structure de la vue canam_service_qualite. v_tableau_bord_qualite
-- Suppression de la table temporaire et création finale de la structure d'une vue
DROP TABLE IF EXISTS `v_tableau_bord_qualite`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_tableau_bord_qualite` AS select 'reclamation' AS `module`,`reclamations`.`statut` AS `statut`,count(0) AS `nombre` from `reclamations` group by `reclamations`.`statut` union all select 'assistance' AS `module`,`demandes_assistance`.`statut` AS `statut`,count(0) AS `nombre` from `demandes_assistance` group by `demandes_assistance`.`statut`;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
