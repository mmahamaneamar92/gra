<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AccountPasswordController extends Controller
{
    public function edit()
    {
        return view('account.password');
    }

    public function update(Request $request)
    {
        $data = $request->validate([
            'current_password' => ['required', 'current_password'],
            'password' => ['required', 'string', 'min:8', 'confirmed', 'different:current_password'],
        ], [
            'current_password.current_password' => 'Le mot de passe actuel est incorrect.',
            'password.min' => 'Le nouveau mot de passe doit contenir au moins 8 caractères.',
            'password.confirmed' => 'La confirmation du nouveau mot de passe ne correspond pas.',
            'password.different' => 'Le nouveau mot de passe doit être différent de l’actuel.',
        ]);

        $user = $request->user();
        $user->password = Hash::make($data['password']);
        $user->save();

        return redirect()->route('account.password.edit')->with('success', 'Votre mot de passe a été modifié.');
    }
}
