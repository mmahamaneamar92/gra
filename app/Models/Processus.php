<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class Processus extends Model {protected $table='processus'; protected $fillable=['code', 'libelle', 'description', 'actif']; protected $casts=['actif'=>'boolean'];}
