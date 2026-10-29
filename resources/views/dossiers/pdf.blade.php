<!doctype html>
<html lang="fr">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>{{ $label }} — rapport PDF</title>
    <style>
        @page { margin: 22px 24px; }
        body { font-family: DejaVu Sans, sans-serif; color: #1d2b27; font-size: 8px; }
        h1 { color: #087b50; font-size: 18px; margin: 0 0 5px; }
        h2 { color: #087b50; font-size: 10px; margin: 0 0 4px; }
        p { margin: 2px 0; }
        .meta { color: #68766f; font-size: 9px; margin-bottom: 10px; }
        .filters { width: 100%; border-collapse: collapse; margin-bottom: 10px; }
        .filters td { border: 1px solid #dfe7e2; background: #f3f8f5; padding: 6px; }
        .data { width: 100%; border-collapse: collapse; table-layout: fixed; }
        .data th, .data td { border: 1px solid #dfe7e2; padding: 6px; text-align: left; vertical-align: top; overflow-wrap: anywhere; }
        .data th { background: #edf4f0; color: #24443a; }
        .col-dossier { width: 17%; }
        .col-assure { width: 20%; }
        .col-suivi { width: 18%; }
        .col-infos { width: 25%; }
        .col-traitement { width: 20%; }
        .muted { color: #68766f; }
        .empty { text-align: center; color: #68766f; padding: 18px; }
        tr.dossier-row { page-break-inside: avoid; }
    </style>
</head>
<body>
    <h1>Rapport — {{ $label }}</h1>
    <div class="meta">CANAM — Service Qualité · Généré le {{ $generatedAt }} · {{ $dossiers->count() }} dossier(s)</div>
    <table class="filters"><tr>
        <td><strong>Statut :</strong> {{ $filters['statut'] ? ucfirst(str_replace('_', ' ', $filters['statut'])) : 'Tous' }}</td>
        <td><strong>Recherche :</strong> {{ $filters['recherche'] ?: 'Aucune' }}</td>
    </tr></table>

    <table class="data">
        <thead><tr>
            <th class="col-dossier">Dossier</th>
            <th class="col-assure">Assuré / demandeur</th>
            <th class="col-suivi">Statut et suivi</th>
            <th class="col-infos">Informations du dossier</th>
            <th class="col-traitement">Traitement</th>
        </tr></thead>
        <tbody>
            @forelse($dossiers as $dossier)
                <tr class="dossier-row">
                    <td>
                        <h2>{{ $dossier->numero_ordre }}</h2>
                        <p>Réception : {{ $dossier->date_reception?->format('d/m/Y') ?? '—' }}</p>
                        <p>Module : {{ $module === 'reclamation' ? 'Réclamation' : 'Assistance' }}</p>
                        <p>Priorité : {{ ucfirst($dossier->priorite ?? 'normale') }}</p>
                    </td>
                    <td>
                        <p><strong>{{ $dossier->reclamant ?? $dossier->demandeur ?? '—' }}</strong></p>
                        <p>Contact : {{ $dossier->contact ?? '—' }}</p>
                        <p>N° AMO/récépissé : {{ $dossier->numero_amo_recepisse ?? '—' }}</p>
                        <p>Matricule : {{ $dossier->numero_matricule ?? '—' }}</p>
                        <p>Région : {{ $dossier->region?->nom ?? '—' }}</p>
                        <p>Localité : {{ $dossier->localite?->nom ?? '—' }}</p>
                        <p>OGD : {{ $dossier->ogd?->nom ?? '—' }}</p>
                    </td>
                    <td>
                        <p><strong>{{ ucfirst(str_replace('_', ' ', $dossier->statut)) }}</strong></p>
                        <p>Responsable : {{ $dossier->responsable?->name ?? 'Non affecté' }}</p>
                        <p>Affectation : {{ $dossier->date_affectation?->format('d/m/Y H:i') ?? '—' }}</p>
                        <p>Échéance : {{ $dossier->echeance_traitement?->format('d/m/Y H:i') ?? '—' }}</p>
                        <p>Traité le : {{ $dossier->date_traitement?->format('d/m/Y H:i') ?? '—' }}</p>
                        @if($module === 'reclamation')<p>Émission carte : {{ $dossier->date_emission_carte?->format('d/m/Y') ?? '—' }}</p>@endif
                    </td>
                    <td>
                        <p><strong>Objet :</strong> {{ $dossier->objet }}</p>
                        <p>Qualification : {{ $dossier->qualification?->libelle ?? '—' }}</p>
                        <p>Processus : {{ $dossier->processus?->libelle ?? '—' }}</p>
                        <p>Provenance : {{ $dossier->provenance?->libelle ?? '—' }}</p>
                        <p><strong>Causes :</strong> {{ $dossier->causes_probleme ?? '—' }}</p>
                    </td>
                    <td>
                        <p><strong>Action entreprise :</strong> {{ $dossier->action_entreprise ?? '—' }}</p>
                        <p><strong>Observations :</strong> {{ $dossier->observations ?? '—' }}</p>
                        @if($dossier->motif_annulation)<p><strong>Motif d’annulation :</strong> {{ $dossier->motif_annulation }}</p>@endif
                    </td>
                </tr>
            @empty
                <tr><td colspan="5" class="empty">Aucun dossier ne correspond aux filtres sélectionnés.</td></tr>
            @endforelse
        </tbody>
    </table>
    <p class="muted">Le rapport reprend les informations enregistrées pour les dossiers correspondant aux filtres actifs.</p>
</body>
</html>
