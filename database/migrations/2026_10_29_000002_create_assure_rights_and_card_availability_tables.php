<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('droits_assures')) {
            Schema::create('droits_assures', function (Blueprint $table) {
                $table->id();
                $table->string('numero_amo', 100)->nullable()->index();
                $table->string('numero_recepisse', 100)->nullable()->index();
                $table->enum('statut', ['ouverts', 'suspendus', 'fermes', 'inconnu'])->default('inconnu');
                $table->date('date_debut')->nullable();
                $table->date('date_fin')->nullable();
                $table->dateTime('verifie_le')->nullable();
                $table->text('observations')->nullable();

                // Colonnes propres à V_BENEFICIAIRE_AMO (capture des droits).
                $table->string('ogd_source', 6)->nullable();
                $table->string('matricule_ogd', 50)->nullable();
                $table->string('amo_assure', 13)->nullable();
                $table->string('amo_ayant_droit', 13)->nullable();
                $table->string('nom_source', 30)->nullable();
                $table->string('prenom_source', 30)->nullable();
                $table->string('date_naissance_source', 10)->nullable();
                $table->char('lien_source', 1)->nullable();
                $table->integer('sexe_source')->nullable();
                $table->string('numero_emp', 20)->nullable();
                $table->string('csp', 3)->nullable();
                $table->string('localite_source', 32)->nullable();
                $table->char('telephone_source', 11)->nullable();
                $table->string('date_immatriculation_source', 10)->nullable();
                $table->string('date_ouverture_droit_source', 10)->nullable();
                $table->string('date_fermeture_droit_source', 10)->nullable();
                $table->date('date_fermeture_premium')->nullable();
                $table->dateTime('date_maj_source')->nullable();

                $table->timestamps();
                $table->index('statut');
            });
        }

        if (! Schema::hasTable('disponibilite_cartes')) {
            Schema::create('disponibilite_cartes', function (Blueprint $table) {
                $table->id();
                $table->string('numero_amo', 100)->nullable()->index();
                $table->string('numero_recepisse', 100)->nullable()->index();
                $table->enum('disponibilite', ['disponible', 'en_preparation', 'emise', 'indisponible', 'inconnue'])->default('inconnue');
                $table->dateTime('date_mise_a_jour')->nullable();
                $table->text('observations')->nullable();

                // Colonnes propres à V_CARTES_AMO (capture des cartes).
                $table->string('nom_source', 50)->nullable();
                $table->string('prenom_source', 50)->nullable();
                $table->date('date_naissance')->nullable();
                $table->string('nina', 15)->nullable();
                $table->string('ogd_source', 100)->nullable();
                $table->string('centre_enr', 6)->nullable();
                $table->string('amo_assure', 13)->nullable();
                $table->string('telephone_source', 100)->nullable();
                $table->date('date_emission')->nullable();
                $table->date('date_remise')->nullable();
                $table->bigInteger('id_statut_carte')->nullable();

                $table->timestamps();
                $table->index('disponibilite');
            });
        }
    }

    public function down(): void
    {
        // Keep business data safe; remove the tables explicitly when needed.
    }
};
