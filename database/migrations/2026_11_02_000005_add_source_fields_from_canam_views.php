<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('droits_assures')) {
            Schema::table('droits_assures', function (Blueprint $table) {
                if (! Schema::hasColumn('droits_assures', 'ogd_source')) $table->string('ogd_source', 6)->nullable();
                if (! Schema::hasColumn('droits_assures', 'matricule_ogd')) $table->string('matricule_ogd', 50)->nullable();
                if (! Schema::hasColumn('droits_assures', 'amo_assure')) $table->string('amo_assure', 13)->nullable();
                if (! Schema::hasColumn('droits_assures', 'amo_ayant_droit')) $table->string('amo_ayant_droit', 13)->nullable();
                if (! Schema::hasColumn('droits_assures', 'nom_source')) $table->string('nom_source', 30)->nullable();
                if (! Schema::hasColumn('droits_assures', 'prenom_source')) $table->string('prenom_source', 30)->nullable();
                if (! Schema::hasColumn('droits_assures', 'date_naissance_source')) $table->string('date_naissance_source', 10)->nullable();
                if (! Schema::hasColumn('droits_assures', 'lien_source')) $table->char('lien_source', 1)->nullable();
                if (! Schema::hasColumn('droits_assures', 'sexe_source')) $table->smallInteger('sexe_source')->nullable();
                if (! Schema::hasColumn('droits_assures', 'numero_emp')) $table->string('numero_emp', 20)->nullable();
                if (! Schema::hasColumn('droits_assures', 'csp')) $table->string('csp', 3)->nullable();
                if (! Schema::hasColumn('droits_assures', 'localite_source')) $table->string('localite_source', 32)->nullable();
                if (! Schema::hasColumn('droits_assures', 'telephone_source')) $table->char('telephone_source', 11)->nullable();
                if (! Schema::hasColumn('droits_assures', 'date_immatriculation_source')) $table->string('date_immatriculation_source', 10)->nullable();
                if (! Schema::hasColumn('droits_assures', 'date_ouverture_droit_source')) $table->string('date_ouverture_droit_source', 10)->nullable();
                if (! Schema::hasColumn('droits_assures', 'date_fermeture_droit_source')) $table->string('date_fermeture_droit_source', 10)->nullable();
                if (! Schema::hasColumn('droits_assures', 'date_fermeture_premium')) $table->date('date_fermeture_premium')->nullable();
                if (! Schema::hasColumn('droits_assures', 'date_maj_source')) $table->dateTime('date_maj_source')->nullable();
            });
        }

        if (Schema::hasTable('disponibilite_cartes')) {
            Schema::table('disponibilite_cartes', function (Blueprint $table) {
                if (! Schema::hasColumn('disponibilite_cartes', 'nom_source')) $table->string('nom_source', 50)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'prenom_source')) $table->string('prenom_source', 50)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'date_naissance')) $table->date('date_naissance')->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'nina')) $table->string('nina', 15)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'ogd_source')) $table->string('ogd_source', 100)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'centre_enr')) $table->string('centre_enr', 6)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'amo_assure')) $table->string('amo_assure', 13)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'telephone_source')) $table->string('telephone_source', 100)->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'date_emission')) $table->date('date_emission')->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'date_remise')) $table->date('date_remise')->nullable();
                if (! Schema::hasColumn('disponibilite_cartes', 'id_statut_carte')) $table->bigInteger('id_statut_carte')->nullable();
            });
        }
    }

    public function down(): void
    {
        // Conserver les informations administratives saisies dans ces colonnes.
    }
};
