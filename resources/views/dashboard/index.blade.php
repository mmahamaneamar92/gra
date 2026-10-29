@extends('layouts.app')
@section('title', 'Tableau de bord')
@section('content')
<div class="page-head">
    <div class="dashboard-heading">
        <img class="dashboard-logo" src="{{ asset('img/LogoCANAM.png') }}" alt="Logo de la CANAM Mali">
        <div>
            <h1>Tableau de bord</h1>
            <p>Suivi des dossiers, des droits des assurés et de la disponibilité des cartes</p>
        </div>
    </div>
    <a class="btn primary" href="{{ route('dashboard.assures.pdf', array_filter($filters, fn ($value) => $value !== '')) }}">Télécharger le rapport PDF filtré</a>
</div>

<div class="stats">
    <div class="stat"><span>Réclamations</span><strong>{{ $totalReclamations }}</strong><a href="{{ route('reclamations.index') }}">Consulter →</a></div>
    <div class="stat"><span>Demandes d’assistance</span><strong>{{ $totalAssistance }}</strong><a href="{{ route('assistance.index') }}">Consulter →</a></div>
    <div class="stat"><span>Dossiers en cours</span><strong>{{ $enCours }}</strong></div>
    <div class="stat danger"><span>Dossiers en retard</span><strong>{{ $enRetard }}</strong></div>
</div>

<section class="panel">
    <h2>Rechercher et filtrer les assurés</h2>
    <form class="filters" method="GET" action="{{ route('dashboard') }}">
        <input type="search" name="recherche" value="{{ $filters['recherche'] }}" placeholder="N° AMO/récépissé, nom, matricule ou contact">
        <select name="droits_statut">
            <option value="">Tous les statuts des droits</option>
            @foreach($rightsLabels as $status => $label)
                <option value="{{ $status }}" @selected($filters['droits_statut'] === $status)>{{ $label }}</option>
            @endforeach
        </select>
        <select name="carte_statut">
            <option value="">Tous les statuts des cartes</option>
            @foreach($cardLabels as $status => $label)
                <option value="{{ $status }}" @selected($filters['carte_statut'] === $status)>{{ $label }}</option>
            @endforeach
        </select>
        <button class="btn">Appliquer les filtres</button>
        <a class="btn light" href="{{ route('dashboard') }}">Réinitialiser</a>
    </form>

    <h2>Détail des assurés ({{ $assureRows->total() }} résultat(s))</h2>
    <div class="panel table-wrap"><table class="assure-details">
        <thead><tr><th>N° AMO/récépissé</th><th>Nom</th><th>Matricule</th><th>Contact</th><th>Région / localité</th><th>Droits</th><th>Carte</th><th>Observations</th></tr></thead>
        <tbody>
            @forelse($assureRows as $row)
                <tr>
                    <td>{{ $row->numero_amo_recepisse }}</td>
                    <td>{{ $row->nom_assure ?? '—' }}</td>
                    <td>{{ $row->numero_matricule ?? '—' }}</td>
                    <td>{{ $row->contact ?? '—' }}</td>
                    <td>{{ $row->region ?? '—' }}{{ $row->localite ? ' / '.$row->localite : '' }}</td>
                    <td>{{ $row->droits_statut ? ($rightsLabels[$row->droits_statut] ?? $row->droits_statut) : 'Aucune fiche' }}<br><small>{{ $row->droits_date_debut ?? '—' }} → {{ $row->droits_date_fin ?? '—' }}</small></td>
                    <td>{{ $row->numero_carte ?? '—' }}<br><small>{{ $row->carte_statut ? ($cardLabels[$row->carte_statut] ?? $row->carte_statut) : 'Aucune carte' }}</small></td>
                    <td>{{ $row->droits_observations ?? $row->carte_observations ?? '—' }}</td>
                </tr>
            @empty
                <tr><td colspan="8" class="empty">Aucun assuré ne correspond aux filtres.</td></tr>
            @endforelse
        </tbody>
    </table></div>
    {{ $assureRows->links() }}
</section>

<div class="grid-two">
    <section class="panel">
        <h2>Statut des droits des assurés <span class="summary-total">Total : {{ $rightsTotal }}</span></h2>
        <div class="table-wrap"><table class="status-summary"><thead><tr><th>Statut</th><th>Nombre</th></tr></thead><tbody>
            @foreach($rightsLabels as $status => $label)
                <tr><td>{{ $label }}</td><td><strong>{{ $rightsCounts[$status] }}</strong></td></tr>
            @endforeach
        </tbody></table></div>
    </section>
    <section class="panel">
        <h2>Disponibilité des cartes <span class="summary-total">Total : {{ $cardsTotal }}</span></h2>
        <div class="table-wrap"><table class="status-summary"><thead><tr><th>Statut</th><th>Nombre</th></tr></thead><tbody>
            @foreach($cardLabels as $status => $label)
                <tr><td>{{ $label }}</td><td><strong>{{ $cardCounts[$status] }}</strong></td></tr>
            @endforeach
        </tbody></table></div>
    </section>
</div>

<div class="grid-two">
    <section class="panel"><h2>Dernières réclamations</h2>@include('dashboard._table', ['items' => $recentReclamations, 'routeName' => 'reclamations.show'])</section>
    <section class="panel"><h2>Dernières demandes d’assistance</h2>@include('dashboard._table', ['items' => $recentAssistance, 'routeName' => 'assistance.show'])</section>
</div>
@endsection
