<?php

namespace App\Console\Commands;

use Carbon\Carbon;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Throwable;

class SynchroniserDonneesOracle extends Command
{
    protected $signature = 'canam:sync-oracle {--dry-run : Lire Oracle sans modifier MySQL}';
    protected $description = 'Synchronise les droits et cartes CANAM depuis les vues Oracle vers les tables locales';

    public function handle(): int
    {
        try {
            $oracle = DB::connection('oracle');
            $rights = $oracle->table('V_BENEFICIAIRE_AMO')->get();
            $cards = $oracle->table('V_CARTES_AMO')->get();
        } catch (Throwable $e) {
            $this->error('Lecture Oracle impossible : '.$e->getMessage());
            return self::FAILURE;
        }

        if ($this->option('dry-run')) {
            $this->info("Lecture réussie : {$rights->count()} bénéficiaires et {$cards->count()} cartes.");
            return self::SUCCESS;
        }

        $today = Carbon::today();
        $rightsCount = 0;
        foreach ($rights as $sourceRow) {
            $row = (object) array_change_key_case((array) $sourceRow, CASE_LOWER);
            $amo = trim((string) ($row->amoassure ?? ''));
            if ($amo === '') continue;
            $end = $this->parseOracleDate($row->datefermeturedroit ?? null);
            $status = $end && $end->lt($today) ? 'fermes' : 'ouverts';
            DB::table('droits_assures')->updateOrInsert(
                ['numero_amo_recepisse' => $amo],
                [
                    'statut' => $status,
                    'date_debut' => $this->parseOracleDate($row->dateouverturedroit ?? null)?->toDateString(),
                    'date_fin' => $end?->toDateString(),
                    'verifie_le' => now(),
                    'observations' => 'Synchronisé depuis GRCCANAM.V_BENEFICIAIRE_AMO'.(($row->amoayd ?? null) ? ' | AMOAYD: '.$row->amoayd : ''),
                    'amo_assure' => $amo,
                    'amo_ayant_droit' => $row->amoayd ?? null,
                    'nom_assure' => trim(($row->nom ?? '').' '.($row->prenom ?? '')),
                    'date_immatriculation_source' => $row->dateimmatriculation ?? null,
                    'date_fermeture_premium' => isset($row->datefermeturepremium) ? $this->parseOracleDate($row->datefermeturepremium)?->toDateString() : null,
                    'updated_at' => now(), 'created_at' => now(),
                ]
            );
            $rightsCount++;
        }

        $cardCount = 0;
        $receiptByAmo = [];
        $statusMap = config('canam.oracle_card_status_map', []);
        foreach ($cards as $sourceRow) {
            $row = (object) array_change_key_case((array) $sourceRow, CASE_LOWER);
            $amo = trim((string) ($row->num_amo ?? ''));
            $receipt = trim((string) ($row->numero_recepisse ?? ''));
            $cardNo = trim((string) ($row->numero_carte ?? ''));
            $reference = $amo ?: $receipt;
            if ($amo !== '' && $receipt !== '') $receiptByAmo[$amo] = $receipt;
            if ($reference === '') continue;
            $rawStatus = (string) ($row->id_statut_carte ?? '');
            $availability = in_array($statusMap[$rawStatus] ?? null, ['disponible', 'en_preparation', 'emise', 'indisponible', 'inconnue'], true)
                ? $statusMap[$rawStatus] : 'inconnue';
            $key = $cardNo !== '' ? ['numero_carte' => $cardNo] : ['numero_amo_recepisse' => $reference];
            DB::table('disponibilite_cartes')->updateOrInsert($key, [
                'numero_amo_recepisse' => $reference,
                'numero_recepisse' => $receipt ?: null,
                'disponibilite' => $availability,
                'numero_carte' => $cardNo ?: null,
                'date_mise_a_jour' => $this->parseOracleDate($row->date_emission ?? $row->date_creation ?? null),
                'observations' => 'Synchronisé depuis GRCCANAM.V_CARTES_AMO; ID_STATUT_CARTE='.$rawStatus,
                'id_statut_source' => $rawStatus ?: null,
                'nom_assure' => trim(($row->nom ?? '').' '.($row->prenom ?? '')),
                'ogd_source' => $row->ogd ?? null,
                'numero_lot_source' => $row->numero_lot ?? null,
                'date_emission_source' => $this->parseOracleDate($row->date_emission ?? null)?->toDateString(),
                'updated_at' => now(), 'created_at' => now(),
            ]);
            $cardCount++;
        }

        foreach ($receiptByAmo as $amo => $receipt) {
            DB::table('droits_assures')->where('numero_amo_recepisse', $amo)->update([
                'numero_recepisse' => $receipt,
                'updated_at' => now(),
            ]);
        }

        $this->info("Synchronisation terminée : {$rightsCount} droits, {$cardCount} cartes.");
        return self::SUCCESS;
    }

    private function parseOracleDate(mixed $value): ?Carbon
    {
        if (!$value) return null;
        try { return $value instanceof \DateTimeInterface ? Carbon::instance($value) : Carbon::createFromFormat('d/m/Y', trim((string) $value)); }
        catch (Throwable) { try { return Carbon::parse($value); } catch (Throwable) { return null; } }
    }
}
