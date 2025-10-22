-- Dans dtwventebdd
CREATE EXTENSION IF NOT EXISTS dblink;

-- verif de la connexion
SELECT dblink_connect('my_conn', 'dbname=ventebdd user=postgres password=postgres');

-- alimentation de la dimension temps

-- alimentation avec uniquement avec uniquement les dates metier importantes
INSERT INTO entreprise._DimTemps (
    datecomplete, jour, mois, annee, trimestre, semestre, 
    nommois, nomtrimestre, estweekend
)
SELECT DISTINCT
    date_value as datecomplete,
    EXTRACT(DAY FROM date_value) as jour,
    EXTRACT(MONTH FROM date_value) as mois,
    EXTRACT(YEAR FROM date_value) as annee,
    EXTRACT(QUARTER FROM date_value) as trimestre,
    CASE WHEN EXTRACT(MONTH FROM date_value) <= 6 THEN 1 ELSE 2 END as semestre,
    TRIM(TO_CHAR(date_value, 'Month')) as nommois,
    'T' || EXTRACT(QUARTER FROM date_value) as nomtrimestre,
    EXTRACT(DOW FROM date_value) IN (0, 6) as estweekend
FROM (
    -- UNIQUEMENT les dates liées aux commandes et livraisons
    SELECT datecom as date_value FROM dblink('my_conn', 'SELECT datecom FROM entreprise._commande') AS cmd(datecom DATE)
    UNION
    SELECT dateobjliv FROM dblink('my_conn', 'SELECT dateobjliv FROM entreprise._commande WHERE dateobjliv IS NOT NULL') AS obj(dateobjliv DATE)
    UNION  
    SELECT dateenv FROM dblink('my_conn', 'SELECT dateenv FROM entreprise._commande WHERE dateenv IS NOT NULL') AS env(dateenv DATE)
) AS dates_metier
WHERE date_value IS NOT NULL
ORDER BY date_value;


-- alimentation dimension produit
INSERT INTO entreprise._DimTemps (
    datecomplete, jour, mois, annee, trimestre, semestre, 
    nommois, nomtrimestre, estweekend
)
SELECT DISTINCT
    datecom as datecomplete,
    EXTRACT(DAY FROM datecom) as jour,
    EXTRACT(MONTH FROM datecom) as mois,
    EXTRACT(YEAR FROM datecom) as annee,
    EXTRACT(QUARTER FROM datecom) as trimestre,
    CASE WHEN EXTRACT(MONTH FROM datecom) <= 6 THEN 1 ELSE 2 END as semestre,
    TRIM(TO_CHAR(datecom, 'Month')) as nommois,  -- TRIM pour enlever les espaces
    'T' || EXTRACT(QUARTER FROM datecom) as nomtrimestre,
    EXTRACT(DOW FROM datecom) IN (0, 6) as estweekend
FROM dblink('my_conn', 
    'SELECT datecom FROM entreprise._commande 
     UNION SELECT dateobjliv FROM entreprise._commande 
     UNION SELECT dateenv FROM entreprise._commande 
     WHERE dateenv IS NOT NULL'
) AS dates(datecom DATE)
WHERE datecom IS NOT NULL
AND datecom NOT IN (SELECT datecomplete FROM entreprise._DimTemps);  -- Évite les doublons

-- alimentation dimension client
INSERT INTO entreprise._DimClient (
    codecli, societe, ville, region, pays, codepostal
)
SELECT 
    codecli,
    societe,
    ville,
    region,
    pays,
    codepostal
FROM dblink('my_conn', 
    'SELECT codecli, societe, ville, region, pays, codepostal 
     FROM entreprise._client'
) AS c(
    codecli VARCHAR, societe VARCHAR, ville VARCHAR, 
    region VARCHAR, pays VARCHAR, codepostal VARCHAR
);

-- alimentation dimension employe
INSERT INTO entreprise._DimEmploye (
    noemp, nomComplet, fonction, ville, region, pays
)
SELECT 
    noemp,
    nom || ' ' || prenom as nomComplet,
    fonction,
    ville,
    region,
    pays
FROM dblink('my_conn', 
    'SELECT noemp, nom, prenom, fonction, ville, region, pays 
     FROM entreprise._employe'
) AS e(
    noemp INTEGER, nom VARCHAR, prenom VARCHAR, fonction VARCHAR,
    ville VARCHAR, region VARCHAR, pays VARCHAR
);


-- alimentation dimension transporteur
INSERT INTO entreprise._DimTransporteur (
    notran, nomtran, tel
)
SELECT 
    notran,
    nomtran,
    tel
FROM dblink('my_conn', 
    'SELECT notran, nomtran, tel FROM entreprise._transporteur'
) AS t(notran INTEGER, nomtran VARCHAR, tel VARCHAR);

