<?php

use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    public function up(): void
    {
        // Retained as a no-op for installations that recorded the earlier migration name.
        // Rights and card source columns are intentionally different.
    }

    public function down(): void
    {
        // No schema changes are performed by this compatibility migration.
    }
};
