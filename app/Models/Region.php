<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class Region extends Model {protected $fillable=['code','nom','actif']; protected $casts=['actif'=>'boolean']; public function localites(){return $this->hasMany(Localite::class);}}
