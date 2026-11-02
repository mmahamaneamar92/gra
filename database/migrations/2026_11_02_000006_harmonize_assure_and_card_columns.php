<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('droits_assures')) {
            Schema::table('droits_assures', function (Blueprint $table) {
                if (! Schema::hasColumn('droits_assures', 'disponibilite')) $table->enum('disponibilite', ['disponible', 'en_preparation', 'emise', 'indisponible', 'inconnue'])->default('inconnue');
                if (! Schema::hasColumn('droits_assures', 'date_mise_a_jour')) $table->dateTime('date_mise_a_jour')->nullable();
                if (! Schema::hasColumn('droits_assures', 'date_naissance')) $table->date('date_naissance')->nullable();
                if (! Schema::hasColumn('droits_assures', 'nina')) $table->string('nina', 15)->nullable();
                if (! Schema::hasColumn('droits_assures', 'centre_enr')) $table->string('centre_enr', 6)->nullable();
                if (! Schema::hasColumn('droits_assures', 'date_emission')) $table->date('date_emission')->nullable();
                if (! Schema::hasColumn('droits_assures', 'date_remise')) $table->date('date_remise')->nullable();
                if (! Schema::hasColumn('droits_assures', 'id_statut_carte')) $table->bigInteger('id_statut_carte')->nullable();
            });
        }

        if (Schema::hasTable('disponibilite_cartes')) {
            Schema::table('disponibilite_cartes', function (Blueprint $table) {
                if (! Schema::hasColumn('disponibilite_cartes', 'statut')) $table->enum('statut', ['ouverts', 'suspendus', 'fermes', 'inconnu'])->default('inconnu');
                if (! Schema::hasColumn('disponibilite_cartes', 'date_debut')) $table->date('date_debut')->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'date_fin')) $table->date('date_fin')->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'verifie_le')) $table->dateTime('verifie_le')->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'matricule_ogd')) $table->string('matricule_ogd', 50)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'amo_ayant_droit')) $table->string('amo_ayant_droit', 13)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'date_naissance_source')) $table->string('date_naissance_source', 10)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'lien_source')) $table->char('lien_source', 1)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'sexe_source')) $table->smallInteger('sexe_source')->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'numero_emp')) $table->string('numero_emp', 20)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'csp')) $table->string('csp', 3)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'localite_source')) $table->string('localite_source', 32)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'date_immatriculation_source')) $table->string('date_immatriculation_source', 10)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'date_ouverture_droit_source')) $table->string('date_ouverture_droit_source', 10)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'date_fermeture_droit_source')) $table->string('date_fermeture_droit_source', 10)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'date_fermeture_premium')) $table->date('date_fermeture_premium')->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'date_maj_source')) $table->dateTime('date_maj_source')->nullable();
            });
        }

        // Align common descriptive columns across both tables to the larger source sizes.
        if (Schema::hasTable('droits_assures')) {
            DB::statement('ALTER TABLE `droits_assures` MODIFY `ogd_source` VARCHAR(100) NULL, MODIFY `nom_source` VARCHAR(50) NULL, MODIFY `prenom_source` VARCHAR(50) NULL, MODIFY `telephone_source` VARCHAR(100) NULL');
        }
    }

    public function down(): void
    {
        // The two tables now share a common data shape; keep stored records on rollback.
    }
};
