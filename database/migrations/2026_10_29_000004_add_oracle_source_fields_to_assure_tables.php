<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('droits_assures', function (Blueprint $table) {
            $table->string('amo_assure', 13)->nullable();
            $table->string('amo_ayant_droit', 13)->nullable();
            $table->string('numero_recepisse', 100)->nullable()->index();
            $table->string('nom_assure', 60)->nullable();
            $table->string('date_immatriculation_source', 10)->nullable();
            $table->date('date_fermeture_premium')->nullable();
        });

        Schema::table('disponibilite_cartes', function (Blueprint $table) {
            $table->string('numero_recepisse', 100)->nullable()->index();
            $table->string('id_statut_source', 20)->nullable();
            $table->string('nom_assure', 60)->nullable();
            $table->string('ogd_source', 6)->nullable();
            $table->string('numero_lot_source', 40)->nullable();
            $table->date('date_emission_source')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('droits_assures', function (Blueprint $table) {
            $table->dropIndex(['numero_recepisse']);
            $table->dropColumn(['amo_assure', 'amo_ayant_droit', 'numero_recepisse', 'nom_assure', 'date_immatriculation_source', 'date_fermeture_premium']);
        });
        Schema::table('disponibilite_cartes', function (Blueprint $table) {
            $table->dropIndex(['numero_recepisse']);
            $table->dropColumn(['numero_recepisse', 'id_statut_source', 'nom_assure', 'ogd_source', 'numero_lot_source', 'date_emission_source']);
        });
    }
};
