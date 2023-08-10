# Utilisation du module

L'appel au module se fait de la manière suivante.

```tf
module "tags" {
  source = "github.com/m-chevalier/terraform-module-tagging"

  is_production = true
  project_id    = "my-project-id"
}
```

## Mettre les tags communs sur toutes les ressources

```tf
provider "aws" {
  region  = "eu-west-1"
  default_tags {
   tags = module.tags.common_tags
 }
}
```

## Mettre les tags uniquement sur une ressource

```tf
resource "aws_s3_bucket" "example" {
  bucket = "test-bucket-tags"
  tags = module.tags.common_tags
}
```

## Ajouter des tags supplémentaires au module

```tf
module "tags" {
  source = "github.com/m-chevalier/terraform-module-tagging"

  is_production = true
  project_id    = "my-project-id"
  additional_tags = {
    Nom         = "valeur"
  }
}
```
