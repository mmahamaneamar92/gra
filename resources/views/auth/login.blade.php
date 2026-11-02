@extends('layouts.auth')

@section('title', 'Connexion — Service Qualité CANAM')

@section('content')
    <h2>Connexion</h2>
    <p class="muted">Utilisez votre adresse email professionnelle.</p>

    <form method="POST" action="{{ route('login') }}" class="stack auth-form">
        @csrf

        <div class="field">
            <label for="email">Adresse email</label>
            <input id="email" type="email" name="email" value="{{ old('email') }}" required autofocus autocomplete="username">
        </div>

        <div class="field">
            <label for="password">Mot de passe</label>
            <input id="password" type="password" name="password" required autocomplete="current-password">
        </div>

        <label class="auth-remember">
            <input type="checkbox" name="remember">
            Se souvenir de moi
        </label>

        <button class="btn primary auth-submit" type="submit">Se connecter</button>
    </form>
@endsection
