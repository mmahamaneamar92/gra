<!doctype html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', 'Connexion — Service Qualité CANAM')</title>
    <link rel="stylesheet" href="{{ asset('css/canam.css') }}?v={{ filemtime(public_path('css/canam.css')) }}">
</head>
<body class="auth-body">
    <main class="auth-shell">
        <section class="auth-brand">
            <img src="{{ asset('img/LogoCANAM.png') }}" alt="Logo CANAM">
            <p class="auth-kicker">CANAM Mali</p>
            <h1>Service Qualité</h1>
            <p>Suivi des réclamations, des demandes d’assistance et des droits des assurés.</p>
        </section>

        <section class="auth-card">
            @if(session('status'))
                <div class="alert success">{{ session('status') }}</div>
            @endif

            @if($errors->any())
                <div class="alert error">
                    <strong>Connexion impossible :</strong>
                    <ul>
                        @foreach($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            @yield('content')
        </section>
    </main>
</body>
</html>
