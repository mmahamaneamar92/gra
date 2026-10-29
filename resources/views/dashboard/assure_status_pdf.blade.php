<!doctype html>
<html lang="fr">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Rapport droits et cartes des assurés</title>
    <style>
        @page { margin: 22px 24px; }
        body { font-family: DejaVu Sans, sans-serif; color: #1d2b3a; font-size: 8px; }
        h1 { color: #0b5c9e; font-size: 18px; margin: 0 0 5px; }
        h2 { color: #0b5c9e; font-size: 12px; margin: 15px 0 6px; }
        p { margin: 3px 0; }
        .meta { color: #68766f; font-size: 9px; margin-bottom: 9px; }
        .brand-header { width: 100%; border-collapse: collapse; margin-bottom: 8px; }
        .brand-header td { border: 0; padding: 0 8px 0 0; vertical-align: middle; }
        .brand-logo { width: 58px; height: 58px; }
        .summary { width: 100%; border-collapse: collapse; margin: 8px 0 14px; }
        .summary td { width: 50%; padding: 7px; border: 1px solid #d7e5f2; background: #f0f6fc; font-size: 10px; }
        table.data { width: 100%; border-collapse: collapse; table-layout: fixed; }
        .data th, .data td { padding: 5px; border: 1px solid #d6e2ec; text-align: left; vertical-align: top; overflow-wrap: anywhere; }
        .data th { background: #eaf3fb; color: #21415e; }
        .col-id { width: 16%; }
        .col-contact { width: 12%; }
        .col-loc { width: 11%; }
        .col-rights { width: 19%; }
        .col-card { width: 19%; }
        .col-observation { width: 23%; }
        .muted { color: #687989; }
        .empty { text-align: center; padding: 15px; color: #68766f; }
    </style>
</head>
<body>
    <table class="brand-header"><tr>
        <td style="width:66px"><img class="brand-logo" src="{{ $logoData }}" alt="Logo CANAM"></td>
        <td><h1>Rapport des droits et de la disponibilité des cartes</h1><div class="meta">CANAM — Service Qualité · Généré le {{ $generatedAt }} · {{ $rows->count() }} ligne(s)</div></td>
    </tr></table>

    <table class="summary"><tr>
        <td><strong>Filtre droits :</strong> {{ $filters['droits_statut'] ? ($rightsLabels[$filters['droits_statut']] ?? $filters['droits_statut']) : 'Tous' }}</td>
        <td><strong>Filtre cartes :</strong> {{ $filters['carte_statut'] ? ($cardLabels[$filters['carte_statut']] ?? $filters['carte_statut']) : 'Toutes' }}</td>
    </tr><tr>
        <td colspan="2"><strong>Recherche :</strong> {{ $filters['recherche'] ?: 'Aucune' }}</td>
    </tr></table>

    <table class="data">
        <thead><tr>
            <th class="col-id">Identité / AMO</th>
            <th class="col-contact">Contact</th>
            <th class="col-loc">Région / localité</th>
            <th class="col-rights">Droits</th>
            <th class="col-card">Carte</th>
            <th class="col-observation">Observations</th>
        </tr></thead>
        <tbody>
            @forelse($rows as $row)
                <tr>
                    <td><strong>{{ $row->nom_assure ?? 'Nom non renseigné' }}</strong><br>N° AMO/récépissé : {{ $row->numero_amo_recepisse }}<br>Matricule : {{ $row->numero_matricule ?? '—' }}</td>
                    <td>{{ $row->contact ?? '—' }}</td>
                    <td>{{ $row->region ?? '—' }}<br>{{ $row->localite ?? '—' }}</td>
                    <td>
                        <strong>{{ $row->droits_statut ? ($rightsLabels[$row->droits_statut] ?? $row->droits_statut) : 'Aucune fiche' }}</strong><br>
                        Validité : {{ $row->droits_date_debut ?? '—' }} au {{ $row->droits_date_fin ?? '—' }}<br>
                        Vérifié le : {{ $row->droits_verifie_le ?? '—' }}
                    </td>
                    <td>
                        <strong>{{ $row->numero_carte ?? 'Aucun numéro' }}</strong><br>
                        {{ $row->carte_statut ? ($cardLabels[$row->carte_statut] ?? $row->carte_statut) : 'Aucune carte' }}<br>
                        Mis à jour le : {{ $row->carte_date_mise_a_jour ?? '—' }}
                    </td>
                    <td>Droits : {{ $row->droits_observations ?? '—' }}<br>Carte : {{ $row->carte_observations ?? '—' }}</td>
                </tr>
            @empty
                <tr><td colspan="6" class="empty">Aucun assuré ne correspond aux filtres.</td></tr>
            @endforelse
        </tbody>
    </table>
    <p class="muted">Les coordonnées et informations nominatives proviennent du dossier CANAM le plus récent associé au N° AMO/récépissé.</p>
</body>
</html>
