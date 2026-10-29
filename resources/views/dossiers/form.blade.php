@extends('layouts.app')
@section('title',($dossier?'Modifier':'Nouveau').' — '.$label)
@section('content')
<div class="page-head"><div><h1>{{ $dossier?'Modifier le dossier':'Enregistrer un dossier' }}</h1><p>{{ $label }}</p></div><a class="btn light" href="{{ $dossier?route($prefix.'.show',$dossier->id):route($prefix.'.index') }}">Retour</a></div>
<form class="panel form-grid" method="POST" action="{{ $dossier?route($prefix.'.update',$dossier->id):route($prefix.'.store') }}">@csrf @if($dossier)@method('PUT')@endif
<div class="field"><label>Date de réception *</label><input type="date" name="date_reception" required value="{{ old('date_reception',$dossier?->date_reception?->format('Y-m-d')??now()->format('Y-m-d')) }}"></div>
<div class="field"><label>{{ $module==='reclamation'?'Réclamant':'Demandeur' }} *</label><input name="{{ $module==='reclamation'?'reclamant':'demandeur' }}" required value="{{ old($module==='reclamation'?'reclamant':'demandeur',$dossier?->reclamant??$dossier?->demandeur??'') }}"></div>
<div class="field"><label>Région</label><select name="region_id" id="region_id"><option value="">— Sélectionner —</option>@foreach($regions as $r)<option value="{{ $r->id }}" @selected(old('region_id',$dossier->region_id??'')==$r->id)>{{ $r->nom }}</option>@endforeach</select></div>
<div class="field"><label>Localité</label><select name="localite_id" id="localite_id"><option value="">— Sélectionner —</option>@foreach($localites as $l)<option data-region="{{ $l->region_id }}" value="{{ $l->id }}" @selected(old('localite_id',$dossier->localite_id??'')==$l->id)>{{ $l->nom }}</option>@endforeach</select></div>
<div class="field"><label>N° AMO ou récépissé</label><input id="numero_amo_recepisse" name="numero_amo_recepisse" maxlength="100" autocomplete="off" value="{{ old('numero_amo_recepisse',$dossier->numero_amo_recepisse??'') }}"><small>Les droits et la disponibilité de la carte sont recherchés automatiquement avec ce numéro.</small></div><div class="field"><label>Numéro matricule</label><input name="numero_matricule" value="{{ old('numero_matricule',$dossier->numero_matricule??'') }}"></div>
<section class="field full verification-panel" id="controle-assure" data-url="{{ route('assures.controle') }}" aria-live="polite">
<h3>Vérification de l’assuré</h3><p class="verification-message" data-role="message">Saisissez le N° AMO ou le récépissé pour vérifier les droits et la disponibilité de la carte.</p>
<div class="verification-results" data-role="results" hidden>
<div><strong>Droits</strong><p data-role="droits"></p></div>
<div><strong>Carte(s)</strong><div data-role="cartes"></div></div>
</div>
<small>Ce contrôle informe l’agent ; il n’affecte pas automatiquement la demande.</small>
</section>
<div class="field"><label>Contact</label><input name="contact" value="{{ old('contact',$dossier->contact??'') }}"></div><div class="field"><label>OGD</label><select name="ogd_id"><option value="">— Sélectionner —</option>@foreach($ogds as $o)<option value="{{ $o->id }}" @selected(old('ogd_id',$dossier->ogd_id??'')==$o->id)>{{ $o->nom }}</option>@endforeach</select></div>
<div class="field full"><label>Objet du dossier *</label><textarea name="objet" rows="3" required>{{ old('objet',$dossier->objet??'') }}</textarea></div>
<div class="field"><label>Provenance</label><select name="provenance_id"><option value="">— Sélectionner —</option>@foreach($provenances as $p)<option value="{{ $p->id }}" @selected(old('provenance_id',$dossier->provenance_id??'')==$p->id)>{{ $p->libelle }}</option>@endforeach</select></div>
<div class="field"><label>Qualification</label><select name="qualification_id"><option value="">— Sélectionner —</option>@foreach($qualifications as $q)<option value="{{ $q->id }}" @selected(old('qualification_id',$dossier->qualification_id??'')==$q->id)>{{ $q->libelle }}</option>@endforeach</select><small>L’échéance est déterminée par la règle active à l’affectation ou à la réception.</small></div>
<div class="field"><label>Processus concerné</label><select name="processus_id"><option value="">— Sélectionner —</option>@foreach($processus as $p)<option value="{{ $p->id }}" @selected(old('processus_id',$dossier->processus_id??'')==$p->id)>{{ $p->libelle }}</option>@endforeach</select></div>
<div class="field"><label>Priorité</label><select name="priorite">@foreach(['basse'=>'Basse','normale'=>'Normale','haute'=>'Haute','urgente'=>'Urgente'] as $v=>$l)<option value="{{ $v }}" @selected(old('priorite',$dossier->priorite??'normale')===$v)>{{ $l }}</option>@endforeach</select></div>
@if($module==='reclamation')<div class="field"><label>Date d’émission de la carte</label><input type="date" name="date_emission_carte" value="{{ old('date_emission_carte',$dossier?->date_emission_carte?->format('Y-m-d')) }}"></div>@endif
<div class="field full"><label>Causes du problème</label><textarea name="causes_probleme" rows="3">{{ old('causes_probleme',$dossier->causes_probleme??'') }}</textarea></div><div class="field full"><label>Action entreprise</label><textarea name="action_entreprise" rows="3">{{ old('action_entreprise',$dossier->action_entreprise??'') }}</textarea></div><div class="field full"><label>Observations</label><textarea name="observations" rows="2">{{ old('observations',$dossier->observations??'') }}</textarea></div>
<div class="form-actions"><button class="btn primary" type="submit">{{ $dossier?'Enregistrer les modifications':'Enregistrer le dossier' }}</button><a class="btn light" href="{{ route($prefix.'.index') }}">Annuler</a></div></form>
@endsection
@push('scripts')<script>window.initLocalites && window.initLocalites();</script>@endpush
