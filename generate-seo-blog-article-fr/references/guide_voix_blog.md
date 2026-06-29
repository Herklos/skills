Référence réutilisable pour rédiger des articles de blog en français dans une voix fondateur-ingénieur. Adaptez le nom du produit, l'auteur, les liens et les avertissements juridiques à votre contexte avant utilisation.

**Compagnon anglais :** `generate-seo-blog-article/references/blog_voice_guide.md`

---

## 1. Objectif

Utiliser ce document quand :

- Vous rédigez un nouvel article de blog en français
- Vous briefez quelqu'un (ou une IA) pour écrire dans votre voix
- Vous relisez un brouillon avant publication

**Workflow :** Choisir un type d'article (section 5) → suivre son template → appliquer les principes de voix (section 3) → vérifier la blacklist IA (section 3, Éviter l'écriture type IA) → formater en Markdown simple (section 6) → vérifier la liste Faire / Ne pas faire (section 9).

Pour un teaser de direction produit majeure, utiliser le template **Vision / philosophie**. Philosophie et curiosité d'abord ; détails produit ensuite ; CTA clair à la fin (liste d'attente, inscription, invitation au feedback).

**Règle de langue :** les nouveaux articles doivent être **entièrement rédigés en français**. Pas de corps dans une autre langue avec seulement des titres traduits ou un bandeau « traduction en cours ».

---

## 2. Qui parle

**Voix principale :** le fondateur ou la fondatrice, profil ingénieur, qui explique les choix produit en tant que personne qui construit et teste, pas en tant que marketeur ou conseiller réglementé.

- **« Nous »** = l'équipe (décisions, expériences, direction produit)
- **« Vous »** = le lecteur (praticien, utilisateur, membre de la communauté)
- **« Je »** : rare ; préférer « nous » pour la voix d'équipe

Si plusieurs auteurs contribuent au blog, chacun peut avoir une nuance (plus orienté CTA produit, plus orienté vision). Quand vous écrivez dans la voix fondateur, gardez des CTAs plus doux et menez avec le *pourquoi* avant le *essayez*.

---

## 3. Principes de voix

1. **Fondateur-ingénieur, pas copy d'agence.** Expliquez ce que vous avez construit, testé et appris. Ancrez les affirmations dans du travail réel : « Après avoir lancé des tonnes de tests… », « nous avons réalisé que pour la plupart des utilisateurs, ce seuil se situe généralement autour de 80 %. »

2. **Mission avant pitch.** Ouvrez sur le problème ou l'insight, pas sur le produit. Votre produit apparaît naturellement comme réponse, une fois que le lecteur comprend pourquoi c'est important.

3. **Honnête sur les limites.** Les articles pratiques, comparatifs et techniques incluent toujours inconvénients, risques ou « quand ne pas utiliser ». Ne jamais laisser entendre des résultats garantis.

4. **Simple et direct.** Phrases courtes à moyennes. Listes numérotées pour étapes, fonctionnalités, pour/contre. Gras pour les décisions clés. Citations en blockquote pour les punchlines après un paragraphe de contexte.

5. **Enthousiasme conversationnel, avec parcimonie.** « Nous sommes très heureux d'annoncer… », « Nous avons même obtenu de bons résultats ! » : pour les lancements et jalons, pas chaque paragraphe.

6. **Montrez votre raisonnement.** Pour un plan payant, un choix de design ou une option de configuration, expliquez *pourquoi* : coûts d'exploitation, retours utilisateurs, résultats de tests.

7. **Éduquer d'abord sur les posts SEO.** Définir le terme, expliquer le contexte, donner pour/contre, puis mentionner comment votre produit aide, souvent dans une courte section de fin, pas dans chaque paragraphe.

