<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Si le schéma SQL CANAM a déjà été importé, ne rien recréer.
        if (Schema::hasTable('users')) {
            $required = ['roles', 'user_roles', 'regions', 'localites', 'ogds', 'processus', 'provenances', 'qualifications', 'delais_traitement', 'reclamations', 'demandes_assistance', 'affectations', 'relances', 'notifications_assistance', 'historique_statuts', 'pieces_jointes', 'journal_activites'];
            $missing = array_values(array_filter($required, fn ($table) => !Schema::hasTable($table)));
            if ($missing) {
                throw new RuntimeException('Schéma CANAM partiellement présent. Tables absentes : '.implode(', ', $missing).'. Vérifiez le script SQL avant de poursuivre.');
            }
            return;
        }

        $file = database_path('sql/canam_service_qualite.sql');
        if (!is_file($file)) {
            throw new RuntimeException('Script SQL introuvable : '.$file);
        }

        $sql = file_get_contents($file);
        // La base doit être créée et sélectionnée via .env avant php artisan migrate.
        $sql = preg_replace('/^\s*--.*$/m', '', $sql);
        $sql = preg_replace('/CREATE\s+DATABASE\s+IF\s+NOT\s+EXISTS\s+canam_service_qualite\s+CHARACTER\s+SET\s+utf8mb4\s+COLLATE\s+utf8mb4_unicode_ci\s*;/i', '', $sql);
        $sql = preg_replace('/\bUSE\s+canam_service_qualite\s*;/i', '', $sql);
        // Les DROP appartiennent uniquement au script manuel de réinstallation de recette.
        $sql = preg_replace('/^\s*DROP\s+(?:VIEW|TABLE)\s+IF\s+EXISTS\s+[^;]+;\s*$/im', '', $sql);
        $sql = preg_replace('/SET\s+FOREIGN_KEY_CHECKS\s*=\s*[01]\s*;/i', '', $sql);
        $sql = preg_replace('/SET\s+NAMES\s+utf8mb4\s*;/i', '', $sql);

        foreach (array_filter(array_map('trim', explode(';', $sql))) as $statement) {
            DB::unprepared($statement);
        }
    }

    public function down(): void
    {
        // Volontairement non destructif : le schéma métier est aussi fourni comme SQL de référence.
        // Pour supprimer une base de test, faites-le explicitement après sauvegarde.
    }
};
