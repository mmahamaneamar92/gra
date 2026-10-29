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
            ->where(fn ($query) => $query->where('numero_amo_recepisse', $reference)->orWhere('numero_recepisse', $reference)->orWhere('amo_ayant_droit', $reference))
            ->first(['statut', 'date_debut', 'date_fin', 'verifie_le', 'observations', 'amo_assure', 'amo_ayant_droit', 'numero_recepisse', 'nom_assure', 'date_immatriculation_source', 'date_fermeture_premium']);

        $cartes = DB::table('disponibilite_cartes')
            ->where(fn ($query) => $query->where('numero_amo_recepisse', $reference)->orWhere('numero_recepisse', $reference))
            ->orderByDesc('date_mise_a_jour')
            ->orderByDesc('id')
            ->get(['numero_carte', 'disponibilite', 'date_mise_a_jour', 'observations', 'numero_recepisse', 'id_statut_source', 'nom_assure', 'ogd_source', 'numero_lot_source', 'date_emission_source']);

        return response()->json([
            'numero_amo_recepisse' => $reference,
            'droits' => $droits,
            'cartes' => $cartes,
        ]);
    }
}
