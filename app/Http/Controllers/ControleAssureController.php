<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ControleAssureController extends Controller
{
    public function show(Request $request)
    {
        $data = $request->validate([
            'numero_amo_recepisse' => ['required', 'string', 'max:100'],
        ]);

        $reference = trim($data['numero_amo_recepisse']);

        $droits = DB::table('droits_assures')
            ->where('numero_amo_recepisse', $reference)
            ->first(['statut', 'date_debut', 'date_fin', 'verifie_le', 'observations']);

        $cartes = DB::table('disponibilite_cartes')
            ->where('numero_amo_recepisse', $reference)
            ->orderByDesc('date_mise_a_jour')
            ->orderByDesc('id')
            ->get(['numero_carte', 'disponibilite', 'date_mise_a_jour', 'observations']);

        return response()->json([
            'numero_amo_recepisse' => $reference,
            'droits' => $droits,
            'cartes' => $cartes,
        ]);
    }
}
