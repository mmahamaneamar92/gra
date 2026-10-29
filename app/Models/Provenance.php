<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class Provenance extends Model {protected $table='provenances'; protected $fillable=['module', 'libelle', 'actif']; protected $casts=['actif'=>'boolean'];}
