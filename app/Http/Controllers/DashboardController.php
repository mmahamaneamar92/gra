<?php

namespace App\Http\Controllers;

use App\Models\DemandeAssistance;
use App\Models\Reclamation;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
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

    public function index(Request $request)
    {
        $filters = $this->validatedFilters($request);
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
            'assureRows' => $this->assureRowsQuery($filters)->orderBy('refs.numero_amo_recepisse')->orderBy('cartes.numero_carte')->paginate(20)->withQueryString(),
            'filters' => $filters,
        ]);
    }

    public function exportAssureStatusPdf(Request $request)
    {
        $filters = $this->validatedFilters($request);
        $rows = $this->assureRowsQuery($filters)
            ->orderBy('refs.numero_amo_recepisse')
            ->orderBy('cartes.numero_carte')
            ->get();

        return Pdf::loadView('dashboard.assure_status_pdf', [
            'rows' => $rows,
            'filters' => $filters,
            'rightsLabels' => self::RIGHTS_STATUSES,
            'cardLabels' => self::CARD_STATUSES,
            'logoData' => 'data:image/png;base64,'.base64_encode(file_get_contents(public_path('img/LogoCANAM.png'))),
            'generatedAt' => now()->format('d/m/Y H:i'),
        ])->setPaper('a4', 'landscape')->download('droits-et-disponibilite-cartes-'.now()->format('Y-m-d').'.pdf');
    }

    private function validatedFilters(Request $request): array
    {
        $data = $request->validate([
            'droits_statut' => ['nullable', 'in:ouverts,suspendus,fermes,inconnu'],
            'carte_statut' => ['nullable', 'in:disponible,en_preparation,emise,indisponible,inconnue'],
            'recherche' => ['nullable', 'string', 'max:100'],
        ]);

        return [
            'droits_statut' => $data['droits_statut'] ?? '',
            'carte_statut' => $data['carte_statut'] ?? '',
            'recherche' => trim($data['recherche'] ?? ''),
        ];
    }

    private function assureRowsQuery(array $filters)
    {
        $references = DB::table('droits_assures')
            ->whereNotNull('numero_amo_recepisse')
            ->select('numero_amo_recepisse')
            ->union(
                DB::table('disponibilite_cartes')
                    ->whereNotNull('numero_amo_recepisse')
                    ->select('numero_amo_recepisse')
            );

        $dossierSources = DB::table('reclamations')->selectRaw(
            "id, 'Réclamation' AS module, numero_amo_recepisse, reclamant AS nom, numero_matricule, contact, region_id, localite_id, date_reception"
        )->unionAll(DB::table('demandes_assistance')->selectRaw(
            "id, 'Assistance' AS module, numero_amo_recepisse, demandeur AS nom, numero_matricule, contact, region_id, localite_id, date_reception"
        ));

        $rankedDossiers = DB::query()->fromSub($dossierSources, 'source')
            ->select('source.*')
            ->selectRaw('ROW_NUMBER() OVER (PARTITION BY source.numero_amo_recepisse ORDER BY source.date_reception DESC, source.module ASC, source.id DESC) AS dossier_rank');

        $latestDossier = DB::query()->fromSub($rankedDossiers, 'ranked')
            ->where('dossier_rank', 1);

        $query = DB::query()->fromSub($references, 'refs')
            ->leftJoin('droits_assures as droits', 'droits.numero_amo_recepisse', '=', 'refs.numero_amo_recepisse')
            ->leftJoin('disponibilite_cartes as cartes', 'cartes.numero_amo_recepisse', '=', 'refs.numero_amo_recepisse')
            ->leftJoinSub($latestDossier, 'assure', 'assure.numero_amo_recepisse', '=', 'refs.numero_amo_recepisse')
            ->leftJoin('regions', 'regions.id', '=', 'assure.region_id')
            ->leftJoin('localites', 'localites.id', '=', 'assure.localite_id')
            ->select([
                'refs.numero_amo_recepisse',
                'assure.nom as nom_assure',
                'assure.numero_matricule',
                'assure.contact',
                'regions.nom as region',
                'localites.nom as localite',
                'droits.statut as droits_statut',
                'droits.date_debut as droits_date_debut',
                'droits.date_fin as droits_date_fin',
                'droits.verifie_le as droits_verifie_le',
                'droits.observations as droits_observations',
                'cartes.numero_carte',
                'cartes.disponibilite as carte_statut',
                'cartes.date_mise_a_jour as carte_date_mise_a_jour',
                'cartes.observations as carte_observations',
            ]);

        if ($filters['droits_statut'] !== '') {
            $query->where('droits.statut', $filters['droits_statut']);
        }

        if ($filters['carte_statut'] !== '') {
            $query->where('cartes.disponibilite', $filters['carte_statut']);
        }

        if ($filters['recherche'] !== '') {
            $search = '%'.$filters['recherche'].'%';
            $query->where(function ($where) use ($search) {
                $where->where('refs.numero_amo_recepisse', 'like', $search)
                    ->orWhere('assure.nom', 'like', $search)
                    ->orWhere('assure.numero_matricule', 'like', $search)
                    ->orWhere('assure.contact', 'like', $search);
            });
        }

        return $query;
    }

    private function statusCounts(string $table, string $column, array $statuses): array
    {
        $counts = array_fill_keys(array_keys($statuses), 0);
        $rows = DB::table($table)->select($column, DB::raw('COUNT(*) as total'))->groupBy($column)->get();

        foreach ($rows as $row) {
            if (array_key_exists($row->{$column}, $counts)) {
                $counts[$row->{$column}] = (int) $row->total;
            }
        }

        return $counts;
    }
}