8. **Préserver le rythme authentique.** De légères imperfections sont OK (« personalisé », « ca », « Qu'est ce »). Ne pas sur-polir en prose marketing française générique. Ne pas calquer mot à mot un texte anglais sans adapter le rythme français.

9. **Transparence comme valeur, pas slogan.** Citer open source, tests, modes bac à sable ou d'essai, et résultats visibles quand c'est pertinent, avec des détails, pas des affirmations vagues.

10. **Avertissements sur le contenu sensible.** Tout article sur performance, réglages, sujets réglementés ou promesses de résultat doit finir par le bloc Avertissement standard (section 7).

### Termes bilingues (quand garder l'anglais)

Adaptez cette table à votre domaine. En général, gardez en anglais les termes techniques établis que votre audience connaît ; traduisez le reste.

| Garder en anglais | Traduire en français |
|-------------------|----------------------|
| Noms de produit, marques, APIs, intégrations tierces | concepts métier, workflows, plateforme, méthodes |
| Acronymes sectoriels avec expansion FR entre parenthèses | définitions et explications en français |
| Termes techniques sans équivalent naturel (ex. *backtesting*, *sandbox*) | tout ce que le lecteur francophone attend en français |

### Éviter l'écriture type IA

Les articles ne doivent pas sonner comme une sortie IA générique. Cela s'applique aux brouillons humains et IA. Voir aussi le principe 8 (ne pas sur-polir) et la section 9 Ne pas faire.

**Parité avec l'anglais :** cette section est le miroir français de la blacklist IA du guide anglais.

**Ne jamais utiliser le tiret cadratin (Unicode U+2014).** Utiliser une virgule, un point, deux-points ou des parenthèses à la place.

- Mauvais : « Le logiciel open source est puissant [tiret cadratin] mais demande une configuration technique. »
- Bon : « Le logiciel open source est puissant, mais demande une configuration technique. »

#### Tier A : interdiction stricte (tolérance zéro)

| Catégorie | Interdit (FR) |
|-----------|---------------|
| Ponctuation | tiret cadratin (U+2014) |
| Verbes | exploiter (sens *leverage*), plonger dans, embarquer dans, tirer parti de (*harness*), favoriser (*foster*), utiliser (*utilize* calque), mettre en lumière / souligner (*underscore*), mettre en valeur (*showcase*), naviguer dans (*navigate* métaphorique) |
| Transitions | de plus, par ailleurs, en outre, de surcroît, en conclusion, pour conclure, en essence, au final, en fin de compte, au bout du compte |
| Ouvertures | dans un monde en constante évolution, à l'ère du numérique, dans le monde d'aujourd'hui, dans l'univers de / le domaine de (*in the realm of*), en ce qui concerne / lorsqu'il s'agit de (*when it comes to*), plongeons dans, allons-y explorer |
| Remplissage d'importance | il est important de noter, il convient de noter, il vaut la peine de noter, il est à noter, joue un rôle crucial / vital, rôle crucial dans |

#### Tier B : signal d'alerte (remplacer à la vue)

| Catégorie | Liste de vigilance (FR) |
|-----------|-------------------------|
| Adjectifs | robuste, fluide sans raison (*seamless* calque), holistique, exhaustif / complet (*comprehensive* vide), multiforme, nuancé (vide), central / pivot (*pivotal*), complexe élaboré (*intricate*), méticuleux, révolutionnaire (*groundbreaking*), en constante évolution, dynamique, vibrant |
| Noms / métaphores | paysage, univers / sphère (*realm*), tapisserie, témoignage (*testament*), phare (*beacon*), symphonie, écosystème (vague), paradigme, synergie |
| Verbes | débloquer (*unlock*), élever / rehausser (*elevate*), faciliter, booster / turbocharger |
| Expressions | plongée approfondie, change la donne, à la pointe, sauce secrète / ingrédient secret, fait la différence (*moves the needle*), au fond / à la base (*at its core*) |

#### Tier C : schémas structurels (réécrire la phrase)

- Accroche symétrique : « La plupart pensent X, mais la vérité est Y »
- Corrélatif : « pas seulement X, mais Y » / « non pas X, mais Y » / « il ne s'agit pas de X, il s'agit de Y »
- Listes en règle de trois parfaitement parallèles (même longueur, même structure grammaticale)
- Ouvertures de paragraphe : *Certes,* *Notamment,* *Il est intéressant de noter,* *Fait important,*
- Résidus de chat : « J'espère que cela vous aidera », « N'hésitez pas à me dire si »
- Empilement de hedges : *souvent*, *généralement*, *il convient de considérer* dans un même paragraphe

#### Quoi écrire à la place

| Défaut IA | Préférer |
|-----------|----------|
| exploiter (leverage) | utiliser |
| plonger dans | regarder, examiner |
| utiliser (calque *utilize*) | utiliser (contexte simple) ou reformuler |
| de plus / par ailleurs / en outre | et, aussi, ou nouvelle phrase |
| robuste | solide, fiable |
| fluide / sans couture (*seamless*) | simple, facile |
| en conclusion / pour conclure | (supprimer ; énoncer le point) |
| il est important de noter que X | X directement |

#### Scan avant publication

1. Chercher les tirets cadratins dans le brouillon (doit être zéro)
2. Chercher les mots Tier A (doit être zéro)
3. Parcourir Tier B ; remplacer tout ce qui n'est pas vraiment nécessaire
4. Lire à voix haute : si ça sonne Wikipédia ou post LinkedIn, raccourcir et préciser

### Curseurs de ton

| Dimension | Votre style | À éviter |
|-----------|-------------|----------|
| Formalité | Conversationnel, direct | Essai corporate « infrastructure » |
| Longueur des phrases | Courtes à moyennes, listes | Tirets cadratins ou phrases composées lourdes |
| Affirmations | « Nous avons réalisé », « nos tests montrent » | Langage système abstrait (« infrastructure d'exécution ») |
| Vente | Expliquer pourquoi, puis lien | Hard sell sans raisonnement |
| Risque | Pour/contre explicites, avertissements | Résultats implicites garantis |

### Ce qu'il ne faut PAS sonner comme

Évitez l'analyse système formelle à la troisième personne, la prose au tiret cadratin et le vocabulaire SEO « infrastructure » vague. Votre voix est personnelle, guidée par l'expérience, narrative d'équipe (« Chez [Entreprise], nous avons réalisé… »).

Ne publiez pas d'articles hybrides (corps dans une autre langue + titres français seulement).

---

## 4. Piliers de message

Les intégrer naturellement, jamais en liste à puces dans le corps de l'article. Personnalisez selon votre produit.

| Pilier | Comment il apparaît dans vos posts |
|--------|-------------------------------------|
| **Simplicité** | « Ça ne devrait pas être plus compliqué que ça. » Offres par usage vs complexité complète du produit. |
| **Transparence** | Code open source, résultats de tests, mode bac à sable ou d'essai, données de performance visibles. |
| **Accessibilité** | Offre gratuite, pas de frais cachés, programmes partenaires finançant l'accès gratuit. |
| **Communauté** | Canaux de feedback, forums, groupes de discussion, roadmap publique, priorités utilisateurs. |
| **Open source** | Dépôt public comme socle ; personnalisation ; auditabilité. |
| **Confidentialité / contrôle** | Données chez l'utilisateur, options local-first, traitement des données explicite. |

**Cadrage produit récurrent (à adapter) :**

- **Version cloud / hébergée** = simple, orientée usage courant
- **Version self-hosted / open source** = pleine puissance, personnalisation, profils techniques
- **Offres par palier** (gratuit, pro, entreprise) avec raisonnement transparent sur chaque niveau

---

## 5. Templates d'articles

### A. Annonce produit

**Quand :** Sorties de version, nouvelles fonctionnalités, refontes app, changements de plans.

**Structure :**

1. **H1** = titre (souvent « Présentation de X » ou « [Produit] X.Y.Z - Les nouveautés »)
2. **Image de couverture** (image Markdown standard)
3. **Accroche** : enthousiasme + liste numérotée des changements majeurs (2 à 4 items)
4. **Un H2 par fonctionnalité majeure** : ce que c'est, pourquoi c'est important, capture(s) d'écran
5. **« Autres améliorations »** : corrections, mises à jour d'intégrations, détails mineurs
6. **CTA optionnel** : lien vers inscription, essai ou documentation
7. **Clôture** : « Nous espérons que vous apprécierez… » / invitation au feedback

**Longueur :** 2 à 5 min de lecture

**Ouvertures types :**

- « Nous sommes très heureux d'annoncer la sortie de [Produit] 2.0 ! »
- « Lors de la création d'un [workflow], la partie la plus difficile est souvent de le valider avant le lancement… »

---

### B. Éducatif / SEO

**Quand :** Posts what-is, glossaire, how-it-works, guides de concepts.

**Structure :**

1. **H1** = titre (souvent « Comprendre X » ou « Qu'est-ce que X »)
2. **Définition en une ligne** dans le premier paragraphe (sans titre)
3. **Sections H2** : un concept par section :
   - Qu'est-ce que X
   - Pourquoi X compte
   - Pour / contre (ou psychologie, exemples, comment y faire face)
   - Comment [Produit] aide (courte section de fin)
4. **Optionnel :** table des matières (posts longs), image de couverture
5. **Conclusion** : bref résumé (optionnel sur glossaire court)

**Longueur :** 2 à 5 min de lecture

**Ouvertures types :**

- Définition directe : « Le [TERME], abréviation de "[expansion]" (traduction), est [définition simple]. »
- Accroche contexte : « Pour [tâche], il existe de nombreuses approches différentes… » (éviter « en ce qui concerne », Tier A)
- « Bienvenue dans votre guide sur… » (guides longs seulement)

**Mention produit :** En général une section vers la fin, pas chaque paragraphe.

---

### C. Deep dive technique

**Quand :** Making-of, explications techniques, décomposition de méthodologie.

**Structure :**

1. **H1** = titre (souvent « Making of de X » ou « X : analyse approfondie »)
2. **Optionnel :** lien ou résumé vidéo en tête
3. **Histoire d'origine** : « Chez [Entreprise], nous cherchons toujours de meilleures façons de [résoudre le problème]… »
4. **H2 : Présentation de [sujet]** : concept, lien vers source d'autorité, blockquote insight
5. **H2 : Résumé vidéo** (si vidéo) : H3 pour/contre en listes numérotées
6. **H2 : Quand utiliser** : conditions, limites avec honnêteté
7. **H2 : Analyse technique** : sous-sections H3, captures avec légendes, chiffres précis des tests
8. **H2 : Autres ressources** : liens vers guides et articles liés
9. **H2 : Avertissement** : bloc standard (section 7)

**Longueur :** 8 à 12 min de lecture

**Habitudes clés :**

- Toujours associer avantages et inconvénients
- Citer résultats de tests avec précision (seuils, tailles d'échantillon, cas limites)
- Liens croisés vers articles et docs liés
- Images avec légendes en italique sous les captures

---

### D. Listicle

**Quand :** Comparatifs « meilleurs outils X ».

**Structure :**

1. **H1** = titre numéroté (« 10 meilleurs outils [catégorie], gratuits et payants »)
2. **Intro brève** : pourquoi choisir est difficile, ce que couvre l'article
3. **H2 : Qu'est-ce qu'un [sujet] ?** : 2 à 3 phrases
4. **H2 par entrée** : `## 1. [Votre produit]` toujours en premier, puis concurrents
5. Chaque entrée : paragraphe description + résumé de notation optionnel (facilité, prix, fonctionnalités)
6. Entrée de votre produit la plus longue, liens vers docs, open source et capacités clés

**Longueur :** 3 min de lecture

**Ton :** Neutre-comparatif pour les concurrents ; plus chaleureux et détaillé pour votre produit.

---

### E. Partenariat / événement

**Quand :** Intégrations, co-marketing, événements, annonces d'écosystème.

**Structure :**

1. **H1** = titre d'annonce
2. **Image de couverture**
3. **Ouverture** : « [Produit] est ravi d'annoncer… »
4. **H2 : Qu'est-ce que [partenaire]** : courte description avec lien externe
5. **H2 : Comment utiliser [X] avec [Produit]** : lien vers guide de configuration
6. **Optionnel :** section finale pour posts partenaires

**Longueur :** 1 à 2 min de lecture

---

### F. Vision / philosophie

**Quand :** Changements de direction majeurs, roadmap, lancement plateforme, refontes accessibilité, teasers philosophie produit.

**Structure :**

1. **H1** = titre vision
2. **Optionnel :** lien ou résumé vidéo pour lancements majeurs
3. **Problème observé** : « Chez [Entreprise], nous avons réalisé que… »
4. **Ce que nous avons décidé** : ligne pivot en gras : **Nous avons décidé de changer cela.**
5. **Principes numérotés ou paliers d'offres** : ce qui change et pourquoi
6. **Section transparence / honnêteté** : risques, limites, comment l'offre gratuite reste viable
7. **Continuité** : rassurer les utilisateurs existants
8. **Invitation au feedback** : site feedback, canaux communauté, programme beta
9. **CTA** : liste d'attente, lien démarrer, ou « rejoignez-nous »

**Longueur :** 4 à 6 min de lecture

**Pour un teaser produit spécifiquement :**

- Curiosité d'abord ; ne pas tout expliquer
- Arc narratif : où en est le domaine aujourd'hui → ce qui manque → nouvelle philosophie
- Nommer un petit ensemble de piliers (3 à 6) qui définissent la direction
- Fin avec CTA participation beta ou accès anticipé

---

## 6. Formatage Markdown

Sortie en **Markdown simple uniquement**. Pas de frontmatter, pas de composants framework, pas de balises personnalisées.

### Structure du document

```markdown
# Titre de l'article

![Texte alt de couverture](/images/blog/votre-slug/cover.png)

Paragraphe d'ouverture avec accroche ou définition.

## Première section majeure

Contenu avec **gras pour les décisions clés** et listes numérotées si utile.

> Blockquote pour un insight percutant après le contexte.

## Section suivante

![Texte alt capture](/images/blog/votre-slug/capture.png)
*Légende en italique sous la capture*

[Lien vers article lié](slug-article-lie)

[Lien vers documentation](/fr/guides/section/page)
```

### Images

- Utiliser le Markdown standard : `![texte alt](chemin)`
- Ajouter une légende en italique sur la ligne sous les captures
- Préférer des textes alt et noms de fichiers descriptifs

### Liens

- **Externe :** `[Texte du lien](https://exemple.com)`
- **Blog interne :** `[Titre de l'article](slug-article)`
- **Documentation :** `[Nom du guide](/fr/guides/section/page)` (adapter le préfixe de locale)

### Blockquotes

Pour insights, pivots ou phrases mémorables après un paragraphe de contexte :

```markdown
> Après avoir lancé des tonnes de tests, nous avons réalisé que cette approche fonctionne aussi très bien sur des cycles plus courts.
```

### CTAs

Liens Markdown simples ou courts paragraphes d'appel à l'action. Pas de composants bouton personnalisés.

```markdown
[Commencer l'essai gratuit](https://exemple.com/inscription)

Ou rejoindre la [liste d'attente beta](https://exemple.com/waitlist).
```

### Métadonnées (à garder hors du corps de l'article)

Suivre ces éléments en dehors du fichier Markdown (CMS, tableur ou brief) :

- Titre
- Meta description (1 à 2 phrases pour SEO et aperçus sociaux)
- Tags
- Chemin image de couverture
- Date de publication
- Auteur
- Niveau de difficulté (1 = débutant, 2 = intermédiaire, 3 = avancé)
- Temps de lecture estimé (minutes)

---

## 7. Banque de phrases

### Ouvertures

| Contexte | Exemple |
|----------|---------|
| Origine | « Chez [Entreprise], nous cherchons toujours de meilleures façons de [résoudre le problème]. Après avoir expérimenté de nombreuses approches, nous avons réalisé que parfois, rester simple fonctionne. » |
| Insight produit | « Chez [Entreprise], nous avons réalisé que le produit actuel convient aux utilisateurs techniques mais est trop complexe pour la majorité des gens. » |
| Mission | « Chez [Entreprise], notre mission est de simplifier [résultat visé]. » |
| Enthousiasme release | « Nous sommes très heureux d'annoncer la sortie de [Produit] 2.0 ! » |
| Partenariat | « [Produit] est ravi d'annoncer son partenariat avec [Partenaire]… » |
| Glossaire / SEO | « Le [TERME], abréviation de "[expansion]" (traduction), est [définition simple]. » |
| Intro guide | « Bienvenue dans votre guide sur [sujet]. Après avoir lu cet article, vous aurez une compréhension claire de… » |

### Transitions

- « Par conséquent, … »
- « Ce qui signifie que … » / « cela signifie : »
- « En suivant cette philosophie, … » / « Suivant cette philosophie, … »
- « Explorons maintenant … » (éviter « plongeons dans »)
- « Plus de détails sur … »
- « De la même façon que [article lié], … »
- « En fin de compte, … » (usage parcimonieux)
- « Bien sûr, … » (avant nuance ou mise en garde)

### Lignes pivot / décision

- **Nous avons décidé de changer cela.**
- « L'objectif avec [X] est de … »
- « Alors que [A] est conçu pour [X], [B] rend très facile de [Y] »

### Clôtures

- « Nous espérons que vous apprécierez la nouvelle [fonctionnalité] ! »
- « Nous espérons que vous apprécierez ces changements et avons hâte de recevoir vos retours. »
- « N'hésitez pas à utiliser, expérimenter et nous faire part de vos retours sur … »
- « Si vous avez des idées de fonctionnalités que vous aimeriez voir, contactez-nous. »
- « En fin de compte, [sujet] offre … Restez engagé avec la communauté, gardez votre logiciel à jour, et profitez de la suite. »

### Insights blockquote

- « Comment est-ce possible ? Avec notre offre gratuite, nous nous appuyons sur des programmes partenaires pour couvrir nos coûts d'exploitation. »
- « Ces offres cibleront désormais explicitement les utilisateurs qui veulent créer ou personnaliser des workflows. »
- « [Méthode] est une tentative de [objectif] via [mécanisme], mais sans prédire chaque variable. »

### Avertissement standard (articles performance / résultats)

Adapter le domaine et la formulation juridique à votre produit et juridiction.

```markdown
## Avertissement

Veuillez noter que le contenu de cet article est destiné à des fins d'information générale uniquement et ne constitue pas un conseil professionnel. Les informations contenues ici sont fournies à titre informatif. Rien dans ce document ne doit être interprété comme un conseil juridique, financier ou fiscal. Le contenu de cet article reflète les opinions de l'auteur et/ou de l'équipe [Entreprise]. Aucun des auteurs n'est conseiller agréé dans un domaine réglementé, sauf mention explicite. L'utilisation de tout produit ou méthode décrit ici peut comporter des risques. L'auteur et/ou [Entreprise] ne garantissent aucun résultat particulier. Les résultats passés ne préjugent pas des résultats futurs.
```

Utiliser `## Avertissement` sur les posts courts ; même texte.

**Quand l'inclure :** Deep dives, discussions de performance, articles avec objectifs de résultat ou résultats de tests précis. À omettre pour glossaire pur, partenariats et annonces produit simples.

---

## 8. Habitudes de liens

### Liens croisés blog interne

Lier par slug. Construire un réseau : deep dives se référencent entre eux ; posts plateforme référencent les intros d'offres.

### Liens documentation (haute valeur)

Lier vers guides de configuration, concepts clés, intégrations et pages de paramétrage là où le lecteur en aura besoin ensuite. Utiliser le préfixe de locale si applicable (ex. `/fr/guides/...`).

### Pages produit

Lier vers accueil, tarifs, pages fonctionnalités et inscription quand pertinent. Un CTA clair suffit.

### Autorités externes

Lier vers sources réputées pour définitions, standards et contexte tiers (publications sectorielles, documentation officielle, références reconnues).

### Communauté

Lier vers portails de feedback, forums, canaux de discussion et pages roadmap lors d'invitations à contribuer.

---

## 9. Faire / Ne pas faire

### Faire

- Commencer par insight, problème ou définition, pas « Dans un monde en constante évolution… »
- Utiliser des listes numérotées pour fonctionnalités, étapes, pour/contre
- Inclure inconvénients et « quand ne pas utiliser » sur le contenu pratique et comparatif
- Expliquer tarifs ou fonctionnalités payantes avec raisonnement (coûts d'exploitation, effort de développement)
- Lier vers guides et articles blog liés
- Utiliser de vrais chiffres de vos tests quand disponibles
- Garder les posts éducatifs utiles même si le lecteur n'utilise jamais votre produit
- Terminer les posts sensibles par l'avertissement standard
- Attribuer l'auteur à la personne qui a réellement écrit le texte
- Rédiger l'article **entièrement en français**

### Ne pas faire

- Ne jamais utiliser de tirets cadratins (Unicode U+2014)
- Ne jamais utiliser les mots/phrases Tier A (section 3, Éviter l'écriture type IA)
- Remplacer les mots Tier B sauf si aucune alternative plus simple n'existe
- Écrire comme un essai infrastructure formel (chaînes de tirets cadratins, vocabulaire « infrastructure d'exécution » vague, pas de narrative d'équipe)
- Publier un corps dans une autre langue avec seulement des titres français
- Laisser entendre des résultats garantis ou minimiser les risques
- Ouvrir avec hard sell ou dump de fonctionnalités sur les posts vision
- Sur-polir la grammaire en marketing français générique ; votre voix est directe, pas corporate
- Mettre « En conclusion » / « Pour conclure » sur chaque post ; seulement si l'article est assez long pour un résumé
- Mettre le produit dans chaque paragraphe du contenu éducatif
- Omettre pour/contre sur tout ce qui touche aux méthodes, outils ou promesses de résultat
- Utiliser un langage de conseiller réglementé (« nous vous recommandons de… ») sauf qualification explicite
- Calquer mot à mot le marketing anglais sans adapter le rythme français

---

## 10. Bloc prompt IA

Copier-coller pour demander à une IA de rédiger un article :

```
Rédige un article de blog en français, dans la voix de [Nom de l'auteur] ([Rôle] chez [Entreprise]).

Règles de voix :
- Fondateur-ingénieur qui explique aux praticiens, pas une agence marketing
- Utiliser « nous » pour les décisions d'équipe, « vous » pour le lecteur
- Ancrer les affirmations dans expériences et observations réelles (« nous avons réalisé », « nos tests montrent »)
- Toujours honnête sur les limites et les inconvénients
- Mission d'abord : simplicité, transparence, accessibilité, open source, communauté (si applicable)
- Conversationnel et direct ; phrases courtes à moyennes ; listes numérotées pour fonctionnalités/pour-contre
- Gras pour décisions clés ; blockquotes pour insights percutants
- Ne PAS sonner comme un essai infrastructure formel : pas de chaînes de tirets cadratins, pas de ton corporate « infrastructure d'exécution »
- Légères imperfections de français authentique OK ; ne pas sur-polir
- Règles anti-IA (obligatoires) :
  - NE JAMAIS utiliser de tirets cadratins (Unicode U+2014). Utiliser virgules, points ou deux-points.
  - NE JAMAIS utiliser : exploiter (leverage), plonger dans, embarquer dans, de plus, par ailleurs, en outre, en conclusion, pour conclure, dans un monde en constante évolution, à l'ère du numérique, plongeons dans, il est important de noter, joue un rôle crucial, dans l'univers de, en ce qui concerne
  - Éviter : robuste, holistique, paysage, tapisserie, univers, pivot, pas seulement X mais Y / non pas X mais Y
  - Varier la longueur des phrases. Préférer chiffres précis et observations aux formulations vagues d'importance.

Type d'article : [Annonce produit | Éducatif/SEO | Deep dive technique | Listicle | Partenariat | Vision/philosophie]

Sujet : [VOTRE SUJET]

Produit : [NOM DU PRODUIT]

Structure : Suivre le template pour ce type d'article depuis guide_voix_blog.md section 5.

Sortie : Markdown simple uniquement. Pas de frontmatter, pas de MDX, pas de composants personnalisés.

Inclure :
- Avertissement en fin si performance, résultats ou sujets réglementés
- Liens internes et externes utiles
- Emplacements image avec texte alt et modèle de légende si captures applicables
- Article entièrement en français
```

---

## Référence rapide : type d'article → template

| Type | Template | Temps de lecture typique |
|------|----------|--------------------------|
| Annonce produit | A | 2–5 min |
| Éducatif / SEO | B | 2–5 min |
| Deep dive technique | C | 8–12 min |
| Listicle | D | 3 min |
| Partenariat / événement | E | 1–2 min |
| Vision / philosophie | F | 4–6 min |
