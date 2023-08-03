# Utilisation du module

L'appel au module se fait de la manière suivante.

```tf
module "tags" {
  source = "./tag_module"

  is_production = true
  project_id    = "my-project"
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

## Ajouter des tags spécifiques sur une ressource

```tf
resource "aws_s3_bucket" "example" {
  bucket = "test-bucket-tags"
  
  tags = {
    Test = "valeur"
  }
}
```

Cette ressource aura pour tags à la fois les tags communs ainsi que le tag `Test : valeur`

## Mettre les tags du module sur une ressource

Dans le cas où `default_tags` n'a pas été spécifié, il est possible d'ajouter les `common_tags` à une ressource :

```tf
resource "aws_s3_bucket" "example" {
  bucket = "test-bucket-tags"
  
  tags = module.tags.common_tags
}
```

Il est aussi possible d'ajouter des tags spécifiques à cette ressource :

```tf
resource "aws_s3_bucket" "example" {
  bucket = "test-bucket-tags"
  
  tags = merge(module.tags.common_tags,{
    Test = "Valeur"
  })
}
```

Cette ressource aura ainsi les tags communs ainsi que le tag spécifique `Test : Valeur`
