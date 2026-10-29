window.initLocalites=function(){const region=document.getElementById('region_id'),localite=document.getElementById('localite_id');if(!region||!localite)return;const filter=()=>{[...localite.options].forEach(o=>{if(!o.value)return;o.hidden=!!region.value&&o.dataset.region!==region.value;if(o.hidden&&o.selected)localite.value='';});};region.addEventListener('change',filter);filter();};

window.initControleAssure=function(){
    const input=document.getElementById('numero_amo_recepisse');
    const panel=document.getElementById('controle-assure');
    if(!input||!panel)return;

    const message=panel.querySelector('[data-role="message"]');
    const results=panel.querySelector('[data-role="results"]');
    const droitsEl=panel.querySelector('[data-role="droits"]');
    const cartesEl=panel.querySelector('[data-role="cartes"]');
    const droitLabels={ouverts:'Droits ouverts',suspendus:'Droits suspendus',fermes:'Droits fermés',inconnu:'Statut des droits inconnu'};
    const carteLabels={disponible:'Disponible',en_preparation:'En préparation',emise:'Émise',indisponible:'Indisponible',inconnue:'Disponibilité inconnue'};
    let timer=null;
    let activeRequest=null;
    let latestReference='';

    const setMessage=(text)=>{message.textContent=text;};
    const addLine=(container,label,value)=>{
        if(!value)return;
        const line=document.createElement('p');
        line.textContent=label+': '+value;
        container.appendChild(line);
    };

    const check=async()=>{
        const reference=input.value.trim();
        latestReference=reference;
        if(activeRequest)activeRequest.abort();
        results.hidden=true;
        droitsEl.replaceChildren();
        cartesEl.replaceChildren();
        if(!reference){setMessage('Saisissez le N° AMO ou le récépissé pour vérifier les droits et la disponibilité de la carte.');return;}

        setMessage('Vérification en cours…');
        activeRequest=new AbortController();
        try{
            const url=new URL(panel.dataset.url,window.location.origin);
            url.searchParams.set('numero_amo_recepisse',reference);
            const response=await fetch(url,{headers:{'Accept':'application/json'},signal:activeRequest.signal});
            if(!response.ok)throw new Error('La vérification est momentanément indisponible.');
            const data=await response.json();
            if(latestReference!==reference)return;

            if(data.droits){
                const status=droitLabels[data.droits.statut]||data.droits.statut||'Statut inconnu';
                addLine(droitsEl,'Résultat',status);
                if(data.droits.date_debut)addLine(droitsEl,'Début des droits',data.droits.date_debut);
                if(data.droits.date_fin)addLine(droitsEl,'Fin des droits',data.droits.date_fin);
                if(data.droits.verifie_le)addLine(droitsEl,'Vérifié le',data.droits.verifie_le);
                if(data.droits.observations)addLine(droitsEl,'Observation',data.droits.observations);
            }else{
                addLine(droitsEl,'Résultat','Aucune fiche de droits trouvée pour ce N° AMO/récépissé.');
            }

            if(data.cartes&&data.cartes.length){
                data.cartes.forEach((carte,index)=>{
                    const block=document.createElement('div');
                    block.className='verification-card';
                    addLine(block,'Carte '+(index+1),carteLabels[carte.disponibilite]||carte.disponibilite||'Statut inconnu');
                    if(carte.numero_carte)addLine(block,'Numéro',carte.numero_carte);
                    if(carte.date_mise_a_jour)addLine(block,'Mise à jour',carte.date_mise_a_jour);
                    if(carte.observations)addLine(block,'Observation',carte.observations);
                    cartesEl.appendChild(block);
                });
            }else{
                addLine(cartesEl,'Résultat','Aucune carte trouvée pour ce N° AMO/récépissé.');
            }
            results.hidden=false;
            setMessage('Vérification terminée pour le N° AMO/récépissé '+reference+'.');
        }catch(error){
            if(error.name==='AbortError')return;
            setMessage(error.message||'La vérification est momentanément indisponible.');
        }
    };

    input.addEventListener('input',()=>{clearTimeout(timer);timer=setTimeout(check,350);});
    input.addEventListener('change',check);
    if(input.value.trim())check();
};

document.addEventListener('DOMContentLoaded',()=>{
    if(typeof window.initLocalites==='function')window.initLocalites();
    if(typeof window.initControleAssure==='function')window.initControleAssure();
    document.querySelectorAll('form[data-confirm]').forEach(f=>f.addEventListener('submit',e=>{if(!confirm(f.dataset.confirm))e.preventDefault();}));
});
