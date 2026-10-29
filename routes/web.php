<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\{DashboardController,ReclamationController,DemandeAssistanceController,DelaiController,ReferentielController,UserController,AccountPasswordController};
Route::get('/',fn()=>redirect()->route('dashboard'));
Route::middleware(['auth'])->group(function(){
 Route::get('/dashboard',[DashboardController::class,'index'])->name('dashboard');
 Route::get('/mon-compte/mot-de-passe',[AccountPasswordController::class,'edit'])->name('account.password.edit');
 Route::put('/mon-compte/mot-de-passe',[AccountPasswordController::class,'update'])->name('account.password.update');
 Route::get('/controle-assure',[App\Http\Controllers\ControleAssureController::class,'show'])->name('assures.controle');
 Route::resource('reclamations',ReclamationController::class);
 Route::post('reclamations/{id}/affecter',[ReclamationController::class,'affecter'])->name('reclamations.affecter');
 Route::post('reclamations/{id}/statut',[ReclamationController::class,'statut'])->name('reclamations.statut');
 Route::post('reclamations/{id}/relancer',[ReclamationController::class,'relancer'])->name('reclamations.relancer');
 Route::resource('assistance',DemandeAssistanceController::class)->parameters(['assistance'=>'id']);
 Route::post('assistance/{id}/affecter',[DemandeAssistanceController::class,'affecter'])->name('assistance.affecter');
 Route::post('assistance/{id}/statut',[DemandeAssistanceController::class,'statut'])->name('assistance.statut');
 Route::post('assistance/{id}/relancer',[DemandeAssistanceController::class,'relancer'])->name('assistance.relancer');
 Route::post('assistance/{id}/notifier',[DemandeAssistanceController::class,'notifier'])->name('assistance.notifier');
 Route::resource('/administration/utilisateurs',UserController::class)->only(['index','create','store','edit','update'])->names('admin.users')->parameters(['utilisateurs'=>'id']);
 Route::get('/administration/delais',[DelaiController::class,'index'])->name('admin.delais');Route::post('/administration/delais',[DelaiController::class,'store'])->name('admin.delais.store');
 Route::get('/administration/referentiels',[ReferentielController::class,'index'])->name('admin.referentiels');Route::post('/administration/referentiels',[ReferentielController::class,'store'])->name('admin.referentiels.store');
});
require __DIR__.'/auth.php';
