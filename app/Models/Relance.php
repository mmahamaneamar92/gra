<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class Relance extends Model {protected $table='relances'; protected $fillable=['module','reclamation_id','demande_assistance_id','date_relance','responsable_relance_id','destinataire_id','canal','motif','resultat','prochaine_action','statut','cree_par']; protected $casts=['date_relance'=>'datetime','prochaine_action'=>'datetime']; public function auteur(){return $this->belongsTo(User::class,'cree_par');} public function responsable(){return $this->belongsTo(User::class,'responsable_relance_id');}}
