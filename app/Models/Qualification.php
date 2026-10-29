<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class Qualification extends Model {protected $table='qualifications'; protected $fillable=['module', 'code', 'libelle', 'description', 'actif']; protected $casts=['actif'=>'boolean'];}
