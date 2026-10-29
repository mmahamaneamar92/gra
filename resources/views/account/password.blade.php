@extends('layouts.app')

@section('title', 'Modifier mon mot de passe')

@section('content')
<div class="page-head">
    <div>
        <h1>Modifier mon mot de passe</h1>
        <p>Choisissez un nouveau mot de passe pour votre compte.</p>
    </div>
</div>

<form class="panel password-form" method="POST" action="{{ route('account.password.update') }}">
    @csrf
    @method('PUT')

    <div class="field">
        <label for="current_password">Mot de passe actuel</label>
        <input id="current_password" type="password" name="current_password" autocomplete="current-password" required>
    </div>

    <div class="field">
        <label for="password">Nouveau mot de passe</label>
        <input id="password" type="password" name="password" autocomplete="new-password" minlength="8" required>
        <small>Au moins 8 caractères.</small>
    </div>

    <div class="field">
        <label for="password_confirmation">Confirmer le nouveau mot de passe</label>
        <input id="password_confirmation" type="password" name="password_confirmation" autocomplete="new-password" minlength="8" required>
    </div>

    <div class="form-actions">
        <button class="btn primary" type="submit">Enregistrer le nouveau mot de passe</button>
    </div>
</form>
@endsection
