<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
class User extends Authenticatable {
 use HasFactory, Notifiable;
 protected $table='users';
 protected $fillable=['nom','prenom','identifiant','email','telephone','password','actif'];
 protected $hidden=['password','remember_token'];
 protected $casts=['actif'=>'boolean','derniere_connexion'=>'datetime','password'=>'hashed'];
 public function roles(){return $this->belongsToMany(Role::class,'user_roles')->withPivot('attribue_par')->withTimestamps();}
 public function isRole(...$roles): bool { $normalized=[]; array_walk_recursive($roles,static function($role) use (&$normalized){if(is_string($role)||is_numeric($role))$normalized[]=strtoupper((string)$role);}); return $normalized!==[] && $this->roles()->whereIn('code',$normalized)->exists(); }
 public function hasAnyRole(...$roles): bool { return $this->isRole(...$roles); }
 public function getNameAttribute(): string { return trim(($this->prenom??'').' '.($this->nom??'')) ?: $this->identifiant; }
 public function getAuthIdentifierName(){return 'id';}
}
