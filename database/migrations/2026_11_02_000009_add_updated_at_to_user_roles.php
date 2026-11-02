<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('user_roles') && ! Schema::hasColumn('user_roles', 'updated_at')) {
            Schema::table('user_roles', function (Blueprint $table) {
                $table->timestamp('updated_at')->nullable()->useCurrent()->useCurrentOnUpdate()->after('created_at');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('user_roles') && Schema::hasColumn('user_roles', 'updated_at')) {
            Schema::table('user_roles', function (Blueprint $table) {
                $table->dropColumn('updated_at');
            });
        }
    }
};
