<?php

return [
    // Définir chaque ID_STATUT_CARTE Oracle qui signifie réellement « émise ».
    // Par défaut, l'ID source est conservé sans inventer son libellé métier.
    'oracle_card_status_map' => collect(explode(',', (string) env('CANAM_ORACLE_CARD_STATUS_MAP', '')))
        ->mapWithKeys(function ($pair) {
            $parts = array_map('trim', explode('=', $pair, 2));
            return count($parts) === 2 ? [$parts[0] => $parts[1]] : [];
        })->all(),
];
