# Utilisation du module

La manière la plus rapide d'utiliser le module est la suivante :

```tf
module "tags" {
  source = "REMPLACER PAR LE REPO GIT"
  is_production = true 
}
```

Les paramètres sont les suivants :
|Nom|Obligatoire|Valeur|Valeur par défaut|
|-|-|-|-|
|is_production|Oui|true/false|Pas de valeur par défaut|
|project_id|Non|Chaîne de caractères représentant l'identifiant du projet dans Workday|Tag par défaut associé au compte|
|owner|Non|Chaîne de caractères contenant l'email du responsable de la ressource|Email associé au projet dans Workday|
|additional_tags|Non|Dictionnaire de tags qui seront ajoutés au résultat du module|`{}`|

## Mettre les tags communs sur toutes les ressources

Pour mettre les tags directement sur toutes les ressources, on peut utiliser le bloc "default_tags" du provider AWS :

```tf
provider "aws" {
  region  = "eu-west-1"
  default_tags {
   tags = module.tags.common_tags
 }
}
```

## Mettre les tags uniquement sur une ressource

Si les tags ne sont pas mis sur toutes les ressources par défaut, il est possible de les ajouter directement sur une ressource :

```tf
resource "aws_s3_bucket" "example" {
  bucket = "test-bucket-tags"
  tags = module.tags.common_tags
}
```

## Ajouter des tags supplémentaires en plus de ceux du module

```tf
module "tags" {
  source = "github.com/m-chevalier/terraform-module-tagging"

  is_production = false
  additional_tags = {
    Nom         = "valeur"
  }
}
```
