<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        foreach (['droits_assures', 'disponibilite_cartes'] as $tableName) {
            if (! Schema::hasTable($tableName)) {
                continue;
            }

            Schema::table($tableName, function (Blueprint $table) use ($tableName) {
                if (! Schema::hasColumn($tableName, 'date_emission_source')) $table->date('date_emission_source')->nullable();
                if (! Schema::hasColumn($tableName, 'id_statut_source')) $table->string('id_statut_source', 20)->nullable();
                if (! Schema::hasColumn($tableName, 'numero_lot_source')) $table->string('numero_lot_source', 40)->nullable();
                if (! Schema::hasColumn($tableName, 'nom_assure')) $table->string('nom_assure', 60)->nullable();
            });
        }
    }

    public function down(): void
    {
        // Keep fields that may already contain CANAM source information.
    }
};
