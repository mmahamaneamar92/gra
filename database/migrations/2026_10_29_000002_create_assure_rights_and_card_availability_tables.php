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
                $table->string('numero_amo_recepisse', 100)->nullable()->unique();
                $table->enum('statut', ['ouverts', 'suspendus', 'fermes', 'inconnu'])->default('inconnu');
                $table->date('date_debut')->nullable();
                $table->date('date_fin')->nullable();
                $table->dateTime('verifie_le')->nullable();
                $table->text('observations')->nullable();
                $table->timestamps();
                $table->index('statut');
            });
        }

        if (! Schema::hasTable('disponibilite_cartes')) {
            Schema::create('disponibilite_cartes', function (Blueprint $table) {
                $table->id();
                $table->string('numero_amo_recepisse', 100)->nullable()->index();
                $table->string('numero_carte', 100)->nullable()->unique();
                $table->enum('disponibilite', ['disponible', 'en_preparation', 'emise', 'indisponible', 'inconnue'])->default('inconnue');
                $table->dateTime('date_mise_a_jour')->nullable();
                $table->text('observations')->nullable();
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
