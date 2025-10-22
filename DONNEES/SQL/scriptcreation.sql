-- Table Catégories
CREATE TABLE entreprise._categorie (
    codecateg SERIAL PRIMARY KEY,
    nomcateg VARCHAR(255) NOT NULL,
    description TEXT
);

-- Table Fournisseurs
CREATE TABLE entreprise._fournisseur (
    nofour SERIAL PRIMARY KEY,
    societe varchar(255) DEFAULT NULL,
    contact varchar(255) DEFAULT NULL,
    fonction varchar(255) DEFAULT NULL,
    adresse varchar(255) DEFAULT NULL,
    ville varchar(255) DEFAULT NULL,
    region varchar(255) DEFAULT NULL,
    codepostal varchar(255) DEFAULT NULL,
    pays varchar(255) DEFAULT NULL,
    tel varchar(255) DEFAULT NULL,
    fax varchar(255) DEFAULT NULL,
    pageaccueil varchar(255) DEFAULT NULL
);

-- Table Clients
CREATE TABLE entreprise._client (
    codecli varchar(255) DEFAULT NULL,
    societe varchar(255) DEFAULT NULL,
    contact varchar(255) DEFAULT NULL,
    fonction varchar(255) DEFAULT NULL,
    adresse varchar(255) DEFAULT NULL,
    ville varchar(255) DEFAULT NULL,
    region varchar(255) DEFAULT NULL,
    codepostal varchar(255) DEFAULT NULL,
    pays varchar(255) DEFAULT NULL,
    tel varchar(255) DEFAULT NULL,
    fax varchar(255) DEFAULT NULL,
	PRIMARY KEY(codecli)
);

-- Table Employés
CREATE TABLE entreprise._employe (
    noemp SERIAL PRIMARY KEY,
    nom varchar(255) DEFAULT NULL,
    prenom varchar(255) DEFAULT NULL,
    fonction varchar(255) DEFAULT NULL,
    titrecourtoisie varchar(255) DEFAULT NULL,
    datenaissance DATE DEFAULT NULL,
    dateembauche DATE DEFAULT NULL,
    adresse varchar(255) DEFAULT NULL,
    ville varchar(255) DEFAULT NULL,
    region varchar(255) DEFAULT NULL,
    codepostal varchar(255) DEFAULT NULL,
    pays varchar(255) DEFAULT NULL,
    teldom varchar(255) DEFAULT NULL,
    extension smallint,
    rendcomptea varchar(255) DEFAULT NULL
);

-- Table Transporteurs
CREATE TABLE entreprise._transporteur (
    notran SERIAL PRIMARY KEY,
    nomtran varchar(255) DEFAULT NULL,
    tel varchar(255) DEFAULT NULL
);

-- Table Produits
CREATE TABLE entreprise._produit (
    refprod SERIAL PRIMARY KEY,
    nomprod varchar(255) DEFAULT NULL,
    nofour INTEGER NOT NULL REFERENCES entreprise._fournisseur(nofour),
    codecateg INTEGER NOT NULL REFERENCES entreprise._categorie(codecateg),
    qteparunit varchar(255) DEFAULT NULL,
    prixunit NUMERIC(6,2) DEFAULT NULL,
    unitesstock smallint,
    unitescom smallint,
    niveaureap smallint,
	indisponible smallint
);

-- Table Commandes
CREATE TABLE entreprise._commande (
    nocom SERIAL PRIMARY KEY,
    codecli VARCHAR(255) NOT NULL REFERENCES entreprise._client(codecli),
    noemp INTEGER NOT NULL REFERENCES entreprise._employe(noemp),
    datecom DATE NOT NULL,
    dateobjliv DATE DEFAULT NULL,
    dateenv DATE DEFAULT NULL,
    notran INTEGER REFERENCES entreprise._transporteur(notran),
    port smallint,
    destinataire varchar(255) DEFAULT NULL,
    adrliv varchar(255) DEFAULT NULL,
    villeliv varchar(255) DEFAULT NULL,
    regionliv varchar(255) DEFAULT NULL,
    codepostalliv varchar(255) DEFAULT NULL,
    paysliv varchar(255) DEFAULT NULL
);

