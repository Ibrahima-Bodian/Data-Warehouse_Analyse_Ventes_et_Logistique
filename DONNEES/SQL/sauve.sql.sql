-- DIMENSIONS 
-- Dimension Temps (critique pour les agrégations)
CREATE TABLE entreprise._DimTemps (
    idtemps SERIAL PRIMARY KEY,
    datecomplete DATE NOT NULL,
    jour INTEGER,
    mois INTEGER,
    annee INTEGER,
    trimestre INTEGER,
    semestre INTEGER,
    nommois VARCHAR(20),
    nomtrimestre VARCHAR(20),
    estweekend BOOLEAN
);

-- Dimension Produit
CREATE TABLE entreprise._DimProduit (
    idproduit SERIAL PRIMARY KEY,
    refprod INTEGER,
    nomprod VARCHAR(255),
    codecateg INTEGER,
    nomcateg VARCHAR(255),
    nofour INTEGER,
    nomfourn VARCHAR(255),
    prixunit NUMERIC(10,2),
    qteparunit VARCHAR(50),
    niveaureap INTEGER
);

-- Dimension Client
CREATE TABLE entreprise._DimClient (
    idclient SERIAL PRIMARY KEY,
    codecli VARCHAR(255),
    societe VARCHAR(255),
    ville VARCHAR(100),
    region VARCHAR(100),
    pays VARCHAR(100),
    codepostal VARCHAR(100)
);


-- Dimension Employé
CREATE TABLE entreprise._DimEmploye (
    idemploye SERIAL PRIMARY KEY,
    noemp INTEGER,
    nomComplet VARCHAR(255),
    fonction VARCHAR(255),
    ville VARCHAR(100),
    region VARCHAR(100),
    pays VARCHAR(100)
);

-- Dimension Transporteur
CREATE TABLE entreprise._DimTransporteur (
    idtransporteur SERIAL PRIMARY KEY,
    notran INTEGER,
    nomtran VARCHAR(255),
    tel VARCHAR(20)
);

-- Dimension Géographie Livraison
CREATE TABLE entreprise._DimGeographie (
    idgeographie SERIAL PRIMARY KEY,
    villeliv VARCHAR(100),
    regionliv VARCHAR(100),
    paysliv VARCHAR(100),
    codepostalliv VARCHAR(100)
);

--FAITS
-- TABLE DE FAITS VENTES
CREATE TABLE entreprise._FaitVentes (
    idtemps INTEGER REFERENCES entreprise._DimTemps(idtemps),
    idproduit INTEGER REFERENCES entreprise._DimProduit(idproduit),
    idclient INTEGER REFERENCES entreprise._DimClient(idclient),
    idemploye INTEGER REFERENCES entreprise._DimEmploye(idemploye),
    idtransporteur INTEGER REFERENCES entreprise._DimTransporteur(idtransporteur),
    
    -- Mesures
    qtevendue INTEGER,
    prixunitvente NUMERIC(10,2),
    montantremise NUMERIC(10,2),
    chiffreaffairesnet NUMERIC(10,2),
    fraisport NUMERIC(10,2),
    margebrute NUMERIC(10,2),
    
    -- Clé primaire composite
    PRIMARY KEY (idtemps, idproduit, idclient, idemploye)
);

-- TABLE DE FAITS LIVRAISONS
CREATE TABLE entreprise._FaitLivraisons (
    idtemps INTEGER REFERENCES entreprise._DimTemps(idtemps),
    idproduit INTEGER REFERENCES entreprise._DimProduit(idproduit),
    idgeographie INTEGER REFERENCES entreprise._DimGeographie(idgeographie),
    idtransporteur INTEGER REFERENCES entreprise._DimTransporteur(idtransporteur),
    
    -- Mesures
    qtelivree INTEGER,
    delailivraisonjours INTEGER,
    ecartdatejours INTEGER,  -- écart entre date objectif et date envoi
    niveaustock INTEGER,
    besoinreappro BOOLEAN,    -- stock < niveau réappro
    unitesencommande INTEGER,
    
    PRIMARY KEY (idtemps, idproduit, idgeographie)
);