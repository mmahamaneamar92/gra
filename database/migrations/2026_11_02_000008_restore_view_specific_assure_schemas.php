<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $this->moveLegacyNames('droits_assures', 30);
        $this->moveLegacyNames('disponibilite_cartes', 50);

        if (Schema::hasTable('droits_assures')) {
            if (Schema::hasColumn('droits_assures', 'date_naissance') && Schema::hasColumn('droits_assures', 'date_naissance_source')) {
                DB::statement("UPDATE `droits_assures` SET `date_naissance_source` = DATE_FORMAT(`date_naissance`, '%d/%m/%Y') WHERE `date_naissance_source` IS NULL AND `date_naissance` IS NOT NULL");
            }
            if (Schema::hasColumn('droits_assures', 'date_mise_a_jour') && Schema::hasColumn('droits_assures', 'date_maj_source')) {
                DB::statement('UPDATE `droits_assures` SET `date_maj_source` = `date_mise_a_jour` WHERE `date_maj_source` IS NULL AND `date_mise_a_jour` IS NOT NULL');
            }

            $this->dropColumns('droits_assures', [
                'disponibilite', 'date_mise_a_jour', 'date_naissance', 'nina', 'centre_enr',
                'date_emission', 'date_emission_source', 'date_remise', 'id_statut_carte',
                'id_statut_source', 'numero_lot_source', 'nom_assure',
            ]);

            DB::statement('ALTER TABLE `droits_assures` MODIFY `ogd_source` VARCHAR(6) NULL, MODIFY `nom_source` VARCHAR(30) NULL, MODIFY `prenom_source` VARCHAR(30) NULL, MODIFY `telephone_source` CHAR(11) NULL');
        }

        if (Schema::hasTable('disponibilite_cartes')) {
            if (Schema::hasColumn('disponibilite_cartes', 'date_emission_source') && Schema::hasColumn('disponibilite_cartes', 'date_emission')) {
                DB::statement('UPDATE `disponibilite_cartes` SET `date_emission` = `date_emission_source` WHERE `date_emission` IS NULL AND `date_emission_source` IS NOT NULL');
            }
            if (Schema::hasColumn('disponibilite_cartes', 'id_statut_source') && Schema::hasColumn('disponibilite_cartes', 'id_statut_carte')) {
                DB::statement("UPDATE `disponibilite_cartes` SET `id_statut_carte` = CAST(`id_statut_source` AS UNSIGNED) WHERE `id_statut_carte` IS NULL AND `id_statut_source` REGEXP '^[0-9]+$'");
            }

            $this->dropColumns('disponibilite_cartes', [
                'statut', 'date_debut', 'date_fin', 'verifie_le', 'matricule_ogd', 'amo_ayant_droit',
                'date_naissance_source', 'lien_source', 'sexe_source', 'numero_emp', 'csp', 'localite_source',
                'date_immatriculation_source', 'date_ouverture_droit_source', 'date_fermeture_droit_source',
                'date_fermeture_premium', 'date_maj_source', 'date_emission_source', 'id_statut_source',
                'numero_lot_source', 'nom_assure',
            ]);
        }
    }

    private function moveLegacyNames(string $tableName, int $maxLength): void
    {
        if (Schema::hasTable($tableName)
            && Schema::hasColumn($tableName, 'nom_assure')
            && Schema::hasColumn($tableName, 'nom_source')) {
            DB::statement("UPDATE `{$tableName}` SET `nom_source` = LEFT(`nom_assure`, {$maxLength}) WHERE (`nom_source` IS NULL OR `nom_source` = '') AND `nom_assure` IS NOT NULL");
        }
    }

    private function dropColumns(string $tableName, array $columns): void
    {
        $existing = array_values(array_filter($columns, fn (string $column) => Schema::hasColumn($tableName, $column)));
        if ($existing !== []) {
            Schema::table($tableName, fn (Blueprint $table) => $table->dropColumn($existing));
        }
    }

    public function down(): void
    {
        // Removed columns may have contained records; keep the restored view-specific shape.
    }
};
