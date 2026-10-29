<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class DelaiTraitement extends Model {protected $table='delais_traitement'; protected $fillable=['module','qualification_id','libelle','duree','unite','calendrier','point_depart','alerte_avant','unite_alerte','frequence_relance','unite_frequence_relance','escalade_apres','actif','date_debut','date_fin','cree_par']; protected $casts=['actif'=>'boolean','date_debut'=>'date','date_fin'=>'date']; public function qualification(){return $this->belongsTo(Qualification::class);}}
