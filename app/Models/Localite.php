<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class Localite extends Model {protected $fillable=['region_id','nom','actif']; protected $casts=['actif'=>'boolean']; public function region(){return $this->belongsTo(Region::class);}}
