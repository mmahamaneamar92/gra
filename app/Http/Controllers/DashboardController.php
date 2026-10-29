<?php

namespace App\Http\Controllers;

use App\Models\DemandeAssistance;
use App\Models\Reclamation;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    private const RIGHTS_STATUSES = [
        'ouverts' => 'Droits ouverts',
        'suspendus' => 'Droits suspendus',
        'fermes' => 'Droits fermés',
        'inconnu' => 'Statut inconnu',
    ];

    private const CARD_STATUSES = [
        'disponible' => 'Disponible',
        'en_preparation' => 'En préparation',
        'emise' => 'Émise',
        'indisponible' => 'Indisponible',
        'inconnue' => 'Disponibilité inconnue',
    ];

    public function index()
    {
        $reclamations = Reclamation::query();
        $assistance = DemandeAssistance::query();
        $activeStatuses = ['recu', 'a_affecter', 'affecte', 'en_cours', 'en_attente_information'];
        $rightsCounts = $this->statusCounts('droits_assures', 'statut', self::RIGHTS_STATUSES);
        $cardCounts = $this->statusCounts('disponibilite_cartes', 'disponibilite', self::CARD_STATUSES);

        return view('dashboard.index', [
            'totalReclamations' => (clone $reclamations)->count(),
            'totalAssistance' => (clone $assistance)->count(),
            'enCours' => (clone $reclamations)->whereIn('statut', $activeStatuses)->count()
                + (clone $assistance)->whereIn('statut', $activeStatuses)->count(),
            'enRetard' => (clone $reclamations)->whereNotIn('statut', ['traite', 'cloture', 'annule'])
                ->whereNotNull('echeance_traitement')->where('echeance_traitement', '<', now())->count()
                + (clone $assistance)->whereNotIn('statut', ['traite', 'a_notifier', 'cloture', 'annule'])
                    ->whereNotNull('echeance_traitement')->where('echeance_traitement', '<', now())->count(),
            'recentReclamations' => Reclamation::latest('created_at')->take(5)->get(),
            'recentAssistance' => DemandeAssistance::latest('created_at')->take(5)->get(),
            'retards' => DB::table('v_dossiers_en_retard')->orderByDesc('retard_heures')->limit(10)->get(),
            'rightsLabels' => self::RIGHTS_STATUSES,
            'rightsCounts' => $rightsCounts,
            'cardLabels' => self::CARD_STATUSES,
            'cardCounts' => $cardCounts,
            'rightsTotal' => array_sum($rightsCounts),
            'cardsTotal' => array_sum($cardCounts),
        ]);
    }

    public function exportAssureStatusPdf()
    {
        $rightsCounts = $this->statusCounts('droits_assures', 'statut', self::RIGHTS_STATUSES);
        $cardCounts = $this->statusCounts('disponibilite_cartes', 'disponibilite', self::CARD_STATUSES);

        return Pdf::loadView('dashboard.assure_status_pdf', [
            'rightsLabels' => self::RIGHTS_STATUSES,
            'rightsCounts' => $rightsCounts,
            'cardLabels' => self::CARD_STATUSES,
            'cardCounts' => $cardCounts,
            'rightsTotal' => array_sum($rightsCounts),
            'cardsTotal' => array_sum($cardCounts),
            'generatedAt' => now()->format('d/m/Y H:i'),
        ])->setPaper('a4', 'portrait')->download('statuts-droits-et-cartes-'.now()->format('Y-m-d').'.pdf');
    }

    private function statusCounts(string $table, string $column, array $statuses): array
    {
        $counts = array_fill_keys(array_keys($statuses), 0);
        $rows = DB::table($table)
            ->select($column, DB::raw('COUNT(*) as total'))
            ->groupBy($column)
            ->get();

        foreach ($rows as $row) {
            if (array_key_exists($row->{$column}, $counts)) {
                $counts[$row->{$column}] = (int) $row->total;
            }
        }

        return $counts;
    }
}
