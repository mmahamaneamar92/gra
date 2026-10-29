<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class DemandeAssistance extends Model {use DossierTrait; protected $table='demandes_assistance'; protected $fillable=['numero_ordre','date_reception','demandeur','region_id','localite_id','numero_amo_recepisse','numero_matricule','contact','ogd_id','objet','provenance_id','qualification_id','processus_id','responsable_traitement_id','date_affectation','delai_traitement_id','echeance_traitement','causes_probleme','action_entreprise','date_traitement','statut','priorite','statut_notification','date_appel','responsable_notification_id','observations','cree_par','cloture_par','date_cloture','motif_annulation']; public function getNumeroAttribute(){return $this->numero_ordre;} }
