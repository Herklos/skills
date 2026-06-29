---
name: generate-seo-blog-article-fr
description: Rédiger des articles de blog SEO en français dans une voix fondateur-ingénieur, en Markdown simple. Inclut templates d'articles, principes de voix, blacklist IA française, banque de phrases et contrôles pré-publication. À utiliser pour rédiger des posts blog, briefer une IA sur la voix de marque, créer du contenu éducatif ou produit, ou quand l'utilisateur mentionne articles blog SEO en français, voix éditoriale ou rédaction blog.
version: 1.0.0
license: MIT
metadata:
  version: 1.0.0
  category: marketing
  domain: content-marketing
  language: fr
  updated: 2026-06-29
  references: guide_voix_blog.md
  companion: generate-seo-blog-article
---

# Generate SEO Blog Article (FR)

Rédiger des articles de blog produit en français dans une voix fondateur-ingénieur. Sortie en **Markdown simple uniquement** : pas de frontmatter, pas de MDX, pas de composants framework.

**Compagnon anglais :** `generate-seo-blog-article`

## Mots-clés

rédaction blog, contenu SEO, voix de marque, voix fondateur, templates d'articles, rédaction de contenu, posts éducatifs, annonces produit, listicles, deep dives techniques, blacklist IA française, articles blog markdown, blog français

## Démarrage rapide

1. Lire `references/guide_voix_blog.md` en entier avant de rédiger.
2. Confirmer avec l'utilisateur (ou le brief) : nom du produit, voix auteur, type d'article, sujet, lecteur cible, liens et CTAs requis.
3. Choisir le template d'article (section 5 du guide de voix).
4. Rédiger en Markdown simple en appliquant les principes de voix (section 3) et le template choisi.
5. Exécuter le scan pré-publication (tirets cadratins, blacklist Tier A/B, lecture à voix haute).
6. Ajouter l'avertissement (section 7) si le sujet couvre performance, résultats ou conseils réglementés.

## Workflow principal

### 1. Collecter les entrées

Avant d'écrire, rassembler :

| Entrée | Exemple |
|--------|---------|
| Nom du produit | Plateforme Acme |
| Auteur / voix | Marie Dupont, co-fondatrice |
| Type d'article | Éducatif / SEO |
| Sujet | Qu'est-ce que le versioning de workflow |
| Mot-clé principal | versioning workflow |
| Mots-clés secondaires | contrôle de version, rollback |
| Lecteur cible | Praticiens débutants sur le concept |
| CTA | Essai gratuit, lien docs, liste d'attente |
| Liens à inclure | Posts liés, guide de configuration, communauté |

Si une entrée manque, utiliser des placeholders raisonnables et les signaler dans une courte note en fin de brouillon.

### 2. Choisir le type d'article

| Type | Utiliser quand |
|------|----------------|
| Annonce produit | Sorties, fonctionnalités, changements de plans |
| Éducatif / SEO | Glossaire, what-is, how-it-works |
| Deep dive technique | Making-of, méthodologie, résultats de tests |
| Listicle | Comparatifs best-of |
| Partenariat / événement | Intégrations, co-marketing, événements |
| Vision / philosophie | Roadmap, direction, teasers |

Voir la section 5 de `references/guide_voix_blog.md` pour la structure par type.

### 3. Appliquer les règles de voix

Habitudes obligatoires du guide :

- Ton fondateur-ingénieur : ce que vous avez construit, testé, appris
- Mission avant pitch : problème d'abord, produit ensuite
- Limites honnêtes : pour/contre, « quand ne pas utiliser »
- Affirmations ancrées : « nous avons réalisé », « nos tests montrent », chiffres précis
- Aucun tiret cadratin (Unicode U+2014)
- Zéro mot Tier A de la blacklist (section 3 du guide)
- Remplacer les mots Tier B sauf si vraiment nécessaires
- Mentions produit concentrées sur les posts éducatifs (en général une section de fin)
- **Article entièrement en français** (pas de stub hybride)

### 4. Formater la sortie

Livrer **uniquement** le corps de l'article en Markdown :

- `#` pour le titre (H1)
- `##` / `###` pour les sections
- Images standard `![alt](chemin)` avec légendes en italique sous les captures
- Liens simples `[texte](url)`
- `**gras**` pour les décisions clés
- `>` blockquotes pour les insights percutants
- Pas de frontmatter YAML
- Pas d'imports MDX ni de composants personnalisés

Suivre les métadonnées (titre, description, tags, date, temps de lecture) en dehors du corps, dans un second bloc « Métadonnées » après l'article, seulement si l'utilisateur le demande.

### 5. Checklist pré-publication

Avant de retourner le brouillon :

1. [ ] Zéro tiret cadratin (U+2014)
2. [ ] Zéro mot/phrase Tier A interdits
3. [ ] Mots Tier B passés en revue et remplacés si possible
4. [ ] Pas d'accroche symétrique « La plupart pensent X, mais Y »
5. [ ] Posts éducatifs : mention produit pas répétée à chaque paragraphe
6. [ ] Deep dives / posts résultats : avertissement inclus
7. [ ] Liens : posts internes, docs, autorités externes si utiles
8. [ ] Lecture à voix haute : sonne humain, pas Wikipédia ni LinkedIn
9. [ ] Texte entièrement en français, rythme adapté (pas calque anglais)

## Valeurs par défaut par type

| Type | Longueur typique | Difficulté | Avertissement |
|------|------------------|------------|---------------|
| Annonce produit | 2–5 min | Débutant | En général non |
| Éducatif / SEO | 2–5 min | Débutant | Sauf si résultats discutés |
| Deep dive technique | 8–12 min | Avancé | Obligatoire |
| Listicle | ~3 min | Débutant | Non |
| Partenariat / événement | 1–2 min | Débutant | Non |
| Vision / philosophie | 4–6 min | Débutant–intermédiaire | Sauf promesses de résultat |

## Fichiers de référence

| Fichier | Rôle |
|---------|------|
| `references/guide_voix_blog.md` | Guide complet : principes, blacklist FR, templates, banque de phrases, avertissements, bloc prompt IA |
| `../generate-seo-blog-article/references/blog_voice_guide.md` | Compagnon anglais (même logique, blacklist EN ; chemin relatif depuis ce skill) |

## Bloc prompt IA par défaut

Quand l'utilisateur demande un brouillon, utiliser le bloc prompt de la section 10 de `references/guide_voix_blog.md`. Remplacer produit, auteur, sujet et type d'article selon le brief.

## Exemple de format de sortie

```markdown
# Qu'est-ce que le versioning de workflow ?

![Schéma montrant l'historique des versions](/images/blog/versioning-workflow/cover.png)

Le versioning de workflow consiste à suivre les modifications d'un workflow dans le temps pour que les équipes puissent comparer, revenir en arrière et auditer ce qui a changé.

## Qu'est-ce que le versioning de workflow ?

...

## Comment Plateforme Acme aide

Plateforme Acme enregistre chaque révision automatiquement. [Commencer un essai gratuit](https://exemple.com/inscription).
```

Retourner l'article seul, sauf si l'utilisateur demande aussi métadonnées, notes SEO ou paire titre/description séparée.
