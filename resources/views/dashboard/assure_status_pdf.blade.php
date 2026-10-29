<!doctype html>
<html lang="fr">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Rapport des droits et cartes</title>
    <style>
        body { font-family: DejaVu Sans, sans-serif; color: #1d2b27; font-size: 12px; }
        h1 { color: #087b50; font-size: 21px; margin: 0 0 6px; }
        h2 { color: #087b50; font-size: 15px; margin: 24px 0 8px; }
        .meta { color: #68766f; margin-bottom: 18px; }
        .totals { width: 100%; margin-bottom: 18px; }
        .totals td { width: 50%; background: #eef6f1; padding: 12px; border: 1px solid #dce9e2; }
        table.data { width: 100%; border-collapse: collapse; }
        .data th, .data td { padding: 8px; border: 1px solid #dfe7e2; text-align: left; }
        .data th { background: #edf4f0; }
        .number { text-align: right !important; width: 100px; }
        .foot { margin-top: 24px; color: #68766f; font-size: 10px; }
    </style>
</head>
<body>
    <h1>Rapport des droits des assurés et des cartes</h1>
    <div class="meta">CANAM — Service Qualité · Généré le {{ $generatedAt }}</div>

    <table class="totals"><tr>
        <td><strong>Total des fiches de droits :</strong> {{ $rightsTotal }}</td>
        <td><strong>Total des cartes enregistrées :</strong> {{ $cardsTotal }}</td>
    </tr></table>

    <h2>Statut des droits</h2>
    <table class="data"><thead><tr><th>Statut</th><th class="number">Nombre</th></tr></thead><tbody>
        @foreach($rightsLabels as $status => $label)
            <tr><td>{{ $label }}</td><td class="number">{{ $rightsCounts[$status] }}</td></tr>
        @endforeach
        <tr><th>Total</th><th class="number">{{ $rightsTotal }}</th></tr>
    </tbody></table>

    <h2>Disponibilité des cartes</h2>
    <table class="data"><thead><tr><th>Statut</th><th class="number">Nombre</th></tr></thead><tbody>
        @foreach($cardLabels as $status => $label)
            <tr><td>{{ $label }}</td><td class="number">{{ $cardCounts[$status] }}</td></tr>
        @endforeach
        <tr><th>Total</th><th class="number">{{ $cardsTotal }}</th></tr>
    </tbody></table>

    <div class="foot">Rapport récapitulatif — aucun numéro AMO/récépissé ni donnée nominative n’est inclus.</div>
</body>
</html>
