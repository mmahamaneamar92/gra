<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $this->splitTable('droits_assures');
        $this->splitTable('disponibilite_cartes');

        if (Schema::hasTable('disponibilite_cartes') && Schema::hasColumn('disponibilite_cartes', 'numero_carte')) {
            $this->dropIndexesForColumn('disponibilite_cartes', 'numero_carte');
            Schema::table('disponibilite_cartes', fn (Blueprint $table) => $table->dropColumn('numero_carte'));
        }
    }

    private function splitTable(string $tableName): void
    {
        if (! Schema::hasTable($tableName)) {
            return;
        }

        if (! Schema::hasColumn($tableName, 'numero_amo')) {
            Schema::table($tableName, fn (Blueprint $table) => $table->string('numero_amo', 100)->nullable()->index());
        }

        if (! Schema::hasColumn($tableName, 'numero_recepisse')) {
            Schema::table($tableName, fn (Blueprint $table) => $table->string('numero_recepisse', 100)->nullable()->index());
        }

        if (! Schema::hasColumn($tableName, 'numero_amo_recepisse')) {
            return;
        }

        // N° AMO dans la vue CANAM : 13 chiffres. Les autres anciennes valeurs
        // sont conservées comme récépissés, sans perte de la référence saisie.
        DB::table($tableName)->select('id', 'numero_amo_recepisse')->orderBy('id')->chunk(500, function ($rows) use ($tableName) {
            foreach ($rows as $row) {
                $reference = trim((string) $row->numero_amo_recepisse);
                if ($reference === '') {
                    continue;
                }

                $column = preg_match('/^\d{13}$/', $reference) ? 'numero_amo' : 'numero_recepisse';
                DB::table($tableName)->where('id', $row->id)->whereNull($column)->update([$column => $reference]);
            }
        });

        $this->dropIndexesForColumn($tableName, 'numero_amo_recepisse');
        Schema::table($tableName, fn (Blueprint $table) => $table->dropColumn('numero_amo_recepisse'));
    }

    private function dropIndexesForColumn(string $tableName, string $columnName): void
    {
        foreach (DB::select("SHOW INDEX FROM `{$tableName}`") as $index) {
            if ($index->Column_name !== $columnName || $index->Key_name === 'PRIMARY') {
                continue;
            }

            $indexName = str_replace('`', '``', $index->Key_name);
            DB::statement("ALTER TABLE `{$tableName}` DROP INDEX `{$indexName}`");
        }
    }

    public function down(): void
    {
        // Les anciennes valeurs fusionnées et numéros de carte supprimés ne sont pas reconstituables sans ambiguïté.
    }
};
