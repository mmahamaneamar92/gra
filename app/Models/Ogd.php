<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class Ogd extends Model {protected $table='ogds'; protected $fillable=['code', 'nom', 'description', 'actif']; protected $casts=['actif'=>'boolean'];}