-- Table DetailCommande(Table de liaison)
CREATE TABLE entreprise._detailcommande (
    nocom INTEGER NOT NULL REFERENCES entreprise._commande(nocom),
    refprod INTEGER NOT NULL REFERENCES entreprise._produit(refprod),
    prixunit NUMERIC(10,2) NOT NULL,
    qte INTEGER NOT NULL CHECK (qte > 0),
    remise NUMERIC(3,2) DEFAULT 0 CHECK (remise >= 0 AND remise <= 1),
    PRIMARY KEY (nocom, refprod)  -- Clé primaire sur nocom + refprod
);


-- Insertion des données
INSERT INTO entreprise._categorie (codecateg, nomcateg, description) VALUES
(1, 'Boissons', 'Boissons, cafés, thés, bières'),
(2, 'Condiments Sauces', 'Assaisonnements et épices'),
(3, 'Desserts', 'Desserts et friandises'),
(4, 'Produits laitiers', 'Fromages'),
(5, 'Pâtes et céréales', 'Pains, biscuits, pâtes & céréales'),
(6, 'Viandes', 'Viandes préparées'),
(7, 'Produits secs', 'Fruits secs, raisins secs, autres'),
(8, 'Poissons et fruits de mer', 'Poissons, fruits de mer, escargots');

INSERT INTO entreprise._transporteur (notran, nomtran, tel) VALUES
(1, 'Speedy Express', '(503) 555-9831'),
(2, 'Forfait United', '(503) 555-3199'),
(3, 'Expédition fédérale', '(503) 555-9931');

INSERT INTO entreprise._employe (noemp, nom, prenom, fonction, titrecourtoisie, datenaissance, dateembauche, adresse, ville, region, codepostal, pays, teldom, extension, rendcomptea) VALUES
(1,'Davolio','Nancy','Représentant(e)','Mlle', '1960-12-08', '2012-05-01','507 - 20th Ave. E. Apt. 2A','Seattle','WA','98122','Etats-Unis','(206) 555-9857',5467,'2'),
(2,'Fuller','Andrew','Vice-Président','Dr.', '1972-12-19', '2012-08-14','908 W. Capital Way','Tacoma','WA','98401','Etats-Unis','(206) 555-9482',3457,''),
(3,'Leverling','Janet','Représentant(e)','Mlle', '1983-08-30', '2012-04-01','722 Moss Bay Blvd.','Kirkland','WA','98033','Etats-Unis','(206) 555-3412',3355,'2'),
(4,'Peacock','Margaret','Représentant(e)','Mme', '1957-09-19', '2013-05-03','4110 Old Redmond Rd.','Redmond','WA','98052','Etats-Unis','(206) 555-8122',5176,'2'),
(5,'Buchanan','Steven','Chef des ventes','M.', '1975-03-04', '2013-10-17','14 Garrett Hill','Londres','unknown','SW1 8JR','Royaume-Uni','(71) 555-4848',345,'2'),
(6,'Suyama','Michael','Représentant(e)','M.', '1983-07-02', '2013-10-17','Coventry House Miner Rd.','Londres','unknown','EC2 7JR','Royaume-Uni','(71) 555-7773',428,'7'),
(7,'Emery','Patrick','Chef des ventes','M.', '29-05-1980', '02-01-2014','Edgeham Hollow Winchester Way','Londres','unknown','RG1 9SP','Royaume-Uni','(71) 555-5598',465,'5'),
(8,'Callahan','Laura','Assistante commerciale','Mlle', '09-01-1978', '05-03-2014','4726 - 11th Ave. NE','Seattle','WA','98105','Etats-Unis','(206) 555-1189',2344,'2'),
(9,'Dodsworth','Anne','Représentant(e)','Mlle', '27-01-1986', '15-11-2014','7 Houndstooth Rd.','London','unknown','WG2 7LT','Royaume-Uni','(71) 555-4444',452,'5'),
(10,'Suyama','Jordan','Représentant(e)','M.', '02-07-1983', '21-10-2013','Coventry House Miner Rd.','Londres','unknown','EC2 7JR','Royaume-Uni','(71) 555-7773',428,'7');