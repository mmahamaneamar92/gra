<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
trait DossierTrait {
 public function initializeDossierTrait(): void{$this->casts=array_merge($this->casts,['date_reception'=>'date','date_affectation'=>'datetime','echeance_traitement'=>'datetime','date_traitement'=>'datetime','date_emission_carte'=>'date','date_cloture'=>'datetime']);}
 public function region(): BelongsTo{return $this->belongsTo(Region::class);}
 public function localite(): BelongsTo{return $this->belongsTo(Localite::class);}
 public function ogd(): BelongsTo{return $this->belongsTo(Ogd::class,'ogd_id');}
 public function provenance(): BelongsTo{return $this->belongsTo(Provenance::class);}
 public function qualification(): BelongsTo{return $this->belongsTo(Qualification::class);}
 public function processus(): BelongsTo{return $this->belongsTo(Processus::class);}
 public function responsable(): BelongsTo{return $this->belongsTo(User::class,'responsable_traitement_id');}
 public function createur(): BelongsTo{return $this->belongsTo(User::class,'cree_par');}
 public function getEnRetardAttribute(): bool{return !in_array($this->statut,['traite','a_notifier','cloture','annule'],true) && $this->echeance_traitement && $this->echeance_traitement->isPast();}
}
