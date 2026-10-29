<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('droits_assures') && ! Schema::hasColumn('droits_assures', 'numero_amo_recepisse')) {
            Schema::table('droits_assures', function (Blueprint $table) {
                $table->string('numero_amo_recepisse', 100)->nullable()->unique('uq_droits_assures_amo');
            });
        }

        if (Schema::hasTable('disponibilite_cartes') && ! Schema::hasColumn('disponibilite_cartes', 'numero_amo_recepisse')) {
            Schema::table('disponibilite_cartes', function (Blueprint $table) {
                $table->string('numero_amo_recepisse', 100)->nullable()->index('idx_disponibilite_cartes_amo');
            });
        }
    }

    public function down(): void
    {
        // Preserve assurance and card reference data when rolling back.
    }
};
