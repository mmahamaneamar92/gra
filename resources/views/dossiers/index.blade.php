@extends('layouts.app')
@section('title', $label)
@section('content')
<div class="page-head">
    <div><h1>{{ $label }}</h1><p>Registre et suivi des dossiers</p></div>
    <div class="actions">
        <a class="btn" href="{{ route($prefix.'.pdf', request()->only('recherche', 'statut')) }}">Exporter les résultats en PDF</a>
        <a class="btn primary" href="{{ route($prefix.'.create') }}">+ Nouveau dossier</a>
    </div>
</div>

@php($statuses = $module === 'reclamation' ? ['brouillon','recu','a_affecter','affecte','en_cours','en_attente_information','traite','cloture','annule'] : ['brouillon','recu','a_affecter','affecte','en_cours','en_attente_information','traite','a_notifier','cloture','annule'])
@php($rightsLabels = ['ouverts' => 'Droits ouverts', 'suspendus' => 'Droits suspendus', 'fermes' => 'Droits fermés', 'inconnu' => 'Inconnu'])
@php($cardLabels = ['disponible' => 'Disponible', 'en_preparation' => 'En préparation', 'emise' => 'Émise', 'indisponible' => 'Indisponible', 'inconnue' => 'Inconnue'])

<form class="filters" method="GET">
    <input name="recherche" value="{{ request('recherche') }}" placeholder="N° dossier, personne, AMO, matricule ou objet">
    <select name="statut">
        <option value="">Tous les statuts</option>
        @foreach($statuses as $status)
            <option value="{{ $status }}" @selected(request('statut') === $status)>{{ ucfirst(str_replace('_', ' ', $status)) }}</option>
        @endforeach
    </select>
    <button class="btn">Filtrer</button>
    <a class="btn light" href="{{ route($prefix.'.index') }}">Réinitialiser</a>
</form>

<div class="panel table-wrap">
    <table class="dossier-register">
        <thead><tr>
            <th>N° d’ordre</th><th>Date réception</th><th>Réclamant / demandeur</th><th>Objet</th><th>Qualification</th><th>Responsable</th>
            <th>Statut des droits</th><th>Ouverture</th><th>Fermeture</th><th>Carte</th><th>Échéance</th><th>Statut dossier</th><th></th>
        </tr></thead>
        <tbody>
            @forelse($dossiers as $d)
                <tr>
                    <td>{{ $d->numero_ordre }}</td>
                    <td>{{ $d->date_reception?->format('d/m/Y') }}</td>
                    <td>{{ $d->reclamant ?? $d->demandeur }}</td>
                    <td class="object-cell">{{ $d->objet }}</td>
                    <td>{{ $d->qualification?->libelle ?? '—' }}</td>
                    <td>{{ $d->responsable?->name ?? 'Non affecté' }}</td>
                    <td>{{ $d->droits_statut ? ($rightsLabels[$d->droits_statut] ?? $d->droits_statut) : '—' }}</td>
                    <td>{{ $d->droits_date_debut ? \Carbon\Carbon::parse($d->droits_date_debut)->format('d/m/Y') : '—' }}</td>
                    <td>{{ $d->droits_date_fin ? \Carbon\Carbon::parse($d->droits_date_fin)->format('d/m/Y') : '—' }}</td>
                    <td>{{ $d->carte_numero ?? '—' }}<br><small>{{ $d->carte_disponibilite ? ($cardLabels[$d->carte_disponibilite] ?? $d->carte_disponibilite) : '—' }}</small></td>
                    <td>{{ $d->echeance_traitement?->format('d/m/Y H:i') ?? 'À calculer après affectation' }} @if($d->en_retard)<span class="badge badge-red">Retard</span>@endif</td>
                    <td><span class="badge">{{ str_replace('_', ' ', $d->statut) }}</span></td>
                    <td><a class="btn small" href="{{ route($prefix.'.show', $d->id) }}">Ouvrir</a></td>
                </tr>
            @empty
                <tr><td colspan="13" class="empty">Aucun dossier trouvé.</td></tr>
            @endforelse
        </tbody>
    </table>
</div>
{{ $dossiers->links() }}
@endsection
