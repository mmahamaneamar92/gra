<?php
namespace App\Http\Controllers; use App\Models\Reclamation;
class ReclamationController extends DossierController {public function __construct(){ $this->module='reclamation';$this->modelClass=Reclamation::class;$this->prefix='reclamations';$this->label='Réclamations';$this->nameField='reclamant';}}
