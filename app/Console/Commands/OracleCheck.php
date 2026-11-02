<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Database\Connection;
use Illuminate\Support\Facades\DB;
use Throwable;

class OracleCheck extends Command
{
    protected $signature = 'canam:oracle
        {--tables : Liste les tables, vues et synonymes accessibles}
        {--table= : Décrit les colonnes d’une table ou vue (TABLE ou OWNER.TABLE)}
        {--sample= : Affiche quelques lignes d’une table ou vue (TABLE ou OWNER.TABLE)}
        {--schema= : Schéma Oracle à inspecter (par défaut ORACLE_SCHEMA)}
        {--limit=20 : Nombre de lignes à afficher pour --sample}
        {--objects-limit=200 : Nombre maximum d’objets listés pour --tables}';

    protected $description = 'Vérifie la connexion Oracle et inspecte les tables/vues accessibles';

    public function handle(): int
    {
        if (! extension_loaded('oci8')) {
            $this->error('L’extension PHP oci8 n’est pas chargée.');
            $this->line('Windows/Laragon : activez oci8 dans php.ini et installez Oracle Instant Client (x64).');
            $this->line('Vérification : php -m | findstr /I oci8');
            $this->line('Puis : php --ri oci8');

            return self::FAILURE;
        }

        try {
            $connection = DB::connection('oracle');
            $connection->selectOne('SELECT 1 AS ok FROM DUAL');
        } catch (Throwable $e) {
            $this->error('Connexion Oracle impossible : '.$e->getMessage());
            $this->line('Vérifiez le réseau, le service name, les identifiants et l’installation OCI8.');

            return self::FAILURE;
        }

        $config = config('database.connections.oracle', []);
        $schema = $this->resolveSchema($connection);

        $this->info('Connexion Oracle OK.');
        $this->line('Hôte      : '.($config['host'] ?? '—').':'.($config['port'] ?? '—'));
        $this->line('Service   : '.($config['service_name'] ?: '—'));
        $this->line('Utilisateur : '.($config['username'] ?? '—'));
        $this->line('Schéma    : '.($schema ?: '—'));

        if ($version = $this->oracleVersion($connection)) {
            $this->line('Version   : '.$version);
        }

        if ($this->option('tables')) {
            $this->listObjects($connection, $schema);
        }

        if ($table = $this->option('table')) {
            $this->describeTable($connection, $schema, (string) $table);
        }

        if ($table = $this->option('sample')) {
            $this->sampleTable($connection, $schema, (string) $table);
        }

        return self::SUCCESS;
    }

    private function resolveSchema(Connection $connection): string
    {
        $schema = strtoupper(trim((string) ($this->option('schema') ?: config('database.connections.oracle.schema', ''))));

        if ($schema !== '') {
            return $schema;
        }

        try {
            $row = $connection->selectOne('SELECT USER AS current_user FROM DUAL');
            $value = (array) $row;

            return strtoupper((string) ($value['current_user'] ?? $value['CURRENT_USER'] ?? ''));
        } catch (Throwable) {
            return '';
        }
    }

    private function oracleVersion(Connection $connection): ?string
    {
        try {
            $row = $connection->selectOne(
                "SELECT version FROM product_component_version WHERE product LIKE 'Oracle Database%' AND ROWNUM = 1"
            );
            $value = (array) $row;

            return (string) ($value['version'] ?? $value['VERSION'] ?? '') ?: null;
        } catch (Throwable) {
            return null;
        }
    }

    private function listObjects(Connection $connection, string $schema): void
    {
        if ($schema === '') {
            $this->warn('Aucun schéma à inspecter. Utilisez --schema=GRCCANAM.');

            return;
        }

        $limit = max(1, (int) $this->option('objects-limit'));

        try {
            $rows = $connection->select(
                'SELECT * FROM (
                    SELECT owner, object_name, object_type
                    FROM all_objects
                    WHERE owner = ? AND object_type IN (\'TABLE\', \'VIEW\', \'SYNONYM\')
                    ORDER BY object_type, object_name
                ) WHERE ROWNUM <= ?',
                [$schema, $limit]
            );
        } catch (Throwable $e) {
            $this->error('Lecture des objets impossible : '.$e->getMessage());

            return;
        }

        if ($rows === []) {
            $this->warn('Aucun objet trouvé pour le schéma '.$schema.'.');

            return;
        }

        $this->table(
            ['Propriétaire', 'Nom', 'Type'],
            array_map(fn ($row) => [
                $row->owner ?? '',
                $row->object_name ?? '',
                $row->object_type ?? '',
            ], $rows)
        );
    }

    private function describeTable(Connection $connection, string $schema, string $table): void
    {
        [$owner, $name] = $this->splitTableName($schema, $table);

        if ($owner === '' || $name === '') {
            $this->error('Nom de table invalide. Utilisez TABLE ou OWNER.TABLE.');

            return;
        }

        try {
            $rows = $connection->select(
                'SELECT column_id, column_name, data_type, data_length, data_precision, data_scale, nullable
                 FROM all_tab_columns
                 WHERE owner = ? AND table_name = ?
                 ORDER BY column_id',
                [$owner, $name]
            );
        } catch (Throwable $e) {
            $this->error('Description impossible : '.$e->getMessage());

            return;
        }

        if ($rows === []) {
            $this->warn('Table ou vue introuvable : '.$owner.'.'.$name);

            return;
        }

        $this->table(
            ['#', 'Colonne', 'Type', 'Taille', 'Précision', 'Échelle', 'Nullable'],
            array_map(fn ($row) => [
                $row->column_id ?? '',
                $row->column_name ?? '',
                $row->data_type ?? '',
                $row->data_length ?? '',
                $row->data_precision ?? '',
                $row->data_scale ?? '',
                $row->nullable ?? '',
            ], $rows)
        );
    }

    private function sampleTable(Connection $connection, string $schema, string $table): void
    {
        [$owner, $name] = $this->splitTableName($schema, $table);

        if ($owner === '' || $name === '') {
            $this->error('Nom de table invalide. Utilisez TABLE ou OWNER.TABLE.');

            return;
        }

        $limit = max(1, (int) $this->option('limit'));

        try {
            $rows = $connection->select(
                sprintf('SELECT * FROM "%s"."%s" WHERE ROWNUM <= %d', $owner, $name, $limit)
            );
        } catch (Throwable $e) {
            $this->error('Lecture des données impossible : '.$e->getMessage());

            return;
        }

        if ($rows === []) {
            $this->warn('Aucune ligne dans '.$owner.'.'.$name.'.');

            return;
        }

        $first = (array) $rows[0];
        $headers = array_map('strtoupper', array_keys($first));
        $data = array_map(fn ($row) => array_values((array) $row), $rows);

        $this->table($headers, $data);
    }

    /**
     * @return array{0: string, 1: string}
     */
    private function splitTableName(string $schema, string $table): array
    {
        $table = strtoupper(trim($table));

        if (str_contains($table, '.')) {
            [$owner, $name] = explode('.', $table, 2);
        } else {
            $owner = strtoupper($schema);
            $name = $table;
        }

        $valid = '/^[A-Z0-9_$#]+$/';

        if (! preg_match($valid, $owner) || ! preg_match($valid, $name)) {
            return ['', ''];
        }

        return [$owner, $name];
    }
}
