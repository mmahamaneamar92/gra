<?php
namespace App\Services;
use App\Models\DelaiTraitement;
use Carbon\Carbon;
class EcheanceService {
 public function regle(string $module, ?int $qualificationId, ?Carbon $dateReference=null): ?DelaiTraitement {
  $dateReference=$dateReference ?: now();
  $base=DelaiTraitement::query()->where('module',$module)->where('actif',1)->whereDate('date_debut','<=',$dateReference->toDateString())->where(function($q)use($dateReference){$q->whereNull('date_fin')->orWhereDate('date_fin','>=',$dateReference->toDateString());});
  if($qualificationId){$specific=(clone $base)->where('qualification_id',$qualificationId)->orderByDesc('date_debut')->first();if($specific)return $specific;}
  return (clone $base)->whereNull('qualification_id')->orderByDesc('date_debut')->first();
 }
 public function calculer(string $module, ?int $qualificationId, $dateReference, ?Carbon $dateAffectation=null): ?Carbon {
  $dateReception=Carbon::parse($dateReference);
  $regle=$this->regle($module,$qualificationId,$dateReception);
  if(!$regle)return null;
  $base=$regle->point_depart==='affectation' ? ($dateAffectation ?: null) : $dateReception->copy()->startOfDay();
  if(!$base)return null; // attend l'affectation lorsque le point de départ est affectation
  if($regle->unite==='heures') return $base->copy()->addHours((int)$regle->duree);
  $date=$base->copy(); $remaining=(int)$regle->duree;
  if($regle->calendrier==='ouvre') { while($remaining>0){$date->addDay(); if(!$date->isWeekend()) $remaining--; } return $date; }
  return $date->addDays($remaining);
 }
}
