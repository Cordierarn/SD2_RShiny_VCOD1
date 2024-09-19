library(httr)
library(jsonlite)

base_url <- "https://data.ademe.fr/data-fair/api/v1/datasets/dpe-v2-logements-existants/lines"
# Paramètres de la requête
params <- list(
  page = 1,
  size = 5,
  select = "N°DPE,Code_postal_(BAN),Etiquette_DPE,Date_réception_DPE",
  q = "69008",
  q_fields = "Code_postal_(BAN)",
  qs = "Date_réception_DPE:[2023-06-29 TO 2023-08-30]"
) 

# Encodage des paramètres
url_encoded <- modify_url(base_url, query = params)
print(url_encoded)

# Effectuer la requête
response <- GET(url_encoded)

# Afficher le statut de la réponse
print(status_code(response))

# On convertit le contenu brut (octets) en une chaîne de caractères (texte). Cela permet de transformer les données reçues de l'API, qui sont généralement au format JSON, en une chaîne lisible par R
content = fromJSON(rawToChar(response$content), flatten = FALSE)

# Afficher le nombre total de ligne dans la base de données
print(content$total)

# Afficher les données récupérées
df <- content$result
dim(df)
View(df)









# Charger les données des codes postaux depuis le fichier CSV
adresses_69 <- read.csv("C:\\Users\\arcordier\\Downloads\\adresses-69.csv", sep = ";", dec = ".")

# Extraire uniquement les codes postaux uniques
codes_postaux <- unique(adresses_69$code_postal)

# Afficher les premiers codes postaux pour vérification
print(head(codes_postaux))


# Initialiser un dataframe vide pour stocker toutes les données
df_final <- data.frame()

# Boucle sur chaque code postal
for (code_postal in codes_postaux) {
  # Paramètres de la requête mis à jour pour chaque code postal
  params <- list(
    page = 1,
    size = 10000,  # Utilisez la taille maximale autorisée
    select = "N°DPE,Code_postal_(BAN),Etiquette_DPE,Date_réception_DPE",
    q = as.character(code_postal),
    q_fields = "Code_postal_(BAN)",
    qs = "Date_réception_DPE:[2021-07-01 TO 2021-12-31]"
  )
  
  # Encodage des paramètres
  url_encoded <- modify_url(base_url, query = params)
  
  # Effectuer la requête
  response <- GET(url_encoded)
  
  # Vérifier le statut de la réponse
  if (status_code(response) == 200) {
    content <- fromJSON(rawToChar(response$content), flatten = TRUE)
    
    # Ajouter les données récupérées au dataframe final
    if (!is.null(content$result)) {
      df <- as.data.frame(content$result)
      df_2021_2 <- rbind(df_2021_2, df)
    }
  } else {
    print(paste("Erreur pour le code postal :", code_postal))
  }
}

# Afficher le nombre total de lignes récupérées
print(nrow(df_final))

# Exporter le dataframe final dans un fichier CSV
write.csv(df_final, "existants_69.csv", row.names = FALSE)

# Afficher un aperçu des données récupérées
View(df_final)
