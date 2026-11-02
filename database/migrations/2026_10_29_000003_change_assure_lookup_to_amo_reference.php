<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('droits_assures')
            && ! Schema::hasColumn('droits_assures', 'numero_amo')
            && ! Schema::hasColumn('droits_assures', 'numero_recepisse')
            && ! Schema::hasColumn('droits_assures', 'numero_amo_recepisse')) {
            Schema::table('droits_assures', function (Blueprint $table) {
                $table->string('numero_amo', 100)->nullable()->index('idx_droits_assures_amo');
                $table->string('numero_recepisse', 100)->nullable()->index('idx_droits_assures_recepisse');
            });
        }

        if (Schema::hasTable('disponibilite_cartes')
            && ! Schema::hasColumn('disponibilite_cartes', 'numero_amo')
            && ! Schema::hasColumn('disponibilite_cartes', 'numero_recepisse')
            && ! Schema::hasColumn('disponibilite_cartes', 'numero_amo_recepisse')) {
            Schema::table('disponibilite_cartes', function (Blueprint $table) {
                $table->string('numero_amo', 100)->nullable()->index('idx_disponibilite_cartes_amo');
                $table->string('numero_recepisse', 100)->nullable()->index('idx_disponibilite_cartes_recepisse');
            });
        }
    }

    public function down(): void
    {
        // Preserve assurance and card reference data when rolling back.
    }
};