-- alimentation dimension géographie
INSERT INTO entreprise._DimGeographie (
    villeliv, regionliv, paysliv, codepostalliv
)
SELECT DISTINCT
    villeliv,
    regionliv,
    paysliv,
    codepostalliv
FROM dblink('my_conn', 
    'SELECT villeliv, regionliv, paysliv, codepostalliv 
     FROM entreprise._commande 
     WHERE villeliv IS NOT NULL'
) AS g(villeliv VARCHAR, regionliv VARCHAR, paysliv VARCHAR, codepostalliv VARCHAR);


--table de faits VENTES
INSERT INTO entreprise._FaitVentes (
    idtemps, idproduit, idclient, idemploye, idtransporteur,
    qtevendue, prixunitvente, montantremise, chiffreaffairesnet, fraisport
)
SELECT 
    dt.idtemps, dp.idproduit, dc.idclient, de.idemploye, dtran.idtransporteur,
    dc_donnee.qte as qtevendue, dc_donnee.prixunit as prixunitvente,
    (dc_donnee.prixunit * dc_donnee.qte * dc_donnee.remise) as montantremise,
    (dc_donnee.prixunit * dc_donnee.qte * (1 - dc_donnee.remise)) as chiffreaffairesnet,
    dc_donnee.port as fraisport
FROM dblink('my_conn', 
    'SELECT dc.nocom, dc.refprod, dc.prixunit, dc.qte, dc.remise,
            c.codecli, c.noemp, c.notran, c.datecom, c.port
     FROM entreprise._detailcommande dc
     JOIN entreprise._commande c ON dc.nocom = c.nocom'
) AS dc_donnee(
    nocom INTEGER, refprod INTEGER, prixunit NUMERIC, qte INTEGER, remise NUMERIC,
    codecli VARCHAR, noemp INTEGER, notran INTEGER, datecom DATE, port NUMERIC
)
JOIN entreprise._DimTemps dt ON dc_donnee.datecom=dt.datecomplete
JOIN entreprise._DimProduit dp ON dc_donnee.refprod=dp.refprod
JOIN entreprise._DimClient dc ON dc_donnee.codecli=dc.codecli
JOIN entreprise._DimEmploye de ON dc_donnee.noemp=de.noemp
LEFT JOIN entreprise._DimTransporteur dtran ON dc_donnee.notran=dtran.notran;







-- CORRECTION - Version fonctionnelle
INSERT INTO entreprise._FaitLivraisons (
    idtemps, idproduit, idgeographie, idtransporteur,
    qtelivree, delailivraisonjours, ecartdatejours, 
    niveaustock, besoinreappro, unitesencommande
)
SELECT 
    dt.idtemps, dp.idproduit, dg.idgeographie, dtran.idtransporteur,
    source_donnee.qte as qtelivree,
    (source_donnee.dateenv - source_donnee.datecom) as delailivraisonjours,
    (source_donnee.dateenv - source_donnee.dateobjliv) as ecartdatejours,
    source_donnee.unitesstock as niveaustock,
    (source_donnee.unitesstock - source_donnee.unitescom <= source_donnee.niveaureap) as besoinreappro,
    source_donnee.unitescom as unitesencommande
FROM dblink('my_conn', 
    'SELECT dc.nocom, dc.refprod, dc.qte,
            c.datecom, c.dateenv, c.dateobjliv, c.notran,
            c.villeliv, c.regionliv, c.paysliv, c.codepostalliv,
            p.unitesstock, p.unitescom, p.niveaureap
     FROM entreprise._detailcommande dc
     JOIN entreprise._commande c ON dc.nocom=c.nocom
     JOIN entreprise._produit p ON dc.refprod=p.refprod
     WHERE c.dateenv IS NOT NULL'
) AS source_donnee(
    nocom INTEGER, refprod INTEGER, qte INTEGER,
    datecom DATE, dateenv DATE, dateobjliv DATE, notran INTEGER,
    villeliv VARCHAR, regionliv VARCHAR, paysliv VARCHAR, codepostalliv VARCHAR,
    unitesstock INTEGER, unitescom INTEGER, niveaureap INTEGER
)
JOIN entreprise._DimTemps dt ON source_donnee.dateenv=dt.datecomplete
JOIN entreprise._DimProduit dp ON source_donnee.refprod=dp.refprod
JOIN entreprise._DimGeographie dg ON 
    source_donnee.villeliv=dg.villeliv 
    AND source_donnee.regionliv=dg.regionliv 
    AND source_donnee.paysliv=dg.paysliv
LEFT JOIN entreprise._DimTransporteur dtran ON source_donnee.notran=dtran.notran;